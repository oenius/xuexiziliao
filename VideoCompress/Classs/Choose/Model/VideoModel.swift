//
//  VideoModel.swift
//  PhotoPicker
//
//  Created by 何少博 on 16/11/10.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

import UIKit
import Photos
class VideoModel: NSObject {

    var phasset:PHAsset?
    var avasset:AVAsset? 
    var representedAssetIdentifier:String?
    var thumImage:UIImage?
    var pixelWidth: Int = 0
    var pixelHeight: Int = 0
    var creationDate: Date?
    var duration: TimeInterval = 0.0
    var bitrate:Float = 0
    var fileSize:Int64 = 0
    var isSelect:Bool = false
    var compressDetail:CompressDetail = CompressDetail()
    var isiCloud:Bool = false
}
