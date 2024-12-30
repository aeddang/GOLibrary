//
//  ShareUtil.swift
//  globe
//
//  Created by JeongCheol Kim on 11/17/23.
//
import SwiftUI
import Foundation
import UIKit
import LinkPresentation

class OptionalTextActivityItemSource: NSObject, UIActivityItemSource {
    let text: String
    weak var viewController: UIViewController?
    
    init(text: String) {
        self.text = text
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return text
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        if activityType?.rawValue == "net.whatsapp.WhatsApp.ShareExtension" {
            // WhatsApp doesn't support both image and text, so return nil and thus only sharing an image. Also alert user about this on the first time.
            let alertedAboutWhatsAppDefaultsKey = "DidAlertAboutWhatsAppLimitation"
            
            if !UserDefaults.standard.bool(forKey: alertedAboutWhatsAppDefaultsKey) {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    guard let presentedViewController = activityViewController.presentedViewController else { return }
                    UserDefaults.standard.set(true, forKey: alertedAboutWhatsAppDefaultsKey)
                    
                    let alert = UIAlertController(title: "WhatsApp Doesn't Support Text + Image", message: "Unfortunately WhatsApp doesn’t support sharing both text and an image at the same time. As a result, only the image will be shared.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    presentedViewController.present(alert, animated: true, completion: nil)
                }
            }
            
            return nil
        } else {
            return text
        }
    }
}

/// For whatever reason `UIActivityViewController` on iOS 13 only provides a preview of the image if it's passed as a URL, rather than a `UIImage` (if `UIImage` just shows app icon, see here: https://stackoverflow.com/questions/57850483/).
/// However we can't pass the URL to the image because when paired with a String on iOS 13 (image URLs are fine on their own) Messages won't accept it.
/// So when sharing both, wrap the UIImage object and manually provide the preview via the `LinkPresentation` framework.
class ImageActivityItemSource: NSObject, UIActivityItemSource {
    let image: UIImage
    var title: String = "Share Image"
    init(image: UIImage, title:String? = nil) {
        self.image = image
        if let title = title {
            self.title = title
        }
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return image
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return image
    }
    
    @available(iOS 13.0, *)
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let imageProvider = NSItemProvider(object: image)
        
        let metadata = LPLinkMetadata()
        //metadata.imageProvider = imageProvider
        metadata.title = self.title
        metadata.iconProvider = imageProvider
        return metadata
    }
}
