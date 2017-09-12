//
//  HDChooseModel.swift
//  VideoCompress
//
//  Created by 何少博 on 16/11/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

import UIKit

class HDChooseModel: NSObject {
    var width:NSString?
    var bitRate:NSString?
    var height:NSString?
    var hd:NSString?
    
    
    init(dic:Dictionary<String,NSString>) {
      super.init()
        width = dic["width"]
        height = dic["height"]
        bitRate = dic["bitRate"]
        hd = NSString(format: "%@x%@",width!,height!)
    }
}
