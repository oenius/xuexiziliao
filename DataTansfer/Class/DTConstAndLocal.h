//
//  DTConstAndLocal.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/22.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTSingleton.h"

UIKIT_EXTERN NSString * const kRequestDeviceNamePath;
UIKIT_EXTERN NSString * const kRequestTaskListPath;
UIKIT_EXTERN NSString * const kRequestContactsPath;
UIKIT_EXTERN NSString * const kRequestPhotosPath;
UIKIT_EXTERN NSString * const kRequestVideosPath;
UIKIT_EXTERN NSString * const kRequestMusicsPath;
UIKIT_EXTERN NSString * const kRequestFileDataPath;
UIKIT_EXTERN NSString * const kReponseDidFinishPath;

UIKIT_EXTERN NSString * const kRequestDeviceNamePathRegex;
UIKIT_EXTERN NSString * const kRequestTaskListPathRegex;
UIKIT_EXTERN NSString * const kRequestContactsPathRegex;
UIKIT_EXTERN NSString * const kRequestPhotosPathRegex;
UIKIT_EXTERN NSString * const kRequestVideosPathRegex;
UIKIT_EXTERN NSString * const kRequestMusicsPathRegex;
UIKIT_EXTERN NSString * const kRequestFileDataPathRegex;
UIKIT_EXTERN NSString * const kReponseDidFinishPathRegex;


UIKIT_EXTERN NSString * const kDataTypeKey;
UIKIT_EXTERN NSString * const kDataIDKey;
UIKIT_EXTERN NSString * const kDataNameKey;

UIKIT_EXTERN NSString * const kDataTypeContactKey;
UIKIT_EXTERN NSString * const kDataTypePhotoKey;
UIKIT_EXTERN NSString * const kDataTypeVideoKey;
UIKIT_EXTERN NSString * const kDataTypeMusicKey;

UIKIT_EXTERN NSString * const kServeriPhoneNameKey;

UIKIT_EXTERN NSString * const kSearchTaskListSuccessNotition;
UIKIT_EXTERN NSString * const kClientiPhoneNameNotition;
UIKIT_EXTERN NSString * const kAllTaskDidFinishNotition;

UIKIT_EXTERN NSString * const itunesURLFormat;

typedef enum : NSUInteger {
    DTFileTypeContact,
    DTFileTypePhtoto,
    DTFileTypeVideo,
    DTFileTypeMusic,
    DTFileTypeBigFileData,
    //    DTFileChoiceType,
    //    ......
} DTFileType;

@interface DTConstAndLocal : NSObject

Singleton_H(Instance);

/**
 获取设备名称

 @return 设备名称
 */
+(NSString *)getDeviceName;

/**
 WiFi网络SSID

 @return SSID
 */
+ (NSString *)fetchSSID;

/**
 获取沙盒缓存文件夹路径

 @return 路径
 */
+(NSString *)cachesDirectory;

/**
 接收的的音乐文件路径

 @return 路径
 */
+(NSString*)getMusicsDir;
/**
 接收的的音乐model Data 路径
 
 @return 路径
 */
+(NSString*)getMusicModelsDir;

/**
 k开启网络监测

 @param statusChangeBlock 状态改变回调
 */
+(void)openNetWorkingCheck:(void(^)(NSString * currentSSID))statusChangeBlock;

/**
 关闭网络监测
 */
+(void)closeNetWorikingCheck;


/**
 展示广告

 @param random     几分之一的概率
 @param controller controller
 */
+(void)showADRandom:(NSInteger) random forController:(UIViewController *)controller;

#pragma 国际化
/** 设备: */
+(NSString *)device;
/** app名称 */
+(NSString *)appNametitle;

/** app副标题 */
+(NSString *)appSubtitle;

/** 主要动能点 */
+(NSString *)appDes;

/// 下载失败
+(NSString *)downFaild;
//    "DOWNLOAD_FAILED" = "Download failed";
    
/// 下载完成
+(NSString *)downSuccess;
//    "Download Completed" = "Download Completed";
    
/// 已完成
+(NSString *)yiwancheng;

///数据传输
+(NSString *)shujuchuanshu;

///  旅游常用语设置界面标题
+(NSString *)settings;

///  新机接收 
+(NSString *)newPhoneRecive;

///  旧机发送 
+(NSString *)oldPhoneSend;

///  通讯录 
+(NSString *)tongxunlu;

///  图片 
+(NSString *)tupian;

///  视频 
+(NSString *)shipin;

///  音乐 
+(NSString *)yinyue;

///  邀请安装 
+(NSString *)anzhuang;

///  请用二维码工具扫描 
+(NSString *)saomiao;

///  传输列表 
+(NSString *)chuanshulist;

///  传输过程中确保窗口处于前台 
+(NSString *)qiantai;

///  当前手机所处WiFi网络:%@ 
+(NSString *)wifiwangluo;

///  请和数据发送方处于同一wifi网络下,当前wifi网络: 
+(NSString *)fasongwifi;

///  请和数据接收方处于同一wifi网络下,当前wifi网络: 
+(NSString *)jieshouwifi;

///  扫一扫 
+(NSString *)saoyisao;

///  全选 
+(NSString *)quanxuan;

///  取消全选 
+(NSString *)quxiaoquanxuan;

///  选择 
+(NSString *)xuanze;

///  F 
+(NSString *)tishi;

///  当前应用没有此权限，是否前往设置权限 
+(NSString *)noquanxiangoset;

///  取消 
+(NSString *)cancel;

///  确定 
+(NSString *)ok;

///  完成 
+(NSString *)done;

///  等待中... 
+(NSString *)Waiting;

///  暂停 
+(NSString *)pause;

///  返回 
+(NSString *)back;

///  保存成功 
+(NSString *)savesuccess;

///  保存失败 
+(NSString *)saveFailed;

///  收件箱 
+(NSString *)inbox;

///  开始发送 
+(NSString *)startSending;

///  请使用接收设备打开此应用，并扫描该二维码 
+(NSString *)jieshousaomiao;

///  正在连接的设备 
+(NSString *)zhengzailianjie;

///  未连接到可用WiFi 
+(NSString *)wifiDisablew;

///  网络连接发生变化 
+(NSString *)wangluobianhua;

///  请注意检查发送设备和接收设备是否处于同一WiFi网络 
+(NSString *)chectnetwork;

///  正在加载资源 
+(NSString *)LoadingResource;

///  正在下载 
+(NSString *)downloading;

///  连接失败 
+(NSString *)connectionfailure;

///  请求超时 
+(NSString *)Requestimeout;

///  请扫描发送设备生成的二维码 
+(NSString *)pleaseSaomiao;

///  正在生成任务 
+(NSString *)GeneratingTasks;

///  请选择文件 
+(NSString *)xuanzewenjia;

///  您确定执行该操作吗？ 
+(NSString *)Areyousure;

///  发生错误 %i 
+(NSString *)fashengcuowu;

///  媒体库的访问权限已被关闭，是否去设置？ 
+(NSString *)meidaLiabrygoset;

///  未能获得相册权限,请到系统设置里打开 
+(NSString *)photoLibraygoset;

///  没有权限获取系统通讯录，是否去设置 
+(NSString *)tongxunlugotset;

///  删除 
+(NSString *)delete;




@end
