//
//  CutPlayerView.swift
//  VideoCompress
//
//  Created by 何少博 on 17/4/13.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit

let kImageSpacing:CGFloat = 7
let kImageViewWidth:CGFloat = 35
let kTopViewWidth:CGFloat = 30
let kTopViewHeight:CGFloat = 20

class CutPlayerView: UIView {
    
    fileprivate var contentView:UIView!
    fileprivate var leftMaskView:UIView!
    fileprivate var rightMaskView:UIView!
    fileprivate var leftTopView:UIImageView!
    fileprivate var rightTopView:UIImageView!
    fileprivate var leftCenter = CGPoint.zero
    fileprivate var rightCenter = CGPoint.zero
    fileprivate var leftTopPosition = CGPoint.zero
    fileprivate var rightTopPosition = CGPoint.zero
    fileprivate var imageViews:[UIImageView] = []
    var avasset:AVAsset?

    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        contentView = UIView(frame: CGRect.zero)
        addSubview(contentView)
        leftMaskView = UIView(frame: CGRect.zero)
        addSubview(leftMaskView)
        rightMaskView = UIView(frame: CGRect.zero)
        addSubview(rightMaskView)
        leftTopView = UIImageView(frame: CGRect.zero)
        addSubview(leftTopView)
        rightTopView = UIImageView(frame: CGRect.zero)
        addSubview(rightTopView)
        let huaKuai = UIImage(named: "huakuai2")
        leftTopView.image = huaKuai
        rightTopView.image = huaKuai
        leftMaskView.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
        rightMaskView.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
        let leftPan = UIPanGestureRecognizer(target: self, action: #selector(moveLeftView(pan:)))
        leftTopView.addGestureRecognizer(leftPan)
        leftTopView.isUserInteractionEnabled = true
        leftTopView.contentMode = .scaleAspectFit
        let rightPan = UIPanGestureRecognizer(target: self, action: #selector(moveRifhtView(pan:)))
        rightTopView.addGestureRecognizer(rightPan)
        rightTopView.isUserInteractionEnabled = true
        rightTopView.contentMode = .scaleAspectFit
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor.clear
    }
    
    
    @objc fileprivate func moveLeftView(pan:UIPanGestureRecognizer){
        let po = pan.translation(in: self)
        if (pan.state == .began) {
            leftCenter = (pan.view?.center)!
        }
        pan.view?.center = CGPoint(x: leftCenter.x+po.x, y: leftCenter.y)
   
        if ((pan.view?.frame.maxX)! > rightTopView.frame.minX) {
            var frame1 = pan.view?.frame
            frame1?.origin.x = rightTopView.frame.origin.x - kTopViewWidth
            pan.view?.frame = frame1!
        }else if (pan.view?.frame.minX)! <= CGFloat(0.5) {
            return
        }
        leftTopPosition = (pan.view?.center)!
        self.layoutSubviews()

    }
    @objc fileprivate func moveRifhtView(pan:UIPanGestureRecognizer){
        let po = pan.translation(in: self)
        if (pan.state == .began) {
            rightCenter = (pan.view?.center)!
        }
        pan.view?.center = CGPoint(x: rightCenter.x+po.x, y: rightCenter.y)
        
        if ((pan.view?.frame.minX)! < leftTopView.frame.maxX) {
            var frame1 = pan.view?.frame
            frame1?.origin.x = leftTopView.frame.origin.x + kTopViewWidth
            pan.view?.frame = frame1!
        }else if (pan.view?.frame.maxX)!-0.5 >= self.bounds.width {
            return
        }
        rightTopPosition = (pan.view?.center)!
        self.layoutSubviews()

    }
    
  
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let WIDTH = self.bounds.size.width
        let HEIGHT = self.bounds.size.height
        contentView.frame = CGRect(x: kTopViewWidth/2, y: kTopViewHeight, width: WIDTH-kTopViewWidth,height: HEIGHT-kTopViewHeight)
        contentView.clipsToBounds = true
        var leftMaskFrame =  CGRect(x: kTopViewWidth/2, y: kTopViewHeight, width: 0.1, height: HEIGHT-kTopViewHeight)
        if leftTopPosition != CGPoint.zero {
            leftTopView.center = leftTopPosition
            leftMaskFrame.size.width = leftTopPosition.x - kTopViewWidth/2
        }else{
             leftTopView.frame = CGRect(x: 0, y: 0, width: kTopViewWidth, height: kTopViewHeight)
        }
        leftMaskView.frame = leftMaskFrame
        
        var rightMaskFrame = CGRect(x: WIDTH-kTopViewWidth/2, y: kTopViewHeight, width: 0.1, height: HEIGHT-kTopViewHeight)
        if rightTopPosition != CGPoint.zero {
            rightTopView.center = rightTopPosition
            rightMaskFrame.size.width = WIDTH-rightTopPosition.x - kTopViewWidth/2
            rightMaskFrame.origin.x = rightTopPosition.x
        }else{
            rightTopView.frame = CGRect(x: WIDTH-kTopViewWidth, y: 0, width: kTopViewWidth, height: kTopViewHeight)
        }
        rightMaskView.frame = rightMaskFrame
    }
    
