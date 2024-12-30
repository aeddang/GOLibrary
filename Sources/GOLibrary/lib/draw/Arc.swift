//
//  Circle.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2022/06/26.
//
import Foundation
import SwiftUI
struct Arc: Shape {

    var start:CGFloat = 0
    var end:CGFloat = 360
 
    func path(in rect: CGRect) -> Path {
       
        let path = UIBezierPath(arcCenter: CGPoint(x: rect.width/2, y: rect.height/2),
                                radius: rect.height/2,
                                startAngle: self.start.toRadians(),
                                endAngle: self.end.toRadians(),
                                clockwise: true)
        
        return Path(path.cgPath)
    }
}

extension View {
    func drawStrokeCircle(start: CGFloat = 0, end: CGFloat = 360, color:Color = Color.blue, width:CGFloat = 2) -> some View {
        Arc(start:start, end: end)
            .stroke(style: .init(lineWidth: width, lineCap: .round))
            .foregroundColor(color)
    }
}

