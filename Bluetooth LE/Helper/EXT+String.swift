//
//  EXT+String.swift
//  Bluetooth LE
//
//  Created by Shahab Darvish on 10/2/20.
//

import Foundation

extension String {
    func index(at offset: Int) -> Index? {
        precondition(offset >= 0, "offset can't be negative")
        return index(startIndex, offsetBy: offset, limitedBy: index(before: endIndex))
    }
}

extension String {
    
    func trimLeadingSpaces() -> String {
        var t = self
        while t.hasPrefix(" ") {
            t = "" + t.dropFirst()        }
        return t
    }
    
    mutating func trimLeadingSpaces() {
        self = self.trimLeadingSpaces()
    }
    
}

extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
}
