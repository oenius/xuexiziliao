//
//  VideoCompressDefine.swift
//  VideoCompress
//
//  Created by 何少博 on 16/11/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

import Foundation

let isFirst = "isFirst"
let compress_detail_key = "compressDetail"
let AssetChangedSuccssed_key = "AssetChangedSuccssed_key"


let back_Color = UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1)
//获取沙盒主目录路径
let homeDir = NSHomeDirectory()

//获取Documents目录路径
let documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first

// 获取Library目录路径
let libraryDire = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first

// 获取Caches目录路径
let cacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first

// 获取tmp目录路径
let tmpDir = NSTemporaryDirectory()


//MARK: - 国际化词条
/* 压缩 */
let COMPRESS_Compress = NSLocalizedString("compression", comment: "compression")
/* 裁剪 */
let COMPRESS_Crop = NSLocalizedString("gallery.Crop", comment: "Crop")
/* 编辑 */
let COMPRESS_Edit = NSLocalizedString("edit", comment: "Edit")
/* 删除 */
let COMPRESS_Delete = NSLocalizedString("delete", comment: "Delete")
/* 完成 */
let COMPRESS_Done = NSLocalizedString("bb_Done", comment: "Done")
/* 保存 */
let COMPRESS_Save = NSLocalizedString("baby.save2", comment: "Save")
/* 分享 */
let COMPRESS_Share = NSLocalizedString("baby_Share", comment: "Share")

/* 删除失败原因 */
let COMPRESS_deleteFiledDetail = NSLocalizedString("deleteFiled.detail", comment: "You refused to delete or the video you selected contained videos synced from icloud or computer.")
//"deleteFiled.detail" = "You refused to delete or the video you selected contained videos synced from icloud or computer.";
/* 正在压缩 */
let COMPRESS_compressing = NSLocalizedString("Compressing", comment: "Compressing")
//"Compressing" = "Compressing";

/* 注意：在压缩过程中请不要关闭程序或者锁定设备 */
let COMPRESS_notics = NSLocalizedString("Note.compressing", comment: "Note:Don't close the program or lock the device during compression")
//"Note.compressing" = "Note:Don't close the program or lock the device during compression";

/* 添加 */
let COMPRESS_add = NSLocalizedString("gallery.Add", comment: "Add")
//"gallery.Add" = "Add";

/* 压缩文件 */
let COMPRESS_compressFile = NSLocalizedString("Compress File", comment: "Compress File")
//"Compress File" = "Compress File";

/* 压缩前 圧縮前*/
let COMPRESS_before = NSLocalizedString("Before compression", comment: "Before compression")

/* 压缩后 圧縮後*/
let COMPRESS_after = NSLocalizedString("After compression", comment: "After compression")

/* 未完成 */
let COMPRESS_unfinished = NSLocalizedString("MagicDay.Unfinished", comment: "Unfinished")

/* 确定 */
let COMPRESS_ok = NSLocalizedString("OK", comment: "OK")

/* 取消 */
let COMPRESS_cancel = NSLocalizedString("common.Cancel", comment: "Cancel")

/* 已完成 */
let COMPRESS_completed = NSLocalizedString("task.completed", comment: "Completed")
//"task.completed" = "Completed";

/* 成功保存到相册! */
let COMPRESS_saveSuccess = NSLocalizedString("HCShareSuccess", comment: "Successfully saved to album!")
//"HCShareSuccess" = "Successfully saved to album!";

/* 提示信息 */
let COMPRESS_prompt = NSLocalizedString("user.Prompt", comment: "Prompt")
//"user.Prompt" = "Prompt";

/* 节省手机空间步骤介绍第三部 */
let COMPRESS_deletedPrompt = NSLocalizedString("save_space.alert to show backup and cleanup workflow step three description", comment: "Cleaned  photos and videos will go to the \"Recently Deleted\"  album, where they will be automatically  deleted after 30 days. Users can also delete them manually.")
//"save_space.alert to show backup and cleanup workflow step three description" = "Cleaned  photos and videos will go to the \"Recently Deleted\"  album, where they will be automatically  deleted after 30 days. Users can also delete them manually.";

/* 删除失败 */
let COMPRESS_deletedFaild = NSLocalizedString("pocketbook.delete failed", comment: "Failed to delete")
//"pocketbook.delete failed" = "Failed to delete";

/* 宽度 */
let COMPRESS_width = NSLocalizedString("Width", comment: "Width")
//"Width" = "Width";

/* 高度 */
let COMPRESS_height = NSLocalizedString("Height", comment: "Height")
//"Height" = "Height";

/* 分钟 */
let COMPRESS_minute = NSLocalizedString("Minute", comment: "Minute")
//"Minute" = "Minute";

/* 返回 */
let COMPRESS_back = NSLocalizedString("camera.back", comment: "Back")
//"camera.back" = "Back";

/* 您设置了不允许访问，请到设置->隐私->照片里设置打开程序的访问权限 */
let COMPRESS_setPhotosPrivacy = NSLocalizedString("You disabled access, please go to Settings-> Privacy->Photos to set up access", comment: "You disabled access, please go to Settings-> Privacy->Photos to set up access")
//"You disabled access, please go to Settings-> Privacy->Photos to set up access" = "You disabled access, please go to Settings-> Privacy->Photos to set up access";

/* 旅游常用语设置界面标题 */
let COMPRESS_settings = NSLocalizedString("Settings", comment: "Settings")
//"Settings" = "Settings";

/* 比特率 */
let COMPRESS_bitrate = NSLocalizedString("Bit rate", comment: "Bit rate")
//"Bit rate" = "Bit rate";

/* 正在生成预览 */
let COMPRESS_previewing = NSLocalizedString("Previewing is taking place", comment: "Preview is generating")
//"Previewing is taking place" = "Preview is generating";

/* 是否删除原始视频 */
let COMPRESS_deleteOriginalVideo = NSLocalizedString("delete the original video", comment: "Whether to delete the original video?")
//"delete the original video" = "Whether to delete the original video?";

/* 请选择文件 */
let COMPRESS_selectItems = NSLocalizedString("select items", comment: "Please choose the file")
//"select items" = "Please choose the file";

/* 预览 */
let COMPRESS_Preview = NSLocalizedString("PIC.Preview", comment: "Preview")
//"PIC.Preview" = "Preview";


