//
//  HapticManager.swift
//  MyTVFramework
//
//  Created by  ytOh on 2023/03/14.
//

import Foundation
import UIKit

public class HapticManager {
      
    @MainActor
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    @MainActor
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
