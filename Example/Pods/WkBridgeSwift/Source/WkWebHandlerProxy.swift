//
//  WkMessageHandlerProxy.swift
//  WebContainerSwift_Example
//
//  Created by dh_iMac on 2021/3/25.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import WebKit

class WkWebHandlerProxy: NSObject {
    
    weak var delegate:AnyObject?
    init(scriptDelegate:AnyObject ) {
        delegate = scriptDelegate
    }
}

extension WkWebHandlerProxy:WKScriptMessageHandler{
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let proxy = self.delegate {
            if proxy.responds(to: #selector(userContentController(_:didReceive:))) {
                proxy.userContentController(userContentController, didReceive: message)
            }
        }
    }
}

