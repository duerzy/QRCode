//
//  QRCodeGenerator.swift
//  QRCode
//
//  Created by mac on 16/3/30.
//  Copyright © 2016年 HarveyTsang. All rights reserved.
//

import Foundation
import UIKit
class QRCodeGenerator{
    class func QRCode(_ fromString: String)->UIImage{
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        let data = fromString.data(using: String.Encoding.utf8)
        filter?.setValue(data, forKey: "inputMessage")
        let ciImg = filter?.outputImage
        return QRCodeGenerator.createNonInterpolatedUIImageFrom(ciImg!, size: 100.0)
    }
    fileprivate class func createNonInterpolatedUIImageFrom(_ ciimage: CIImage, size: CGFloat)->UIImage{
        let extent = ciimage.extent.integral
        let scale = min(size/extent.width,size/extent.height)
        
        let width = extent.width*scale
        let height = extent.height*scale
        let cs = CGColorSpaceCreateDeviceGray()
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: 0)
        let context = CIContext(options: nil)
        let bitmapImage = context.createCGImage(ciimage, from: extent)
        bitmapRef!.interpolationQuality = .none
        bitmapRef!.scaleBy(x: scale, y: scale)
        bitmapRef!.draw(bitmapImage!, in: extent)
        let scaledImage = bitmapRef!.makeImage()
        return UIImage(cgImage: scaledImage!)
    }
}
