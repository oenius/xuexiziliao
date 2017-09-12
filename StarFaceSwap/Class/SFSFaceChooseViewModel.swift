//
//  SFSFaceChooseViewModel.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/7.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit

//暂时没用
let kAddFaceSuccessNotice = "kAddFaceSuccessNotice"
let kDeletedSuccessNotice = "kDeletedSuccessNotice"


class SFSFaceChooseViewModel: NSObject {
    
    fileprivate var dataSourceArray = [Any]()
    fileprivate var sectionData_0 = [SFSFaceChooseCellModel]()
    fileprivate var sectionData_1 = [SFSFaceChooseCellModel]()
    override init() {
        super.init()
        setSection_0()
        setSection_1()
        dataSourceArray.append(sectionData_0)
        dataSourceArray.append(sectionData_1)
    }
    
    
    
    fileprivate func setSection_0() -> () {
        //分区0
        let model_0 = SFSFaceChooseCellModel()
        model_0.imageName = "add.png"
        model_0.isEditSate = false
        sectionData_0.append(model_0)
    }
    
    fileprivate func setSection_1() -> () {
        //分区1
        let dataDic = SFSDataManager.shareInstance().getFacePointArray()!
        
        let allKeys = dataDic.keys
        let sortKeys = allKeys.sorted(by: {(s1:String,s2:String)-> Bool in return s1 > s2 })
        var count = sortKeys.count
        let shangXian = shiFouShangXian()
        if shangXian == false {
            count = count - 13
        }
        for i in 0..<count {
            let key_name = sortKeys[i]
//            let model = SFSFaceChooseCellModel(imageName_: key_name, pointArray: dataDic[key_name])
            let model = SFSFaceChooseCellModel()
            model.imageName = key_name
            model.points = dataDic[key_name]
            sectionData_1.append(model)
        }
        
//        for key_name in sortKeys {
//            printLog(key_name)
//            let model = SFSFaceChooseCellModel(imageName_: key_name, pointArray: dataDic[key_name])
//            sectionData_1.append(model)
//        }
    }
    
    fileprivate func shiFouShangXian()->Bool{
        let isShangXian = NPCommonConfig.shareInstance().isCurrentVersionOnline()
        let days = NPCommonConfig.shareInstance().appUseDaysCount()
        if isShangXian || days > 0 {
            return true
        }else{
            return false
        }
    }
    
    func setToEidtState(isEdit:Bool) -> () {
        let model_0 = sectionData_0[0]
        if isEdit {
            model_0.imageName = "wancheng.png"
        }else{
            model_0.imageName = "add.png"
        }
        for model in sectionData_1 {
            model.isEditSate = isEdit
        }
    }
    func setSelectedState(selectedState:Bool,at indexPath:IndexPath) -> () {
        
        for model in sectionData_1 {
            model.isSelected = !selectedState
        }
        let model_in = getModelAtIndexPath(indexPath_: indexPath)
        model_in?.isSelected = selectedState
    }
    func getModelAtIndexPath(indexPath_:IndexPath) -> SFSFaceChooseCellModel? {
        if indexPath_.section == 0 {
            return sectionData_0[indexPath_.row]
        }
        else if indexPath_.section == 1{
            if sectionData_1.count <= 0 {
                return nil
            }
            return sectionData_1[indexPath_.row]
        }
        else {
            return nil
        }
    }
    
    func numberOfSections() -> Int {
        return dataSourceArray.count
    }
    
    func numberOfItemsInSection(section: Int) -> Int{
        if section == 0 {
            return sectionData_0.count
        }
        else if section == 1{
            return sectionData_1.count
        }
        else{
            return 0
        }
    }
    
    func saveFaceData(imageName:String,points:[SFSFacePoint]) -> () {
//        let model = SFSFaceChooseCellModel(imageName_: imageName, pointArray: points)
        let model = SFSFaceChooseCellModel()
        model.imageName = imageName
        model.points = points
        sectionData_1.insert(model, at: 0)
        SFSDataManager.shareInstance().saveFaceDataToDefault(imageName: imageName, points: points)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kAddFaceSuccessNotice), object: nil)
    }
    func deletedFaceDate(imageName:String,at indexPath:IndexPath)-> (){
        if indexPath.section == 1 {
            sectionData_1.remove(at: indexPath.row)
            printLog(indexPath)
            printLog(imageName)
            SFSDataManager.shareInstance().deleteFaceDataAtDefault(imageName: imageName)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kDeletedSuccessNotice), object: nil)
        }    }
    
}
