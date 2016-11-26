//
//  DisplayQRCodeViewController.swift
//  QRCodeScanAndCreate
//
//  Created by mac on 2016/11/25.
//  Copyright © 2016年 HarveyTsang. All rights reserved.
//

import UIKit

class DisplayQRCodeViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = QRCodeGenerator.QRCode("Hello World!")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
