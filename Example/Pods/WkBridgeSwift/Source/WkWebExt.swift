//
//  WkWebExt.swift
//  WkBridgeSwift
//
//  Created by dh_iMac on 2021/4/29.
//

import WebKit

extension WKWebView{
        
    class func wkWebHook() -> Void {
        DispatchQueue.doItOnce(token: "WKWebView_initializeMethod") {
            
            let originalMethod = class_getInstanceMethod(self, #selector(load(_:)))
            let swizzledMethod = class_getInstanceMethod(self, #selector(wk_load(_:)))
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
        
        
    }
    @objc func wk_load(_ request: URLRequest) -> WKNavigation? {
        
        if let _httpMethod = request.httpMethod,let _httpBody = request.httpBody {
            if _httpMethod.uppercased() == "POST" {
                let url = request.url,paras = String(data: _httpBody, encoding: .utf8)
                let jsStr  = """
                            var url = '\(url!)';
                            var params = \(paras!);
                            var form = document.createElement('form');
                            form.setAttribute('method', 'post');
                            form.setAttribute('action', url);
                            for(var key in params) {
                                if(params.hasOwnProperty(key)) {
                                    var field = document.createElement('input');
                                    field.setAttribute('type', 'hidden');
                                    field.setAttribute('name', key);
                                    field.setAttribute('value', params[key]);
                                    form.appendChild(field);
                                }
                            }
                            document.body.appendChild(form);
                            form.submit();
                """
                self.evaluateJavaScript(jsStr) { (data:Any?, error:Error?) in
                    if let _error = error{
                        debugPrint("-------------------WkWebJsBridgeError:-----------------")
                        debugPrint(_error)
                    }
                }
                return nil
            }
        }
        return wk_load(request)
    }
    
}

extension DispatchQueue{
    
    private static var _onceTracker = [String]()
    
    fileprivate class func doItOnce(token:String,task:()->()) -> Void {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        task()
    }
    
    
    func async(block: @escaping ()->()) {
        self.async(execute: block)
    }
    
    func after(time: DispatchTime, block: @escaping ()->()) {
        self.asyncAfter(deadline: time, execute: block)
        
    }
}
