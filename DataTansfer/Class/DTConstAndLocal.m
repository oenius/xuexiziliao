//
//  DTConstAndLocal.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/22.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTConstAndLocal.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <AFNetworkReachabilityManager.h>
#import "NPCommonConfig.h"

#pragma mark - 请求路径
NSString * const kRequestDeviceNamePath             = @"requestDeviceName";
NSString * const kRequestTaskListPath               = @"requsetTaskList";
NSString * const kRequestContactsPath               = @"requestContacts";
NSString * const kRequestPhotosPath                 = @"requestPhotos";
NSString * const kRequestVideosPath                 = @"requestVideos";
NSString * const kRequestMusicsPath                 = @"requestMusics";
NSString * const kRequestFileDataPath               = @"requestFileData";
NSString * const kReponseDidFinishPath              = @"reponseDidFinish";

NSString * const kRequestDeviceNamePathRegex        = @"requestDeviceName*";
NSString * const kRequestTaskListPathRegex          = @"requsetTaskList*";
NSString * const kRequestContactsPathRegex          = @"requestContacts*";
NSString * const kRequestPhotosPathRegex            = @"requestPhotos*";
NSString * const kRequestVideosPathRegex            = @"requestVideos*";
NSString * const kRequestMusicsPathRegex            = @"requestMusics*";
NSString * const kRequestFileDataPathRegex          = @"requestFileData*";
NSString * const kReponseDidFinishPathRegex         = @"reponseDidFinish*";
#pragma mark - dict keys

NSString * const kDataTypeKey                       = @"DataType";
NSString * const kDataIDKey                         = @"DataID";
NSString * const kDataNameKey                       = @"DataName";

NSString * const kDataTypeContactKey                = @"DTContact";
NSString * const kDataTypePhotoKey                  = @"DTPhoto";
NSString * const kDataTypeVideoKey                  = @"DTVideo";
NSString * const kDataTypeMusicKey                  = @"DTMusic";

NSString * const kServeriPhoneNameKey               = @"ServeriPhoneName";
//NSString * const k Key  = @"";
#pragma mark - Notifition

///通知
NSString * const kSearchTaskListSuccessNotition     = @"searchTaskListSuccessNotition";
NSString * const kClientiPhoneNameNotition          = @"clientDeviceNameNotition";
NSString * const kAllTaskDidFinishNotition          = @"allTaskDidFinishNotition";


#pragma mark - other

NSString * const itunesURLFormat = @"http://itunes.apple.com/app/id%@";


static BOOL _isShowADSafe = YES;


@implementation DTConstAndLocal

Singleton_M(Instance);

+(NSString *)getDeviceName{
    UIDevice * de = [UIDevice currentDevice];
    NSString * name = de.name;
    if (name == nil) { name = de.model; }
    return name;
}
+ (NSString *)fetchSSID {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) { break; }
    }
    return [info objectForKey:@"SSID"];
}

+(NSString *)cachesDirectory{
    NSString * dir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    return dir;
}
+(NSString*)getMusicsDir{
    NSString * caches = [self cachesDirectory];
    NSString * musicsDir = [caches stringByAppendingPathComponent:@"musics"];
    NSFileManager* fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:musicsDir]) {
        [fm createDirectoryAtPath:musicsDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return musicsDir;
}
+(NSString*)getMusicModelsDir{
    NSString * caches = [self cachesDirectory];
    NSString * musicModelsDir = [caches stringByAppendingPathComponent:@"musicModels"];
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:musicModelsDir]) {
        [fm createDirectoryAtPath:musicModelsDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return musicModelsDir;
}

+(void)openNetWorkingCheck:(void(^)(NSString * currentSSID))statusChangeBlock{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSString * ssid = [self fetchSSID];
        if (statusChangeBlock) {
            statusChangeBlock(ssid);
        }
    }];
}

