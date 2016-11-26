//
//  QRScanViewController.swift
//  QRCode
//
//  Created by mac on 16/3/29.
//  Copyright © 2016年 HarveyTsang. All rights reserved.
//

import UIKit
import AVFoundation

class QRScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    struct Color {
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
    }
    
    var completeCbClosure: ((String)->Void)?
    
    private let midRectWidth: CGFloat = 200
    private let lineWidth: CGFloat = 2.0
    private let lineColor: Color = Color(red: 24.0/255.0, green: 110.0/255.0, blue: 227.0/255.0)
    private let screenSize = UIScreen.main.bounds.size
    private let midRect: CGRect
    private let indicator = CAGradientLayer()
    private let session = AVCaptureSession()
    private let torchBtn = UIButton(type: .custom)
    private var device : AVCaptureDevice?
    
    init(cb:@escaping (String)->Void){
        self.completeCbClosure = cb
        midRect = CGRect(x: screenSize.width/2.0 - midRectWidth/2.0, y: screenSize.height/2.0 - midRectWidth/2.0, width: midRectWidth, height: midRectWidth)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        midRect = CGRect(x: screenSize.width/2.0 - midRectWidth/2.0, y: screenSize.height/2.0 - midRectWidth/2.0, width: midRectWidth, height: midRectWidth)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupUI()
        
        setupTorch()
        
        scan()
    }
    private func setupUI(){
        let cancelBtn = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(self.cancel))
        self.navigationItem.rightBarButtonItem = cancelBtn
        
        let imageV = UIImageView(frame: self.view.frame)
        imageV.image = self.getBackgroundImage()
        self.view.addSubview(imageV)
        
        setupIndicator()
        self.view.layer.addSublayer(indicator)
        
        torchBtn.frame = CGRect(x: 50, y: 400, width: 50, height: 55)
        torchBtn.setImage(UIImage(named: "off"), for: .normal)
        torchBtn.setImage(UIImage(named: "on"), for: .selected)
        torchBtn.addTarget(self, action: #selector(self.torchBtnAction), for: .touchUpInside)
        self.view.addSubview(torchBtn)
        
        animate()
    }
    private func setupIndicator(){
        let middleColor = UIColor(colorLiteralRed: Float(lineColor.red), green: Float(lineColor.green), blue: Float(lineColor.blue), alpha: 1.0).cgColor
        let endColor = UIColor(colorLiteralRed: Float(lineColor.red), green: Float(lineColor.green), blue: Float(lineColor.blue), alpha: 0.1).cgColor
        indicator.colors = [endColor, middleColor, endColor]
        indicator.locations = [0.0, 0.5, 1.0]
        indicator.startPoint = CGPoint(x: 0.0, y: 0.0)
        indicator.endPoint = CGPoint(x: 1.0, y: 0.0)
        indicator.frame = CGRect(x: screenSize.width/2.0 - midRectWidth/2.0, y: screenSize.height/2.0 - midRectWidth/2.0, width: midRectWidth, height: 2)
    }
    
    private func setupTorch(){
        device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if !(device!.hasTorch){
            self.torchBtn.isEnabled = false
        }
    }
    
    private func turnTorch(mode: AVCaptureTorchMode){
        do{
            try device?.lockForConfiguration()
        }catch{
            return
        }
        device?.torchMode = mode
        device?.unlockForConfiguration()
    }
    
    @objc private func cancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func torchBtnAction(){
        torchBtn.isSelected = !torchBtn.isSelected
        if torchBtn.isSelected{
            turnTorch(mode: .on)
        }else{
            turnTorch(mode: .off)
        }
    }
    
    private func animate(){
        let animate = CAKeyframeAnimation(keyPath: "position.y")
        animate.values = [indicator.position.y, indicator.position.y + midRect.height, indicator.position.y]
        animate.keyTimes = [0.0, 0.5, 1.0]
        animate.timingFunctions = [.init(name: kCAMediaTimingFunctionEaseInEaseOut), .init(name: kCAMediaTimingFunctionEaseInEaseOut)]
        animate.duration = 2.5
        animate.repeatCount = 9999
        indicator.add(animate, forKey: "scanAnimation")
    }
    
    private func getBackgroundImage() -> UIImage {
        UIGraphicsBeginImageContext(self.view.frame.size)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        let drawRect = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        ctx.fill(drawRect)
        ctx.clear(midRect)
        
        let lines: [[CGPoint]] = [[.init(x:midRect.origin.x, y: midRect.origin.y+10), midRect.origin, .init(x:midRect.origin.x+10, y: midRect.origin.y)],
                                  [.init(x:midRect.maxX-10, y: midRect.minY), .init(x: midRect.maxX, y: midRect.minY), .init(x:midRect.maxX, y: midRect.minY+10)],
                                  [.init(x: midRect.minX, y: midRect.maxY-10), .init(x: midRect.minX, y: midRect.maxY), .init(x: midRect.minX+10, y: midRect.maxY)],
                                  [.init(x: midRect.maxX-10, y:midRect.maxY), .init(x: midRect.maxX, y: midRect.maxY), .init(x: midRect.maxX, y: midRect.maxY-10)]]
        ctx.setLineWidth(lineWidth)
        ctx.setStrokeColor(red: lineColor.red, green: lineColor.green, blue: lineColor.blue, alpha: 1.0)
        ctx.beginPath()
        for line in lines{
            ctx.move(to: line[0])
            ctx.addLine(to: line[1])
            ctx.addLine(to: line[2])
        }
        ctx.strokePath()
        
        let returnImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return returnImage!
    }
    
    private func scan(){
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else{
            return
        }
        do{
            try device.lockForConfiguration()
            if device.isFocusModeSupported(.continuousAutoFocus){
                device.focusMode = .continuousAutoFocus
            }
            if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance){
                device.whiteBalanceMode = .continuousAutoWhiteBalance
            }
            if device.isExposureModeSupported(.continuousAutoExposure){
                device.exposureMode = .continuousAutoExposure
            }
            device.unlockForConfiguration()
        }catch let error as NSError{
            debugPrint(error)
        }
        
        var input : AVCaptureInput
        do{
            try input = AVCaptureDeviceInput(device: device)
        }catch{
            return
        }
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.rectOfInterest = CGRect(x: midRect.origin.y / screenSize.height, y: midRect.origin.x / screenSize.width, width: midRect.size.height / screenSize.height, height: midRect.size.width / screenSize.width)
        
        session.canSetSessionPreset(AVCaptureSessionPresetHigh)
        session.addInput(input)
        session.addOutput(output)
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        if let layer = AVCaptureVideoPreviewLayer(session: session){
            layer.videoGravity = AVLayerVideoGravityResizeAspectFill
            layer.frame = self.view.layer.bounds
            self.view.layer.insertSublayer(layer, at: 0)
            session.startRunning()
        }
    }
    
    @objc private func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        if metadataObjects.count > 0{
            session.stopRunning()
            let metadataObject = metadataObjects[0]
            if let cb = self.completeCbClosure{
                cb(metadataObject.stringValue)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

