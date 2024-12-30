//
//  RoundRectMask.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/07.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
struct RoundRectMask: Shape {
    let radius: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let tls = CGPoint(x: rect.minX, y: rect.minY + radius)
        let tlc = CGPoint(x: rect.minX + radius, y: rect.minY + radius)
        let trs = CGPoint(x: rect.maxX - radius, y: rect.minY)
        let trc = CGPoint(x: rect.maxX - radius, y: rect.minY + radius)
        let brs = CGPoint(x: rect.maxX, y: rect.maxY - radius)
        let brc = CGPoint(x: rect.maxX - radius, y: rect.maxY - radius)
        let bls = CGPoint(x: rect.minX + radius, y: rect.maxY)
        let blc = CGPoint(x: rect.minX + radius, y: rect.maxY - radius)
        
        path.move(to: tls)
        path.addRelativeArc(center: tlc, radius: radius,startAngle: Angle.degrees(180), delta: Angle.degrees(90))
        path.addLine(to: trs)
        path.addRelativeArc(center: trc, radius: radius,startAngle: Angle.degrees(270), delta: Angle.degrees(90))
        path.addLine(to: brs)
        path.addRelativeArc(center: brc, radius: radius,startAngle: Angle.degrees(0), delta: Angle.degrees(90))
        path.addLine(to: bls)
        path.addRelativeArc(center: blc, radius: radius,startAngle: Angle.degrees(90), delta: Angle.degrees(90))
        
        return path
    }
}

struct RoundTopRectMask: Shape {
    let radius: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let tls = CGPoint(x: rect.minX, y: rect.minY + radius)
        let tlc = CGPoint(x: rect.minX + radius, y: rect.minY + radius)
        let trs = CGPoint(x: rect.maxX - radius, y: rect.minY)
        let trc = CGPoint(x: rect.maxX - radius, y: rect.minY + radius)
        let brs = CGPoint(x: rect.maxX, y: rect.maxY)
        let bls = CGPoint(x: rect.minX, y: rect.maxY)
        
        
        path.move(to: tls)
        path.addRelativeArc(center: tlc, radius: radius,startAngle: Angle.degrees(180), delta: Angle.degrees(90))
        path.addLine(to: trs)
        path.addRelativeArc(center: trc, radius: radius,startAngle: Angle.degrees(270), delta: Angle.degrees(90))
        path.addLine(to: brs)
        path.addLine(to: bls)
        path.addLine(to: tls)
        return path
    }
}

#if DEBUG
struct RoundRectMask_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            RoundTopRectMask(radius:50).frame(width:250, height:250)
        }
    }
}
#endif
