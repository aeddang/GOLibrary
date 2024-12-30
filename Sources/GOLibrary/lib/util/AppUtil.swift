//
//  AppUtil.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/11.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration.CaptiveNetwork
import NetworkExtension
import AdSupport
import CoreTelephony

public struct AppUtil{
    public static var version: String {
        guard let dictionary = Bundle.main.infoDictionary,
            let v = dictionary["CFBundleShortVersionString"] as? String
            else {return ""}
            return v
    }
    
    public static var build: String {
        guard let dictionary = Bundle.main.infoDictionary,
            let b = dictionary["CFBundleVersion"] as? String else {return "1"}
            return b
    }
    
    public static var model: String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulatorModelIdentifier
        }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    
    public static var idfa: String {
        //isAdvertisingTrackingEnabled iOS14에서부터 deprecated되서 사용못함
//        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
//            let identifier = ASIdentifierManager.shared().advertisingIdentifier
//            return identifier.uuidString
//        }
//        return ""
        let identifier = ASIdentifierManager.shared().advertisingIdentifier
        if identifier.uuidString != "00000000-0000-0000-0000-000000000000" {
            return identifier.uuidString
        }
        return ""
    }
    
    @MainActor
    public static func getWindow()->UIWindow?{
        guard let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        guard let firstWindow = firstScene.windows.first else {
            return nil
        }
        return firstWindow
    }
    
    @MainActor
    public static func goAppStore(){
        let path = "https://itunes.apple.com/kr/app/apple-store/id1255487920?mt=8"
        Self.openURL(path)
    }
    
    @MainActor
    public static func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    @MainActor
    public static func isPad() -> Bool {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            return true
        }
        return false
    }
    @MainActor
    public static func isWideScreen() -> Bool {
        if UIScreen.main.bounds.size.width > 1300 {
            return true
        }
        return false
    }
    
    @MainActor
    public static func openURL(_ path:String) {
        guard let url = URL(string: path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? path) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    @MainActor
    public static func openEmail(_ email:String) {
        if let url = URL(string: "mailto:\(email)") {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
          } else {
            UIApplication.shared.openURL(url)
          }
        }
    }
    
    public static func getYearRange(len:Int , offset:Int = 0 )->[Int]{
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: Date())
        let range = 0...len
        let year  = (components.year ?? 2020) - offset
        let ranges = range.map{ (year - $0) }
        return ranges
    }
    public static func networkTimeDate() -> Date {
        return Date()
    }
    
    public static func networkTime() -> Int {
        return Int(networkTimeDate().timeIntervalSince1970)
    }

    public static func getTime(fromInt: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(fromInt))
        return Self.getTime(fromDate: date)
    }

    public static func getTime(fromDate: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        fmt.timeZone = TimeZone.current
        return fmt.string(from: fromDate)
    }
    
    public static func getTime(fromDate: Date, format: String) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = format
        fmt.timeZone = TimeZone.current
        return fmt.string(from: fromDate)
    }
    
    public static func getDate(dateString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.date(from: dateString)
    }
    
    @MainActor
    public static func goAppSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }
    
    public static func getNetworkInfo(compleationHandler: @escaping ([String: Any])->Void){
        var currentWirelessInfo: [String: Any] = [:]
        if #available(iOS 14.0, *) {
            NEHotspotNetwork.fetchCurrent { network in
                guard let network = network else {
                    compleationHandler([:])
                    return
                }
                let bssid = network.bssid
                let ssid = network.ssid
                currentWirelessInfo = ["BSSID ": bssid, "SSID": ssid, "SSIDDATA": "<54656e64 615f3443 38354430>"]
                compleationHandler(currentWirelessInfo)
            }
        }
        else {
            #if !TARGET_IPHONE_SIMULATOR
            guard let interfaceNames = CNCopySupportedInterfaces() as? [String] else {
                compleationHandler([:])
                return
            }
            guard let name = interfaceNames.first, let info = CNCopyCurrentNetworkInfo(name as CFString) as? [String: Any] else {
                compleationHandler([:])
                return
            }
            currentWirelessInfo = info
            #else
            currentWirelessInfo = ["BSSID ": "c8:3a:35:4c:85:d0", "SSID": "Tenda_4C85D0", "SSIDDATA": "<54656e64 615f3443 38354430>"]
            #endif
            compleationHandler(currentWirelessInfo)
        }
    }
    
    public static func getSSID() -> String? {
        let interfaces = CNCopySupportedInterfaces()
        if interfaces == nil { return nil }
        guard let interfacesArray = interfaces as? [String] else { return nil }
        if interfacesArray.count <= 0 { return nil }
        for interfaceName in interfacesArray where interfaceName == "en0" {
            let unsafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName as CFString)
            if unsafeInterfaceData == nil { return nil }
            guard let interfaceData = unsafeInterfaceData as? [String: AnyObject] else { return nil }
            return interfaceData["SSID"] as? String
        }
        return nil
    }
    
    public static func getIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                guard let interface = ptr?.pointee else { return "" }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    let name: String = String(cString: (interface.ifa_name))
                    if  name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t((interface.ifa_addr.pointee.sa_len)), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address 
    }
    
    public static func getSafeString(_ s:String?,  defaultValue:String = "") -> String {
        guard let s = s else { return defaultValue }
        return s.isEmpty ? defaultValue : s
    }
    public static func getSafeInt(bool:Bool?,  defaultValue:Int = 1) -> Int {
        guard let v = bool else { return defaultValue }
        return v ? 1 : 0
    }
    
    public static func getJsonString(dic:[String:Any])->String?{
        if JSONSerialization.isValidJSONObject(dic) {
            do{
                let data =  try JSONSerialization.data(withJSONObject: dic , options: [])
                let jsonString = String(decoding: data, as: UTF8.self)
                DataLog.d("stringfy : " + jsonString, tag: "getJsonString")
                return jsonString
            } catch {
                DataLog.e("stringfy : JSONSerialization " + error.localizedDescription, tag: "getJsonString")
                return nil
            }
        }
        DataLog.e("stringfy : JSONSerialization isValidJSONObject error", tag: "getJsonString")
        return nil
    }
    
    public static func getJsonParam(jsonString: String) -> [String: Any]? {
        guard let data = jsonString.data(using: .utf8) else {
            DataLog.e("parse : jsonString data error", tag: "getJsonParam")
            return nil
        }
        do{
            let value = try JSONSerialization.jsonObject(with: data , options: [])
            guard let dictionary = value as? [String: Any] else {
                DataLog.e("parse : dictionary error", tag: "getJsonParam")
                return nil
            }
            return dictionary
        } catch {
           DataLog.e("parse : JSONSerialization " + error.localizedDescription, tag: "getJsonParam")
           return nil
        }
    }
    
    public static func getJsonArray(jsonString: String) -> [Any]? {
        guard let data = jsonString.data(using: .utf8) else {
            DataLog.e("parse : jsonString data error", tag: "getJsonArray")
            return nil
        }
        do{
            let value = try JSONSerialization.jsonObject(with: data , options: [])
            guard let arr = value as? [Any] else {
                DataLog.e("parse : array error", tag: "getJsonArray")
                return nil
            }
            return arr
        } catch {
           DataLog.e("parse : JSONSerialization " + error.localizedDescription, tag: "getJsonArray")
           return nil
        }
    }
    
    public static func getQurry(url: String, key:String) -> String? {
        if let components = URLComponents(string: url) {
            if let queryItems = components.queryItems {
                if let item = queryItems.first(where: {$0.name == key}) {
                    return item.value 
                } else {
                    return nil
                }
            }
        }
        return nil
    }
    
    public static func getQurryString(dic:[String:String], prefix:String = "?") -> String {
        if !dic.isEmpty {
            var query = dic.keys.reduce("", {
                let v = dic[$1] ?? ""
                return $0 + "&" + $1 + "=" + v
            })
            query.removeFirst()
            return prefix + query
        } else {
            return prefix
        }
    }

    @MainActor
    public static func setAutolayoutSamesize(item: UIView, toitem: UIView) {
        item.translatesAutoresizingMaskIntoConstraints = false
        
        let top = NSLayoutConstraint(item: item,
                                     attribute: NSLayoutConstraint.Attribute.centerX,
                                     relatedBy: NSLayoutConstraint.Relation.equal,
                                     toItem: toitem,
                                     attribute: NSLayoutConstraint.Attribute.centerX,
                                     multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: item,
                                        attribute: NSLayoutConstraint.Attribute.width,
                                        relatedBy: NSLayoutConstraint.Relation.equal,
                                        toItem: toitem,
                                        attribute: NSLayoutConstraint.Attribute.width,
                                        multiplier: 1.0, constant: 0.0)
        let left  = NSLayoutConstraint(item: item,
                                       attribute: NSLayoutConstraint.Attribute.centerY,
                                       relatedBy: NSLayoutConstraint.Relation.equal,
                                       toItem: toitem,
                                       attribute: NSLayoutConstraint.Attribute.centerY,
                                       multiplier: 1.0, constant: 0.0)
        let right = NSLayoutConstraint(item: item,
                                       attribute: NSLayoutConstraint.Attribute.height,
                                       relatedBy: NSLayoutConstraint.Relation.equal,
                                       toItem: toitem,
                                       attribute: NSLayoutConstraint.Attribute.height,
                                       multiplier: 1.0, constant: 0.0)
        let arrconst = [right, left, top, bottom]
        toitem.addConstraints(arrconst)
    }
    
    
    public static func binarySearch<T: Comparable>(_ a: [T], key: T, range: Range<Int>) -> Int? {
        if range.lowerBound >= range.upperBound {
            return nil
        } else {
            let midIndex = range.lowerBound + (range.upperBound - range.lowerBound) / 2
            if a[midIndex] > key {
                return binarySearch(a, key: key, range: range.lowerBound ..< midIndex)
            } else if a[midIndex] < key {
                return binarySearch(a, key: key, range: midIndex + 1 ..< range.upperBound)
            } else {
                return midIndex
            }
        }
    }
    
    public static func hasDynamicIsland(model:String)->Bool {
        switch model {
        case "iPhone14,7", "iPhone14,8","iPhone15,2", "iPhone15,3": return true
        default : return false
        }
    }
    
    public static func isCarrierInformationSkt() -> Bool  {
        let netinfo = CTTelephonyNetworkInfo()
        var isSkt = true // 16버전 체크 불가능 기본갑설정
       
        if let carriers = netinfo.serviceSubscriberCellularProviders{
            for carrier in carriers {
                let ctcarrier = carrier.value
                if ctcarrier.carrierName?.lowercased() == "SK Telecom".lowercased() && ctcarrier.isoCountryCode?.isEmpty == false {
                    isSkt = true
                }
            }
        }
        return isSkt
    }
    
    public static func switchDeviceOrientationToMask(_ interface:UIInterfaceOrientation) -> UIInterfaceOrientationMask{
        switch interface{
        case .landscapeRight: return .landscapeRight
        case .landscapeLeft: return .landscapeLeft
        case .portrait: return .portrait
        case .portraitUpsideDown : return .portraitUpsideDown
        default: return .all
        }
    }
    public static func switchDeviceOrientationToString(_ interface:UIInterfaceOrientation) -> String{
        switch interface{
        case .landscapeRight: return "Orientation landscapeRight"
        case .landscapeLeft: return "Orientation landscapeLeft"
        case .portrait: return "Orientation portrait"
        case .portraitUpsideDown : return "Orientation portraitUpsideDown"
        default: return "Orientation all"
        }
    }
    
    public static func switchDeviceMaskToOrientation(_ mask:UIInterfaceOrientationMask) -> UIInterfaceOrientation{
        switch mask{
        case .landscapeRight: return .landscapeRight
        case .landscapeLeft: return .landscapeLeft
        case .landscape: return .landscapeRight
        case .portrait: return .portrait
        case .allButUpsideDown : return .portrait
        case .portraitUpsideDown : return .portraitUpsideDown
        default: return .unknown
        }
    }
    
    public static func switchDeviceMaskToString(_ mask:UIInterfaceOrientationMask) -> String{
        switch mask{
        case .landscapeRight: return "Mask landscapeRight"
        case .landscapeLeft: return "Mask landscapeLeft"
        case .landscape: return "Mask landscapeRight"
        case .portrait: return "Mask portrait"
        case .allButUpsideDown : return "Mask portrait"
        case .portraitUpsideDown : return "Mask portraitUpsideDown"
        default: return "Mask unknown"
        }
    }
    
    /*
    static func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
        #if os(iOS)
        switch identifier {
        case "iPod5,1":                                       return "iPod touch (5th generation)"
        case "iPod7,1":                                       return "iPod touch (6th generation)"
        case "iPod9,1":                                       return "iPod touch (7th generation)"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
        case "iPhone4,1":                                     return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                        return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                        return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
        case "iPhone7,2":                                     return "iPhone 6"
        case "iPhone7,1":                                     return "iPhone 6 Plus"
        case "iPhone8,1":                                     return "iPhone 6s"
        case "iPhone8,2":                                     return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
        case "iPhone11,2":                                    return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
        case "iPhone11,8":                                    return "iPhone XR"
        case "iPhone12,1":                                    return "iPhone 11"
        case "iPhone12,3":                                    return "iPhone 11 Pro"
        case "iPhone12,5":                                    return "iPhone 11 Pro Max"
        case "iPhone13,1":                                    return "iPhone 12 mini"
        case "iPhone13,2":                                    return "iPhone 12"
        case "iPhone13,3":                                    return "iPhone 12 Pro"
        case "iPhone13,4":                                    return "iPhone 12 Pro Max"
        case "iPhone14,4":                                    return "iPhone 13 mini"
        case "iPhone14,5":                                    return "iPhone 13"
        case "iPhone14,2":                                    return "iPhone 13 Pro"
        case "iPhone14,3":                                    return "iPhone 13 Pro Max"
        case "iPhone14,7":                                    return "iPhone 14"
        case "iPhone14,8":                                    return "iPhone 14 Plus"
        case "iPhone15,2":                                    return "iPhone 14 Pro"
        case "iPhone15,3":                                    return "iPhone 14 Pro Max"
        case "iPhone8,4":                                     return "iPhone SE"
        case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
        case "iPhone14,6":                                    return "iPhone SE (3rd generation)"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":      return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":                 return "iPad (3rd generation)"
        case "iPad3,4", "iPad3,5", "iPad3,6":                 return "iPad (4th generation)"
        case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
        case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
        case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
        case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
        case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
        case "iPad13,18", "iPad13,19":                        return "iPad (10th generation)"
        case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
        case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
        case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
        case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
        case "iPad13,16", "iPad13,17":                        return "iPad Air (5th generation)"
        case "iPad2,5", "iPad2,6", "iPad2,7":                 return "iPad mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
        case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
        case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
        case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
        case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
        case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
        case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
        case "iPad14,3", "iPad14,4":                          return "iPad Pro (11-inch) (4th generation)"
        case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
        case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
        case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
        case "iPad14,5", "iPad14,6":                          return "iPad Pro (12.9-inch) (6th generation)"
        case "AppleTV5,3":                                    return "Apple TV"
        case "AppleTV6,2":                                    return "Apple TV 4K"
        case "AudioAccessory1,1":                             return "HomePod"
        case "AudioAccessory5,1":                             return "HomePod mini"
        case "i386", "x86_64", "arm64":                       return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
        default:                                              return identifier
        }
        #elseif os(tvOS)
        switch identifier {
        case "AppleTV5,3": return "Apple TV 4"
        case "AppleTV6,2": return "Apple TV 4K"
        case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
        default: return identifier
        }
        #endif
    }
    */
}

