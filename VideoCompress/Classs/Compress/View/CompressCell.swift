//
//  CompressCell.swift
//  VideoCompress
//
//  Created by 何少博 on 16/11/14.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

import UIKit
import Photos
class CompressCell: UITableViewCell {
    typealias previewSelect = (_ isAfter:Bool,_ model:TZAssetModel) -> Void

    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myTimeLabel: UILabel!
    
    
    @IBOutlet weak var beforeContentView: UIView!
    @IBOutlet weak var beforeLabel: UILabel!
    @IBOutlet weak var beforeHDLabel: UILabel!
    @IBOutlet weak var beforeBitRateLabel: UILabel!
    @IBOutlet weak var beforeSizeLabel: UILabel!
    @IBOutlet weak var beforePreviewBtn: UIButton!
    
    
    @IBOutlet weak var afterContentView: UIView!
    @IBOutlet weak var afterLabel: UILabel!
    @IBOutlet weak var afterHDLabel: UILabel!
    @IBOutlet weak var afterBitRateLabel: UILabel!
    @IBOutlet weak var afterSizeLabel: UILabel!
    @IBOutlet weak var afterPreviewBtn: UIButton!
    
    
    var previewClick:previewSelect!
    var model:TZAssetModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        afterPreviewBtn.addTarget(self, action: #selector(afterPreviewBtnClick), for: .touchUpInside)
        afterPreviewBtn.layer.borderColor = UIColor.white.cgColor
        afterPreviewBtn.layer.borderWidth = 1
        afterPreviewBtn.setTitle(COMPRESS_Preview, for: .normal)
        afterLabel.text = COMPRESS_after
//        afterContentView.layer.borderColor = UIColor.white.cgColor
//        afterContentView.layer.borderWidth = 1
        
        beforePreviewBtn.addTarget(self, action: #selector(beforePreviewBtnClick), for: .touchUpInside)
        beforePreviewBtn.layer.borderColor = UIColor.white.cgColor
        beforePreviewBtn.layer.borderWidth = 1
        beforePreviewBtn.setTitle(COMPRESS_Preview, for: .normal)
        beforeLabel.text = COMPRESS_before
//        beforeContentView.layer.borderColor = UIColor.white.cgColor
//        beforeContentView.layer.borderWidth = 1
    }

    func loadVideoDataWithBlock(video:TZAssetModel,preview:@escaping previewSelect) {
        previewClick = preview
        model = video
        loadModelData(video: video)
    }
    func loadModelData(video:TZAssetModel) {
        myImageView.image = video.thumImage
        myTimeLabel.text = secondToTimeSting(time: video.duration)
        beforeHDLabel.text = "\(video.pixelWidth)X\(video.pixelHeight)"
        beforeSizeLabel.text = StringWithFileSize(size_t: video.fileSize)
        beforeBitRateLabel.text = StringWithFilebitRate(size_t: video.bitrate)
        let detail = video.compressDetail
            afterHDLabel.text = "\(detail.width)X\(detail.height)"
            //        let sizeValue = (Float(detail.bitRate+128000))/1000.0/8.0*Float(model.duration)*1024
            let sizeValue = (Float(detail.bitRate+128000))/1024.0/8.0*Float(model.duration)*1024
            let size = Int(sizeValue)
            afterSizeLabel.text = "≈\(StringWithFileSize(size_t: size))"
            afterBitRateLabel.text = StringWithFilebitRate(size_t: CGFloat(detail.bitRate))
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func secondToTimeSting(time:CGFloat?) -> String? {
        guard let newTime = time else {
            return nil
        }
        let date = NSDate(timeIntervalSince1970:TimeInterval(newTime))
        let formatter = DateFormatter()
        if newTime/3600 >= 1 {
            formatter.dateFormat = "HH:mm:ss"
        }else{
            formatter.dateFormat = "mm:ss"
        }
        return formatter.string(from: date as Date)
    }
    //MARK: - actions
    
    func beforePreviewBtnClick(){
        previewClick(false,model)
    }
    
    func afterPreviewBtnClick(){
        previewClick(true,model)
    }
    //MARK: - 字符转换
    func StringWithFileSize(size_t:Int?) -> String?{
        var stringSize = ""
        guard let size = size_t else {
            return nil
        }
        if size < 1000 {
            stringSize = String(format: "%1luB", size)
        }
        else if size < 1000 * 1024{
            stringSize = String(format: "%.1fKB", Double(size)/1024.0)
        }
        else if size < 1000 * 1024 * 1024{
            stringSize = String(format: "%.1fMB", Double(size)/(1024.0*1024))
        }
        else {
            stringSize = String(format: "%.1fGB", Double(size)/(1024.0 * 1024 * 1024))
        }
        return stringSize
    }
    func StringWithFilebitRate(size_t:CGFloat?) -> String?{
        guard let size = size_t else {
            return nil
        }
        var stringSize = ""
        if size < 1000 {
            stringSize = String(format: "%.0fbps", size)
        }
        else {
            stringSize = String(format: "%.0fkbps", Double(size)/1024.0)
        }
//        else if size < 1000 * 1000 * 1000{
//            stringSize = String(format: "%.1fMkbps", Double(size)/(1000.0*1000))
//        }
//        else {
//            stringSize = String(format: "%.1fGkbps", Double(size)/(1000.0 * 1000.0 * 1000.0))
//        }
        return stringSize
    }
}
