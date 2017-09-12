//
//  VideoChooseCell.swift
//  VideoCompress
//
//  Created by 何少博 on 16/11/14.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

import UIKit
import Photos
class VideoChooseCell: UICollectionViewCell {
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myTimeLabel: UILabel!
    @IBOutlet weak var selectBtn: UIButton!
    
    fileprivate weak var assetModel:TZAssetModel?
    var selectBlock:(()->Void)?
    var isSelect:Bool {
        didSet{
            if isSelect == true {
                selectBtn.isHidden = false
                selectBtn.setImage(UIImage(named: "select_yes.png"), for: UIControlState.normal)
            }else{
                if (assetModel?.isEdit)!  {
                    selectBtn.setImage(UIImage(named: "select_no.png"), for: UIControlState.normal)
                    selectBtn.isHidden = false
                }else{
                    selectBtn.setImage(nil, for: .normal)
                    selectBtn.isHidden = true
                }
            }
        }
    }
    
    func loadVideoData(videoAsset:TZAssetModel?) -> () {
        guard let model = videoAsset else {
            return
        }
        self.assetModel = model
        if model.isSelected == true {
            selectBtn.isHidden = false
            selectBtn.setImage(UIImage(named: "select_yes.png"), for: .normal)
        }else{
            if model.isEdit {
                selectBtn.setImage(UIImage(named: "select_no.png"), for: .normal)
                selectBtn.isHidden = false
            }else{
                selectBtn.setImage(nil, for: .normal)
                selectBtn.isHidden = true
            } 
        }
//        myImageView.image = UIImage(named:"no_data")
        
        TZImageManager.shareInstance().getVideoAssetThumImageAndOther(model) { (detail) in
            
            weak var weakSelf = self
            let thumImage = detail?[kAssetThumImageKey] as? UIImage
                model.thumImage = thumImage ?? UIImage(named:"no_data")
                DispatchQueue.main.async {
                    weakSelf?.myImageView.image = model.thumImage
                }
            let duraNum = detail?[kAssetDurationKey] as? NSNumber
                model.duration = CGFloat((duraNum?.floatValue)!)
            let widthNum = detail?[kAssetPixelWidthKey] as? NSNumber
                model.pixelWidth = widthNum?.intValue ?? 0
            let heightNum = detail?[kAssetPixelHeightKey] as? NSNumber
                model.pixelHeight = heightNum?.intValue ?? 0
            let creatDate = detail?[kAssetCreationDate] as? NSDate
                model.creationDate = creatDate as? Date ?? Date()
            
        }
        myTimeLabel.text = model.timeLength
    }
    @IBAction func selectPhotoButtonMethod(_ sender: UIButton) {
        selectBlock!()
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
    required init?(coder aDecoder: NSCoder) {
        isSelect = false
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myImageView.contentMode = .scaleAspectFill
    }

}
