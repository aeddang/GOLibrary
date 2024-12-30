//
//  Timer.swift
//  MyTVFramework
//
//  Created by JeongCheol Kim on 2023/07/20.
//

import Foundation
import Combine

class ScheduleExcutor: ObservableObject, PageProtocol{
    private(set) var excutor:AnyCancellable? = nil
    func reservation(delay:Double,_ action:@escaping () -> Void){
        self.excutor?.cancel()
        self.excutor = Timer.publish(
            every:delay, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.cancel()
                action()
            }
    }
    
    func scedule(delay:Double,_ action:@escaping (Int) -> Void){
        self.excutor?.cancel()
        var count = 0
        self.excutor = Timer.publish(
            every:delay, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                action(count)
                count += 1
            }
    }
    
    func cancel(){
        self.excutor?.cancel()
        self.excutor = nil
    }
}



