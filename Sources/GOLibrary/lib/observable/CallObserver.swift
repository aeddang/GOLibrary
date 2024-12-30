//
//  AudioMirrorManager.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/05/18.
//

import Foundation
import SwiftUI
import Combine
import AVKit
import CallKit



public class CallObserver : NSObject, ObservableObject, CXCallObserverDelegate, PageProtocol{
    
    private var callObserver:CXCallObserver? = nil
    @Published public private(set) var isCall:Bool = false
    public func start(){

        callObserver = CXCallObserver()
        callObserver?.setDelegate(self, queue: nil)
    }
    
    public func stop(){
        isCall = false
        callObserver?.setDelegate(nil, queue: nil)
        callObserver = nil
    }
    
    
    public func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        DataLog.d("callObserver hasConnected " + call.hasConnected.description, tag: self.tag)
        DataLog.d("callObserver hasEnded " + call.hasEnded.description, tag: self.tag)
        self.isCall = true
        if (call.hasConnected && !call.hasEnded) {
            DataLog.d("call.hasConnected = true, hasEnded = false", tag: self.tag)
            return
        }
        if (call.hasEnded) {
            DataLog.d("hasEnded = true ", tag: self.tag)
            self.isCall = false
        }
    }
    
    
    
}
