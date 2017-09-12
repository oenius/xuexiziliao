//
//  UIButton_EXT.swift
//  VideoCompress
//
//  Created by 何少博 on 17/4/10.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit

extension UIButton{
    
    enum ButtonTitlePosition {
        case left
        case bottom
    }
    
    func setButtonTitlePosition(position:ButtonTitlePosition) -> Void {
        self.titleLabel?.sizeToFit()
        guard let titleSize = self.titleLabel?.bounds.size else {
            return;
        }
        guard let imageSize = self.imageView?.bounds.size  else {
            return;
        }
        let interval:CGFloat = 1.0
        if position == .left {
            self.imageEdgeInsets = UIEdgeInsetsMake(0,
                                                    titleSize.width+interval,
                                                    0,
                                                     -(titleSize.width + interval))
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageSize.width + interval),
                                                    0,
                                                    imageSize.width + interval)
        }else{
            self.imageEdgeInsets = UIEdgeInsetsMake(0,
                                                    0,
                                                    titleSize.height + interval,
                                                    -(titleSize.width))
            self.titleEdgeInsets = UIEdgeInsetsMake(imageSize.height + interval,
                                                    -(imageSize.width),
                                                    0,
                                                    0)
        }
    }
    
}
