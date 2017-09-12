//
//  SFSCropView.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/2.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit

protocol SFSCropViewDelegate:NSObjectProtocol {
    func cropEnded(cropView:SFSCropView) -> ()
    func cropMoved(cropView:SFSCropView) -> ()
}

class SFSCropView: UIView {
   
    var delegate:SFSCropViewDelegate?
    private var upperLeft:SFSCorpCornerView?
    private var upperRight:SFSCorpCornerView?
    private var lowerRight:SFSCorpCornerView?
    private var lowerLeft:SFSCorpCornerView?
    private var horizontalCropLines:[UIView] = []
    private var verticalCropLines:[UIView] = []
    private var horizontalGridLines:[UIView] = []
    private var verticalGridLines:[UIView] = []
    private var cropLinesDismissed:Bool = false
    private var gridLinesDismissed:Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        
        for _ in 0..<kCropLines {
            let line = UIView()
            line.backgroundColor = UIColor.white
            horizontalCropLines.append(line)
            addSubview(line)
        }
        
        for _ in 0..<kCropLines {
            let line = UIView()
            line.backgroundColor = UIColor.white
            verticalCropLines.append(line)
            addSubview(line)
        }
        
        for _ in 0..<kGridLines {
            let line = UIView()
            line.backgroundColor = UIColor.lightGray
            horizontalGridLines.append(line)
            addSubview(line)
        }
        
        for _ in 0..<kGridLines {
            let line = UIView()
            line.backgroundColor = UIColor.lightGray
            verticalGridLines.append(line)
            addSubview(line)
        }
        
        cropLinesDismissed = false
        gridLinesDismissed = true
        
        upperLeft = SFSCorpCornerView(type: .upperLeft)
        upperLeft?.center = CGPoint(x: kCropViewCornerLength / 2, y: kCropViewCornerLength / 2)
        upperLeft?.autoresizingMask = UIViewAutoresizing(rawValue: 0)
        addSubview(upperLeft!)
        
        upperRight = SFSCorpCornerView(type: .upperRight)
        upperRight?.center = CGPoint(x: self.frame.width - kCropViewCornerLength / 2, y: kCropViewCornerLength / 2)
        upperRight?.autoresizingMask = UIViewAutoresizing.flexibleLeftMargin
        addSubview(upperRight!)
        
