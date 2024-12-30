//
//  InfinityListView.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/16.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import SwiftUI
import Combine

public class InfinityScrollModel:ComponentObservable{
   
    public enum Request {
        case reload, scrollMove(Int, UnitPoint? = nil), scrollTo(Int, UnitPoint? = nil), scrollLock(Bool)
    }
    public enum Event {
        case up, down, bottom, top, pullCompleted, ready
    }
    public enum Status: String{
        case scroll, pull
    }
    public enum ItemEvent {
        case select(InfinityData), delete(InfinityData), declaration(InfinityData), dataChanged
    }
    public enum ScrollType :Equatable{
        case horizontal(isDragEnd:Bool? = nil),
             vertical(isDragEnd:Bool? = nil)
        
        public static func == (lhs: ScrollType, rhs: ScrollType) -> Bool {
            switch (lhs, rhs) {
            case ( .horizontal, .horizontal):return true
            case ( .vertical, .vertical):return true
            default: return false
            }
        }
    }

    static let DRAG_RANGE:CGFloat = 70
    static let DRAG_COMPLETED_RANGE:CGFloat = 50
    @Published public private(set)var request:Request? = nil {
        didSet{if self.request != nil { self.request = nil}}
    }
    @Published public fileprivate(set) var event:Event? = nil
    @Published public private(set) var scrollStatus:Status = .scroll
    @Published public private(set) var itemEvent:ItemEvent? = nil {
        didSet{if self.itemEvent != nil { self.itemEvent = nil}}
    }
    @Published public private(set) var isCompleted = false
    @Published public private(set) var isLoading = false
    @Published public private(set) var page = 0
    @Published public private(set) var total = 0
    @Published public private(set) var scrollPosition:CGFloat = 0
    var prevPosition:CGFloat = 0
    fileprivate(set) var minDiff:CGFloat = 0
    fileprivate(set) var appearList:[Int] = []
    fileprivate(set) var appearValue:Float = 0

    var initItemId:Int? = nil
   
    let idstr:String = UUID().uuidString
    let topIdx:Int = UUID.init().hashValue
    let bottomIdx:Int = UUID.init().hashValue
    var size = 20
    var isLoadable:Bool {
        get {
            return !self.isLoading && !self.isCompleted
        }
    }
    
    fileprivate(set) var isScrollEnd:Bool = false
    private(set) var isDragEnd:Bool = false
    private(set) var limitedScrollIndex:Int = -1
    private(set) var updateScrollDiff:CGFloat = 1.0
    private(set) var topRange:CGFloat = 80
    private(set) var type: ScrollType = .vertical(isDragEnd: false)
    private(set) var scrollSizeVertical:CGSize = CGSize(width: 375, height: 740)
    private(set) var scrollSizeHorizental:CGSize = CGSize(width: 375, height: 740)
    var isSetup:Bool = false
    init(limitedScrollIndex:Int = -1) {
        self.limitedScrollIndex = limitedScrollIndex
        super.init()
    }
    
    @discardableResult
    public func setup(type: ScrollType? = nil) -> InfinityScrollModel {
        let type:ScrollType = type ?? self.type
        self.type = type
        switch type {
        case .horizontal(let end):
            self.isDragEnd = end ?? false
        case .vertical(let end):
            self.isDragEnd = end ?? false
        }
        self.isSetup = true
        return self
    }
    
    public func excute(_ request:Request)->InfinityScrollModel {
        self.request = request
        return self
    }
    
    func onReload(){
        self.isCompleted = false
        self.page = 0
        self.total = 0
        self.isLoading = false
        //self.prevPosition = 0
    }
    
    func onLoad(){
        self.isLoading = true
    }
    func onLoaded(){
        self.isLoading = false
    }
    func onComplete(itemCount:Int){
        isCompleted =  size > itemCount
        self.total = self.total + itemCount
        self.page = self.page + 1
        self.isLoading = false
    }
    
