//
//  SFSPhotoTweakView.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/2.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit

class SFSPhotoTweakView: UIView {

    fileprivate(set) var angle:CGFloat = 0
    fileprivate(set) var photoContentOffset:CGPoint = CGPoint.zero
    fileprivate(set) var cropView:SFSCropView?
    fileprivate(set) var photoContentView:SFSPhotoContentView?
    fileprivate(set) var slider:UISlider?
    fileprivate(set) var resetBtn:UIButton?
    
    fileprivate var scrollView:SFSPhotoScrollView?
    fileprivate var image:UIImage?
    fileprivate var originalSize:CGSize = CGSize.zero
    fileprivate var manualZoomed:Bool = false
    
    // masks
    fileprivate var topMask:UIView?
    fileprivate var leftMask:UIView?
    fileprivate var bottomMask:UIView?
    fileprivate var rightMask:UIView?
    
    // constants
    fileprivate var maximumCanvasSize:CGSize = CGSize.zero
    fileprivate var centerY:CGFloat = 0
    fileprivate var originalPoint:CGPoint = CGPoint.zero
    fileprivate var maxRotationAngle:CGFloat = 0
    
    init(frame:CGRect,image:UIImage?,maxRotationAngle:CGFloat) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(hexString: "f9f9f9")
        self.clipsToBounds = true
        self.image = image
        self.maxRotationAngle = maxRotationAngle
        maximumCanvasSize = CGSize(width: kMaximumCanvasWidthRatio * frame.size.width,
                                  height: kMaximumCanvasHeightRatio * frame.size.height - kCanvasHeaderHeigth)
        let scaleX = (image?.size.width)! / maximumCanvasSize.width
        let scaleY = (image?.size.height)! / maximumCanvasSize.height
        let scale = max(scaleX, scaleY)
        let boundsT = CGRect(x: 0,
                             y: 0,
                         width: (image?.size.width)! / scale,
                        height: (image?.size.height)! / scale)
        originalSize = boundsT.size
        centerY = maximumCanvasSize.height / 2 + 70
        
        scrollView = SFSPhotoScrollView(frame: boundsT)
        scrollView?.center = CGPoint(x: frame.width/2, y: centerY)
     
        scrollView?.bounces = true
        scrollView?.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scrollView?.alwaysBounceVertical = true
        scrollView?.alwaysBounceHorizontal = true
        scrollView?.delegate = self
        scrollView?.minimumZoomScale = 1
        scrollView?.maximumZoomScale = 10
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.clipsToBounds = false
        scrollView?.contentSize = CGSize(width: (scrollView?.bounds.size.width)!, height: (scrollView?.bounds.size.height)!)
        addSubview(scrollView!)
        
        
        photoContentView = SFSPhotoContentView(image: image!)
        photoContentView?.frame = (scrollView?.bounds)!
        photoContentView?.backgroundColor = UIColor.clear
        photoContentView?.isUserInteractionEnabled = true
        scrollView?.photoContentView = photoContentView
        scrollView?.addSubview(photoContentView!)
        
        cropView = SFSCropView(frame: (scrollView?.frame)!)
        cropView?.center = (scrollView?.center)!
        cropView?.delegate = self
        addSubview(cropView!)
        
        let maskColor = UIColor(white: 0, alpha: 0.4)
        topMask = UIView()
        topMask?.backgroundColor = maskColor
        addSubview(topMask!)
        
        leftMask = UIView()
        leftMask?.backgroundColor = maskColor
        addSubview(leftMask!)
        
        bottomMask = UIView()
        bottomMask?.backgroundColor = maskColor
        addSubview(bottomMask!)
        
        rightMask = UIView()
        rightMask?.backgroundColor = maskColor
        addSubview(rightMask!)
        
