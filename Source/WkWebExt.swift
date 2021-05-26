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
    
    private func currentViewController() -> UIViewController {
        
        var vc = UIApplication.shared.keyWindow?.rootViewController
        if (vc?.isKind(of: UITabBarController.self))! {
            vc = (vc as! UITabBarController).selectedViewController
        }else if (vc?.isKind(of: UINavigationController.self))!{
            vc = (vc as! UINavigationController).visibleViewController
        }else if ((vc?.presentedViewController) != nil){
            vc =  vc?.presentedViewController
        }
        return vc!
    }
    
    private func renderCurrentPage(idx:Int,max:Int,content:CGContext,frame:CGRect,height:CGFloat,finished:@escaping ()->())->Void{
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            
            var myFrame = frame
            myFrame.origin.y = -(CGFloat((idx))*height);
            let currentFrame = myFrame
            self.frame = currentFrame
            self.layer.render(in: content)
            if idx < max{
                let nextIdx = idx + 1
                self.renderCurrentPage(idx: nextIdx, max: max, content: content, frame: frame, height: height, finished: finished)
            }else{
                finished()
            }
        }
    }
    
    func wkTakeSnapshot(_ snapshot:((UIImage?)->())?) -> Void {
        
        DispatchQueue.main.async { [self] in
            
            let vc = currentViewController()
            let mask = vc.view.snapshotView(afterScreenUpdates: true)!
            mask.frame = CGRect(x: mask.frame.origin.x, y: mask.frame.origin.y, width: mask.frame.size.width, height: mask.frame.size.height)
            guard let _superview = self.superview else {
                return
            }
            _superview.addSubview(mask)
            
            let oldFrame = self.frame
            let oldOffset = self.scrollView.contentOffset
            let contentSize = self.scrollView.contentSize
            
            self.translatesAutoresizingMaskIntoConstraints = !self.translatesAutoresizingMaskIntoConstraints
            
            let superConstraints = _superview.constraints
            NSLayoutConstraint.deactivate(superConstraints)
            
            
            let _height = self.scrollView.bounds.size.height
            let screenCount = Int(ceilf(Float(contentSize.height/_height)))
            
            UIGraphicsBeginImageContextWithOptions(contentSize, true, UIScreen.main.scale)
            let content = UIGraphicsGetCurrentContext()
            
            let curIdx = 0
            let myFrame = CGRect(origin: .zero, size: contentSize);
            self.scrollView.contentOffset = .zero
            
            renderCurrentPage(idx: curIdx, max: screenCount, content: content!, frame: myFrame, height: _height) {
                
                let snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                self.frame = oldFrame;
                self.scrollView.contentOffset = oldOffset;
                self.translatesAutoresizingMaskIntoConstraints = !self.translatesAutoresizingMaskIntoConstraints
                NSLayoutConstraint.activate(superConstraints)
            
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    mask.removeFromSuperview()
                    if let _snapshot = snapshot{
                        _snapshot(snapshotImage)
                    }
                }
            }
        }
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


