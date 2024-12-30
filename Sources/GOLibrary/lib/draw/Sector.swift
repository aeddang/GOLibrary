//
//  GraphArc.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/22.
//
import Foundation
import SwiftUI
struct Sector: Shape {

    var start:CGFloat = 180
    var end:CGFloat = 360
    var innerRadius = 10
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(arcCenter: CGPoint(x: rect.width/2, y: rect.height/2),
                                radius: rect.height/2,
                                startAngle: self.start.toRadians(),
                                endAngle: self.end.toRadians(),
                                clockwise: true)
        path.addLine(to: CGPoint(x: rect.width/2, y: rect.height/2))
        
        return Path(path.cgPath)
    }
}

extension View {
    func drawSector(start: CGFloat = 180, end: CGFloat = 360) -> some View {
        clipShape( Sector(start:start, end: end) )
    }
}
