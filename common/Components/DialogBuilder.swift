//
//  DialogBuilder.swift
//  common
//
//  Copyright © 2018 minimalistic apps. All rights reserved.
//

import StatusAlert

public class DialogBuilder {
    public enum ButtonOptions {
        case OK_CANCEL, RETRY_CANCEL, OK
    }
    
    public enum DialogResult {
        case OK, CANCEL, RETRY
    }
    
    public static func getDialogForMessage(title: String, message:String, buttonTitle: String, completion:((DialogResult)->Void)?) -> UIAlertController {
        // Prepare the popup assets
        let dialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: buttonTitle, style: .default) { action in
            if let c = completion {
                c(.OK)
            }
        })
        return dialog
    }
    
    public static func getDialogForMessage(message:String, completion:((DialogResult)->Void)?) -> UIAlertController {
        // Prepare the popup assets
        let title = NSLocalizedString("Message", comment: "Message Default Title")
        let dialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Message OK button"), style: .default) { action in
            if let c = completion {
                c(.OK)
            }
        })
        return dialog
    }
    
    public static func alertOnError(message:String) {
        // Creating StatusAlert instance
        let statusAlert = StatusAlert()
        statusAlert.title = NSLocalizedString("Error_Happened", comment: "Default title for any error occured")
        statusAlert.message = message
        statusAlert.canBePickedOrDismissed = true
        statusAlert.alertShowingDuration = 3
        statusAlert.image = UIImage(named: "alert_error")
        if #available(iOS 13.0, *) {
            statusAlert.appearance.tintColor = UIColor.label
        }
        // Presenting created instance
        statusAlert.showInKeyWindow()
    }
    
    public static func alertOnSuccess(message:String) {
        let statusAlert = StatusAlert()
        statusAlert.alertShowingDuration = 3
        statusAlert.image = UIImage(named: "alert_success")
        statusAlert.message = message
        statusAlert.canBePickedOrDismissed = true
        if #available(iOS 13.0, *) {
            statusAlert.appearance.tintColor = UIColor.label
        }
        statusAlert.showInKeyWindow()
    }
}
