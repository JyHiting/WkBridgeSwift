//
//  MuWkWebiOSHandlerProtocol.swift
//  WebContainerSwift
//
//  Created by dh_iMac on 2021/3/22.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

public typealias WkBridgeResponseCallback = (_ response:Any?)->()
public typealias WkBridgeLogicalProcessingEntry = (_ paras:Any?,_ responseCallback:WkBridgeResponseCallback?)->Void

protocol WkWebiOSHandlerProtocol {
    
    static func doSomething(_ paras:Any?,_ responseCallback:WkBridgeResponseCallback?) -> Void
    
}
