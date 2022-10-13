//
//  AlertDialog.swift
//  Bluetooth LE
//
//  Created by Shahab Darvish on 10/12/22.
//

import Foundation
import UIKit

protocol AlertDialogDelegate {
    func didCancelAlertDialog(tag: Int)
}

@objcMembers
class AlertDialog {
    var alertController: UIAlertController?
}
