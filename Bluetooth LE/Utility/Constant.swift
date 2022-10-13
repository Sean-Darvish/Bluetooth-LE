//
//  Constant.swift
//  Bluetooth LE
//
//  Created by Shahab Darvish on 10/12/22.
//

import Foundation
import UIKit

@objcMembers
final class Constant: NSObject {
    
    // MARK: - Shared Instance
    @objc static let shared: Constant = {
        let instance = Constant()
        // setup code
        return instance
    }()
    
    // MARK: - Initialization Method
    override init() {
        super.init()
    }
    
    
    // MARK: - Define Constants - debugOn
    let debugOn: Bool = true
    let debugOn1: Bool = false
    let debugOn2: Bool = false
    let debugOn3: Bool = false
    let debugOn4: Bool = false
    
    
    // MARK: - Define Constants - Notification Name
    let liveDataNotificationName: String = "LiveDataNotification"
    let dataLogNotificationName: String = "DataLogNotification"
    let readDtcCommandNotification: String = "readDtcCommandNotification"
    let reponseFromHCommand: String = "reponseFromHCommand"
    let bladeControl_1: Int = 1
    let bladeControl_2: Int = 2
    let firmwareLength: Int = 4
    let exitViewController: Int = 999
    let pageViewIndicatorHeight: Int = 32 + 55 //indicator plus tab bar
    let reponseFromFp3Command: String = "reponseFromFp3Command"
    let reponseFromFp3Checksum: String = "reponseFromFp3Checksum"
    let enableSwipeNotification: String = "enableSwipeNotification"
    let disableSwipeNotification: String = "disableSwipeNotification"
    let UH_command: String = "UH_command"
    let UG_command: String = "UG_command"
    let UW_command: String = "UW_command"
    let DEV_command: String = "DEV_command"
    let UY_command: String = "UY_command"
    let checkFirmwareUpdateNotification: String = "checkFirmwareUpdateNotification"
    let autotuneOutTransferInNotification: String = "autotuneOutTransferInNotification"
    let showAutotuneToturialNotification: String = "showAutotuneToturialNotification"
    let showPreviewAututuneNotification: String = "showPreviewAututuneNotification"
    let pageControlUpdateNotification: String = "pageControlUpdateNotification"
    let pageControlEventNotification: String = "pageControlEventNotification"
    let parsePacketNotification: String = "parsePacketNotification"
    
    let didDiscoverPeripheralNotification: String = "didDiscoverPeripheralNotification"
    let didConnectPeripheralNotification: String = "didConnectPeripheralNotification"
    let didDisconnectPeripheralNotification: String = "didDisconnectPeripheralNotification"
    let didFailToConnectNotification: String = "didFailToConnectNotification"
    
    let didConnectCharacteristicNotification: String = "didConnectCharacteristicNotification"
    let didDiscoverServicesNotification: String = "didDiscoverServicesNotification"
    let didUpdateNotificationStateNotification: String = "didUpdateNotificationStateNotification"
    let didUpdateValueForcharacteristicNotification: String = "didUpdateValueForcharacteristicNotification"
    let vinCommandNotification: String = "vinCommandNotification"
    
    let devCommandNotification: String = "devCommandNotification"
    let ecmCommandNotification: String = "ecmCommandNotification"
    let clearDtcCommandNotification: String = "clearDtcCommandNotification"
    let commandTimeoutNotification: String = "commandTimeoutNotification"
    let testConnectionNotification: String = "testConnectionNotification"
    let xCommandNotification: String = "xCommandNotification"
    let pCommandNotification: String = "pCommandNotification"
    
    let turnOffAutotuneNotification: String = "turnOffAutotuneNotification"
    let applyLearnedValuesNotification: String = "applyLearnedValuesNotification"
    let autotunePreviewCalcNotification: String = "autotunePreviewCalcNotification"
    let finishAutotuneNotification: String = "finishAutotuneNotification"
    let resumeAutotuneDataFeedNotification: String = "resumeAutotuneDataFeedNotification"
    let exitViewControllerNotification: String = "exitViewControllerNotification"
    let requestConnectionFailedNotification: String = "requestConnectionFailedNotification"
    let requestConnectionSuccessNotification: String = "requestConnectionSuccessNotification"
    let lostConnectionNotification: String = "lostConnectionNotification"
    let ota00CommandNotification: String = "ota00CommandNotification"
    let ota10CommandNotification: String = "ota10CommandNotification"
    let ota10CommandAcknowledgeNotification: String = "ota10CommandAcknowledgeNotification"
    let ota20CommandNotification: String = "ota20CommandNotification"
    let ota30CommandNotification: String = "ota30CommandNotification"
    let otaDataNotification: String = "otaDataNotification"
    let otaVerifyCommandNotification: String = "otaVerifyCommandNotification"
    
    // MARK: - Define Constants - iPhoneXstatusBarHeight
    let iPhoneXstatusBarHeight = 26;
    
    
    // MARK: - Define Constants - Apple MerchantId and Strip setup
    //Strip setup
    let StripePublishableTestKey = "pk_test_XXXX"; //Test Key
     
    // To learn how to obtain an Apple Merchant ID, head to https://stripe.com/docs/mobile/apple-pay
    let AppleMerchantId = "XXX.mapstore";
    
    let ApiVersion = "XXX";

    
    
    // MARK: - Define Constants - Servers and passwords

    let dealerServer = "XXX/api.php";   //Dealer Server
    let dealerServerPrefix = "XXX.com";   //Dealer Server Prefix
    let dealerApiUser = "XXX"
    let dealerApiPasswd = "XXX"


    //Hex Values
    let dealerDynoMapHex_PV = "5056"
    let harleyDealerIdHex = "010101"

    
    //Server setup
    let devServer = "https://XX."

    
    // MARK: - Define Constants - Others
    

    let defaultButtonColor = UIButton(type: UIButton.ButtonType.system).titleColor(for: .normal)!
//    MARK:TODO parametric 2021
    let numberOfSectors =  96 //will be 512
    let sectorSize = 256 // was 256
    let sectorLogSize = 512
    
    let disableDealerSearch = true
    let tableViewCellHeight: CGFloat = 93.0
    
    
    let isEditGenTables = true
    let isNewDemoModeVC = true
    var callFromViewController = ""
    
    
    let shiftedBy: [UInt64] = [(1<<56), (1<<48), (1<<40), (1<<32), (1<<24), (1<<16), (1<<8), 1]
    
    
    // MARK: - Define Constants - Helper functions
    
    func basicAuthBase64EncodedString(userId: String, password: String) -> String {
        let authStr = String(format: "%@:%@", userId, password)
        let authData = authStr.data(using: .utf8)
        let authValue: String =  String(format: "Basic %@", (authData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)))!)
        let basicAuthBase64EncodedString: String = authValue
        
        return basicAuthBase64EncodedString
    }
    
    //User name
    let apiuser = "XXX"
    let apiuserPasswd = "XXX"
    
    //Create HTTPHeaders with user and password
    func apiuserHTTPHeaders() -> [String:String] {
        let headers = [
            "Authorization": Constant.shared.basicAuthBase64EncodedString(userId: Constant.shared.apiuser, password: Constant.shared.apiuserPasswd)
        ]
        return headers
    }
    
    func dealerApiuserHTTPHeaders() -> [String:String] {
        let headers = [
            "Authorization": Constant.shared.basicAuthBase64EncodedString(userId: Constant.shared.dealerApiUser, password: Constant.shared.dealerApiPasswd)
        ]
        return headers
    }


    
}


