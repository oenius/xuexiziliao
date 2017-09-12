//
//  ListViewCell.swift
//  VideoCompress
//
//  Created by 何少博 on 16/11/15.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

import UIKit
import Photos
class ListViewCell: UITableViewCell {

 
    //初始化方法
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.value1, reuseIdentifier: reuseIdentifier)
        textLabel?.font = UIFont.systemFont(ofSize: 14)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        backgroundColor = back_Color
        textLabel?.textColor = UIColor.white
        detailTextLabel?.textColor = UIColor.lightGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    /*
     *    加载数据方法
     */
    func loadPhotoListData(listModel:TZAlbumModel?) -> () {
        guard let model = listModel else {
            return
        }
        accessoryType = .disclosureIndicator
        textLabel?.text = model.name
        detailTextLabel?.text = "\(model.count)"
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
