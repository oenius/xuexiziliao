//
//  AppDelegate.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/17.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "AppDelegate.h"
#import "NPCommonConfig.h"
#import "DTTabBarController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate
+ (void)initialize{
    // 广告关键字定义
    //    [NPCommonConfig shareInstance].adKeyWords =  @[@"network", @"ping", @"dns"];
    // 免费版 appId
    [NPCommonConfig shareInstance].liteAppId = @"1243961498";
    // 付费版 appId
    [NPCommonConfig shareInstance].proAppId = @"1243961679";
    // 移除广告内购id
    [NPCommonConfig shareInstance].removeAdPurchaseProductId = @"RemoveAdsForMobileTransfer2";
    // 用户反馈邮箱地址 ,请修改为各组，对应账号下的反馈邮箱地址
    [NPCommonConfig shareInstance].fadebackEmail = @"np2016.ant@gmail.com";
    // 应用推广作者 id。 xinggui.zhang: '1124342842' ;  jingbing.yuan '743484976' ;  meiyan.chen '1209894980'
    
    [NPCommonConfig shareInstance].artistId = @"1209894980";
    
    // 禁用自动显示全屏广告.设为： NSIntegerMax
    // 默认界面‘viewWillAppear’调用13次，自动弹出全屏广告
    // 如果需要设置其他值，请参考质数列表。‘NPCommonConfig.m’ 文件中有说明
    // 质数列表: 2、3、5、7、11、13、17、19、23、29、31、37、41、43、47、53、59、61、67、71、73、79、83、89、97
    [NPCommonConfig shareInstance].viewAppearUntilShowInterstitialAd = 999999999;   // 全屏广告
    [NPCommonConfig shareInstance].viewAppearUntilPromptRate = 31;          // 提示评论
    [NPCommonConfig shareInstance].shouldShowNetworkErrorNotification = YES;    // 网络未连接时显示通知栏提示信息
    
    //    [NPCommonConfig shareInstance].shouldPreloadRewardVideoAd = YES;
    //    [NPCommonConfig shareInstance].nativeAdViewCloseType = NPNativeAdViewCloseTypeNotCoverAdLeftTop;
    
#ifndef DEBUG
    // 发布阶段使用真实广告ID
    // 横幅广告
    [NPCommonConfig shareInstance].admobBannerAdID              = @"ca-app-pub-7028363992110677/9567203343";
    // 全屏广告
    [NPCommonConfig shareInstance].admobInterstitialAdID        = @"ca-app-pub-7028363992110677/2043936548";
    // 原生80H广告
    [NPCommonConfig shareInstance].admobNativeExpressAdID       = @"ca-app-pub-7028363992110677/3520669743";
    // 原生250H广告
    [NPCommonConfig shareInstance].admobNativeExpress250HAdID   = @"ca-app-pub-7028363992110677/6474136145";
    //启动 开屏广告
    [NPCommonConfig shareInstance].admobNativeLaunchAdID        = @"ca-app-pub-7028363992110677/7950869344";
    // 原生250H 自定义半屏广告
    [NPCommonConfig shareInstance].admobCustomHalfScreenAdID    = @"ca-app-pub-7028363992110677/8699245747";
    
    // 激励视频广告, 暂不支持
    //    [NPCommonConfig shareInstance].admobRewardVideoAdID         = @"ca-app-pub-7028363992110677/1434419340";
#endif
    
    //-------------------------Facebook 广告配置 ------------------------------------//
    // fb 显示测试广告，需要将LOG 中 testDevice 添加到该数值, 否则广告出不来   // 在Console找到测试设备的id  添加测试设备.
    [NPCommonConfig shareInstance].fbAdTestDevices = @[@"c245499da04a2451b94819bd5e4f73d2e99dbb62",
                                                       @"1a3bc305ebbfe4f0e0405b2169b3ad44b14d5a8c",
                                                       @"a1d63df45bd3925aa8a79e1d0ebd2986"
                                                       ];
    
    
    //如果不设置facebook 该广告位，ID设为 nil 即可，内部会自动获取admob广告
    // banner view
    [NPCommonConfig shareInstance].fbBannerAdID =                 nil;
    //native views
    [NPCommonConfig shareInstance].fbNativeSmallAdID =            nil;
    [NPCommonConfig shareInstance].fbNativeMidAdID =              nil;
    [NPCommonConfig shareInstance].fbNativeLargeAdID =            @"1420998874654772_1420999497988043";   // //@"221536061675894_221537691675731";
    [NPCommonConfig shareInstance].fbNativeLaunchAdID =           @"1420998874654772_1420999204654739";
    // InterstitialAd
    [NPCommonConfig shareInstance].fbInterstitialAdID =           nil;
    
    // 如需自定义 广告优先策略，请继承 ‘CVAdPlatformPriorityStrategy’ 进行实现
    //    [NPCommonConfig shareInstance].adPlatformPriorityStrategy = [[CVAdPlatformPriorityStrategy alloc] init];
    
    // 配置提示评论相关信息
    [[NPCommonConfig shareInstance] initRateAppConfig];
    // 注意，必须在请求开屏广告之前执行‘initAdvertise’
    [[NPCommonConfig shareInstance] initAdvertise];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[NPCommonConfig shareInstance] initAnalyticsWhenAppDidLaunch];
    //------- 开屏广告植入 ------ //
    //以下信息 和市场核对后填写，使用英文即可
    [NPCommonConfig shareInstance].launchViewCenterContentStr = [DTConstAndLocal appDes];
    [NPCommonConfig shareInstance].launchViewAppTitle = [DTConstAndLocal appNametitle];
    [NPCommonConfig shareInstance].launchViewAppSubtitle = [DTConstAndLocal appSubtitle];
    // 另外，注意更换开屏广告中的icon 图标, 'AdvertiseImages.xcassets' 中 icon图片需要更换
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    BOOL shouldShowAD = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (shouldShowAD) {
        // 添加 【 开屏广告 】，建议背景图片的使用和 LaunchScreen 保持一致.
        __weak typeof(self) weakSelf = self;
        [[NPCommonConfig shareInstance] launchViewControllerWithKeyWindow:self.window forLaunch:^(NPLaunchAdViewController *launchAdViewController) {
            launchAdViewController.dismiss = ^(NPLaunchViewDismissType dismissType){
                DTTabBarController * rootViewController = [[DTTabBarController alloc]init];
                
                weakSelf.window.rootViewController = rootViewController;
            };
        }];
    }else{
        DTTabBarController * rootViewController = [[DTTabBarController alloc]init];
        
        self.window.rootViewController = rootViewController;
    }
    
    [self.window makeKeyAndVisible];
    [self clearnTheTemporaryFile];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
   
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     application.idleTimerDisabled = NO;
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    application.idleTimerDisabled = YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)clearnTheTemporaryFile{
    NSString * tempDir = NSTemporaryDirectory();
    NSError * error ;
    NSArray * contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempDir error:&error];
    if (error) {
        LOG(@"获取tmp目录失败:%@",error);
        return;
    }
    for (NSString * fileName in contents) {
        NSString * filePath = [tempDir stringByAppendingPathComponent:fileName];
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (isExist) {
            NSError * removeError;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&removeError];
            if (removeError) {
                LOG(@"删除文件失败:%@",removeError);
            }
        }
    }

}
@end
