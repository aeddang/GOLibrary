//
//  Ring.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/22.
//
import Foundation
import SwiftUI
struct Line: Shape {
    var points:[CGPoint]
    func path(in rect: CGRect) -> Path {
        var path = Path()
        if points.count <= 1 { return path }
        path.move(to: points.first! )
        points.dropFirst().forEach{ point in
            path.addLine(to: point)
        }
        return path
    }
}

extension View {
    func drawLine(_ points:[CGPoint], color:Color = Color.black, stroke:CGFloat = 1) -> some View {
        clipShape(
            Line(points:points)
        )
            
    }
}
