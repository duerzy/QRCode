//
//  QRScan.swift
//  QRCode
//
//  Created by mac on 16/5/3.
//  Copyright © 2016年 HarveyTsang. All rights reserved.
//

import UIKit

class QRScan: UINavigationController {

    init(cb: @escaping ((String)->Void)){
        super.init(rootViewController: QRScanViewController(cb: cb))
        self.navigationBar.barTintColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func show(){
        currentVC().present(self, animated: true, completion: nil)
    }
    fileprivate func currentVC()->UIViewController{
        var result: UIViewController? = nil
        let window = UIApplication.shared.keyWindow
        if window!.windowLevel != UIWindowLevelNormal{
            
        }
        let frontView = window?.subviews[0]
        let nextResponder = frontView?.next
        if nextResponder!.isKind(of: UIViewController.classForCoder()){
            result = nextResponder as? UIViewController
        }else{
            result = window?.rootViewController
        }
        return result!
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