+(void)closeNetWorikingCheck{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
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

/* 设备: */
+(NSString *)device{
    return NSLocalizedString(@"gallery.Device:", @"");
}
//"gallery.Device:" = "Device:";

/* app名称 */
+(NSString *)appNametitle{
    return NSLocalizedString(@"appNameTitle", @"");
}
//"appNameTitle" = "MobileSync";

/* app副标题 */
+(NSString *)appSubtitle{
    return NSLocalizedString(@"appSubtitle", @"");
}
//"appSubtitle" = "Copy & Sync  Phone Data";

/* 主要动能点 */
+(NSString *)appDes{
    return NSLocalizedString(@"appDes", @"");
}
//"appDes" = "Back up your contacts and transfer your data";

/// 下载失败
+(NSString *)downFaild{
    return NSLocalizedString(@"DOWNLOAD_FAILED", @"");
}
//    "DOWNLOAD_FAILED" = "Download failed";
/// 下载完成
+(NSString *)downSuccess{
    return NSLocalizedString(@"Download Completed", @"");
}
//    "Download Completed" = "Download Completed";
/// 已完成
+(NSString *)yiwancheng{
    return NSLocalizedString(@"task.completed", @"");
}
//    "task.completed" = "Completed";
    
///数据传输
+(NSString *)shujuchuanshu{
    return NSLocalizedString(@"data_transmission", @"");
}

/// 旅游常用语设置界面标题 
+(NSString *)settings{
    return NSLocalizedString(@"BG_Settings", @"");
}
//"BG_Settings" = "Settings";

/// 新机接收 
+(NSString *)newPhoneRecive{
    return NSLocalizedString(@"newPhone", @"");
}
//"newPhone" = "Receive to new phone";

/// 旧机发送 
+(NSString *)oldPhoneSend{
    return NSLocalizedString(@"oldPhone", @"");
}
//"oldPhone" = "Send from old phone";

/// 通讯录 
+(NSString *)tongxunlu{
    return NSLocalizedString(@"sendPhoto.ContactList", @"");
}
//"sendPhoto.ContactList" = "Contacts";

/// 用户收到客服反馈中包含图片时的消息占位符 
+(NSString *)tupian{
    return NSLocalizedString(@"DT_Image", @"");
}
//"DT_Image" = "Image";

/// 视频 
+(NSString *)shipin{
    return NSLocalizedString(@"gallery.Videos", @"");
}
//"gallery.Videos" = "Videos";

/// 音乐 
+(NSString *)yinyue{
    return NSLocalizedString(@"Musics", @"");
}
//"Musics" = "Music";

/// 邀请安装 
+(NSString *)anzhuang{
    return NSLocalizedString(@"Invitation_to_install", @"");
}
//"Invitation_to_install" = "Invitation to install";

/// 请用二维码工具扫描 
+(NSString *)saomiao{
    return NSLocalizedString(@"Please_scan", @"");
}
//"Please_scan" = "Please scan with a QR code tool";

/// 传输列表 
+(NSString *)chuanshulist{
    return NSLocalizedString(@"left page.transfer list", @"");
}
//"left page.transfer list" = "Transfer List";

/// 传输过程中确保窗口处于前台 
+(NSString *)qiantai{
    return NSLocalizedString(@"massageTwo", @"");
}
//"massageTwo" = "Make sure that the window is in the foreground during transmission";

/// 当前手机所处WiFi网络:%@ 
+(NSString *)wifiwangluo{
    return NSLocalizedString(@"DHL_Current connected network:%@", @"");
}
//"DHL_Current connected network:%@" = "Current connected WiFi:%@";

/// 请和数据发送方处于同一wifi网络下,当前wifi网络: 
+(NSString *)fasongwifi{
    return NSLocalizedString(@"Please_be_in", @"");
}
//"Please_be_in" = "Please be in the same WiFi network as the data sender, the current WiFi network:";

/// 请和数据接收方处于同一wifi网络下,当前wifi网络: 
+(NSString *)jieshouwifi{
    return NSLocalizedString(@"Please_connect_to", @"");
}
//"Please_connect_to" = "Please connect to the data receiver in the same WiFi network, the current WiFi network:";

/// 扫一扫 
+(NSString *)saoyisao{
    return NSLocalizedString(@"scan_it", @"");
}
//"scan_it" = "Scan";

/// 全选 
+(NSString *)quanxuan{
    return NSLocalizedString(@"Select All", @"");
}
//"Select All" = "Select All";

/// 取消全选 
+(NSString *)quxiaoquanxuan{
    return NSLocalizedString(@"cancel_select_all", @"");
}
//"cancel_select_all" = "Uncheck all";

/// 选择 
+(NSString *)xuanze{
    return NSLocalizedString(@"common.select", @"");
}
//"common.select" = "Select";

/// F 
+(NSString *)tishi{
    return NSLocalizedString(@"BB_Minecraft_prompt", @"");
}
//"BB_Minecraft_prompt" = "Friendly Reminder";

/// 当前应用没有此权限，是否前往设置权限 
+(NSString *)noquanxiangoset{
    return NSLocalizedString(@"setting.permissions", @"");
}
//"setting.permissions" = "No permission in current app,wether go to settings?";

/// 取消 
+(NSString *)cancel{
    return NSLocalizedString(@"common.Cancel", @"");
}
//"common.Cancel" = "Cancel";

/// 确定 
+(NSString *)ok{
    return NSLocalizedString(@"Sure", @"");
}
//"Sure" = "OK";

/// 完成 
+(NSString *)done{
    return NSLocalizedString(@"Done", @"");
}
//"Done" = "Done";

/// 等待中... 
+(NSString *)Waiting{
    return NSLocalizedString(@"common.Waiting", @"");
}
//"common.Waiting" = "Waiting...";

/// 暂停 
+(NSString *)pause{
    return NSLocalizedString(@"XWStop", @"");
}
//"XWStop" = "Pause";

/// 返回 
+(NSString *)back{
    return NSLocalizedString(@"Back", @"");
}
//"Back" = "Back";

/// 保存成功 
+(NSString *)savesuccess{
    return NSLocalizedString(@"save successfully1", @"");
}
//"save successfully1" = "Saved Successfully";

/// 保存失败 
+(NSString *)saveFailed{
    return NSLocalizedString(@"common.Failed to save", @"");
}
//"common.Failed to save" = "Failed to save";

/// 收件箱 
+(NSString *)inbox{
    return NSLocalizedString(@"inbox", @"");
}
//"inbox" = "Inbox";

/// 开始发送 
+(NSString *)startSending{
    return NSLocalizedString(@"Start_sending", @"");
}
//"Start_sending" = "Start sending";

/// 请使用接收设备打开此应用，并扫描该二维码 
+(NSString *)jieshousaomiao{
    return NSLocalizedString(@"scan_QR", @"");
}
//"scan_QR" = "Please use the receiving device to open the app and scan the QR code.";

/// 正在连接的设备 
+(NSString *)zhengzailianjie{
    return NSLocalizedString(@"device_connected", @"");
}
//"device_connected" = "Connecting devices";

/// 未连接到可用WiFi 
+(NSString *)wifiDisablew{
    return NSLocalizedString(@"Not_available_WiFi", @"");
}
//"Not_available_WiFi" = "Not connected to available WiFi";

/// 网络连接发生变化 
+(NSString *)wangluobianhua{
    return NSLocalizedString(@"network_changed", @"");
}
//"network_changed" = "Network connection changed";

/// 请注意检查发送设备和接收设备是否处于同一WiFi网络 
+(NSString *)chectnetwork{
    return NSLocalizedString(@"Whether_same_WiFi", @"");
}
//"Whether_same_WiFi" = "Please check whether the sending and receiving devices are on the same WiFi network";

/// 正在加载资源 
+(NSString *)LoadingResource{
    return NSLocalizedString(@"Loading_resource", @"");
}
//"Loading_resource" = "Loading resource";

/// 正在下载 
+(NSString *)downloading{
    return NSLocalizedString(@"downloading", @"");
}
//"downloading" = "Downloading";

/// 连接失败 
+(NSString *)connectionfailure{
    return NSLocalizedString(@"Connection_failed", @"");
}
//"Connection_failed" = "Connection failure";

/// 请求超时 
+(NSString *)Requestimeout{
    return NSLocalizedString(@"Request_timed_out", @"");
}
//"Request_timed_out" = "Request Timeout";

/// 请扫描发送设备生成的二维码 
+(NSString *)pleaseSaomiao{
    return NSLocalizedString(@"please_scan_QR", @"");
}
//"please_scan_QR" = "Please scan the QR code generated by the sending device";

/// 正在生成任务 
+(NSString *)GeneratingTasks{
    return NSLocalizedString(@"Generating_task", @"");
}
//"Generating_task" = "Generating tasks";

/// 请选择文件 
+(NSString *)xuanzewenjia{
    return NSLocalizedString(@"Please choose the file", @"");
}
//"Please choose the file" = "Please choose the file";

/// 您确定执行该操作吗？ 
+(NSString *)Areyousure{
    return NSLocalizedString(@"Are you sure?", @"");
}
//"Are you sure?" = "Are you sure?";

/// 发生错误 %i 
+(NSString *)fashengcuowu{
    return NSLocalizedString(@"ERROR_NUMBER", @"");
}
//"ERROR_NUMBER" = "Error %i occured";

/// 媒体库的访问权限已被关闭，是否去设置？ 
+(NSString *)meidaLiabrygoset{
    return NSLocalizedString(@"mediaLiabry_key", @"");
}
//"mediaLiabry_key" = "Your device has no permission to access Media. Set now?";

/// 未能获得相册权限,请到系统设置里打开 
+(NSString *)photoLibraygoset{
    return NSLocalizedString(@"ss_PBPhotoTip", @"");
}
//"ss_PBPhotoTip" = "Fail to open\"Photos\", please go to \"setting\" to enable it";

/// 没有权限获取系统通讯录，是否去设置 
+(NSString *)tongxunlugotset{
    return NSLocalizedString(@"NoPower", @"");
}
//"NoPower" = "No authority to access address list. Set now?";

/// 删除 
+(NSString *)delete{
    return NSLocalizedString(@"common.Delete", @"");
}
//"common.Delete" = "Delete";

@end
