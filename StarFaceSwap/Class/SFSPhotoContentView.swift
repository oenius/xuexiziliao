//
//  SFSPhotoContentView.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/2.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit

class SFSPhotoContentView: UIView {

    var imageView:UIImageView?
    var image:UIImage?
    
    init(image:UIImage) {
        super.init(frame: CGRect.zero)
        self.image = image
        self.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        imageView = UIImageView()
        imageView?.image = image
        imageView?.isUserInteractionEnabled = true
        addSubview(imageView!)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.frame = self.bounds
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
