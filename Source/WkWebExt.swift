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
    func wkTakeSnapshot(_ snapshot:((UIImage?)->())?) -> Void {
        
        DispatchQueue.main.async { [self] in

            let mask = self.snapshotView(afterScreenUpdates: false)!
            mask.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: mask.bounds.size.width, height: mask.bounds.size.height)
            guard let _superview = self.superview else {
                return
            }
            _superview.addSubview(mask)
                        
            let oldFrame = self.frame
            let oldOffset = self.scrollView.contentOffset
            let contentSize = self.scrollView.contentSize
            let screenCount = Int(ceilf(Float(contentSize.height/self.scrollView.bounds.size.height)))

            self.frame = CGRect(origin: .zero, size: contentSize)
            self.scrollView.contentOffset = .zero

            UIGraphicsBeginImageContextWithOptions(contentSize, true, UIScreen.main.scale)
            let content = UIGraphicsGetCurrentContext()
            
                
            var curIdx = 0
            let _height = _superview.bounds.size.height
            
            repeat{

                let pageIdx = curIdx
                OperationQueue.main.addOperation {

                    var myFrame = self.frame;
                    myFrame.origin.y = -(CGFloat((pageIdx))*_height);
                    self.frame = myFrame;
                    self.layer.render(in: content!)
                }

                curIdx += 1

            }while(curIdx < screenCount)

            OperationQueue.main.addOperation {

                let snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                self.frame = oldFrame;
                self.scrollView.contentOffset = oldOffset;
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


