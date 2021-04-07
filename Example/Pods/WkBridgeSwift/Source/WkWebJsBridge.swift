//
//  MuWkWebJsBridge.swift
//  WebContainerSwift
//
//  Created by dh_iMac on 2021/3/22.
//

import WebKit

public class WkWebJsBridge: NSObject {
    
    weak var webView:WKWebView?
    private var handlers:Dictionary<String, Any> = [:]
    private var jsCallbacks:Dictionary<String,WkBridgeResponseCallback> = [:]
    
    public static func bridgeFor(webView:WKWebView) -> WkWebJsBridge {
        
        let webBridge = WkWebJsBridge(wk: webView)
        let injectJs = _JsBridgeInjectJs()
        let handlerProxy = WkWebHandlerProxy(scriptDelegate: webBridge)
        let userScript = WKUserScript(source: injectJs, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        
        webView.configuration.userContentController.addUserScript(userScript)
        webView.configuration.userContentController.add(handlerProxy, name: "$jsCalliOSFunc")
        webView.configuration.userContentController.add(handlerProxy, name: "$jsCallback2iOS")
        webView.configuration.userContentController.add(handlerProxy, name: "$jsErrorOccur")
        return webBridge
    }
    
    /// 注册无参数方法
    /// - Parameters:
    ///   - handler: 注册方法名
    ///   - doSomething: 执行方法
    /// - Returns: 无
    public func register(handler:String,doSomething:@escaping ()->Void)  -> Void {
        handlers[handler] = doSomething
    }
    
    /// 注册有参数方法
    /// - Parameters:
    ///   - handler: 注册方法名
    ///   - doSomething: 执行方法
    /// - Returns: 无
    public func register(handler:String,doSomething:@escaping (_ paras:Any?)->Void)  -> Void {
        handlers[handler] = doSomething
    }
    
    
    /// 注册有参数有回调方法
    /// - Parameters:
    ///   - handler: 注册方法名
    ///   - doSomething: 执行方法
    /// - Returns: 无
    public func register(handler:String,doSomething:@escaping (_ paras:Any?,_ responseCallback:WkBridgeResponseCallback?)->Void)  -> Void {
        handlers[handler] = doSomething
    }
    
    /// 调用js注册的方法
    /// - Parameters:
    ///   - name: js 方法名
    ///   - paras: 可选的传入参数
    ///   - callback: 可选的回调函数
    /// - Returns: 无
    public func callJsService(name:String,paras:Any? = nil,callback:WkBridgeResponseCallback? = nil) -> Void {
        
        let paras = _javascriptstring(paras: paras)
        var jsStr = "_jsServiceCallBackDispatcher(\(paras),"
        jsStr += "\"\(name)\""
        if let _callback = callback {
            //保存js的回调
            let cbId = UUID().uuidString
            jsStr += ",\"\(cbId)\""
            jsCallbacks[cbId] = _callback
        }else{
            jsStr += ",null"
        }
        jsStr += ")"
        _executeJsOnMain(js: jsStr)
    }
    
    init(wk:WKWebView) {
        webView = wk
    }
    
    deinit {
        if let _web = webView {
            let allScripts:[WKUserScript] = _web.configuration.userContentController.userScripts
            let newScripts:[WKUserScript] = allScripts.map {
                $0.copy() as! WKUserScript
            }
            _web.configuration.userContentController.removeAllUserScripts()
            for userScript in newScripts {
                let source = userScript.source
                if !source.contains("JyHiting__JsBridgeInjectJs") {
                    _web.configuration.userContentController.addUserScript(userScript)
                }
            }
            _web.configuration.userContentController.removeScriptMessageHandler(forName: "$jsCalliOSFunc")
            _web.configuration.userContentController.removeScriptMessageHandler(forName: "$jsCallback2iOS")
            _web.configuration.userContentController.removeScriptMessageHandler(forName: "$jsErrorOccur")
        }
    }
    
}

extension WkWebJsBridge:WKScriptMessageHandler{
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == "$jsCalliOSFunc" {
            let body = message.body as? Dictionary<String,Any>
            guard let iOSApi = body?["$iOSApi"] as? String  else {
                //无法解析调用接口信息，或未指定调用接口
                JsBridgeError(error: "无法解析调用接口信息，或未指定调用接口，请排查接口信息是否正确")
                return
            }
            var resCallback:WkBridgeResponseCallback?
            if let callbackId = body?["$iOSApiCallbackId"] as? String {
                //回调存在
                resCallback = { (_ response:Any?)->() in
                    let _callbackId = callbackId
                    //response to string
                    let res = self._javascriptstring(paras: response)
                    var jsStr = "window._nativeServiceCallBackDispatcher(\(res),"
                    jsStr += "\"\(_callbackId)\""
                    jsStr += ")"
                    self._executeJsOnMain(js: jsStr)
                }
            }
            var paras:Any?
            if let _apiParas = body?["$iOSApiParas"] {
                //接口参数存在
                paras = _apiParas
            }
            guard let handler = handlers[iOSApi]else {
                //接口对应处理函数查询不到
                //排查是否挂在此接口对应的处理函数
                JsBridgeError(error: "接口对应处理函数查询不到，请排查是否挂在此接口对应的处理函数")
                return
            }
            
            if paras == nil && resCallback == nil {
                guard let _handler = handler as? () ->Void  else {
                    //调用函数转换异常
                    //需要排查调用函数和本地注册函数是否一致
                    JsBridgeError(error: "调用函数转换异常，需要排查调用函数和本地注册函数是否一致")
                    return
                }
                _handler()
            }else if resCallback == nil{
                guard let _handler = handler as? (Any?) ->Void else {
                    //调用函数转换异常
                    //需要排查调用函数和本地注册函数是否一致
                    JsBridgeError(error: "调用函数转换异常，需要排查调用函数和本地注册函数是否一致")
                    return
                }
                _handler(paras!)
            }else{
                guard let _handler = handler as? (Any?,WkBridgeResponseCallback?) ->Void else {
                    //调用函数转换异常
                    //需要排查调用函数和本地注册函数是否一致
                    JsBridgeError(error: "调用函数转换异常，需要排查调用函数和本地注册函数是否一致")
                    return
                }
                _handler(paras!,resCallback!)
            }
            
        }else if message.name == "$jsCallback2iOS"{
            let body = message.body as? Dictionary<String,Any>
            if let jsCallbackId = body?["jsCallbackId"] as? String {
                guard let callback = jsCallbacks[jsCallbackId] else {
                    return
                }
                callback(body?["res"])
                jsCallbacks.removeValue(forKey: jsCallbackId)
            }
        }else if message.name == "$jsErrorOccur"{
            JsBridgeWarning(warning: "js 异常：\(message.body)")
        }
    }
    
}

