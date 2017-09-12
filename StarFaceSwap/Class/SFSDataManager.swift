//
//  SFSDataManager.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/7.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit
let kIsFisrtStart       = "kIsFisrtStart"
let kFacePointDic       = "kFacePointDic"
let kChangeFaceTimes    = "kChangeFaceTimes"
let kShowADTimes        = "kShowADTimes"
let kIsBack             = "kIsBack"

class SFSDataManager: NSObject {
    fileprivate static let instance = SFSDataManager()
    static func shareInstance() -> SFSDataManager {
        return instance
    }
    
    func clearTmpFolder() -> () {

        let tmpPath = getTmpFolder()
        var contents:[String] = []
        do {
             contents = try FileManager.default.contentsOfDirectory(atPath: tmpPath)
            
        } catch  {
            printLog("获取tmp文件内容失败")
        }
        
        if contents.count > 0 {
            for fileName in contents {
                let filePath = tmpPath.appending(fileName)
              let isExist = FileManager.default.fileExists(atPath: filePath)
                if isExist {
                    do {
                        try FileManager.default.removeItem(atPath: filePath)
                    } catch  {
                        printLog("\(filePath) 删除失败")
                    }
                    
                }
            }
        }
        
    }
    
    func getTmpFolder() -> String {
        let tmp = NSTemporaryDirectory()
        return tmp
    }
    
    func getFaceFolder() -> String {
        var docm = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        docm += "/faces"
        let isExist = FileManager.default.fileExists(atPath: docm)
        if !isExist {
            do {
                try FileManager.default.createDirectory(atPath: docm, withIntermediateDirectories: true, attributes: nil)
            } catch{
                printLog("创建文件夹错误")
            }
        }
        return docm
    }
    
    
    func isFirstLaunch() -> Bool {
        let isFisrt = UserDefaults.standard.bool(forKey: kIsFisrtStart)
        if isFisrt {
            return false
        }
        let kk:Bool = true
        UserDefaults.standard.set(kk, forKey: kIsFisrtStart)
        UserDefaults.standard.set(0, forKey: kChangeFaceTimes)
        UserDefaults.standard.set(5, forKey: kShowADTimes)
//        let isBack:Bool = false
        UserDefaults.standard.set(false, forKey: kIsBack)
        UserDefaults.standard.synchronize()
        return true
    }
    func setFacePointDic(dic:Dictionary<String,[SFSFacePoint]>) -> () {
        let dicData = NSKeyedArchiver.archivedData(withRootObject: dic)
        UserDefaults.standard.set(dicData, forKey: kFacePointDic)
        UserDefaults.standard.synchronize()
    }
    func getFacePointArray() -> Dictionary<String,[SFSFacePoint]>? {
        let faceData = UserDefaults.standard.object(forKey: kFacePointDic) as! Data
        let dic = NSKeyedUnarchiver.unarchiveObject(with: faceData) as? Dictionary<String, [SFSFacePoint]>
        return dic
    }
    
    
    func saveFaceDataToDefault(imageName:String,points:[SFSFacePoint]) -> () {
        var dic = getFacePointArray()
        dic?[imageName] = points
        setFacePointDic(dic: dic!)
    }
    func deleteFaceDataAtDefault(imageName:String) -> () {
        var dic = getFacePointArray()
        _ = dic?.removeValue(forKey: imageName)
        setFacePointDic(dic: dic!)
        printLog(dic)
    }
    
    func getRandom(min:UInt32,max:UInt32) -> UInt32 {
        let round = max+1 - min
        return arc4random_uniform(round) + min
    }
    
    func isShouldShowAD() -> Bool {
        
        var times = UserDefaults.standard.integer(forKey: kChangeFaceTimes)
        let showADTimes = UserDefaults.standard.integer(forKey: kShowADTimes)
        if times >= showADTimes {
            let newShowADTimes = Int(getRandom(min: 4, max: 6))
            UserDefaults.standard.set(0, forKey: kChangeFaceTimes)
            UserDefaults.standard.set(newShowADTimes, forKey: kShowADTimes)
            return true
        }else{
            times = times + 1
            UserDefaults.standard.set(times, forKey: kChangeFaceTimes)
            return false
        }
    }
    func setIsBack() -> () {
        UserDefaults.standard.set(true, forKey: kIsBack)
        UserDefaults.standard.synchronize()
    }
    func isBack() -> Bool {
        let isBack = UserDefaults.standard.bool(forKey: kIsBack)
        if isBack {
            UserDefaults.standard.set(false, forKey: kIsBack)
            return true
        }else{
            return false
        }
    }
}
