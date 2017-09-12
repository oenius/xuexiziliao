//
//  VideoHDChooseCell.swift
//  VideoCompress
//
//  Created by 何少博 on 16/11/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

import UIKit

class VideoHDChooseCell: UITableViewCell {

    @IBOutlet weak var hdLabel: UILabel!
    @IBOutlet weak var bitRateLabrl: UILabel!
    @IBOutlet weak var aboutSizeLabrl: UILabel!
    
    var model:HDChooseModel!{
        didSet{
            hdLabel.text = model.hd as String?
            bitRateLabrl.text = StringWithFilebitRate(size: (model.bitRate?.floatValue)!)
            let sizeValue = (Float((model.bitRate?.floatValue)!+128000))/1024.0/8.0*60*1024
            
            aboutSizeLabrl.text = "≈\(StringWithFileSize(size: Int64(sizeValue)))/\(COMPRESS_minute)"
        }
    }
    func StringWithFileSize(size:Int64) -> String{
        var stringSize = ""
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
    func StringWithFilebitRate(size:Float) -> String{
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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
