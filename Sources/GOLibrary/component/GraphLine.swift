//
//  GraphLine.swift
//  Pupping
//
//  Created by JeongCheol Kim on 2022/01/23.
//

//
//  ProgressSlider.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/18.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI

public struct GraphLine: PageView {
    var selectIdx:Int = -1
    var selectedColor:Color = Color.blue
    var points:[Float]? = nil
    var lineColor:Color = Color.black
    var stroke:CGFloat = 5
    public var body: some View {
        GeometryReader { geometry in
            ZStack{
                if self.points?.isEmpty == false {
                    let positions = self.getPositions(geometry)
                    Line(
                        points: positions
                    )
                    .stroke(self.lineColor, style: .init(lineWidth: self.stroke, lineCap: .round, lineJoin: .round))
                    .foregroundColor(self.lineColor)
                    
                    ForEach(zip(0..<positions.count, positions).map{ idx , pos in
                        PointData(
                            id:UUID().uuidString,
                            idx: idx,
                            pos: pos
                        )
                    }){ p in
                        Circle()
                            .stroke( p.idx == selectIdx ? self.selectedColor : self.lineColor, lineWidth: self.stroke)
                            .background(Circle().fill(Color.white))
                            .frame(
                                width: 2,
                                height: 2,
                                alignment: .topLeading)
                            .position(x: p.pos.x, y: p.pos.y)
                        
                    }
                }
            }
            .modifier(MatchParent())
        }
    }
    
    private func getPositions(_ geometry:GeometryProxy)->[CGPoint]{
        let positions:[CGPoint] = zip(0..<self.points!.count, self.points!).map{idx, p in
            let num = self.points!.count  - 1
            if num < 1 {return CGPoint(x:0, y:0)}
            return CGPoint(
                x: geometry.size.width / CGFloat(num) * CGFloat(idx),
                y: geometry.size.height * CGFloat(1-p))
        }
        return positions
    }
    
    struct PointData:Identifiable{
        let id:String
        let idx:Int
        let pos:CGPoint
    }
}


#if DEBUG
struct GraphLine_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GraphLine(
                selectIdx: 2,
                points:  [0.8, 0.1, 0.9]
            )
            .frame(width: 200, height:150)
        }
    }
}
#endif




