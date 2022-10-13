//
//  Donglesw.swift
//  Bluetooth LE
//
//  Created by Shahab Darvish on 10/2/20.
//


import Foundation
import UIKit

enum ActiveDevice
{
    case Classic
    case Ble
    case DeviceDisconnected
    
}

enum BtStatus
{
    case BtConnected
    case BtDisconnected
    case BtTestConnection
    case BtConnectionRequest
    case BtConnectionCancelRequest
    case BtScanRequest
    case BtConnectionFailed
    
}

struct Device: Codable {
    let id:String
    var name: String
    var rssi: Double
}

@objcMembers
final class Donglesw: NSObject {
    
    // MARK: - Shared Instance
    @objc static let shared: Donglesw = {
        let instance = Donglesw()
        // setup code
        return instance
    }()
    
    // MARK: - Initialization Method
    override init() {
        super.init()
    }
    
    
    var activeDevice: ActiveDevice = .DeviceDisconnected
    var btStatus: BtStatus = .BtDisconnected
    var vin: String = ""
    var isCustomerSelectedDealerMap: Bool = false
    var searchMapOwnerDealerId: String = ""
    var vinExistInDealerServer: Bool = false
    var isMissingBootLoader = false
    
    // MARK:  Bluetooth Status
    
    @objc func isConnected() -> Bool {
        
        if Donglesw.shared.btStatus == .BtConnected {
            return true
        }else {
            return false
        }
    }
    
    func isDisconnected() -> Bool {
        
        if Donglesw.shared.btStatus == .BtDisconnected {
            return true
        }else {
            return false
        }
    }
    
    
    
    func getActiveDevice() -> ActiveDevice {
        return activeDevice
    }
    
    func setActiveDevice(activeDevice: ActiveDevice) {
        self.activeDevice = activeDevice
        
        switch activeDevice {
        case .Classic:
            if #available(iOS 13.0, *) {
                BleUtil.shared.stopScan()
            } else {
                // Fallback on earlier versions
            }
            break
            
        case .Ble:
            break
            
        case .DeviceDisconnected:
            break
            
        }
    }
}