    func onError(){
        self.isLoading = false
    }
    
    
    fileprivate func onMove(pos:CGFloat){
        if self.isScrollEnd {
            return
        }
        //ComponentLog.d("onMove prevPosition " + self.prevPosition.description, tag: "InfinityScrollViewProtocol" + self.id.description)
        let diff = self.prevPosition - pos
        //ComponentLog.d("onMove pos " + pos.description, tag: "InfinityScrollViewProtocol")
        if abs(diff) > 300 { return }
        if abs(diff) > self.minDiff{
            self.scrollPosition = pos
            self.prevPosition = ceil(pos)
        }
        if diff > 30 { return }
        if pos >= -self.topRange {
            self.minDiff = self.updateScrollDiff
            onTop()
        } else {
            if diff < -1 {
                self.onUp()
            }
            if diff > 1 {
                self.onDown()
            }
        }
        if self.scrollStatus != .scroll {
            self.scrollStatus = .scroll
        }
    }

    var delayUpdateSubscription:AnyCancellable?
    func delayUpdate(){
        self.delayUpdateSubscription?.cancel()
        self.delayUpdateSubscription = Timer.publish(
            every: 0.05, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.delayUpdateSubscription?.cancel()
                self.onUpdate()
            }
    }
    func onAppear(idx:Int){
        if self.appearList.first(where: {$0 == idx}) == nil {
            self.appearList.append(idx)
        }
        self.delayUpdate()
    }
    
    func onDisappear(idx:Int){
        if let find = self.appearList.firstIndex(where: {$0 == idx}) {
            self.appearList.remove(at: find)
        }
        self.delayUpdate()
    }
    
    
    private func onUpdate(){
        if self.appearList.isEmpty { return }
        self.appearList.sort()
        let value = Float(self.appearList.reduce(0, {$0 + $1}) / self.appearList.count)
        let diff = self.appearValue - value
        self.appearValue = value
        if diff > 0 {
            self.onUp()
            return
        }
        if  diff < 0 {
            self.onDown()
        }
    }
    
    private func onBottom(){
        if self.event == .bottom { return }
        self.event = .bottom
        ComponentLog.d("onBottom", tag: "InfinityScrollViewProtocol" + self.idstr)
    }
    
    private func onTop(){
        if self.event == .top { return }
        self.event = .top
        //ComponentLog.d("onTop", tag: "InfinityScrollViewProtocol" + self.idstr)
    }
    
    private func onUp(){
        //if self.event == .up { return }
        self.event = .up
        //ComponentLog.d("onUp", tag: "InfinityScrollViewProtocol" + self.idstr)
    }
    
    private func onDown(){
        //if self.event == .down { return }
        self.event = .down
        //ComponentLog.d("onDown", tag: "InfinityScrollViewProtocol" + self.idstr)
    }
}



open class InfinityData:Identifiable, Equatable{
    public var id:String = UUID().uuidString
    public var hashId:Int = UUID().hashValue
    var contentID:String = ""
    var index:Int = -1
    var deleteAble = false
    var declarationAble = false
    public static func == (l:InfinityData, r:InfinityData)-> Bool {
        return l.id == r.id
    }
    
    open func resetHashId(){
        self.hashId = UUID().hashValue
    }
}

protocol InfinityScrollViewProtocol :PageProtocol{
    var viewModel:InfinityScrollModel {get set}
    func onReady()
    func onMove(pos:CGFloat)
    func onAppear(idx:Int)
    func onDisappear(idx:Int)
}

extension InfinityScrollViewProtocol {
    func onReady(){
        self.viewModel.event = .ready
    }
    func onMove(pos:CGFloat){
        self.viewModel.onMove(pos: pos)
    }
    
    func onAppear(idx:Int){
        self.viewModel.onAppear(idx: idx)
    }
    
    func onDisappear(idx:Int){
        self.viewModel.onDisappear(idx: idx)
    }
}


