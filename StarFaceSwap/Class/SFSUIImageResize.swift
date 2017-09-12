//
//  SFSUIImageResize.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/3.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit

extension UIImage{
    
//    static inline double radians2 (double degrees) {return degrees * M_PI/180;}
    fileprivate func radians(degrees:Double) -> Double{
        return degrees * Double(M_PI)/180
    }
    
    
     func resizedImage(maxLength:CGFloat) -> UIImage{
        let ratio = self.size.width/self.size.height
        
        if self.size.width > self.size.height {
            if self.size.width > maxLength {
                let size = CGSize(width: maxLength, height: maxLength/ratio)
                let image = resizeWithRotation(sourceImage: self, targetSize: size)
                return image
            }
        }else{
            if self.size.height > maxLength {
                let size = CGSize(width: maxLength*ratio, height: maxLength)
                let image = resizeWithRotation(sourceImage: self, targetSize: size)
                return image
            }
        }
        return self
    }
    
    fileprivate func resizeWithRotation(sourceImage:UIImage,targetSize:CGSize) -> UIImage {
        let targetWidth = targetSize.width;
        let targetHeight = targetSize.height;
        let imagecg = sourceImage.cgImage
        var bitmapInfo = imagecg?.bitmapInfo
        let colorSpaceInfo = imagecg?.colorSpace
        
        if bitmapInfo?.rawValue == CGImageAlphaInfo.none.rawValue {
            bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
        }
        var bitmap:CGContext;
        let imageOr = sourceImage.imageOrientation
        if imageOr == .up || imageOr == .down {
            bitmap = CGContext(data: nil,
                               width: Int(targetWidth),
                               height: Int(targetHeight),
                               bitsPerComponent: (imagecg?.bitsPerComponent)!,
                               bytesPerRow: (imagecg?.bytesPerRow)!,
                               space: colorSpaceInfo!,
                               bitmapInfo: (bitmapInfo?.rawValue)!)!
        }else{
            bitmap = CGContext(data: nil,
                               width: Int(targetHeight),
                               height:Int(targetWidth) ,
                               bitsPerComponent: (imagecg?.bitsPerComponent)!,
                               bytesPerRow: (imagecg?.bytesPerRow)!,
                               space: colorSpaceInfo!,
                               bitmapInfo: (bitmapInfo?.rawValue)!)!
        }
        
        if imageOr == .left {
            let roat = CGFloat(radians(degrees: 90))
            bitmap.rotate(by:roat)
            bitmap.translateBy(x: 0, y: -targetHeight)
        }else if imageOr == .right {
            let roat = CGFloat(radians(degrees: -90))
            bitmap.rotate(by:roat)
            bitmap.translateBy(x: -targetWidth, y: 0)
        }else if imageOr == .up {
            
        }else if imageOr == .down {
            bitmap.translateBy(x: targetWidth, y: targetHeight)
            let roat = CGFloat(radians(degrees: -180))
            bitmap.rotate(by:roat)
        }
        bitmap.draw(imagecg!, in: CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight))
        let newCGimage = bitmap.makeImage()
        let newImage = UIImage(cgImage: newCGimage!)
        return newImage
    }
}




