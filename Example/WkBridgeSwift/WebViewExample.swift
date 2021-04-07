//
//  WebViewExample.swift
//  WebContainerSwift_Example
//
//  Created by dh_iMac on 2021/3/25.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WebKit

import WkBridgeSwift


class WebViewExample: UIViewController {
    
    var wkWebView:WKWebView?
    var bridge:WkWebJsBridge?
    
    
    override func loadView() {
        
        let config = WKWebViewConfiguration()
        let wk = WKWebView(frame: .zero, configuration: config)
        wk.uiDelegate = self
        //处理自己老项目的逻辑和使用bridge之后的操作不干扰
        //wk的循环引用问题大家都知道，自己项目可以继续使用configuration.userContentController.add挂载自己的方法
        //自己项目原有的方式挂载的方法要自己控制内存泄漏的问题，通过bridge的方式注册的方法bridge自己控制
        //        wk.configuration.userContentController.add(self, name: "your_app_func")
        wkWebView = wk
        self.view = wkWebView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let wk = wkWebView {
            bridge = WkWebJsBridge.bridgeFor(webView: wk)
            //打开日志功能，默认不打开
            bridge?.openLogs()
            //示例代码
            bridge?.register(handler: "dismissSelf", doSomething: { [unowned self] in
                self.dismiss(animated: true, completion: nil)
            })
            //注册无参数无回调方法提供给web端调用
            bridge?.register(handler: "dotask1", doSomething: { [unowned self] in
                self.bridge?.callJsService(name: "alertInfo", paras: "js调用了iOS方法：无参数无回调方法", callback: nil)
            })
            //注册有参数无回调方法提供给web端调用
            bridge?.register(handler: "dotask2", doSomething: { [unowned self] (paras) in
                self.bridge?.callJsService(name: "alertInfo", paras: paras, callback: nil)
            })
            //注册有参数有回调方法提供给web端调用
            bridge?.register(handler: "dotask3", doSomething: { (paras, cb:WkBridgeResponseCallback?) in
                cb!(paras)
            })
            
        }
        let exampleHtml = URL(fileURLWithPath: Bundle.main.path(forResource: "example", ofType: "html")!)
        wkWebView?.load(URLRequest(url: exampleHtml))
        //iOS调用js挂载服务示例代码
//        iOSCallJsFunc()
    }
    
    func iOSCallJsFunc() -> Void {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            //调用js服务该服务不需要参数
            self.bridge?.callJsService(name: "jsservice1")
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 6) {
            //调用js服务该服务需要参数但无回调
            self.bridge?.callJsService(name:"jsservice2", paras: ["name":"jyhiting","age":"10086"])
            
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 9) {
            //调用js服务该服务需要参数且有回调
            self.bridge?.callJsService(name: "jsservice3", paras: ["name":"jyhiting","age":10086], callback: { (res) in
                print("\(res!)")
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("WebViewExample deinit")
    }
}

//自己原有项目可以通过沿用老的继续使用和bridge不冲突
extension WebViewExample:WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
}

extension WebViewExample:WKUIDelegate{
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController.init(title: "alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        completionHandler()
    }
}
extension WebViewExample{
    func json2String(paras:Any) -> String? {
        
        guard JSONSerialization.isValidJSONObject(paras) else {
            return nil
        }
        let data : Data = try! JSONSerialization.data(withJSONObject: paras, options: [])
        let string = String(data: data, encoding: .utf8)
        return string
    }
}


