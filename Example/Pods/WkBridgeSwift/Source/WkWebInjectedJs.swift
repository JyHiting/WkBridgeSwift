//
//  MuWkWebInjectedJs.swift
//  WebContainerSwift
//
//  Created by dh_iMac on 2021/3/23.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

extension WkWebJsBridge{
    static func _JsBridgeInjectJs() -> String {
        let js = """
        !function () {
        //JyHiting__JsBridgeInjectJs
        window._nativeServiceCallBackDispatcher = function (res, callbackId) {
            
            try {
                const callbackInfo = window.WkBridgeSwift.callbacklist[callbackId];
                if (callbackInfo) {
                    const scope = callbackInfo.scope;
                    const cb = callbackInfo.callback;
                    cb.bind(scope)(res);
                    delete window.WkBridgeSwift.callbacklist[callbackId];
                }
            } catch (error) {
                if (window.webkit) {
                    window.webkit.messageHandlers.$jsErrorOccur.postMessage(error.message)
                }
                console.error(error);
            }

        };
        window._jsServiceCallBackDispatcher = function (paras, name, jsCallbackId) {
            
            try {
                const serviceInfo = window.WkBridgeSwift.jsServices[name]
                if (serviceInfo) {
                    const scope = serviceInfo.scope;
                    const service = serviceInfo.service;
                    if (jsCallbackId) {
                        //need callback to ios
                        //init callback
                        let callback = function (res) {
                            if (window.webkit) {
                                window.webkit.messageHandlers.$jsCallback2iOS.postMessage({ res: res, jsCallbackId: jsCallbackId })
                            } else {
                                console.error("该平台不支持：window.webkit.messageHandlers");
                            }
                        }
                        service.bind(scope)(paras, callback);
                    } else {
                        service.bind(scope)(paras);
                    }
                } else {
                    //js 注册服务查找异常
                    if (window.webkit) {
                        window.webkit.messageHandlers.$jsErrorOccur.postMessage(name + "所注册的服务不存在")
                    } else {
                        console.error("该平台不支持：window.webkit.messageHandlers");
                    }
                }
            } catch (error) {
                if (window.webkit) {
                    window.webkit.messageHandlers.$jsErrorOccur.postMessage(error.message)
                }
                console.error(error);
            }

        }
        window.WkBridgeSwift = {
            invokeiOSService: function () {
                
                try {
                    const args = [];
                    let message = {}
                    args.push(...arguments);
                    if (args.length == 1) {
                        //api only
                        message.$iOSApi = args.shift()
                    } else if (args.length == 2) {
                        //api + paras
                        message.$iOSApi = args.shift()
                        message.$iOSApiParas = args.shift()
                    } else if (args.length == 3) {
                        //api + paras + callback
                        message.$iOSApi = args.shift()
                        message.$iOSApiParas = args.shift()
                        const _cbToken = window.WkBridgeSwift.generateCallbackId();
                        message.$iOSApiCallbackId = _cbToken
                        window.WkBridgeSwift.callbacklist[_cbToken] = {
                            scope: this,
                            callback: args.shift()
                        }
                    }
                    if (window.webkit) {
                        window.webkit.messageHandlers.$jsCalliOSFunc.postMessage(message)
                    } else {
                        console.error("该平台不支持：window.webkit.messageHandlers");
                    }
                } catch (error) {
                    if (window.webkit) {
                        window.webkit.messageHandlers.$jsErrorOccur.postMessage(error.message)
                    }
                    console.error(error);
                }
            },
            registerJsService: function (name, service) {
                window.WkBridgeSwift.jsServices[name] = {
                    scope: this,
                    service: service
                }
            },
            callbacklist: {},
            jsServices: {},
            generateCallbackId: function () {
                function randomId() {
                    return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
                }
                const uuid = randomId() + randomId() + randomId() + randomId() + randomId() + randomId() + randomId() + randomId();
                return uuid;
            }
        }
        }()
        """
        return js
    }
}


