//
//   WhereverYouCanGo.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/03.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

public class IwillGo:PageProtocol{
    private static let pageID = "pageID"
    private static let params = "params"
    private static let isPopup = "isPopup"
    private static let isHome = "isHome"
    
    var page: PageObject? = nil
    public init(with page:PageObject? = nil) {
        self.page = page
    }
    
    public func stringfy()-> String?{
        guard let value = page else {
            ComponentLog.e("stringfy : page is nil", tag: self.tag)
            return nil
        }
        var dic = [String:Any]()
        dic[IwillGo.pageID] = value.pageID
        dic[IwillGo.params] = value.params
        dic[IwillGo.isPopup] = value.isPopup
        dic[IwillGo.isHome] = value.isHome
        let jsonString = AppUtil.getJsonString(dic: dic)
        return jsonString
    }
    
    public func qurry()-> String?{
        guard let value = page else {
            ComponentLog.e("qurry : page is nil", tag: self.tag)
            return nil
        }
        var qurryString =
        IwillGo.pageID + "=" + value.pageID +
        "&" + IwillGo.isPopup + "=" + value.isPopup.description +
        "&" + IwillGo.isHome + "=" + value.isHome.description +
        "&" + "id" + "=" + value.id
        if let params = value.params {
            for (k, v) in params {
                var str = v as? String
                if str == nil {
                    str = (v as? Bool)?.description
                }
                if str == nil {
                    str = (v as? Int)?.description
                }
                qurryString += "&" + k + "=" + (str ?? "" )
            }
        }
        ComponentLog.d("qurry : " + qurryString, tag: self.tag)
        return qurryString
    }
    
    public func parse(jsonString: String) -> IwillGo? {
        guard let data = jsonString.data(using: .utf8) else {
            ComponentLog.e("parse : jsonString data error", tag: self.tag)
            return nil
        }
        do{
            let value = try JSONSerialization.jsonObject(with: data , options: [])
            guard let dictionary = value as? [String: Any] else {
                ComponentLog.e("parse : dictionary error", tag: self.tag)
                return nil
            }
            return parse(dictionary: dictionary)
        } catch {
           ComponentLog.e("parse : JSONSerialization " + error.localizedDescription, tag: self.tag)
           return nil
        }
    }
    
    public func parse(qurryString: String) -> IwillGo? {
        var dictionary = [String: Any]()
        var params = [String: Any]()
        let pairs = qurryString.components(separatedBy: "&")
        pairs.forEach { pair in
            let dic = pair.components(separatedBy: "=")
            if dic.count == 2 {
                let key = dic[0]
                let value = dic[1]
                    .replacingOccurrences(of: "+", with: " ")
                    .removingPercentEncoding ?? ""
                switch key {
                case IwillGo.pageID: dictionary[key] = value
                case IwillGo.isPopup: dictionary[key] = value
                case IwillGo.isHome: dictionary[key] = value
                default:
                    params[key] = value
                }
            }
        }
        dictionary[ IwillGo.params ] = params
        return parse(dictionary: dictionary)
    }
    
    public func parse(dictionary: [String: Any]) -> IwillGo? {
        guard let pageID = dictionary[IwillGo.pageID] as? String else {
            ComponentLog.e("parse : pageID nil error", tag: self.tag)
            return nil
        }
        let params = dictionary[IwillGo.params] as? [String:Any]
        let isPopup = dictionary[IwillGo.isPopup] as? String ?? "false"
        let isHome = dictionary[IwillGo.isHome] as? String ?? "false"
        page = PageObject(pageID: pageID, params: params, isPopup: isPopup.toBool(), isHome: isHome.toBool())
        //ComponentLog.d("parse : " + page.debugDescription, tag: self.tag)
        return self
    }
}

public struct WhereverYouCanGo {
    public static func parseIwillGo(jsonString: String) -> IwillGo? {
        return IwillGo().parse(jsonString:jsonString)
    }
    public static func parseIwillGo(json: [String: Any]) -> IwillGo? {
        return IwillGo().parse(dictionary: json)
    }

    public static func parseIwillGo(qurryString: String) -> IwillGo? {
        return IwillGo().parse(qurryString:qurryString)
    }

    public static func stringfyIwillGo( page: PageObject ) -> String?
    {
        return IwillGo(with:page).stringfy()
    }
    
    public static func stringfyIwillGo(
        pageID: PageID,
        params: [String:Any]? = nil,
        isPopup: Bool = false,
        isHome: Bool = false
    ) -> String?
    {
        let page = PageObject(pageID: pageID, params: params, isPopup: isPopup, isHome: isHome)
        return IwillGo(with:page).stringfy()
    }
    
    public static func qurryIwillGo( page: PageObject ) -> String?
    {
        return IwillGo(with:page).qurry()
    }
    
    public static func qurryIwillGo(
        pageID: PageID,
        params: [String:Any]? = nil,
        isPopup: Bool = false,
        isHome: Bool = false
    ) -> String?
    {
        let page = PageObject(pageID: pageID, params: params, isPopup: isPopup, isHome: isHome)
        return IwillGo(with:page).qurry()
    }
    
}
