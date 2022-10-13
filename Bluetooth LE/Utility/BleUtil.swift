//
//  LeUtil.swift
//  Bluetooth LE
//
//  Created by Shahab Darvish on 6/12/20.
//

import UIKit
import Foundation
import CoreBluetooth

@objcMembers class EOMState:NSObject {
    static var EOMFlagW = false
    static var EOMFlagG = false
}

@available(iOS 13.0, *)
@objcMembers
open class BleUtil: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, AlertDialogDelegate ,ObservableObject{
    
    func didCancelAlertDialog(tag: Int) {
        print("didCancelAlertDialog BTAlert")
    }
    struct BLEDevice: Identifiable,Codable {
        let id:String
        let name : String
        let rssi: Double
    }
    var scannedBLEDevices: [BLEDevice] = []
    var scannedBLENames: [BLEDevice] = []
    
    var alertDialog: AlertDialog = AlertDialog()
    
    //    @Published var isSwitchOn = false
    //    @Published var peripherals = [Peripheral]()
    //
    // MARK: - Shared Instance
    @objc static let shared: BleUtil = {
        let instance = BleUtil()
        // setup code
        return instance
    }()
    
    // MARK: - Initialization Method
    override init() {
        super.init()
        
        initData()
        
    }
    
    struct PeripheralsStructure {
        var peripheralInstance: CBPeripheral?
        var peripheralRSSI: NSNumber?
        var timeStamp: Date?
    }
    
    // MARK: Private Data
    fileprivate let serviceUUID = CBUUID(string: "49535343-FE7D-XXXX-XXXX-XXXXXXXXXXXX")
    fileprivate let characteristicUUID = CBUUID(string: "49535343-XXXX-XXXX-XXXX-XXXXXXXXXXXX")
    fileprivate let ledcharacteristicUUID = CBUUID(string: "CD830609-XXXX-XXXX-XXXX-XXXXXXXXXXXX")
    fileprivate let mchpLEDCharacteristicUUID = CBUUID(string: "bf3fbd80-XXXX-XXXX-XXXX-XXXXXXXXXXXX")
    fileprivate var characteristicInstance: CBCharacteristic?
    fileprivate var alertController: UIAlertController?
    fileprivate var localTimer: Timer = Timer()
    fileprivate var rssiTime: Date = Date()
    fileprivate var previousPeripheralRSSIValue: Int = 0
    fileprivate var indexPathForSelectedRow: IndexPath?
    fileprivate var remoteCommandEnabled: Bool = false
    fileprivate var upgradeEnabled: Bool = false
    //    fileprivate var appDelegate: AppDelegate = AppDelegate()
    fileprivate var appResults: NSArray = NSArray()
    public var peripheralInstance: CBPeripheral?
    fileprivate var cbCentralManager: CBCentralManager!
    fileprivate var discoveredSevice: CBService?
    fileprivate var ledCharacteristic: CBCharacteristic?
    //    fileprivate var cmdInfoList: [CmdInfo] = []
    fileprivate var cmdInfoListBytes: [UInt8] = []
    fileprivate var timeoutCounter = 0
    fileprivate var cmdCounter = 0
    
    fileprivate var timerCmdTimeout: Timer = Timer()
    fileprivate var btDataStreamAscii: String = ""
    fileprivate var btDataStreamAsciiChecksum: String = ""
    fileprivate var btDataStreamBytes: Array<UInt8> = [UInt8]()
    
    fileprivate var isParsingBtDataStream: Bool = false
    fileprivate var parseBtDataStreamTimer: Timer = Timer()
    
    fileprivate var cmdDict: NSMutableDictionary = NSMutableDictionary.init()
    
    var reconnectPeripheralInstance: CBPeripheral?
    
    fileprivate var devCommandNotificationName: NSNotification.Name = NSNotification.Name(rawValue: "tmpName")
    
    fileprivate var dataToSend: Data?
    fileprivate var sendDataIndex: Int?
    fileprivate var dataToSendCount: Int?
    
    let NOTIFY_MTU = 150 // was MTU = 128
    
    
    
