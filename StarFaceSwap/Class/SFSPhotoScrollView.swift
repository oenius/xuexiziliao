//
//  SFSPhotoScrollView.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/2.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit

class SFSPhotoScrollView: UIScrollView {

    var photoContentView:SFSPhotoContentView?
    
    func setContentOffsetY(offsetY:CGFloat) -> () {
        var contentOffset = self.contentOffset
        contentOffset.y = offsetY
        self.contentOffset = contentOffset
    }
    
    func setContentOffsetX(offsetX:CGFloat) -> () {
        var contentOffset = self.contentOffset
        contentOffset.x = offsetX
        self.contentOffset = contentOffset
    }
    
    func zoomScaleToBound() -> CGFloat {
        let scaleW = self.bounds.size.width / (photoContentView?.bounds.size.width)!
        let scaleH = self.bounds.size.height / (photoContentView?.bounds.size.height)!
        let maxz = max(scaleW, scaleH)
        return maxz
    }

}
