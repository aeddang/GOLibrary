//
//  LayoutAli.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI



public struct MatchParent: ViewModifier {
    var marginX:CGFloat = 0
    var marginY:CGFloat = 0
    var margin:CGFloat? = nil
    public init(marginX: CGFloat = 0, marginY: CGFloat = 0, margin: CGFloat? = nil) {
        self.marginX = marginX
        self.marginY = marginY
        self.margin = margin
    }
    public func body(content: Content) -> some View {
        let mx = margin ?? marginX
        let my = margin ?? marginY
        return content
            .frame(minWidth: 0, maxWidth: .infinity - (mx * 2.0), minHeight:0, maxHeight: .infinity - (my * 2.0))
            .offset(x:mx, y:my)
    }
}
public struct MatchHorizontal: ViewModifier {
    var height:CGFloat = 0
    var margin:CGFloat = 0
    public init(height: CGFloat = 0, margin: CGFloat = 0) {
        self.height = height
        self.margin = margin
    }
    public func body(content: Content) -> some View {
        return content
            .frame(minWidth: 0, maxWidth: .infinity - (margin * 2.0) , minHeight: height, maxHeight: height)
            .offset(x:margin)
    }
}

public struct MatchVertical: ViewModifier {
    var width:CGFloat = 0
    var margin:CGFloat = 0
    public init(width: CGFloat = 0 , margin: CGFloat = 0) {
        self.width = width
        self.margin = margin
    }
    public func body(content: Content) -> some View {
        return content
            .frame(minWidth: width, maxWidth: width , minHeight:0, maxHeight: .infinity - (margin * 2.0))
            .offset(y:margin)
    }
}




public struct Shadow: ViewModifier {
    var color:Color = Color.black
    var opacity:Double = 0.4
    public init(color: Color = Color.black, opacity: Double = 0.4) {
        self.color = color
        self.opacity = opacity
    }
    public func body(content: Content) -> some View {
        return content
            .shadow(color: color.opacity(opacity), radius:5, x: 0, y: 4)
    }
}

struct ShadowTop: ViewModifier {
    var color:Color = Color.black
    var opacity:Double = 0.4
    public init(color: Color = Color.black, opacity: Double = 0.4) {
        self.color = color
        self.opacity = opacity
    }
    func body(content: Content) -> some View {
        return content
            .shadow(color: color.opacity(opacity), radius:5, x: 0, y: -4)
    }
}