    private var peripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?
    
    
    private var queueQueue = DispatchQueue(label: "queue queue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
    
    private var outputData = Data()
    
    
    // MARK:  Share Data
    var peripheralDict = [String: PeripheralsStructure]()
    var requestConnection: Bool = false
    
    // MARK:  Init Data
    func initData() {
        
        devCommandNotificationName = NSNotification.Name(rawValue: Constant.shared.devCommandNotification)
        
        peripheralDict.removeAll()
        cbCentralManager = CBCentralManager(delegate: self, queue: nil)
        localTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(interruptLocalTimer), userInfo: nil, repeats: true)
        
        let numberofSeconds =  0.25
        self.isParsingBtDataStream = false
        parseBtDataStreamTimer = Timer.scheduledTimer(timeInterval: numberofSeconds, target: self, selector: #selector(parseBtDataStream), userInfo: nil, repeats: true)
        
        cmdDict.removeAllObjects()
        
        
    }
    
    
    // MARK:  Write Command
    
    @objc public func write(cmd: String, timeoutInSeconds: Double, timeoutRetryMax: Int32, notificationName: String, callFrom: CallFrom) {
        
        let cmdInfo = CmdInfo.init(data: cmd, timeoutInSeconds: timeoutInSeconds, timeoutRetryMax: timeoutRetryMax, notificationName: notificationName, callFrom: callFrom)
        
        if Donglesw.shared.isConnected() {
            write(cmdInfo: cmdInfo!)
            
            NSLog("Shahab - write: \(String(describing: cmd))")
            
            
            if Constant.shared.debugOn {
                NSLog("connect peripheralInstance: \(String(describing: peripheralInstance?.name))")
                NSLog("connect characteristicInstance uuid: \(String(describing: characteristicInstance?.uuid))")
            }
        }else {
            NSLog("Shawn - write: Not connected)")
        }
        
    }
    
    @objc public func write(cmdInfo: CmdInfo) {
        
        var data: Data
        
        //Data to send with mtu
        if cmdInfo.dataOnly || cmdInfo.isNSData {
            
            data = cmdInfo.nsDataOut.suffix(from: 0)
            dataToSendCount = data.count
            EOMState.EOMFlagW = false
            EOMState.EOMFlagG = false
            // Get the data
            dataToSend = data
            
            // Reset the index
            sendDataIndex = 0;
            
            // Start sending
            sendData()
            
        }else {
            var bytesData = [UInt8] (cmdInfo.cmd.utf8)
            data = Data(bytes: &bytesData, count: bytesData.count)
        }
        //MARK:    Data to send no MTU
        if cmdInfo.dataOnly || cmdInfo.isNSData {
            data = cmdInfo.nsDataOut.suffix(from: 0)
        }else {
            var bytesData = [UInt8] (cmdInfo.cmd.utf8)
            data = Data(bytes: &bytesData, count: bytesData.count)
        }
        
        
        if Donglesw.shared.isConnected() || Donglesw.shared.btStatus == .BtTestConnection {
            
            if cmdInfo.dataOnly || cmdInfo.isNSData {
                
            }else{
                //MARK: Fix-Bug crash on livedata after 10 min or so
                if let peripheralIns = peripheralInstance, let CharIns = characteristicInstance {
                    peripheralIns.writeValue(data, for: CharIns as CBCharacteristic, type:CBCharacteristicWriteType.withResponse)
                } else {
                    NSLog("Shawn - peripheral is nil at  write")
                }
            }
            
            
            if Constant.shared.debugOn {
                if cmdInfo.dataOnly==false {
                    NSLog("Shawn - at cmdinfo write: \(String(describing: cmdInfo.cmd))")
                }
                
                //                NSLog("connect peripheralInstance: \(String(describing: peripheralInstance?.name))")
                //                  NSLog("connect characteristicInstance uuid: \(String(describing: characteristicInstance?.uuid))")
                
            }
        }else {
            NSLog("Shawn - write: Not connected)")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.shared.didConnectPeripheralNotification), object: nil)
        }
        