    func getCutCMTimeRange() -> (startTime:CGFloat,endTime:CGFloat) {
      
        let totalTime = self.avasset?.duration
        let totalMovieDuration = TimeInterval((totalTime?.value)!)/TimeInterval((totalTime?.timescale)!)
        let startTime = (leftTopView.center.x - kTopViewWidth/2)*(CGFloat(totalMovieDuration)/contentView.bounds.width)
        let endTime = (rightTopView.center.x - kTopViewWidth/2)*(CGFloat(totalMovieDuration)/contentView.bounds.width)
        return (startTime,endTime)
        
    }
    
    func setAsset(asset:AVAsset) {
        let WIDTH = self.bounds.size.width
        let HEIGHT = self.bounds.size.height
        DispatchQueue.main.async {
            for chilren in self.imageViews {
                chilren.removeFromSuperview()
            }
            self.imageViews.removeAll()
            self.leftTopPosition = CGPoint.zero
            self.rightTopPosition = CGPoint.zero
            self.leftTopView.frame = CGRect(x: 0, y: 0, width: kTopViewWidth, height: kTopViewHeight)
            self.rightTopView.frame = CGRect(x: WIDTH-kTopViewWidth, y: 0, width: kTopViewWidth, height: kTopViewHeight)
            self.contentView.frame  = CGRect(x: kTopViewWidth/2, y: kTopViewHeight, width: WIDTH-kTopViewWidth, height: HEIGHT-kTopViewHeight)
            self.layoutSubviews()
        }
        let totalTime = asset.duration
        let totalMovieDuration = TimeInterval(totalTime.value)/TimeInterval(totalTime.timescale)
        self.avasset = asset
        DispatchQueue.global().async {
            let count = Int((WIDTH-kTopViewWidth - kImageViewWidth)/kImageSpacing)+1
            for i in 0..<count {
                let currentTime = totalMovieDuration/TimeInterval(count) * TimeInterval(i)
                let dragedCMTime = CMTimeMake(Int64(currentTime), 1)
                let image = self.getAssetImage(for: dragedCMTime, asset: asset)
                DispatchQueue.main.async {
                    let imageView = UIImageView()
                    imageView.image = image
                    imageView.layer.borderColor = UIColor.white.cgColor
                    imageView.layer.borderWidth = 0.5
                    imageView.contentMode = .scaleAspectFill
                    imageView.layer.cornerRadius = 3.0
                    imageView.layer.masksToBounds = true;
                    let x = CGFloat(i) * kImageSpacing
                    imageView.frame = CGRect(x: x, y: 0, width: CGFloat(kImageViewWidth), height: HEIGHT-kTopViewHeight)
                    self.contentView.addSubview(imageView)
                    self.imageViews.append(imageView)
                }
            }
        }
         
    }
    func secondToTimeSting(time:TimeInterval) -> String {
        let date = NSDate(timeIntervalSince1970:time)
        let formatter = DateFormatter()
        if time/3600 >= 1 {
            formatter.dateFormat = "HH:mm:ss"
        }else{
            formatter.dateFormat = "mm:ss"
        }
        return formatter.string(from: date as Date)
    }
    
    func getAssetImage(for cmtime:CMTime ,asset:AVAsset) -> UIImage? {
        
        let gen = AVAssetImageGenerator(asset: asset)
        gen.appliesPreferredTrackTransform = true
        gen.maximumSize = CGSize(width: 200, height: 200)
        
        var image = UIImage()
        do {
            var actualTime:CMTime = CMTimeMake(0, 0)
            let imagecg = try gen.copyCGImage(at: cmtime, actualTime: &actualTime)
            image = UIImage(cgImage: imagecg)
        } catch {
            
        }
        return image
        
    }
    deinit {
    }
//    let totalTime = asset.duration
//    let totalMovieDuration = TimeInterval(totalTime.value)/TimeInterval(totalTime.timescale)
//    let timeString = secondToTimeSting(time: totalMovieDuration)
//    rightLabel.text = timeString
    
}