        updateMasks(animate: false)
        
        
        let contentView = UIView(frame: CGRect(x: 0, y: self.bounds.height-50-44, width: self.bounds.width, height: 50))
        contentView.backgroundColor = UIColor(hexString: "fbfbfb")
        contentView.isUserInteractionEnabled = true
        let sliderLabel = UILabel(frame: CGRect(x: 0, y: 10, width: contentView.bounds.width/4, height: 30))
        contentView.addSubview(sliderLabel)
        sliderLabel.textAlignment = .center
        sliderLabel.adjustsFontSizeToFitWidth = true
        sliderLabel.text = SFS_rotate
        sliderLabel.textColor = UIColor(hexString: "578fff")
        slider = UISlider(frame: CGRect(x: contentView.bounds.width/4,
                                        y: 10,
                                    width: contentView.bounds.width/4*3-10,
                                   height: 30))
        slider?.minimumValue = -(Float)(maxRotationAngle)
        slider?.maximumValue = Float(maxRotationAngle)
        slider?.minimumTrackTintColor = UIColor(hexString: "b8b8b8")
        slider?.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .valueChanged)
        slider?.addTarget(self, action: #selector(sliderTouchEnded(sender:)), for: [.touchCancel,.touchUpInside,.touchUpOutside])
        slider?.setThumbImage(UIImage(named:"line"), for: .normal)
        contentView.addSubview(slider!)
        addSubview(contentView)
        
        originalPoint = self.convert((scrollView?.center)!, to: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        reset()
//    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let sliderContainsPoint = self.slider?.superview?.frame.contains(point)//self.slider?.frame.contains(point)
        
        let crRectInset1 = self.cropView?.frame.insetBy(dx: -kCropViewHotArea, dy: -kCropViewHotArea)
        let crRectInset2 = self.cropView?.frame.insetBy(dx: kCropViewHotArea, dy: kCropViewHotArea)
        
        let crContainsPoint1 = crRectInset1?.contains(point)
        let crContainsPoint2 = crRectInset2?.contains(point)
        
        let crContainsPoint = crContainsPoint1! && !crContainsPoint2!
        
        if sliderContainsPoint! {
            return slider
        }
        else if crContainsPoint {
            return cropView
        }
        
        return scrollView!
    }
    
    
  
    
    
    func updateMasks(animate:Bool) -> () {
        
        weak var weakSelf = self
        
        let animationBlock = { () -> Void in
            
            let cropWidth = (weakSelf?.cropView?.frame.size.width)!
            let cropHeight = (weakSelf?.cropView?.frame.size.height)!
            let cropX = (weakSelf?.cropView?.frame.origin.x)!
            let cropY = (weakSelf?.cropView?.frame.origin.y)!
            let selfWidth = (weakSelf?.frame.width)!
            let selfHeight = (weakSelf?.frame.height)!
            
            weakSelf?.topMask?.frame = CGRect(x: 0,
                                              y: 0,
                                          width: cropX + cropWidth,
                                         height: cropY)
            
            weakSelf?.leftMask?.frame = CGRect(x: 0,
                                               y: cropY,
                                           width: cropX,
                                          height: selfHeight - cropY)
            
            weakSelf?.bottomMask?.frame = CGRect(x: cropX,
                                                 y: cropY + cropHeight,
                                             width: selfWidth - cropX,
                                            height: selfHeight - (cropY + cropHeight))
            
            weakSelf?.rightMask?.frame = CGRect(x: cropX + cropWidth,
                                                y: 0,
                                            width: selfWidth - (cropX + cropWidth),
                                           height: cropY + cropHeight)
            
        }
        
        if animate {
            UIView.animate(withDuration: 0.25, animations: animationBlock)
        }else{
            animationBlock()
        }
        
    }
    
    func checkScrollViewContentOffset() -> () {
        let offsetX = max((scrollView?.contentOffset.x)!, 0)
        scrollView?.setContentOffsetX(offsetX: offsetX)
        let offsetY = max((scrollView?.contentOffset.y)!, 0)
        scrollView?.setContentOffsetY(offsetY: offsetY)
        
        let sizeY1 = (scrollView?.contentSize.height)! - (scrollView?.contentOffset.y)!
        let sizeY2 = (scrollView?.bounds.size.height)!
        if sizeY1 <= sizeY2 {
            let offsetY2 = (scrollView?.contentSize.height)! - (scrollView?.bounds.size.height)!
            scrollView?.setContentOffsetY(offsetY: offsetY2)
        }
        
        let sizeX1 = (scrollView?.contentSize.width)! - (scrollView?.contentOffset.x)!
        let sizeX2 = (scrollView?.bounds.size.width)!
        if sizeX1 <= sizeX2 {
            let offsetX2 = (scrollView?.contentSize.width)! - (scrollView?.bounds.size.width)!
            scrollView?.setContentOffsetX(offsetX: offsetX2)
        }
    }
    
    func sliderValueChanged(sender:UISlider) -> () {
        updateMasks(animate: false)
        cropView?.updateGridLines(animate: false)
        
        angle = CGFloat((slider?.value)!)
        scrollView?.transform = CGAffineTransform(rotationAngle: angle)
        
        let width = fabs(cos(angle)) * (cropView?.frame.size.width)! + fabs(sin(angle)) * (cropView?.frame.size.height)!
        
        let height = fabs(sin(angle)) * (cropView?.frame.size.width)! + fabs(cos(angle)) * (cropView?.frame.size.height)!
        
        let center = (scrollView?.center)!
        
        let contentOffset = (scrollView?.contentOffset)!
        let contentOffsetCenter = CGPoint(x: contentOffset.x + (scrollView?.bounds.size.width)! / 2,
                                          y: contentOffset.y + (scrollView?.bounds.size.height)! / 2)
       scrollView?.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        let newContentOffset = CGPoint(x: contentOffsetCenter.x - (scrollView?.bounds.size.width)! / 2,
                                       y: contentOffsetCenter.y - (scrollView?.bounds.size.height)! / 2)
        scrollView?.contentOffset = newContentOffset
        scrollView?.center = center
        
        
        let shouldScale = ((scrollView?.contentSize.width)! / (scrollView?.bounds.size.width)! <= 1.0 ) || ((scrollView?.contentSize.height)!/(scrollView?.bounds.size.height)! <= 1.0)
        
        if !manualZoomed || shouldScale {
            scrollView?.setZoomScale((scrollView?.zoomScaleToBound())!, animated: false)
            scrollView?.minimumZoomScale = (scrollView?.zoomScaleToBound())!
            manualZoomed = false
        }
        
        checkScrollViewContentOffset()
    }
    
    func sliderTouchEnded(sender:UISlider) -> () {
        cropView?.dismissGridLines()
        cropView?.showCropLines()
    }
    
    func photoTranslation() -> CGPoint {
        
        let rect = (photoContentView?.convert((photoContentView?.bounds)!, to: self))!
        
        let point = CGPoint(x: rect.origin.x + rect.size.width/2,
                            y: rect.origin.y + rect.size.height/2)
        let zeroPoint = CGPoint(x: self.frame.width/2, y: centerY)
        
        let finalPoint = CGPoint(x: point.x - zeroPoint.x, y: point.y - zeroPoint.y)
        
        return finalPoint
    }
    func reset() -> () {
        UIView.animate(withDuration: 0.25) { 
            self.angle = 0
            self.scrollView?.transform = .identity
            self.scrollView?.center = CGPoint(x: self.frame.width/2,
                                         y: self.centerY)
            self.scrollView?.bounds = CGRect(origin: CGPoint.zero, size: self.originalSize)
            self.scrollView?.minimumZoomScale = 1
            self.scrollView?.setZoomScale(1, animated: false)
            
            self.cropView?.frame = (self.scrollView?.frame)!
            self.cropView?.center = (self.scrollView?.center)!
            self.updateMasks(animate: false)
            self.slider?.setValue(0, animated: true)
            self.cropView?.updateCropLines(animate: false)
        }
       
    }
}
extension SFSPhotoTweakView:UIScrollViewDelegate,SFSCropViewDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoContentView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        manualZoomed = true
    }
    
    func cropMoved(cropView: SFSCropView) {
        updateMasks(animate: false)
        cropView.updateCropLines(animate: false)
    }
    
    func cropEnded(cropView: SFSCropView) {
        let scaleX = originalSize.width / cropView.bounds.size.width
        let scaleY = originalSize.height / cropView.bounds.size.height
        
        let scale = min(scaleX, scaleY)
        
        let newCropBounds = CGRect(x: 0,
                                   y: 0,
                               width: scale * cropView.frame.size.width,
                              height: scale * cropView.frame.size.height)
        
        let width = fabs(cos(angle)) * newCropBounds.size.width + fabs(sin(angle)) * newCropBounds.size.height
        
        let height = fabs(sin(angle)) * newCropBounds.size.width + fabs(cos(angle)) * newCropBounds.size.height
        
        var scaleFrame = cropView.frame
        
        if scaleFrame.size.width >= (scrollView?.bounds.size.width)! {
            scaleFrame.size.width = (scrollView?.frame.size.width)! - 1
        }
        if scaleFrame.size.height >= (scrollView?.bounds.size.height)! {
            scaleFrame.size.height = (scrollView?.bounds.size.height)! - 1
        }
        
        let contentOffset = (scrollView?.contentOffset)!
        let contentOffsetCenter = CGPoint(x: contentOffset.x + (scrollView?.bounds.size.width)! / 2,
                                          y: contentOffset.y + (scrollView?.bounds.size.height)! / 2)
        
        
        var  bounds = (scrollView?.bounds)!
        bounds.size.width = width;
        bounds.size.height = height;
        
        scrollView?.bounds = CGRect(x: 0,
                                    y: 0,
                                    width: width,
                                    height: height)
        
        let newContentOffset = CGPoint(x: contentOffsetCenter.x - (scrollView?.bounds.size.width)! / 2,
                                       y: contentOffsetCenter.y - (scrollView?.bounds.size.height)! / 2)
        scrollView?.contentOffset = newContentOffset
        
        UIView.animate(withDuration: 0.25) {
            cropView.bounds = CGRect(x: 0,
                                     y: 0,
                                 width: newCropBounds.size.width,
                                height: newCropBounds.size.height)
            
            cropView.center = CGPoint(x: self.frame.width/2,
                                      y: self.centerY)
            
            cropView.updateCropLines(animate: false)
            let zoomRect = self.convert(scaleFrame, to: self.scrollView?.photoContentView)
            self.scrollView?.zoom(to: zoomRect, animated: false)
            
        }
        
        manualZoomed = true
        updateMasks(animate: true)
        
        let scaleH = (scrollView?.bounds.size.height)! / (scrollView?.contentSize.height)!
        let scaleW = (scrollView?.bounds.size.width)! / (scrollView?.contentSize.width)!
        var scaleM = max(scaleH, scaleW)
        weak var weakSelf = self
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) { 
            if scaleM > 1 {
                scaleM = scaleM * (weakSelf?.scrollView?.zoomScale)!
                weakSelf?.scrollView?.setZoomScale(scaleM, animated: false)
            }
            
            UIView.animate(withDuration: 0.2, animations: { 
                weakSelf?.checkScrollViewContentOffset()
            })
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
