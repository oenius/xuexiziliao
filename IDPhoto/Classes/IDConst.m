//
//  IDConst.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/24.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDConst.h"
#import "NPCommonConfig.h"

NSString * const ID_TYPE_XIAOYICUN   = @"IP_xiaoyicun";
NSString * const ID_TYPE_YICUN       = @"IP_yicun";
NSString * const ID_TYPE_DAYICUN     = @"IP_dayicun";
NSString * const ID_TYPE_ERCUN       = @"IP_ercun";
NSString * const ID_TYPE_XIAOERCUN   = @"IP_xiaoercun";
NSString * const ID_TYPE_SANCUNCUN   = @"IP_sancun";
NSString * const ID_TYPE_WUCUN       = @"IP_wucun";
NSString * const ID_TYPE_S2R         = @"IP_S2R";
NSString * const ID_TYPE_2R          = @"IP_2R";
NSString * const ID_TYPE_S3R         = @"IP_S3R";
NSString * const ID_TYPE_3R          = @"IP_3R";
NSString * const ID_TYPE_4R          = @"IP_4R";


static BOOL _isShowADSafe = YES;

@implementation IDConst

+(instancetype)instance{
    static IDConst * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[IDConst alloc]init];
    });
    return instance;
}
/* 未检测到人脸 */
//"DK_Face not detected" = "No face was detected";
-(NSString *)NoFace{
    return NSLocalizedString(@"DK_Face not detected", @"No face was detected");
}
/* 继续 */
//"Resume" = "Resume";
-(NSString *)Resume{
    return NSLocalizedString(@"Resume", @"Resume");
}
/* 成功保存到相册! */
//"MsgSuccess" = "Successfully saved to album!";
-(NSString *)MsgSuccess{
    return NSLocalizedString(@"MsgSuccess", @"Successfully saved to album!");
}
/* 保存失败 */
//"Failed to save" = "Failed to save";
-(NSString *)FailedSave{
    return NSLocalizedString(@"Failed to save", @"Failed to save");
}
/* 正在处理... */
//"in_processing" = "Processing...";
-(NSString *)Processing{
    return NSLocalizedString(@"in_processing", @"Processing...");
}

