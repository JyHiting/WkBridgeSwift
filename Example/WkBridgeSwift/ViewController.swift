//
//  ViewController.swift
//  WebContainerSwift
//
//  Created by 1575792978@qq.com on 03/09/2021.
//  Copyright (c) 2021 1575792978@qq.com. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let bridgeBt = UIButton(frame: CGRect(x: 120, y: 120, width: 120, height: 60))
        bridgeBt.backgroundColor = .gray
        bridgeBt.setTitle("Wk bridge", for: .normal)
        bridgeBt.setTitleColor(.darkText, for: .normal)
        bridgeBt.addTarget(self, action: #selector(entryBridge), for: .touchUpInside)
        self.view.addSubview(bridgeBt)
    }
    
    @objc func entryBridge() -> Void {
        let web = WebViewExample()
        self.present(web, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}




