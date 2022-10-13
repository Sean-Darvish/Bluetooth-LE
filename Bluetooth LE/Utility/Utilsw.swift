//
//  Utilsw.swift
//  Bluetooth LE
//
//  Created by Shahab Darvish on 10/12/22.
//

import Foundation

@objcMembers
final class Utilsw: NSObject {
    
    
    // MARK: - Shared Instance
    
    static let shared: Utilsw = {
        let instance = Utilsw()
        // setup code
        return instance
    }()
    
    var range = NSRange.init()
    var base = 0
    var index = 0
    var jj = 0
    var ii = 0
    
    let mConstant: Constant = Constant()
    
    //MARK: Strip out header info and return actual data in packet
    func removeHeaderInfo(hexData: String, offset: Int) -> String {
        
        if offset>=hexData.count {
            return hexData
        }
        
        let index = hexData.index(hexData.startIndex, offsetBy: offset)
        let actualHexData = String(hexData.suffix(from: index))
        
        return actualHexData
    }
    
    func convertBytesToHex(byte: UInt8) -> String {
        
        //Convert bytes to Hex
        
        let hexValue = String(format: "%02X", byte)
        
        return String(hexValue)
    }
    
    func convertBytesToHex(byteBuffer: Array<UInt8>) -> String {
        
        //Convert bytesArr to Hex String
        var tmpHexDataBuffer: String = ""
        for ii in 0..<byteBuffer.count
        {
            let hexValue = String(format: "%02X", byteBuffer[ii])
            tmpHexDataBuffer = tmpHexDataBuffer.appending(hexValue)  ////Accumulate hexData
        }
        
        return String(tmpHexDataBuffer)
    }
    
    func getPacketSize(asciiBuffer: String) -> Int {
        let headerLen = 12
        var packetSize: Int = -1
        
        if asciiBuffer.count < headerLen {
                return -1    //Don't have enough data yet
        }
        
        let headerInfo = String(asciiBuffer.prefix(headerLen))
        let packetSizeTxt = String(headerInfo.suffix(1))
        //MARK: Handle OTA file size `
        if packetSizeTxt=="X" {
           packetSize = 3078
            
        }else {
            if headerInfo.contains("`"){
                packetSize = 3078   // 3072 + 6
            }else if headerInfo.contains("p"){
                packetSize = 4102   // 4096 + 6 = 4102
            }else{
                packetSize = Int(packetSizeTxt, radix: 32)!
                packetSize = packetSize * 64
            }
            
           
        }

        return packetSize
    }
    
    // MARK: Helper methods to parse FP3 reponse
    //Validate packet size
    func allPacketsArrived(asciiBuffer: String) -> Bool {
        let headerLength = 12
        
        if mConstant.debugOn {
            NSLog("parsePacket RawData: \(String(describing: asciiBuffer))")
        }
        
        if asciiBuffer.count < headerLength {
            if mConstant.debugOn {
                NSLog("allPacketsArrived:  Waiting for More data - missing Header Info asciiBuffer.count=%d     headerLength=%d", asciiBuffer.count, headerLength)
            }
            if asciiBuffer.count == 10
            {
                NSLog("allPacketsArrived:  Waiting for More data - missing Header Info asciiBuffer.count=%d     headerLength=%d", asciiBuffer.count, headerLength)
            }else
            {
                return false    //Don't have enough data yet
            }
        }
        
        //Get Packet size
        let packetSize = getPacketSize(asciiBuffer: asciiBuffer)
        let bufferSize = asciiBuffer.count
        
        //Compare the packetsize to Actual data length
        if bufferSize >= packetSize {
            if mConstant.debugOn {
                NSLog("allPacketsArrived: Got all data -  packetSize: \(String(describing: packetSize))     bufferSize: \(String(describing: bufferSize))")
            }
            return true
        }else {
            if mConstant.debugOn {
                NSLog("allPacketsArrived:  Waiting for More data -  packetSize: \(String(describing: packetSize))     bufferSize: \(String(describing: bufferSize))")
            }
            
            return false
        }
    }
}
