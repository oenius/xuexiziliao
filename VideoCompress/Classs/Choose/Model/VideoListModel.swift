//
//  VideoListModel.swift
//  PhotoPicker
//
//  Created by 何少博 on 16/11/7.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

import UIKit
import Photos
class VideoListModel: NSObject {

    var count:Int = 0

    var lastObject:PHAsset?

    var title:String?
    
    var fetchArray:[Any]?

    var assetCollection:PHAssetCollection?
}