        self.cmdDict.setValue(cmdInfo, forKey: (cmdInfo.key)!)
        
    }
    
    // First up, check if we're meant to be sending an EOM
    fileprivate var sendingEOM = false;
    
    /** Sends the next amount of data to the connected central
     */
    fileprivate func sendData() {
        if sendingEOM {
            // send it
            let didSend = true
            
            // Did it send?
            if (didSend == true) {
                
                // It did, so mark it as sent
                sendingEOM = false
                
                print("Sent: EOM")
            }
            
            // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
            return
        }
        
        // We're not sending an EOM, so we're sending data
        
        // Is there any left to send?
        guard sendDataIndex ?? 0 < dataToSend!.count else {
            // No data left.  Do nothing
            return
        }
        
        // There's data left, so send until the callback fails, or we're done.
        var didSend = true
        
        while didSend {
            // Make the next chunk
            
            // Work out how big it should be
            var amountToSend = dataToSend!.count - sendDataIndex!;
            
            // Can't be longer than 20 bytes
            if (amountToSend > NOTIFY_MTU) {
                amountToSend = NOTIFY_MTU;
            }
            
            // Copy out the data we want
            let chunk = dataToSend!.withUnsafeBytes{(body: UnsafePointer<UInt8>) in
                return Data(
                    bytes: body + sendDataIndex!,
                    count: amountToSend
                )
            }
            
            // Send it
            didSend = true
            //peripheralManager!.updateValue(
            //                   chunk as Data,
            //                   for: characteristicUUID!,
            //                   onSubscribedCentrals: nil
            //               )
            if Donglesw.shared.isConnected() || Donglesw.shared.btStatus == .BtTestConnection {
                peripheralInstance!.writeValue(chunk, for: characteristicInstance! as CBCharacteristic, type:CBCharacteristicWriteType.withResponse)
            }
            // If it didn't work, drop out and wait for the callback
            if (!didSend) {
                return
            }
            
            let stringFromData = NSString(
                data: chunk as Data,
                encoding: String.Encoding.utf8.rawValue
            )
            let string1 = String(data: chunk, encoding: String.Encoding.utf8) ?? "Data could not be printed"
            //             print(string1)
            print("Chunk 5 * 27 Sent: \(String(describing: stringFromData))")
            
            // It did send, so update our index
            sendDataIndex! += amountToSend;
            
            // Was it the last one?
            if (sendDataIndex! >= dataToSend!.count) {
                
                // It was - send an EOM
                
                // Set this so if the send fails, we'll send it next time
                sendingEOM = true
                
                // Send it
                let eomSent = true
                //                    peripheralManager!.updateValue(
                //                       "EOM".data(using: String.Encoding.utf8)!,
                //                       for: characteristicUUID!,
                //                       onSubscribedCentrals: nil
                //                   )
                //                NotificationCenter.default.post(name: Notification.Name("UW_command"), object: nil)
                EOMState.EOMFlagW = true
                
                if (eomSent) {
                    // It sent, we're all done
                    sendingEOM = false
                    print("Sent: EOM")
                }
                
                return
            }
        }
    }
    
    
    func testTime() {
        let date1 = Date()
        let date2 = Date().addingTimeInterval(100)
        
        if date1 == date2 {
            print("date1 == date2")
        }
        else if date1 > date2 {
            print("date1 > date2")
        }
        else if date1 < date2 {
            print("date1 < date2")
        }
        
    }
    
    
    
    
    
    
    // MARK: - Public methods
    @objc public func startScan() {
        
        //If connected to classic Don't scan and try to connect to BLE
        if Donglesw.shared.getActiveDevice() == .Classic {
            return
        }
        
        print("Here at NO Ble connected")
        if peripheralInstance != nil {
            cbCentralManager.cancelPeripheralConnection(peripheralInstance!)
        }
        
        //Init Variables
        peripheralInstance = nil
        characteristicInstance = nil
        
        Donglesw.shared.btStatus = .BtDisconnected
        
        self.peripheralDict.removeAll()
        scanForPeripherals()
        
    }
    
    public func stopScan() {
        if self.cbCentralManager!.isScanning{
            self.cbCentralManager?.stopScan()
            NSLog("Here at stop main")
        }
    }
    
    
    public func connect(peripheral: CBPeripheral?) {
        NSLog("Here BleUtil connect: \(String(describing: peripheralInstance?.name))")
        if let perl = peripheral {
            cbCentralManager.connect(perl, options: nil)
        }
        //        cbCentralManager.connect(peripheral!, options: nil)
        
        
    }
    
    @objc public func cancelConnect() {
        
        
        cbCentralManager.cancelPeripheralConnection(peripheralInstance!)
        
    }
    
    public func cancelConnect(peripheral: CBPeripheral) {
        
        cbCentralManager.cancelPeripheralConnection(peripheral)
        
        //        startScan()
        
    }
    
    
    @objc public func disConnect() {
        cancelConnect()
    }
    
    func scanForPeripherals() {
        cbCentralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        //        cbCentralManager.scanForPeripherals(withServices: [serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        NSLog("Here at scan isscaning out")
        let triggerTime = (Int64(NSEC_PER_SEC) * 9000000)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
            NSLog("Here at scan isscaning")
            if self.cbCentralManager!.isScanning{
                self.cbCentralManager?.stopScan()
                NSLog("Here at scan main")
                //                self.updateViewForStopScanning()
            }
        })
    }
    
    
    @objc public func isScanning() -> Bool {
        if self.cbCentralManager.isScanning{
            return true;
        }else {
            return false;
        }
    }
    
    
    // MARK: - Test Bluetooth Connection
    func testConnection() {
        timeoutCounter = 0
        addObservers()
        print("testing connection ")
        sendCommand()
    }
    
    func connectionSuccess() {
        NSLog("BLE test connection Success")
        //        stopScan()
        reconnectPeripheralInstance = self.peripheralInstance    //Save for reconnection
        
        Donglesw.shared.btStatus = .BtConnected
        removeObservers()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.shared.didConnectCharacteristicNotification), object: nil)
    }
    
    func connectionFail() {
        NSLog("BLE test connection Failed")
        
        removeObservers()
        startScan()
    }
    
    func sendCommand() {
        BleUtil.shared.write(cmd: "UVIN00", timeoutInSeconds: 3, timeoutRetryMax: 2, notificationName: devCommandNotificationName.rawValue, callFrom: TestConnection)
        let seconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            //   delay here
            BleUtil.shared.write(cmd: "UDEV00", timeoutInSeconds: 3, timeoutRetryMax: 2, notificationName: self.devCommandNotificationName.rawValue, callFrom: TestConnection)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            //   delay here
            BleUtil.shared.write(cmd: "UECM00", timeoutInSeconds: 3, timeoutRetryMax: 2, notificationName: self.devCommandNotificationName.rawValue, callFrom: TestConnection)
        }
    }
    
    
    // MARK: - Add/Remove Observer
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(processCallbacks(notification:)), name: devCommandNotificationName, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: devCommandNotificationName, object: nil)
    }
    
    
    
    // MARK: Process Callbacks
    @objc func processCallbacks(notification: NSNotification) {
        guard let notificationObject = notification.object else {
            connectionFail()
            return //Command Timed out
        }
        
        let cmdInfo = notificationObject as! CmdInfo
        if handledTimeout(cmdInfo: cmdInfo) {
            timeoutCounter = timeoutCounter + 1
            if timeoutCounter < cmdInfo.timeoutRetryMax {
                sendCommand() //Resend command
            }else {
                connectionFail()
            }
        }else {
            connectionSuccess()
        }
    }
    
    
    func handledTimeout(cmdInfo: CmdInfo) -> Bool {
        
        if cmdInfo.cmdStatus == CMD_TIMED_OUT && cmdInfo.callFrom == TestConnection {
            return true;    //Command Timed out
        }else {
            return false;    //No Timed out
        }
    }
    
    
    
    
    // MARK: - CCBCentralManagerDelegate and CBPeripheralDelegate Delegates
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .unsupported:
            print("BLE is Unsupported")
            break
        case .unauthorized:
            print("BLE is Unauthorized")
            break
        case .unknown:
            print("BLE is Unknown")
            break
        case .resetting:
            print("BLE is Resetting")
            break
        case .poweredOff:
            print("BLE is Powered Off")
            stopScan()
            break
        case .poweredOn:
            print("BLE is poweredOn")
            if Donglesw.shared.isConnected(){
                print("BLE is poweredOn but connected")
            }else{
                startScan()    //scanForPeripherals()
            }
            break
            
        @unknown default:
            print("BLE is default")
            break
        }
    }
    var deviceID0 = 0
    var deviceID1 = 0
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        self.peripheralInstance = peripheral
        let peripheralConnectable: AnyObject = advertisementData["kCBAdvDataIsConnectable"]! as AnyObject
        
        
        if ((self.peripheralInstance == nil || self.peripheralInstance?.state == CBPeripheralState.disconnected) && (peripheralConnectable as! NSNumber == 1)) {
            var peripheralName: String = String()
            if (advertisementData.index(forKey: "kCBAdvDataLocalName") != nil) {
                peripheralName = advertisementData["kCBAdvDataLocalName"] as! String
            }
            if (peripheralName == "" || peripheralName.isEmpty) {
                
                if (peripheral.name == nil || peripheral.name!.isEmpty) {
                    peripheralName = "Unknown"
                } else {
                    peripheralName = peripheral.name!
                }
            }
            NSLog("Scanning for peripheral: RN4870,  found: \(peripheralName) rssi:\(String(RSSI.doubleValue))")
            
            // MARK : BLE pNames
            //"RN4870-15B2"
            if (peripheralName.range(of:"Tile") != nil) || (peripheralName.range(of:"RN") != nil){
                //            if (peripheralName != nil){
                //                self.cbCentralManager.stopScan()
                if(Constant.shared.debugOn3) {
                    NSLog("Scanning for peripheral: RN4870,  found: \(peripheralName) rssi:\(String(RSSI.doubleValue))")
                }
                peripheralDict.updateValue(PeripheralsStructure(peripheralInstance: peripheral, peripheralRSSI: RSSI, timeStamp: Date()), forKey: peripheralName)
                
                self.scannedBLEDevices.append(BLEDevice(id:String(deviceID1), name:peripheralName,  rssi: RSSI.doubleValue))
                deviceID1 = deviceID1 + 1
                
                self.scannedBLENames.append(BLEDevice(id:String(deviceID0), name:peripheralName, rssi: RSSI.doubleValue))
                deviceID0 = deviceID0 + 1
                
                // Post notification
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.shared.didDiscoverPeripheralNotification), object: nil)
                
                // Connect!
                if RSSI.doubleValue > -600.0  {
                    let encoder = JSONEncoder()
                    let device = Device(id: String(deviceID1), name: peripheralName, rssi: RSSI.doubleValue)
                    if let encoded = try? encoder.encode(device) {
                        let defaults = UserDefaults.standard
                        defaults.set(encoded, forKey: "SavedPerson")
                    }
                    if let safeName = peripheral.name {
                        self.scannedBLEDevices.append(BLEDevice(id:String(deviceID1), name:safeName,rssi:RSSI.doubleValue))
                    }
                    reconnectPeripheralInstance = peripheral    //Save for reconnection
                    
                    print ( "Here at connect \(Donglesw.shared.isConnected())")
                    print ( "Here at reconncet peri \(String(describing: reconnectPeripheralInstance))")
                    //                    stopScan()
                }
            }
            
            deviceID1 = deviceID1 + 1
        }
        
        if self.requestConnection == true {
            if Donglesw.shared.isDisconnected() && peripheralDict.count >= 1 {
                connect(peripheral: peripheral)
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        Donglesw.shared.btStatus = .BtConnected
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
        
        // Post notification
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.shared.didConnectPeripheralNotification), object: nil)
        
        NSLog("Here at didConnect peripheral: \(String(describing: peripheral.name))")
        
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        Donglesw.shared.btStatus = .BtDisconnected
        
        NSLog("didDisconnectPeripheral peripheral: \(String(describing: peripheral.name))")
        
        // Post notification
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.shared.didDisconnectPeripheralNotification), object: nil)
        
        self.peripheralDict.removeAll()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.shared.lostConnectionNotification), object: nil)
        //Try to reconnect after disconnect
        if Donglesw.shared.getActiveDevice() != .Classic {
            
            if !Donglesw.shared.isConnected() {
                
                //MARK: Fix Autoreconnect livedata
                connect(peripheral: reconnectPeripheralInstance)
                Donglesw.shared.btStatus = .BtConnected
                
            }
        }
        
        //Assign BtDisconnected after check if need to scan
        Donglesw.shared.btStatus = .BtDisconnected
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        Donglesw.shared.btStatus = .BtDisconnected
        
        // Post notification
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.shared.didFailToConnectNotification), object: nil)
        print("Here at Connection Error# \(String(describing: error?.localizedDescription))")
        
    }
    
    func centralManager(_ central: CBCentralManager!, didRetrievePeripherals peripherals: [AnyObject]!) {
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if (peripheral.services!.isEmpty) {
            
            cbCentralManager.cancelPeripheralConnection(peripheral)
            return
        }
        
        for service in peripheral.services! {
            NSLog("Service discovered: \(service.uuid)")
            if (service.uuid == serviceUUID) {
                peripheral.discoverCharacteristics([characteristicUUID], for: service )
            }
            
        }
        
        // Post notification
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.shared.didDiscoverServicesNotification), object: nil)
        
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        print("Error changing notification state: \(error?.localizedDescription)")
        
        // Exit if it's not the transfer characteristic
        guard characteristic.uuid.isEqual(characteristicUUID) else {
            return
        }
        
        // Notification has started
        if (characteristic.isNotifying) {
            print("Notification began on \(characteristic)")
            stopScan()
        } else { // Notification has stopped
            print("Notification stopped on (\(characteristic))  Disconnecting")
            cbCentralManager?.cancelPeripheralConnection(peripheral)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if (service.characteristics!.isEmpty) {
            
            cbCentralManager.cancelPeripheralConnection(peripheral)
            return
        }
        
        self.peripheralInstance = peripheral
        for characteristic in service.characteristics! {
            NSLog("Characteristics discovered: \(characteristic.uuid)")
            if (service.uuid == serviceUUID) {
                peripheral.setNotifyValue(true, for: characteristic)
                
                if (characteristic.uuid == characteristicUUID) {
                    peripheral.setNotifyValue(true, for: characteristic )
                    characteristicInstance = characteristic
                    //MARK:TODO LED bug
                    //                    peripheral.readValue(for: characteristic )
                    
                    NSLog("peripheral.setNotifyValue(true, for: characteristic)")
                    NSLog("connect Characteristics discovered: \(characteristic.uuid)")
                    
                    //MARK: Bug SHould be before write command to stop scan
                    stopScan()
                    
                    NSLog("Here at stop 1")
                    if Donglesw.shared.getActiveDevice() != .Classic {
                        Donglesw.shared.btStatus = .BtConnected
                        Donglesw.shared.setActiveDevice(activeDevice: .Ble)
                        //MARK:todo putback
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 ) {
                            self.testConnection()
                        }
                        
                    }
                    
                    
                    break
                }
                
            }
        }
        
        
        
    }
    
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if Constant.shared.debugOn {
            guard error == nil else {
                print("Error discovering services: \(error as Any)")
                return
            }
            NSLog("Shawn - at: Message sent")
            //            NSLog("didWriteValueFor characteristice uuid: \(String(describing: characteristicInstance?.uuid))")
        }
        
    }
    
    //
    
    // MARK: Handle Bluetooth Reponses here
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if let error1 = error{
            
            let subTitleString = "Found error while read characteristic data, Please try again"
            let alertController = UIAlertController(title: "Error" , message: subTitleString, preferredStyle: .alert)
            
            let buttonAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                alertController.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(buttonAction)
            
            //          self.present(alertController, animated: true)
            
            print("/////// Eror /////",error1)
        }
        //MARK:TODO LED bug
        //         if (characteristic.value != nil) {
        var bytesData = [UInt8] (repeating: 0, count: characteristic.value!.count)
        (characteristic.value! as NSData).getBytes(&bytesData, length: characteristic.value!.count)
        
        self.btDataStreamBytes.append(contentsOf: bytesData)
        
        let packetDataAscii = String(bytes: bytesData, encoding: String.Encoding.ascii)
        self.btDataStreamAscii.append(packetDataAscii!)
        //        print ("Shawn - Parse package response ",packetDataAscii,characteristic.value!.count)
        print("Max write W/R value MTU: \(peripheral.maximumWriteValueLength(for: .withResponse))")
        
    }
    
    
    
    
    // MARK:  Process data stream from bluetooth
    
    @objc func parseBtDataStream() {
        var dataBufferByte: Array<UInt8> = [UInt8]()
        var actualDataBufferByte: Array<UInt8> = [UInt8]()
        
        let offsetHex = (6 + 6) * 2
        let offset = 6 + 6
        
        
        
        /////////////////////////////////////////////////////////////////////
        //        Check to see if able to parse data
        /////////////////////////////////////////////////////////////////////
        if self.btDataStreamBytes.count == 0 || self.isParsingBtDataStream || !Donglesw.shared.isConnected() {
            
            if self.cmdDict.count > 0 && self.isParsingBtDataStream == false {
                //**  Check Time out and send timeout notification as needed  **//
                checkTimedout()
            }
            
            if self.btDataStreamAscii.hasPrefix("SRSM00") || self.btDataStreamAscii.hasPrefix("UY2400") || self.btDataStreamAscii.hasPrefix("UY0200") ||  self.btDataStreamAscii.hasPrefix("UF01Z") || self.btDataStreamAscii.hasPrefix("UY0020") || self.btDataStreamAscii.hasPrefix("UFL0")
            {
                NSLog("Shawn - parseBtDataStream: SRSM00")
            }else{
                return
            }
            
        }
        
        
        /////////////////////////////////////////////////////////////////////
        //   Check for command time out and if all packets arrive for a command
        /////////////////////////////////////////////////////////////////////
        
        //Get Acknowledgement for the command found in btDataStream
        let cmdInfo = parseForAcknowledgement()
        
        //**  Check Time out and send timeout notification as needed  **//
        checkTimedout()
        
        
        //** Check to see if all data arrived for the command **//
        if cmdInfo.cmd.count==0 || !(Utilsw.shared.allPacketsArrived(asciiBuffer: self.btDataStreamAscii) ) {
            if self.btDataStreamAscii.hasPrefix("RSM00")
            {
                NSLog("Shawn - parseBtDataStream: RSM00 self.btDataStreamAscii SM00")
                
            }else if self.btDataStreamBytes.count == 1{
                NSLog("Shawn - parseBtDataStream: RSM00 slot32")
                
            }else{
                self.isParsingBtDataStream = false
                return
            }
            
        }
        if Constant.shared.debugOn {
            NSLog("Shawn - parseBtDataStream cmd: \(String(describing: cmdInfo.cmd))   self.btDataStreamAscii.count=%d",  self.btDataStreamAscii.count)
        }
        
        
        /////////////////////////////////////////////////////////////////////
        //   Got reponse for a command and all packets arrived
        /////////////////////////////////////////////////////////////////////
        
        //Start Parsing Data - Only allow one parsing process at a time
        self.isParsingBtDataStream = true
        
        
        cmdDict.removeObject(forKey: cmdInfo.key)
        
        
        
        //Start collect response data
        let packetSize = Utilsw.shared.getPacketSize(asciiBuffer: self.btDataStreamAscii) + offset
        cmdInfo.responseTime = Date().timeIntervalSince1970 - cmdInfo.startTime.timeIntervalSince1970
        cmdInfo.packetSize = Int32(packetSize)
        
        if Constant.shared.debugOn3 {
            NSLog("Shawn -: parseBtDataStream Length :  packetSize=%d   Ascii.count=%d  Bytes.count=%d", packetSize, self.btDataStreamAscii.count, self.btDataStreamBytes.count)
        }
        
        if Constant.shared.debugOn4 {
            NSLog("Shawn -: parseBtDataStream responseTime : \(String(describing: cmdInfo.cmd))   packetSize=%d   %f second(s)", packetSize, cmdInfo.responseTime)
        }
        
        
        cmdInfo.cmdStatus = CMD_SUCCESS
        
        
        
        /////////////////////////////////////////////////////////////////////
        //                Start Parsing data Shawn -: parseBtDataStream responseTim
        /////////////////////////////////////////////////////////////////////
        
        //Get the reponse for a command
        dataBufferByte.append(contentsOf: self.btDataStreamBytes.prefix(packetSize))
        let dataBufferAscii = String(self.btDataStreamAscii.prefix(packetSize))
        
        //Remove response from btDataStreamBytes
        removeFromBtDataStreams(packetSize: packetSize)
        
        
        //Get Hex Data
        let dataBufferHex = Utilsw.shared.convertBytesToHex(byteBuffer: dataBufferByte)
        
        //Get Actual data - removed the header info from te packets
        let actualDataBufferHex = String(Utilsw.shared.removeHeaderInfo(hexData: dataBufferHex, offset: offsetHex))  //Remove header information
        let actualDataBufferAscii = String(Utilsw.shared.removeHeaderInfo(hexData: dataBufferAscii, offset: offset))  //Remove header information
        var actualDataBufferByteSize = (dataBufferByte.count - offset)
        if actualDataBufferByteSize <= 0 {
            actualDataBufferByteSize = 0
        }
        actualDataBufferByte.append(contentsOf: dataBufferByte.suffix(actualDataBufferByteSize))
        
        
        //Set data in CmdInfo object
        cmdInfo.responseHeader = String(dataBufferAscii.prefix(offset))
        cmdInfo.responseCode = String(cmdInfo.responseHeader.suffix(offset-6))
        cmdInfo.respCode = cmdInfo.getResponseCode(cmdInfo.responseCode)
        cmdInfo.dataHex = actualDataBufferHex
        cmdInfo.dataAscii = actualDataBufferAscii
        
        let nsData = NSData(bytes: &actualDataBufferByte, length: actualDataBufferByte.count)
        cmdInfo.setByteData(nsData as Data?, (Int32)(actualDataBufferByteSize) )
        
        // check if EAController to parsePacket
        if actualDataBufferByteSize==0  {//|| isFirmwareUpdate(cmdInfo: cmdInfo) || isHcommandChecksum(cmdInfo: cmdInfo)  {
            //Don't use EAController ParsePacket
            if cmdInfo.packetSize == 11  || cmdInfo.notificationName == "UY_command"{
                //Still Tell EAController to parsePacket SRSM
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.shared.parsePacketNotification), object: cmdInfo)
                
            }else{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: cmdInfo.notificationName!), object: cmdInfo)
            }
        }else {
            //Tell EAController to parsePacket
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constant.shared.parsePacketNotification), object: cmdInfo)
        }
        
        //        //Done - process the next command
        //        if !(cmdInfo.responseHeader.contains("RSM0")){
        if cmdInfo.notificationName == "UH_command"{
            
        }else{
            self.isParsingBtDataStream = false
        }
        
        
        
        if Constant.shared.debugOn {
            NSLog("parseBtDataStream dataBufferAscii.count=%d, %d   dataBufferHex.count=%d, %d",  dataBufferAscii.count, actualDataBufferAscii.count, dataBufferHex.count, actualDataBufferHex.count)
        }
        
        if Constant.shared.debugOn4 {
            NSLog("parseBtDataStream cmd: \(String(describing: cmdInfo.cmd))   packetSize=%d, actualDataBufferHex.count=%d   actualDataBufferAscii.count=%d ", packetSize, actualDataBufferHex.count, actualDataBufferAscii.count)
            NSLog("parseBtDataStream actualDataBufferAscii: \(String(describing: actualDataBufferAscii))")
            NSLog("parseBtDataStream actualDataBufferHex: \(String(describing: actualDataBufferHex))")
        }
        
    }
    
    
    func removeFromBtDataStreams(packetSize: Int) {
        
        if packetSize == 0 {
            return
        }
        
        var tmpPacketSize = self.btDataStreamBytes.count
        if packetSize >  tmpPacketSize {
            self.btDataStreamBytes.removeFirst(tmpPacketSize)
        }else {
            self.btDataStreamBytes.removeFirst(packetSize)
        }
        
        
        tmpPacketSize = self.btDataStreamAscii.count
        if packetSize >  tmpPacketSize {
            self.btDataStreamAscii.removeFirst(tmpPacketSize)
        }else {
            self.btDataStreamAscii.removeFirst(packetSize)
        }
        
    }
    
    
    func parseForAcknowledgement() -> CmdInfo {
        
        var cmdInfo: CmdInfo
        let notFound: CmdInfo = CmdInfo.init()
        var commandOnly: String;
        
        if self.btDataStreamAscii.count == 10 || self.btDataStreamAscii.count == 9  {
            for (key, value) in cmdDict {
                
                cmdInfo = value as! CmdInfo
                
                // Swift 4
                // Get command
                if cmdInfo.cmd.count > 6 {
                    commandOnly = String(cmdInfo.cmd.prefix(6))
                }else {
                    commandOnly = cmdInfo.cmd
                }
                
                cmdInfo.acknowledgement = commandOnly
                
                if Constant.shared.debugOn {
                    NSLog("Shahab - parseForAcknowledgement cmd:  \(String(describing: cmdInfo.cmd))   %d", cmdInfo.cmd.count)
                }
                
                if self.btDataStreamAscii.hasPrefix(commandOnly) && self.btDataStreamAscii.index(at: 0) != nil  {
                    
                    //                    self.cmdInfoList.remove(at: index)
                    
                    if cmdInfo.acknowledgementNotificationName.count > 0 && cmdInfo.acknowledgementNotificationSent == 0 {
                        cmdInfo.acknowledgementNotificationSent = cmdInfo.acknowledgementNotificationSent + 1
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: cmdInfo.acknowledgementNotificationName!), object: cmdInfo)    //Send acknowledgementNotificationName
                    }
                    
                    if Constant.shared.debugOn {
                        NSLog("Shawn - - Got Acknowledgement - Ascii.hasPrefix:  \(String(describing: cmdInfo.cmd))  \(String(describing: self.btDataStreamAscii))")
                        
                    }
                    if self.btDataStreamBytes[0] == 0{
                        self.btDataStreamBytes.remove(at: 0)
                    }
                    
                    return cmdInfo
                }else {
                    checkTimedout(cmdInfo: cmdInfo)
                }
                
            }
            if  self.btDataStreamAscii.count == 10
            {
                self.btDataStreamBytes.removeFirst()
                self.btDataStreamAscii.removeFirst()
            }
        }else{
            while self.btDataStreamAscii.count > 0  {
                for (key, value) in cmdDict {
                    
                    cmdInfo = value as! CmdInfo
                    
                    // Swift 4
                    // Get command
                    if cmdInfo.cmd.count > 6 {
                        commandOnly = String(cmdInfo.cmd.prefix(6))
                    }else {
                        commandOnly = cmdInfo.cmd
                    }
                    
                    cmdInfo.acknowledgement = commandOnly
                    
                    if Constant.shared.debugOn {
                        NSLog("-=- - parseForAcknowledgement cmd:  \(String(describing: cmdInfo.cmd))   %d", cmdInfo.cmd.count)
                    }
                    
                    if self.btDataStreamAscii.hasPrefix(commandOnly) && self.btDataStreamAscii.index(at: 0) != nil  {
                        
                        if cmdInfo.acknowledgementNotificationName.count > 0 && cmdInfo.acknowledgementNotificationSent == 0 {
                            cmdInfo.acknowledgementNotificationSent = cmdInfo.acknowledgementNotificationSent + 1
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: cmdInfo.acknowledgementNotificationName!), object: cmdInfo)    //Send acknowledgementNotificationName
                        }
                        
                        if self.btDataStreamBytes[0] == 0{
                            self.btDataStreamBytes.remove(at: 0)
                        }
                        
                        return cmdInfo
                    }else {
                        checkTimedout(cmdInfo: cmdInfo)
                    }
                    
                    
                }
                
                //If not found - trim the leading characters
                
                self.btDataStreamBytes.removeFirst()
                self.btDataStreamAscii.removeFirst()
                
                
                
            }
        }
        return notFound
        
    }
    
    func checkTimedout() {
        //        print("Shawn - in func checkTimedout:  self.cmdInfoList.count=", self.cmdInfoList.count)
        var cmdInfo: CmdInfo
        
        for (key, value) in cmdDict {
            
            cmdInfo = value as! CmdInfo
            
            let currentTime = Date()
            
            if currentTime > cmdInfo.endTime {
                //Handle Timeout
                cmdInfo.timedoutAt = currentTime
                cmdInfo.cmdStatus = CMD_TIMED_OUT
                
                if cmdInfo.dataOnly == false {
                    NSLog("Shawn - Command timeout: %@", cmdInfo.cmd)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: cmdInfo.notificationName!), object: cmdInfo)    //Send timeout to each caller base on caller name
                }
                cmdDict.removeObject(forKey: cmdInfo.key)
                
                break;
                
            }
        }
    }
    
    func checkTimedout(cmdInfo: CmdInfo) -> CmdInfo {
        let currentTime = Date()
        
        if currentTime > cmdInfo.endTime {
            //Handle Timeout
            cmdInfo.timedoutAt = currentTime
            cmdInfo.cmdStatus = CMD_TIMED_OUT
            
            if cmdInfo.dataOnly == false {
                NSLog("Shawn - Commandinfo timeout: %@", cmdInfo.cmd)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: cmdInfo.notificationName!), object: cmdInfo)    //Send timeout to each caller base on caller name
            }
            
            cmdDict.removeObject(forKey: cmdInfo.key)
            
        }
        
        return cmdInfo
        
    }
    // MARK:  Helper methods
    
    @objc func interruptLocalTimer() {
        
        for keyDict in Array(BleUtil.shared.peripheralDict.keys) {
            if ((BleUtil.shared.peripheralDict[keyDict]!.timeStamp!).timeIntervalSinceNow < -15.0) {
                BleUtil.shared.peripheralDict.removeValue(forKey: keyDict)
            }
        }
        
    }
    
    @objc func isFirmwareUpdate(cmdInfo: CmdInfo) -> Bool {
        switch cmdInfo.cmdCode {
        case UOTA00:
            return true;
        case UOTA10:
            return true;
        case UOTA20:
            return true;
        case UOTA30:
            return true;
            
        default:
            return false;
        }
    }
    
    @objc func isHcommandChecksum(cmdInfo: CmdInfo) -> Bool {
        switch cmdInfo.respCode {
        case URHM0:
            return true;
        case SRSM0:
            return true;
            
        default:
            return false;
        }
    }
    
}
