//
//  WkWebJsBridgeLog.swift
//  WebContainerSwift
//
//  Created by dh_iMac on 2021/3/25.
//  Copyright © 2021 CocoaPods. All rights reserved.
//


extension WkWebJsBridge{
    
    static var isOpenLogs = false
    
    /// 打开日志功能默认不打开
    /// 输出一些常规的警告错误信息
    /// - Returns:
    public  func openLogs() -> Void {
        Self.isOpenLogs = true
    }
    
    /// 关闭日志功能
    /// - Returns: 
    public func closeLogs() -> Void {
        Self.isOpenLogs = false
    }
    
    func JsBridgeLog(message:Any) -> Void {
        
        guard Self.isOpenLogs else {
            return
        }
        debugPrint("-------------------WkWebJsBridgeLog:-----------------")
        debugPrint(message)
    }
    
    func JsBridgeWarning(warning:Any) -> Void {
        
        guard Self.isOpenLogs else {
            return
        }
        debugPrint("-------------------WkWebJsBridgeWarning:-----------------")
        debugPrint(warning)
    }
    func JsBridgeError(error:Any) -> Void {
        
        guard Self.isOpenLogs else {
            return
        }
        debugPrint("-------------------WkWebJsBridgeError:-----------------")
        debugPrint(error)
    }
}
