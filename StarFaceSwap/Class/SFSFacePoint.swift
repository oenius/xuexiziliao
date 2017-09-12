//
//  SFSFacePoint.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/6.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit

let kXCoder = "kXCoder"
let kYCoder = "kYCoder"

//可以不遵守NSCopying协议
class SFSFacePoint: NSObject,NSCoding,NSCopying{
    var x:Float = 0
    var y:Float = 0
    
     required init?(coder aDecoder: NSCoder) {
        x = Float(aDecoder.decodeFloat(forKey: kXCoder))
        y = Float(aDecoder.decodeFloat(forKey: kYCoder))
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(x, forKey: kXCoder)
        aCoder.encode(y, forKey: kYCoder)
    }
    override init(){
        super.init()
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = SFSFacePoint()
        copy.x = x
        copy.y = y
        return copy
    }
   
}