        lowerRight = SFSCorpCornerView(type: .lowerRight)
        lowerRight?.center = CGPoint(x: self.frame.width - kCropViewCornerLength / 2, y: self.frame.height - kCropViewCornerLength / 2)
        lowerRight?.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin , UIViewAutoresizing.flexibleTopMargin]
        addSubview(lowerRight!)
        
        lowerLeft = SFSCorpCornerView(type: .lowerLeft)
        lowerLeft?.center = CGPoint(x: kCropViewCornerLength / 2, y: self.frame.height - kCropViewCornerLength / 2)
        lowerLeft?.autoresizingMask = UIViewAutoresizing.flexibleTopMargin
        addSubview(lowerLeft!)
        updateCropLines(animate: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            updateCropLines(animate: false)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count == 1 {
            let touchesNS = touches as NSSet
            let touch = touchesNS.anyObject() as! UITouch
            let location = touch.location(in: self)
            var newFrame = self.frame
            
            let p0 = CGPoint.zero
            let p1 = CGPoint(x: self.frame.width, y: 0)
            let p2 = CGPoint(x: 0, y: self.frame.height)
            let p3 = CGPoint(x: self.frame.width, y: self.frame.height)
            
            let canChangeWidth = frame.width > kMinimumCropArea
            let canChangeHeight = frame.height > kMinimumCropArea
            
            let distance0 = distanceBetweenPoints(point0: location, point1: p0)
            let distance1 = distanceBetweenPoints(point0: location, point1: p1)
            let distance2 = distanceBetweenPoints(point0: location, point1: p2)
            let distance3 = distanceBetweenPoints(point0: location, point1: p3)
            
            if distance0 < kCropViewHotArea {
                if canChangeWidth {
                    newFrame.origin.x += location.x
                    newFrame.size.width -= location.x
                }
                
                if canChangeHeight {
                    newFrame.origin.y += location.y;
                    newFrame.size.height -= location.y;
                }
            }
            else if distance1 < kCropViewHotArea {
                if canChangeWidth {
                    newFrame.size.width = location.x;
                }
                if canChangeHeight {
                    newFrame.origin.y += location.y;
                    newFrame.size.height -= location.y;
                }
            }
            else if distance2 < kCropViewHotArea{
                if canChangeWidth {
                    newFrame.origin.x += location.x;
                    newFrame.size.width -= location.x;
                }
                if canChangeHeight {
                    newFrame.size.height = location.y;
                }
            }
            else if distance3 < kCropViewHotArea {
                if canChangeWidth {
                    newFrame.size.width = location.x;
                }
                if canChangeHeight {
                    newFrame.size.height = location.y;
                }
            }
            else if fabs(location.x - p0.x) < kCropViewHotArea {
                if canChangeWidth {
                    newFrame.origin.x += location.x;
                    newFrame.size.width -= location.x;
                }
            }
            else if fabs(location.x - p1.x) < kCropViewHotArea {
                if canChangeWidth {
                    newFrame.size.width = location.x;
                }
            }
            else if fabs(location.y - p0.y) < kCropViewHotArea {
                if canChangeHeight {
                    newFrame.origin.y += location.y;
                    newFrame.size.height -= location.y;
                }
            }
            else if fabs(location.y - p2.y) < kCropViewHotArea {
                if canChangeHeight {
                    newFrame.size.height = location.y;
                }
            }
            
            self.frame = newFrame
            
//            updateCropLines(animate: false)
            if delegate != nil {
                delegate?.cropMoved(cropView: self)
            }
        }
    }
    
    private func distanceBetweenPoints(point0:CGPoint,point1:CGPoint) -> CGFloat {
        let dx2 = pow(point1.x - point0.x,2)
        let dy2 = pow(point1.y - point0.y,2)
        let distance = sqrt(dx2+dy2)
        return distance;
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if delegate != nil {
            delegate?.cropEnded(cropView: self)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    func updateCropLines(animate:Bool) -> () {
        if cropLinesDismissed {
            showCropLines()
        }
        
        weak var weakSelf = self
        
        let animationBlock = { () -> Void in
            weakSelf?.updateLines(lines: (weakSelf?.horizontalCropLines)!, horizontal: true)
            weakSelf?.updateLines(lines: (weakSelf?.verticalCropLines)!, horizontal: false)
        }
        
        if animate {
            UIView.animate(withDuration: 0.25, animations: animationBlock)
        }else{
            animationBlock()
        }
    }
    
     func updateGridLines(animate:Bool) -> () {
        if gridLinesDismissed {
            showGridLines()
            dismissCropLines()
        }
        
        weak var weakSelf = self
        
        let animationBlock = { () -> Void in
            weakSelf?.updateLines(lines: (weakSelf?.horizontalGridLines)!, horizontal: true)
            weakSelf?.updateLines(lines: (weakSelf?.verticalGridLines)!, horizontal: false)
        }
        
        if animate {
            UIView.animate(withDuration: 0.25, animations: animationBlock)
        }else{
            animationBlock()
        }
        
    }
    
    private func updateLines(lines:[UIView],horizontal:Bool) -> () {
        
        for i in 0..<lines.count {
            let lineView = lines[i]
            var x_x = self.frame.width / (CGFloat(lines.count) + 1.0) * CGFloat(i + 1)
            var y_y = self.frame.height / (CGFloat(lines.count) + 1.0) * CGFloat(i + 1)
            var w_w = 1 / UIScreen.main.scale
            var h_h = 1 / UIScreen.main.scale
            
            if horizontal {
                x_x = 0
                w_w = self.frame.width
            }else{
                y_y = 0
                h_h = self.frame.height
            }
            
            lineView.frame = CGRect(x: x_x,
                                    y: y_y,
                                width: w_w,
                               height: h_h)
        }
        
    }
    
    
    private func dismissCropLines() -> () {
        UIView.animate(withDuration: 0.2, animations: {
            self.dismissLines(lines: self.horizontalCropLines)
            self.dismissLines(lines: self.verticalCropLines)
        }) { (finish) in
            self.cropLinesDismissed = true
        }
    }
    
    func dismissGridLines() -> () {
        UIView.animate(withDuration: 0.2, animations: { 
            self.dismissLines(lines: self.horizontalGridLines)
            self.dismissLines(lines: self.verticalGridLines)
            }) { (finish) in
                self.gridLinesDismissed = true
        }
    }
    
    func showCropLines() -> () {
        cropLinesDismissed = false
        UIView.animate(withDuration: 0.2) { 
            self.showLines(lines: self.horizontalCropLines)
            self.showLines(lines: self.verticalCropLines)
        }
    }
    private func showGridLines() -> () {
        gridLinesDismissed = false
        UIView.animate(withDuration: 0.2) {
            self.showLines(lines: self.horizontalGridLines)
            self.showLines(lines: self.verticalGridLines)
        }
    }
    private func showLines(lines:[UIView]) -> () {
        for view in lines {
            view.alpha = 1.0;
        }
    }
    private func dismissLines(lines:[UIView]) -> () {
        for view in lines {
            view.alpha = 0.0;
        }
    }
    
}
