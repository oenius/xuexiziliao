//
//  SFSPhotoCropViewController.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/2.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit
import CoreGraphics

let kMaxRotationAngle:CGFloat = 0.5
let kCropLines:Int = 2
let kGridLines:Int = 7

let kCropViewHotArea:CGFloat = 16
let kMinimumCropArea:CGFloat = 60
let kMaximumCanvasWidthRatio:CGFloat = 0.9
let kMaximumCanvasHeightRatio:CGFloat = 0.7
let kCanvasHeaderHeigth:CGFloat = 60
let kCropViewCornerLength:CGFloat = 22

protocol SFSPhotoCropViewControllerDelegate {
    func photoCropController(cropController:SFSPhotoCropViewController,croppedImage:UIImage) -> ()
    func photoCropControllerDidCancel(cropController:SFSPhotoCropViewController) -> ()
}

class SFSPhotoCropViewController: UIViewController {
    
    
    ///代理
    var delegate:SFSPhotoCropViewControllerDelegate?
    /// 要裁剪的图片.
    private(set) var image:UIImage?
    ///是否允许自动保存到相册
    var autoSaveToLibray:Bool = false
    /// 最大旋转角度
    var maxRotationAngle:CGFloat = CGFloat(M_PI_2)
    
    fileprivate var photoView:SFSPhotoTweakView?
    
    init(image:UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.clipsToBounds = true
        self.view.backgroundColor = UIColor(hexString: "202020")
        setupSubViews()
    }

    func setupSubViews() -> () {
        var newFrame = self.view.bounds
        newFrame.origin.y = 44
        photoView = SFSPhotoTweakView(frame: newFrame, image: image, maxRotationAngle: maxRotationAngle)
        
        photoView?.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.view.addSubview(photoView!)
        
        let canceeBtn = UIButton(frame: CGRect(x: 15, y: 2, width: 40, height: 40))
        canceeBtn.setImage(UIImage(named:"close"), for: .normal)
        canceeBtn.addTarget(self, action: #selector(cancelBtnTapped), for: .touchUpInside)
        self.view.addSubview(canceeBtn)
        
        let resetBtn = UIButton(frame: CGRect(x: 15, y: 2, width: 40, height: 40))
        resetBtn.center = CGPoint(x: self.view.bounds.width/2, y: 22)
        resetBtn.setImage(UIImage(named:"reset"), for: .normal)
        resetBtn.addTarget(self, action: #selector(resetBtnTapped), for: .touchUpInside)
        self.view.addSubview(resetBtn)
        
        let doneBtn = UIButton(frame: CGRect(x: self.view.bounds.width-55, y: 2, width: 40, height: 40))
        doneBtn.setImage(UIImage(named:"done"), for: .normal)
        doneBtn.addTarget(self, action: #selector(saveBtnTapped), for: .touchUpInside)
        self.view.addSubview(doneBtn)
        
    }
    
    func cancelBtnTapped() -> () {
        if delegate != nil {
            delegate?.photoCropControllerDidCancel(cropController: self)
        }
    }
    func resetBtnTapped() -> () {
        photoView?.reset()
    }
    func saveBtnTapped() -> () {
        var transform = CGAffineTransform.identity
        
        let translation = photoView?.photoTranslation()
        transform = transform.translatedBy(x: (translation?.x)!, y: (translation?.y)!)
        transform = transform.rotated(by: (photoView?.angle)!)
        
        let t = (photoView?.photoContentView?.transform)!
        let xScale = sqrt(t.a*t.a + t.c*t.c)
        let yScale = sqrt(t.b*t.b + t.d*t.d)
        
        transform = transform.scaledBy(x: xScale, y: yScale)
        
        var imagecg = newTransformedImage(transform: transform,
                                        sourceImage: (image?.cgImage)!,
                                         sourceSize: (image?.size)!,
                                  sourceOrientation: (image?.imageOrientation)!,
                                        outputWidth: (image?.size.width)!,
                                           cropSize: (photoView?.cropView?.frame.size)!,
                                      imageViewSize: (photoView?.photoContentView?.bounds.size)!)
        let newImage = UIImage(cgImage: imagecg!)
        imagecg = nil
        
        if autoSaveToLibray {
            UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil)
        }
        if delegate != nil {
            delegate?.photoCropController(cropController: self, croppedImage: newImage)
        }
        
    }
    
    func newScaledImage(source:CGImage,
                   orientation:UIImageOrientation,
                          size:CGSize,
                       quality:CGInterpolationQuality) -> CGImage? {
        var srcSize = size
        var rotation:CGFloat = 0.0
        switch orientation {
            case .up:
                rotation = 0
                break
            case .down:
                rotation = CGFloat(M_PI)
                break
            case .left:
                rotation = CGFloat(M_PI_2)
                srcSize = CGSize(width: size.height, height: size.width)
                break
            case .right:
                rotation = CGFloat(-M_PI_2)
                srcSize = CGSize(width: size.height, height: size.width)
                break
            default: break
        }
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(data: nil,
                               width: Int(size.width),
                              height: Int(size.height),
                    bitsPerComponent: 8,
                         bytesPerRow: 0,
                               space: rgbColorSpace,
                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue|CGBitmapInfo.byteOrder32Big.rawValue)
        
        context?.interpolationQuality = quality
        context?.translateBy(x: size.width/2, y: size.height/2)
        context?.rotate(by: rotation)
        let rect = CGRect(x: -srcSize.width/2,
                          y: -srcSize.height/2,
                          width: srcSize.width,
                          height: srcSize.height)
        context?.draw(source, in: rect)
        let result = context?.makeImage()
        return result
    }
    func newTransformedImage(transform:CGAffineTransform,
                           sourceImage:CGImage,
                            sourceSize:CGSize,
                     sourceOrientation:UIImageOrientation,
                           outputWidth:CGFloat,
                              cropSize:CGSize,
                         imageViewSize:CGSize) -> CGImage? {
        
        let source = newScaledImage(source: sourceImage,
                                    orientation: sourceOrientation,
                                    size: sourceSize,
                                    quality: .none)
        
        
        let aspect = cropSize.height/cropSize.width
        let outputSize = CGSize(width: outputWidth,
                               height: outputWidth*aspect)
        
        let context = CGContext(data: nil,
                               width: Int(outputSize.width),
                              height: Int(outputSize.height),
                    bitsPerComponent: (source?.bitsPerComponent)!,
                         bytesPerRow: 0,
                               space: (source?.colorSpace)!,
                          bitmapInfo: (source?.bitmapInfo.rawValue)!)
        
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: outputSize.width, height: outputSize.height))
        var uiCoords = CGAffineTransform(scaleX: outputSize.width / cropSize.width, y: outputSize.height / cropSize.height)
        uiCoords = uiCoords.translatedBy(x: cropSize.width/2.0, y: cropSize.height / 2.0)
        uiCoords = uiCoords.scaledBy(x: 1.0, y: -1.0)
        context?.concatenate(uiCoords)
        context?.concatenate(transform)
        context?.scaleBy(x: 1.0, y: -1.0)
        let rect = CGRect(x: -imageViewSize.width/2.0,
                          y: -imageViewSize.height/2.0,
                      width: imageViewSize.width,
                     height: imageViewSize.height)
        context?.draw(source!, in: rect)
        
        let result = context?.makeImage()
        return result
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

