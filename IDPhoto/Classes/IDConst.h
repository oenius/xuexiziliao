//
//  IDConst.h
//  IDPhoto
//
//  Created by 何少博 on 17/4/24.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum : NSUInteger {
    IDPhotoBGTypeWhite,
    IDPhotoBGTypeBlue,
    IDPhotoBGTypeRed,
} IDPhotoBGType;

FOUNDATION_EXTERN NSString * const ID_TYPE_XIAOYICUN;
FOUNDATION_EXTERN NSString * const ID_TYPE_YICUN;
FOUNDATION_EXTERN NSString * const ID_TYPE_DAYICUN;
FOUNDATION_EXTERN NSString * const ID_TYPE_ERCUN;
FOUNDATION_EXTERN NSString * const ID_TYPE_XIAOERCUN;
FOUNDATION_EXTERN NSString * const ID_TYPE_SANCUNCUN;
FOUNDATION_EXTERN NSString * const ID_TYPE_WUCUN;
FOUNDATION_EXTERN NSString * const ID_TYPE_S2R;
FOUNDATION_EXTERN NSString * const ID_TYPE_2R;
FOUNDATION_EXTERN NSString * const ID_TYPE_S3R;
FOUNDATION_EXTERN NSString * const ID_TYPE_3R;
FOUNDATION_EXTERN NSString * const ID_TYPE_4R;

@interface IDConst : NSObject

+(instancetype)instance;

+(void)showADRandom:(NSInteger) random forController:(UIViewController *)controller;

///  /* 未检测到人脸 */
@property (nonatomic,strong,readonly) NSString * NoFace;
///  /* 继续 */
@property (nonatomic,strong,readonly) NSString * Resume;
///  /* 成功保存到相册! */
@property (nonatomic,strong,readonly) NSString * MsgSuccess;
///  /* 保存失败 */
@property (nonatomic,strong,readonly) NSString * FailedSave;
///  /* 正在处理... */
@property (nonatomic,strong,readonly) NSString * Processing;
///  /* 选择尺寸 */
@property (nonatomic,strong,readonly) NSString * ChooseSize;
///  /* 从相册选择 */
@property (nonatomic,strong,readonly) NSString * SelectFromAlbum;
///  /* 从相机拍照 */
@property (nonatomic,strong,readonly) NSString * TakePhoto;
///  /* 当前应用没有此权限，是否前往设置权限 */
@property (nonatomic,strong,readonly) NSString * NoPermissions;
///  /* 美颜 */
@property (nonatomic,strong,readonly) NSString * FaceBeauty;
///  /* 增强 */
@property (nonatomic,strong,readonly) NSString * Enhance;
///  /* 饱和度 */
@property (nonatomic,strong,readonly) NSString * Saturation;
///  /* 亮度 */
@property (nonatomic,strong,readonly) NSString * Brightness;
///  /* 对比度 */
@property (nonatomic,strong,readonly) NSString * Contrast;
///  /* 曝光度 */
@property (nonatomic,strong,readonly) NSString * Exposure;
///  /* 抠图 */
@property (nonatomic,strong,readonly) NSString * Cutout;
///  /* 女装 */
@property (nonatomic,strong,readonly) NSString * NvZhuang;
///  /* 男装 */
@property (nonatomic,strong,readonly) NSString * NanZhuang;
///  /* 无 */
@property (nonatomic,strong,readonly) NSString * None;
///  /* 温馨提示 */
@property (nonatomic,strong,readonly) NSString * Reminder;
///  /* 确定 */
@property (nonatomic,strong,readonly) NSString * OK;
///  /* 取消 */
@property (nonatomic,strong,readonly) NSString * Cancel;
///  /* 设置 */
@property (nonatomic,strong,readonly) NSString * Settings;
///  /* 请重新选择区域 */
@property (nonatomic,strong,readonly) NSString * ReSelectArea;
///  /* 您确定执行该操作吗？ */
@property (nonatomic,strong,readonly) NSString * AreYouSure;
///  /* 下一步 */
@property (nonatomic,strong,readonly) NSString * Next;
///  /* 常用尺寸 */
@property (nonatomic,strong,readonly) NSString * CommonlyUsedSize;
///  /* 请选择背景颜色 */
@property (nonatomic,strong,readonly) NSString * ChooseBgColor;
///  /* 拍照时请使用纯色背景。 */
@property (nonatomic,strong,readonly) NSString * TakephotoOptions1;
///  /* 背景颜色不要与衣服或头发颜色相近。 */
@property (nonatomic,strong,readonly) NSString * TakephotoOptions2;
///  /* 拍照时保持姿势正确，光线均匀，与摄像头距离适当。 */
@property (nonatomic,strong,readonly) NSString * TakephotoOptions3;
///  /* 大眼 */
@property (nonatomic,strong,readonly) NSString * BigEye;
///  /* 橡皮擦 */
@property (nonatomic,strong,readonly) NSString * Eraser;
///  /* 画线进行智能抠图。 */
@property (nonatomic,strong,readonly) NSString * TipsOptions1;
///  /* 在没选中的地方多画几笔。 */
@property (nonatomic,strong,readonly) NSString * TipsOptions2;
///  /* 使用前后景对比清晰的照片。 */
@property (nonatomic,strong,readonly) NSString * TipsOptions3;
///  /* 画线是尽量勾勒出人物主体，以选择更多的区域。 */
@property (nonatomic,strong,readonly) NSString * TipsOptions4;
///  /* 按住预览按钮可实时查看抠图情况。 */
@property (nonatomic,strong,readonly) NSString * TipsOptions5;
///  /* 使用橡皮擦擦除多余部分。 */
@property (nonatomic,strong,readonly) NSString * TipsOptions6;
///  /* 擦除多余部分 */
@property (nonatomic,strong,readonly) NSString * EraseParts;
///  /* 自动 */
@property (nonatomic,strong,readonly) NSString * Automatic;
///  /* 手动 */
@property (nonatomic,strong,readonly) NSString * Manual;
@end