/* 选择尺寸 */
//"choose size" = "Choose Size";
-(NSString *)ChooseSize{
    return NSLocalizedString(@"choose size", @"Choose Size");
}
/* 从相册选择 */
//"Select from the album" = "Select from the album";
-(NSString *)SelectFromAlbum{
    return NSLocalizedString(@"Select from the album", @"Select from the album");
}
/* 从相机拍照 */
//"babytakePhoto" = "Take pictures from the camera";
-(NSString *)TakePhoto{
    return NSLocalizedString(@"babytakePhoto", @"Take pictures from the camera");
}
/* 当前应用没有此权限，是否前往设置权限 */
//"G_setting.permissions" = "No permission in current app,wether go to settings?";
-(NSString *)NoPermissions{
    return NSLocalizedString(@"G_setting.permissions", @"No permission in current app,wether go to settings?");
}
/* 美颜 */
//"camera.face beauty" = "face beauty";
-(NSString *)FaceBeauty{
    return NSLocalizedString(@"camera.face beauty", @"face beauty");
}
/* 增强 */
//"enhance1" = "Enhance";
-(NSString *)Enhance{
    return NSLocalizedString(@"enhance1", @"Enhance");
}
/* 饱和度 */
//"ss_Saturation" = "Saturation";
-(NSString *)Saturation{
    return NSLocalizedString(@"ss_Saturation", @"Saturation");
}
/* 亮度 */
//"Brightness" = "Brightness";
-(NSString *)Brightness{
    return NSLocalizedString(@"Brightness", @"Brightness");
}
/* 对比度 */
//"Contrast" = "Contrast";
-(NSString *)Contrast{
    return NSLocalizedString(@"Contrast", @"Contrast");
}
/* 曝光度 */
//"NC.Exposure" = "Exposure degree";
-(NSString *)Exposure{
    return NSLocalizedString(@"NC.Exposure", @"Exposure degree");
}
/* 抠图 */
//"sectional_pic" = "Cutout";
-(NSString *)Cutout{
    return NSLocalizedString(@"sectional_pic", @"Cutout");
}
/* 女装 */
//"pocketbook.nvzhuang" = "Women's Dress";
-(NSString *)NvZhuang{
    return NSLocalizedString(@"pocketbook.nvzhuang", @"Women's Dress");
}
/* 男装 */
//"pocketbook.nanzhuang" = "Men's Wear";
-(NSString *)NanZhuang{
    return NSLocalizedString(@"pocketbook.nanzhuang", @"Men's Wear");
}
/* 无 */
//"pocketbook.none" = "None";
-(NSString *)None{
    return NSLocalizedString(@"pocketbook.none", @"None");
}
/* 温馨提示 */
//"ff_reminder" = "Friendly Reminder";
-(NSString *)Reminder{
    return NSLocalizedString(@"ff_reminder", @"Friendly Reminder");
}
/* 确定 */
//"DHL_OK" = "OK";
-(NSString *)OK{
    return NSLocalizedString(@"DHL_OK", @"OK");
}
/* 取消 */
//"ringtones_Cancel." = "Cancel";
-(NSString *)Cancel{
    return NSLocalizedString(@"ringtones_Cancel.", @"Cancel");
}
/* 设置 */
//"go Setting" = "Settings";
-(NSString *)Settings{
    return NSLocalizedString(@"go Setting", @"Settings");
}
/* 请重新选择区域 */
-(NSString *)ReSelectArea{
    return NSLocalizedString(@"re-select.the.area", @"Please re-select the area");
}
/* 您确定执行该操作吗？ */
//"Are you sure?" = "Are you sure?";
-(NSString *)AreYouSure{
    return NSLocalizedString(@"Are you sure?", @"");
}
/* 下一步 */
//"Next" = "Next";
-(NSString *)Next{
    return NSLocalizedString(@"Next", @"Next");
}
/* 常用尺寸 */
//"Commonly.Used.Size" = "Commonly used size";
-(NSString *)CommonlyUsedSize{
    return NSLocalizedString(@"Commonly.Used.Size", @"Commonly used size");
}
/* 请选择背景颜色 */
//"choose.bg.color" = "Please select the background color";
-(NSString *)ChooseBgColor{
    return NSLocalizedString(@"choose.bg.color", @"Please select the background color");
}
/* 拍照时请使用纯色背景。 */
//"takephoto.options1" = "Please use a solid background when taking pictures.";
-(NSString *)TakephotoOptions1{
    return NSLocalizedString(@"takephoto.options1", @"Please use a solid background when taking pictures.");
}
/* 背景颜色不要与衣服或头发颜色相近。 */
//"takephoto.options2" = "The background color can't be similar to the color of the clothes or hair";
-(NSString *)TakephotoOptions2{
    return NSLocalizedString(@"takephoto.options2", @"The background color can't be similar to the color of the clothes or hair");
}
/* 拍照时保持姿势正确，光线均匀，与摄像头距离适当。 */
//"takephoto.options3" = "Keep correct posture when taking pictures, keep the light uniform and keep appropriate distance from the camera";
-(NSString *)TakephotoOptions3{
    return NSLocalizedString(@"takephoto.options3", @"Keep correct posture when taking pictures, keep the light uniform and keep appropriate distance from the camera");
}
/* 大眼 */
//"bigEye" = "Big eyes mode";
-(NSString *)BigEye{
    return NSLocalizedString(@"bigEye", @"Big eyes mode");
}
/* 橡皮擦 */
//"eraser" = "Eraser";
-(NSString *)Eraser{
    return NSLocalizedString(@"eraser", @"Eraser");
}
/* 画线进行智能抠图。 */
//"tips.options1" = "Draw lines to cutout smartly";
-(NSString *)TipsOptions1{
    return NSLocalizedString(@"tips.options1", @"Draw lines to cutout smartly");
}
/* 在没选中的地方多画几笔。 */
//"tips.options2" = "Draw more lines in the unselected place";
-(NSString *)TipsOptions2{
    return NSLocalizedString(@"tips.options2", @"Draw more lines in the unselected place");
}
/* 使用前后景对比清晰的照片。 */
//"tips.options3" = "Use the front and back scenes to compare clear pictures.";
-(NSString *)TipsOptions3{
    return NSLocalizedString(@"tips.options3", @"Use the front and back scenes to compare clear pictures.");
}
/* 画线是尽量勾勒出人物主体，以选择更多的区域。 */
//"tips.options4" = "Try to outline the main body when drawing the lines to select more areas";
-(NSString *)TipsOptions4{
    return NSLocalizedString(@"tips.options4", @"Try to outline the main body when drawing the lines to select more areas");
}
/* 按住预览按钮可实时查看抠图情况。 */
//"tips.options5" = "Hold the preview button to view the cutout situation in real time";
-(NSString *)TipsOptions5{
    return NSLocalizedString(@"tips.options5", @"Hold the preview button to view the cutout situation in real time");
}
/* 使用橡皮擦擦除多余部分。 */
//"tips.options6" = "Use an eraser to erase the unnecessary part";
-(NSString *)TipsOptions6{
    return NSLocalizedString(@"tips.options6", @"Use an eraser to erase the unnecessary part");
}
/* 擦除多余部分 */
//"Erase.the.spare.parts" = "Erase unnecessary part";
-(NSString *)EraseParts{
    return NSLocalizedString(@"Erase.the.spare.parts", @"Erase unnecessary part");
}
/* 自动 */
-(NSString *)Automatic{
    return NSLocalizedString(@"DK_automatic", @"Automatic");
}
/* 手动 */
-(NSString *)Manual{
    return NSLocalizedString(@"Manual", @"Manually");
}


+(void)showADRandom:(NSInteger) random forController:(UIViewController *)controller{
    if (_isShowADSafe == NO) { return ;}
    if ([[NPCommonConfig shareInstance]shouldShowAdvertise] ) {
        if ([[NPCommonConfig shareInstance] getProbabilityFor:1 from:random]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _isShowADSafe = NO;
                [[NPCommonConfig shareInstance] showFullScreenAdWithNativeAdAlertViewForController:controller];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _isShowADSafe = YES;
                });
            });
        }
    }
}

@end
