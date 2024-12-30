//
//  ProgressSlider.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/18.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI


public struct GraphCircle: PageView, @preconcurrency AnimateDrawViewProtocol{
    var progress: Float // or some value binded
    var progressColor:Color = Color.blue
    var bgColor:Color = Color.white
    var stroke:CGFloat = 6
    var start:CGFloat = 0
    var end:CGFloat = 360
    var fps:Double = 0.01
    var duration:Double = 0.5
    @State var isRunning: Bool = false
    @State var value:CGFloat = 0
    @State var progressValue:Double = 0
    @State var isDrawing: Bool = false
    
    public var body: some View {
        ZStack {
            Spacer()
                .modifier(MatchParent())
                .drawStrokeCircle(start: self.start, end: self.end,
                                  color: self.bgColor, width: self.stroke)
            Spacer()
                .modifier(MatchParent())
                .drawStrokeCircle(start: self.start, end: self.value,
                                  color: self.progressColor, width: self.stroke)
        }
        .modifier(MatchParent())
        .onAppear(){
            self.value = self.start
            self.startAnimation()
        }
        .onDisappear(){
            self.stopAnimation()
        }
    }
    
    func startAnimation() {
        ComponentLog.d("startAnimation" , tag: self.tag)
        self.isRunning = true
        self.isDrawing = true
        self.createJob(duration: self.duration, fps: self.fps)
    }
    func stopAnimation() {
        ComponentLog.d("stopAnimation" , tag: self.tag)
        self.isRunning = false
        self.isDrawing = false
    }
    
    public func onStart() {
        ComponentLog.d("onStart" , tag: self.tag)
    }
    func onCancel(frm: Int) {
        ComponentLog.d("onCancel" , tag: self.tag)
    }
    
    func onCompute(frm: Int, t:Double) {
        let v = t / self.duration
        let s = sin(v)
        ComponentLog.d("s " + s.description , tag: self.tag)
        self.progressValue = Double(self.progress) * sin( t / self.duration )
    }
    func onDraw(frm: Int) {
        self.value = self.start + ((self.end - self.start)*CGFloat(self.progressValue))
    }
}
#if DEBUG
struct GraphCircle_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            GraphCircle(
                progress:  0.8
            )
            .frame(width: 156, height:156)
        }
    }
}
#endif
