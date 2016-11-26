//
//  ViewController.swift
//  QRCodeScanAndCreate
//
//  Created by mac on 2016/11/25.
//  Copyright © 2016年 HarveyTsang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func scanBtnAction(_ sender: UIButton) {
        let vc = QRScan { (result) in
            debugPrint(result)
        }
        vc.show()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

