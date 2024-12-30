//
//  DialogHandler.swift
//  globe
//
//  Created by JeongCheol Kim on 10/3/23.
//

import Foundation
import UIKit
import SwiftUI

public class DialogHandler{
    @MainActor
    static func alert(
        title:String? = nil, message:String? = nil,
        preferredStyle:UIAlertController.Style = .alert,
        actions:[UIAlertAction] = [],
        cancelText:String = "Cancel",
        confirmText:String = "Confirm",
        cancel:(() -> Void)? = nil,
        confirm:(() -> Void)? = nil
    ){
        let alertController = UIAlertController (
            title: title,
            message: message,
            preferredStyle: preferredStyle)
        
        actions.forEach{ ac in
            alertController.addAction(ac)
        }
        
        if let cancel = cancel {
            let action = UIAlertAction(title: cancelText, style: .default, handler: {_ in
                cancel()
            })
            alertController.addAction(action)
        }
        if let confirm = confirm{
            let action = UIAlertAction(title: confirmText, style: .default, handler: {_ in
                confirm()
            })
            alertController.addAction(action)
        }
        let window = UIApplication.shared.connectedScenes.first as? UIWindowScene
        window?.windows.first?.rootViewController?.present(alertController , animated: true, completion: nil)
        
    }
}
