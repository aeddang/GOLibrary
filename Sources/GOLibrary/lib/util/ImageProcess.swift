//
//  ImageProcess.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/24.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
extension UIImage {
    func contextSize() -> CGSize {
        return CGSize(width: self.size.width * self.scale, height: self.size.height * self.scale)
    }
    func normalized() -> UIImage {
        if self.imageOrientation == .up { return self }
        let contextSize: CGSize = self.contextSize()
        UIGraphicsBeginImageContext(contextSize)
        self.draw(in: CGRect(x:0,y:0, width: contextSize.width, height: contextSize.height))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage ?? self
    }
    
    @MainActor
    func maskRoundedImage(size:CGRect? = nil, radius: CGFloat, borderColor:Color = Color.white, borderWidth:CGFloat = 0) -> UIImage {
        let imageView: UIImageView = UIImageView(image:self)
        let layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = radius
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        if let s = size {layer.frame = s}
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage!
    }
    
    func crop(to:CGSize) -> UIImage {
        let contextSize: CGSize = self.contextSize()

        //Set to square
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        let cropAspect: CGFloat = to.width / to.height

        var cropWidth: CGFloat = to.width
        var cropHeight: CGFloat = to.height

        if to.width > to.height { //Landscape
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            posY = (contextSize.height - cropHeight) / 2
        } else if to.width < to.height { //Portrait
            cropHeight = contextSize.height
            cropWidth = contextSize.height * cropAspect
            posX = (contextSize.width - cropWidth) / 2
        } else { //Square
            if contextSize.width >= contextSize.height { //Square on landscape (or square)
                cropHeight = contextSize.height
                cropWidth = contextSize.height * cropAspect
                posX = (contextSize.width - cropWidth) / 2
            }else{ //Square on portrait
                cropWidth = contextSize.width
                cropHeight = contextSize.width / cropAspect
                posY = (contextSize.height - cropHeight) / 2
            }
        }

        let rect: CGRect = CGRect(x: posX, y: posY, width: cropWidth, height: cropHeight)
        return slice(to: rect)
    }
    
    func centerCrop() -> UIImage {
        let contextSize: CGSize = self.contextSize()

        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cropWidth: CGFloat = 0.0
        var cropHeight: CGFloat = 0.0

        if contextSize.width > contextSize.height { //Landscape
            cropWidth = contextSize.height
            cropHeight = contextSize.height
            posX = (contextSize.width - contextSize.height) / 2
        } else if contextSize.width <  contextSize.height { //Portrait
            cropHeight = contextSize.width
            cropWidth = contextSize.width
            posY = (contextSize.height - contextSize.width) / 2
        } else { //Square
            return self
        }
        let rect: CGRect = CGRect(x: posX, y: posY, width: cropWidth, height: cropHeight)
        return slice(to: rect)
    }
    
    func half(tailing:Bool = false) -> UIImage {
        let contextSize: CGSize = self.contextSize()
        let w = contextSize.width/2
        let rect: CGRect =
            tailing
            ? CGRect(x: w, y: 0, width: w, height: contextSize.height)
            : CGRect(x: 0, y: 0, width: w, height: contextSize.height)
        return slice(to: rect)
    }
    
    func slice(to:CGRect) -> UIImage {
        guard let cgimage = self.cgImage else { return self }
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        guard let newCgImage = contextImage.cgImage else { return self }
        guard let imageRef: CGImage = newCgImage.cropping(to: to) else { return self}
        let resultImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        return resultImage
    }
    
    func resize(to: CGSize) -> UIImage {
        var resultImage: UIImage?
        let newRect = CGRect(x: 0, y: 0, width: to.width, height: to.height).integral
        UIGraphicsBeginImageContextWithOptions(to, false, 0)
        if let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: to.height)
            context.concatenate(flipVertical)
            context.draw(cgImage, in: newRect)
            if let img = context.makeImage() {
                resultImage = UIImage(cgImage: img)
            }
            UIGraphicsEndImageContext()
        }
        return resultImage ?? self
    }
    
    func resizeMaintainAspectRatio(width:CGFloat) -> UIImage {
        let h = self.size.height
        let w = self.size.width
        let hei = width * h / w
        let size = CGSize(
            width: width,
            height: hei)
        
        return resize(to: size)
    }
}

struct UIImageProcess {
    static func merge(one:UIImage, two:UIImage)->UIImage{
        let oneSize = one.contextSize()
        let twoSize = two.contextSize()
        let h = max( oneSize.height,twoSize.height)
        let w = max( oneSize.width,twoSize.width)
        let size = CGSize(width: w, height: h)
        UIGraphicsBeginImageContext(size)
        one.draw(in:
            CGRect(
                x: (size.width-oneSize.width)/2.0,
                y: (size.height-oneSize.height)/2.0 ,
                width: oneSize.width, height: oneSize.height))
        two.draw(in:
            CGRect(
                x: (size.width-twoSize.width)/2.0 ,
                y: (size.height-twoSize.height)/2.0 ,
                width: twoSize.width, height: twoSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    static func mergeHorizental(one:UIImage, two:UIImage)->UIImage{
        let oneSize = one.contextSize()
        let twoSize = two.contextSize()
        let h = max( oneSize.height,twoSize.height)
        let w = oneSize .width + twoSize.width
        let size = CGSize(width: w, height: h)
        UIGraphicsBeginImageContext(size)
        one.draw(in: CGRect(x: 0, y: (size.height-oneSize.height)/2.0 , width: oneSize.width, height: oneSize.height))
        two.draw(in: CGRect(x: oneSize.width , y: (size.height-twoSize.height)/2.0 , width: twoSize.width, height: twoSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
