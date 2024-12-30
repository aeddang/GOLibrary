//
//  Log.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/10.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import os.log

public protocol Log {
    static var tag:String { get }
    static var lv:Int { get }
}
public struct LogManager  {
    nonisolated(unsafe) static var isLaunchTrace = false
    static nonisolated(unsafe) fileprivate(set) var memoryLog:String = ""
    static nonisolated(unsafe) fileprivate(set) var traceLog:String = ""
    nonisolated(unsafe) static var isMemory = Self.isLaunchTrace
    {
        didSet{
           // Setup().isLogMemory = isMemory 
            if !isMemory {
                Self.memoryLog = ""
            }
        }
    }
}

public extension Log {
    static func log(_ message: String, tag:String? = nil , log: OSLog = .default, type: OSLogType = .default) {
        let t = (tag == nil) ? Self.tag : Self.tag + " -> " + tag!
        os_log("%@ %@", log: log, type: type, t, message)
    }
    
    static func t(_ message: String, tag:String? = nil) {
        if LogManager.isMemory {
            LogManager.traceLog += ("\n" + (tag ?? "Log") + " : " + message)
        }
    }
    
    static func i(_ message: String, tag:String? = nil, lv:Int = 1) {
        if Self.lv < lv {return}
        Self.log(message, tag:tag, log:.default, type:.info )
    }
    
    static func d(_ message: String, tag:String? = nil, lv:Int = 1) {
        if LogManager.isMemory {
            LogManager.memoryLog += ("\n" + (tag ?? "Log") + " : " + message)
        }
        if Self.lv < lv {return}
        #if DEBUG
        Self.log(message, tag:tag, log:.default, type:.debug )
        #endif
    }
    
    static func e(_ message: String, tag:String? = nil, lv:Int = 1) {
        if LogManager.isMemory {
            LogManager.memoryLog += ("\n" + (tag ?? "Log") + " : " + message)
        }
        if Self.lv < lv {return}
        Self.log(message, tag:tag, log:.default, type:.error )
    }
}
public struct PageLog:Log {
    nonisolated(unsafe) public static var tag: String = "[MYTV] Page"
    nonisolated(unsafe) public static var lv: Int = 1
}

public struct ComponentLog:Log {
    nonisolated(unsafe) public static var tag: String = "[MYTV] Component"
    nonisolated(unsafe) public static var lv: Int = 1
}

public struct DataLog:Log {
    nonisolated(unsafe) public static var tag: String = "[MYTV] Data"
    nonisolated(unsafe) public static var lv: Int = 1
}
