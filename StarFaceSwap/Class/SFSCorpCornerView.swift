//
//  SFSCorpCornerView.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/2.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit

enum CropCornerType {
    case upperLeft
    case upperRight
    case lowerRight
    case lowerLeft
}


class SFSCorpCornerView: UIView {

    init(type:CropCornerType) {
        super.init(frame: CGRect.zero)
        self.frame = CGRect(x: 0, y: 0, width:kCropViewCornerLength, height: kCropViewCornerLength)
        backgroundColor = UIColor.clear
        let lineWidth:CGFloat = 5.0
        let horizontal = UIView(frame: CGRect(x: 0, y: 0, width: kCropViewCornerLength, height: lineWidth))
        horizontal.backgroundColor = UIColor.white
        addSubview(horizontal)
        
        let vertical = UIView(frame: CGRect(x: 0, y: 0, width: lineWidth, height: kCropViewCornerLength))
        vertical.backgroundColor = UIColor.white
        addSubview(vertical)
        if type == .upperLeft {
            horizontal.center = CGPoint(x: kCropViewCornerLength / 2, y: lineWidth / 2)
            vertical.center = CGPoint(x: lineWidth / 2, y: kCropViewCornerLength / 2)
        }
        else if type == .upperRight{
            horizontal.center = CGPoint(x: kCropViewCornerLength / 2, y: lineWidth / 2)
            vertical.center = CGPoint(x: kCropViewCornerLength - lineWidth / 2, y: kCropViewCornerLength / 2)
        }
        else if type == .lowerRight{
            horizontal.center = CGPoint(x: kCropViewCornerLength / 2, y: kCropViewCornerLength - lineWidth / 2)
            vertical.center = CGPoint(x: kCropViewCornerLength - lineWidth / 2, y: kCropViewCornerLength / 2)
        }
        else if type == .lowerLeft{
            horizontal.center = CGPoint(x: kCropViewCornerLength / 2, y: kCropViewCornerLength - lineWidth / 2)
            vertical.center = CGPoint(x: lineWidth / 2, y: kCropViewCornerLength / 2)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