extension WkWebJsBridge{
    private func _javascriptstring(paras:Any?)->String{
        var jsStr = ""
        if let _paras = paras {
            if _paras is String {
                //string
                jsStr += "\"\(_paras as! String)\""
            }else if _paras is NSNumber{
                //number
                jsStr += "\(_paras as! NSNumber)"
            }else if _paras is Dictionary<String, Any> || _paras is Array<Any>{
                //array dic
                guard JSONSerialization.isValidJSONObject(_paras) else {
                    //参数不合法
                    return ""
                }
                let _jsonData = try? JSONSerialization.data(withJSONObject: _paras, options: [])
                guard let jsondata = _jsonData  else {
                    //json 序列化异常
                    return ""
                }
                let _jsonStr = String(data: jsondata, encoding: .utf8)
                guard let jsonStr = _jsonStr  else {
                    //json to string 异常
                    return ""
                }
                
                jsStr += jsonStr
            }else{
                //非基本类型参数
                //非法
                JsBridgeError(error: "参数传递错误，只支持基本类型参数或者基本类型参数组合")
            }
            
        }else{
            //null
            jsStr += "null"
        }
        return jsStr
    }
    private func _executeJsOnMain(js:String)->Void{
        if Thread.isMainThread {
            self.webView?.evaluateJavaScript(js, completionHandler: { (data, error) in
                
            })
        }else{
            DispatchQueue.main.async {
                self.webView?.evaluateJavaScript(js, completionHandler: { (data, error) in
                    
                })
            }
        }
    }
}

