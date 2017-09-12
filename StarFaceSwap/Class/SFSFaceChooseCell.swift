//
//  SFSFaceChooseCell.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/6.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit

let kShakeKey = "kShakeKey"

class SFSFaceChooseCell: UICollectionViewCell {
    
    typealias delelteBlock = (_ model:SFSFaceChooseCellModel)->Void
    
    var model:SFSFaceChooseCellModel? {
        didSet{
            let name:String = (model?.imageName!)!
//            let path = Bundle.main.path(forResource: name, ofType: nil)
            let imagePath = SFSDataManager.shareInstance().getFaceFolder().appending("/\(name)")
            imageView.image = UIImage(contentsOfFile: imagePath)
            isEditState = (model?.isEditSate)!
            isSelectedState = model?.isSelected
        }
    }
    
    fileprivate var block:delelteBlock?
    fileprivate var deleButton:UIButton!
    fileprivate var imageView:UIImageView!
    fileprivate var isSelectedState:Bool?{
        didSet{
            if isSelectedState! {

                self.layer.borderColor = UIColor(hexString: "57bfff").cgColor
            }else{
                self.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    fileprivate var isEditState:Bool?{
        didSet{
            if isEditState! {
                addShake()
                deleButton.isHidden = false
            }else{
                self.layer.removeAnimation(forKey: kShakeKey)
                deleButton.isHidden = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 2
        setupSubView()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func addShake(){
        let shake = CABasicAnimation(keyPath: "transform")
        shake.duration = 0.125
        shake.autoreverses = true
        shake.repeatCount = MAXFLOAT
        shake.isRemovedOnCompletion = false
        let tran3DF = CATransform3DRotate(self.layer.transform, -0.05, 0, 0, 0.3)
        let tran3DT = CATransform3DRotate(self.layer.transform, 0.05, 0, 0, 0.3)
        shake.fromValue = NSValue(caTransform3D: tran3DF)
        shake.toValue = NSValue(caTransform3D: tran3DT)
        self.layer.add(shake, forKey: kShakeKey)
    }
    
    
    fileprivate func setupSubView(){
        imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        deleButton = UIButton()
        deleButton.setImage(UIImage(named:"delete.png"), for: .normal)
//        deleButton.setBackgroundImage(UIImage(named:"delete.png"), for: .normal)
        deleButton.addTarget(self, action: #selector(deleteBtnClick), for: .touchUpInside)
        deleButton.isHidden = true
        self.addSubview(deleButton)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
        let width:CGFloat = 40.0
        deleButton.frame = CGRect(x: self.bounds.width-width+10, y: self.bounds.height-width+10, width: width, height: width)
    }
    
    
    @objc fileprivate func deleteBtnClick() -> () {
        if self.block != nil {
            self.block!(model!)
        }
    }
    
    func deleteAction(block_:@escaping delelteBlock) -> () {
        self.block = block_
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.borderColor = UIColor.clear.cgColor
    }
}
