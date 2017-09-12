//
//  SFSUtility.swift
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/2.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

import UIKit

func printLog<T>(_ message: T, file : String = #file, lineNumber : Int = #line) {
    
    #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("[\(fileName):line:\(lineNumber)]- \(message)")
        
    #endif
}

/* 设置 */
let SFS_settings = NSLocalizedString("MY_Settings", comment: "Settings")

/* 选择照片 */
let SFS_choosePhoto = NSLocalizedString("Select_Photo.", comment: "Select photo")

/* 从相册选择 */
let SFS_fromAlbum = NSLocalizedString("select_from_album", comment: "Select from the album")

/* 取消 */
let SFS_cancel = NSLocalizedString("Cancel", comment: "Cancel")

/* 重置 */
let SFS_reset = NSLocalizedString("resetImage", comment: "reset")

/* 确定 */
let SFS_ok = NSLocalizedString("DK_ok", comment: "OK")

/* 旋转 */
let SFS_rotate = NSLocalizedString("gallery.Rotate", comment: "Rotate")

/* 返回 */
let SFS_back = NSLocalizedString("Back", comment: "Back")

/* 编辑 */
let SFS_edit = NSLocalizedString("car.edit", comment: "Edit")

/* 正在合成 */
let SFS_mixing = NSLocalizedString("MM_Mixing", comment: "It is synthesizing")

/* 提示信息 */
let SFS_prompt = NSLocalizedString("user.Prompt", comment: "Prompt")

/* 当前应用没有此权限，是否前往设置权限 */
let SFS_settingPermissions = NSLocalizedString("BG_setting.permissions", comment: "No permission in current app,wether go to settings?")

/* 保存到相册 */
let SFS_saveToAlbum = NSLocalizedString("DK_saveToAlbum1", comment: "Save to Album")

/* 添加成功 */
let SFS_addSuccess = NSLocalizedString("Add_Success", comment: "Added successfully")

/* 保存 */
let SFS_save = NSLocalizedString("car.save", comment: "Save")

/* 保存失败 */
let SFS_saveFailed = NSLocalizedString("Save failed", comment: "Failed to save")

/* 保存成功 */
let SFS_saveSuccess = NSLocalizedString("Timer.save.success", comment: "Saved Successfully")

/* 分享 */
let SFS_share = NSLocalizedString("Share", comment: "Share")

/* 开始制作 */
let SFS_startMake = NSLocalizedString("StartMake", comment: "Start making")

/* 添加明星 */
let SFS_addStar = NSLocalizedString("addStar", comment: "Add star face")

/* 从相机拍照 */
let SFS_takePhoto = NSLocalizedString("takePhoto", comment: "Take pictures from the camera")

/* 正在检测，请稍后 */
let SFS_isTesyingWait = NSLocalizedString("isTesying_wait", comment: "Detecting, please wait")

/* 检测到多张人脸，请重新选择。 */
let SFS_moreFace = NSLocalizedString("Detect_more_than_one_face", comment: "Detected multiple faces, please re-select.")

/* 合成失败 */
let SFS_synthesisFailed = NSLocalizedString("Synthesis_failure", comment: "Synthesis failed")

/* 未检测到人脸，请重新选择。 */
let SFS_notFace = NSLocalizedString("Face_not_detected", comment: "No face detected, please re-select.")

