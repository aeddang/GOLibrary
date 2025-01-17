//
//  Page.swift
//  globe
//
//  Created by JeongCheol Kim on 2023/09/18.
//
import SwiftUI
import Foundation
public protocol PageProtocol {}
public extension PageProtocol {
    var tag:String {
        get{ "\(String(describing: Self.self))" }
    }
}


public typealias PageID = String
public typealias PageParam = String

public extension PageParam{
    static let title:String = "title"
    static let id:String = "id"
    static let data:String = "data"
}

public class PageObject : ObservableObject, Equatable, Identifiable, Hashable{
    public let id:String = UUID().uuidString
    public let pageID: PageID
    public let isHome:Bool
    public private(set) var params:[PageParam:Any]?
    
    public private(set) var isPopup:Bool
    public private(set) var detents: Set<PresentationDetent> = [.medium]
    public private(set) var presentationBackgroundInteraction:Bool = false
    public private(set) var presentationDragIndicator:Visibility = .visible
    
    public init(
        pageID:PageID,
        params:[PageParam:Any]? = nil,
        isPopup:Bool = false,
        isHome:Bool = false
    ){
        self.pageID = pageID
        self.params = params
        self.isPopup = isPopup
        self.isHome = isHome
    }
    
    @discardableResult
    public func addParam(key:PageParam, value:Any?)->PageObject{
        guard let value = value else { return self }
        if params == nil {
            params = [PageParam:Any]()
        }
        params![key] = value
        return self
    }
    @discardableResult
    public func removeParam(key:PageParam)->PageObject{
        if params == nil { return self }
        params![key] = nil
        return self
    }
    @discardableResult
    public func addParam(params:[PageParam:Any]?)->PageObject{
        guard let params = params else {
            return self
        }
        if self.params == nil {
            self.params = params
            return self
        }
        params.forEach{
            self.params![$0.key] = $0.value
        }
        return self
    }
    
    @discardableResult
    public func setupSheet(_ detents: Set<PresentationDetent> = [.medium],
                    presentationBackgroundInteraction:Bool = false,
                    presentationDragIndicator:Visibility = .visible
    )->PageObject{
        self.isPopup = true
        self.detents = detents
        self.presentationBackgroundInteraction = presentationBackgroundInteraction
        self.presentationDragIndicator = presentationDragIndicator
        return self
    }
    
    public func getParamValue(key:PageParam)->Any?{
        if params == nil { return nil }
        return params![key]
    }
    public func getPageTitle()->String{
        if params == nil { return "" }
        return params![.title] as? String ?? ""
    }
    
    public static func isSamePage(l:PageObject?, r:PageObject?)-> Bool {
        guard let l = l else {return false}
        guard let r = r else {return false}
        if !l.isPopup && !r.isPopup {
            let same = l.pageID == r.pageID
            return same
        }
        return l.id == r.id
    }
    public static func == (l:PageObject, r:PageObject)-> Bool {
        return l.id == r.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(pageID)
    }
}

public enum PageRequest {
    case movePage(PageObject)
    case showModal(PageObject), closeModal
    case closeAllPopup, closePopup
    case alert(String, action:((_ idx:Int) -> Void)? = nil), alertData(Any, action:((_ idx:Int) -> Void)? = nil), closeAlert
    case toast(String), toastData(Any), closeToast
}

public enum PageEvent {
    case onEvent(Any)
}

public class PagePresenter:ObservableObject, PageProtocol{
    @Published  public private(set) var currentPage:PageObject? = nil
    @Published  public private(set) var currentTopPage:PageObject? = nil
    
    @Published public private(set) var request:PageRequest? = nil
    @Published public private(set) var event:PageEvent? = nil {didSet{ if event != nil { event = nil} }}
    @Published public private(set) var isLoading:Bool = false
    @Published public private(set) var isLock:Bool = false
    private var pageCount:Int = 0
    private var finalAddedPage:PageObject? = nil
    
    @Published public private(set) var isPortrait:Bool = true
    @Published public private(set) var screenOrientation:UIDeviceOrientation = .portrait
    @Published public private(set) var screenSize:CGSize = .zero
    public private(set) var screenEdgeInsets:EdgeInsets = .init()
    
    public init(isPortrait:Bool = true) {
        self.isPortrait = isPortrait
    }
    
    @discardableResult
    public func excute(_ request:PageRequest)->PagePresenter{
        self.request = request
        return self
    }
    @discardableResult
    public func loading(_ on:Bool)->PagePresenter{
        self.isLoading = on
        return self
    }
    @discardableResult
    public func lock(_ on:Bool)->PagePresenter{
        self.isLock = on
        return self
    }
    
    @MainActor
    public func update(orientation:UIDeviceOrientation, geometry:GeometryProxy){
        
        ComponentLog.d("isFlat ->" + orientation.isFlat.description, tag: self.tag)
      
        if orientation.isFlat {
            self.screenEdgeInsets = geometry.safeAreaInsets
            let size = geometry.size
            self.screenSize = size
            self.screenOrientation = orientation
            let isPortrait = size.width <= size.height
            if isPortrait {
                self.isPortrait = isPortrait
                ComponentLog.d("flat size " + geometry.size.debugDescription,tag: self.tag)
                ComponentLog.d("isPortrait " + isPortrait.description,tag: self.tag)
            }
            
        } else {
            ComponentLog.d("isLandscape -> " + orientation.isLandscape.description, tag: self.tag)
            ComponentLog.d("isPortrait -> " + orientation.isPortrait.description, tag: self.tag)
            self.screenOrientation = orientation
            self.isPortrait = orientation.isPortrait
            DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                let size = geometry.size
                PageLog.d("size " + size.debugDescription,tag: self.tag)
                self.screenEdgeInsets = geometry.safeAreaInsets
                self.screenSize = size
            }
        }
    }
    
    @discardableResult
    public func updatedPage(_ page:PageObject, count:Int = 0)->PageObject?{
        if page.isHome {
            self.currentPage = page
        }
        self.pageCount += count
        var add:PageObject = page
        switch count {
        case 0 :
            self.currentTopPage = page
            ComponentLog.d("update Page " + page.pageID, tag:self.tag)
            return page
        case 1 :
            self.finalAddedPage = page
        default :
            add = self.finalAddedPage ?? page
        }
        ComponentLog.d("update Page count " + self.pageCount.description, tag:self.tag)
        if self.pageCount != 1 {return nil}
        self.currentTopPage = add
        ComponentLog.d("updated Page " + add.pageID, tag:self.tag)
        return add
    }
    
    
    
    
}
public protocol PageViewProtocol : PageProtocol, Identifiable{
    var contentBody:AnyView { get }
}

public protocol PageView : View, PageViewProtocol {
    var id:String { get }
    var contentBody:AnyView { get }
}


public extension PageView {
    nonisolated var id:String { get{
        return UUID().uuidString
    }}
    nonisolated var contentBody:AnyView { get{
        return AnyView(self)
    }}
}

public enum ComponentStatus:String {
    case initate,
    active,
    passive ,
    ready ,
    update,
    complete ,
    error,
    end
}

open class ComponentObservable: ObservableObject , PageProtocol, Identifiable{
    @Published var status:ComponentStatus = ComponentStatus.initate
    public let id = UUID().description
}

