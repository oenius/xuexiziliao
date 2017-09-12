//
//  SFSFilterCollectionViewCell.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/8.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit

class SFSFilterCollectionViewCell: UICollectionViewCell {
     var filterNameLabel: UILabel!
     var imageView: UIImageView!
     var suoImageView:UIImageView!
     var maskTmpView:UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        self.backgroundColor = UIColor(hexString: "578fff")
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() -> () {
        filterNameLabel = UILabel()
        filterNameLabel.adjustsFontSizeToFitWidth = true
        filterNameLabel.numberOfLines = 1
        filterNameLabel.textColor = UIColor.white
        filterNameLabel.textAlignment = .center
        addSubview(filterNameLabel)
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
        
        maskTmpView = UIView()
        maskTmpView.contentMode = .scaleAspectFill
        maskTmpView.clipsToBounds = true
        maskTmpView.backgroundColor = UIColor.clear
        addSubview(maskTmpView)
        
        suoImageView = UIImageView()
        suoImageView.contentMode = .scaleAspectFit
        suoImageView.clipsToBounds = true
        addSubview(suoImageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height = self.bounds.size.width
        imageView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: height, height: height))
        maskTmpView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: height, height: height))
        filterNameLabel.frame = CGRect(x: 0, y: height, width: self.bounds.size.width, height: self.bounds.size.height-height)
        suoImageView.frame = CGRect(x: height-40, y: height-40, width: 40, height: 40)
        suoImageView.center = imageView.center
    }
    
}










