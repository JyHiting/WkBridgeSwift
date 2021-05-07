//
//  WebViewExample.swift
//  WebContainerSwift_Example
//
//  Created by dh_iMac on 2021/3/25.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import WebKit
import SnapKit
import WkBridgeSwift


class WebViewExample: UIViewController {
    
    var wkWebView:WKWebView?
    var bridge:WkWebJsBridge?
    
    
    override func loadView() {
        
        self.view = UIView()
        self.view.backgroundColor = .brown
        let menus = UIView()
        menus.backgroundColor = .yellow
        self.view.addSubview(menus)
        menus.snp_makeConstraints { (make) in
            make.left.top.right.equalTo(self.view)
            make.height.equalTo(60)
        }
        
        let takeSnapshot = UIButton()
        takeSnapshot.setTitle("截图", for: .normal)
        takeSnapshot.addTarget(self, action: #selector(takeSnapshotClick), for: .touchUpInside)
        takeSnapshot.backgroundColor = .lightGray
        takeSnapshot.setTitleColor(.yellow, for: .normal)
        
        menus.addSubview(takeSnapshot)
        takeSnapshot.snp_makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.size.equalTo(CGSize(width: 120, height: 45))
            make.centerY.equalTo(menus)
        }
        
        let config = WKWebViewConfiguration()
        let wk = WKWebView(frame: .zero, configuration: config)
        wk.uiDelegate = self
        //处理自己老项目的逻辑和使用bridge之后的操作不干扰
        //wk的循环引用问题大家都知道，自己项目可以继续使用configuration.userContentController.add挂载自己的方法
        //自己项目原有的方式挂载的方法要自己控制内存泄漏的问题，通过bridge的方式注册的方法bridge自己控制
        //wk.configuration.userContentController.add(self, name: "your_app_func")
        wkWebView = wk
        self.view.addSubview(wk)
        
        wk.snp_makeConstraints { (make) in
            make.left.bottom.right.equalTo(self.view)
            make.top.equalTo(menus.snp_bottom)
        }

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
        
        //MARK:-- post body丢失问题默认已经处理，该bridge会自动处理body丢失问题
        //        var req = URLRequest(url: URL(string: "http://10.68.252.191:3000/wkissues/postapi")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        //        req.httpMethod = "post"
        //        let paras:[String:Any] = ["name":"jack","age":88]
        //        req.httpBody = try? JSONSerialization.data(withJSONObject: paras, options: [])
        //        wkWebView?.load(req)
        
        //MARK:-- 加载普通url
        let req = URLRequest(url: URL(string: "https://developer.mozilla.org/zh-CN/docs/Web/HTML/Element/form")!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        wkWebView?.load(req)
        
        //MARK:-- 使用示例代码
//            let exampleHtml = URL(fileURLWithPath: Bundle.main.path(forResource: "example", ofType: "html")!)
//            wkWebView?.load(URLRequest(url: exampleHtml))
        //iOS调用js挂载服务示例代码
        //        iOSCallJsFunc()
        
    }
    
    //MARK:-- iOS调用js方法
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
    
    //MARK:-- 截屏
    @objc func takeSnapshotClick() -> Void {
        bridge?.takeSnapshot({ (img) in
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("WebViewExample deinit")
    }
}
//MARK:--自己原有项目可以通过沿用老的继续使用和bridge不冲突
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


