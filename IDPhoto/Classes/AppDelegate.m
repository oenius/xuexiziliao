//
//  AppDelegate.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/21.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "AppDelegate.h"
#import "NPCommonConfig.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)initialize{
    // 广告关键字定义
    //    [NPCommonConfig shareInstance].adKeyWords =  @[@"network", @"ping", @"dns"];
    // 免费版 appId
    [NPCommonConfig shareInstance].liteAppId = @"1234418498";
    // 付费版 appId
    [NPCommonConfig shareInstance].proAppId = @"1234418686";
    // 移除广告内购id
    [NPCommonConfig shareInstance].removeAdPurchaseProductId = @"Remove_Ads_for_Passport_Lite";
    // 用户反馈邮箱地址 // 无需修改
    [NPCommonConfig shareInstance].fadebackEmail = @"np2016.ant@gmail.com";
    // 应用推广作者 id。 xinggui.zhang: '1124342842' ;  jingbing.yuan '743484976' ;  meiyan.chen '1209894980'
    
    [NPCommonConfig shareInstance].artistId = @"1209894980";
    
    // 禁用自动显示全屏广告.设为： NSIntegerMax
    // 默认界面‘viewWillAppear’调用13次，自动弹出全屏广告
    // 如果需要设置其他值，请参考质数列表。‘NPCommonConfig.m’ 文件中有说明
    // 质数列表: 2、3、5、7、11、13、17、19、23、29、31、37、41、43、47、53、59、61、67、71、73、79、83、89、97
    [NPCommonConfig shareInstance].viewAppearUntilShowInterstitialAd = 999999999;   // 全屏广告
    [NPCommonConfig shareInstance].viewAppearUntilPromptRate = 17;          // 提示评论
    //    [NPCommonConfig shareInstance].shouldPreloadRewardVideoAd = YES;
    //    [NPCommonConfig shareInstance].nativeAdViewCloseType = NPNativeAdViewCloseTypeWithBottomRmoveAds;
    //    [NPCommonConfig shareInstance].fullScreenType = NPViewAppearDisplayFullScreenTypeInterstitialWithNativeAdORRemindWatchVideo;
    
#ifndef DEBUG
    // 发布阶段使用真实广告ID
    // 横幅广告
    [NPCommonConfig shareInstance].admobBannerAdID              = @"ca-app-pub-7028363992110677/2722678149";
    // 全屏广告
    [NPCommonConfig shareInstance].admobInterstitialAdID        = @"ca-app-pub-7028363992110677/4199411346";
    // 原生80H广告
    [NPCommonConfig shareInstance].admobNativeExpressAdID       = @"ca-app-pub-7028363992110677/5676144545";
    // 原生250H广告
    [NPCommonConfig shareInstance].admobNativeExpress250HAdID   = @"ca-app-pub-7028363992110677/7152877744";
    // 激励视频广告
    [NPCommonConfig shareInstance].admobRewardVideoAdID         = @"ca-app-pub-7028363992110677/8629610941";
    //启动 开屏广告
    [NPCommonConfig shareInstance].admobNativeLaunchAdID        = @"ca-app-pub-7028363992110677/1470893344";
    // 原生250H 自定义半屏广告
    [NPCommonConfig shareInstance].admobCustomHalfScreenAdID    = @"ca-app-pub-7028363992110677/2947626546";
    
    // 激励视频广告, 暂不支持
    //    [NPCommonConfig shareInstance].admobRewardVideoAdID         = @"ca-app-pub-7028363992110677/1434419340";
#endif
    
    //-------------------------Facebook 广告配置 ------------------------------------//
    // fb 显示测试广告，需要将LOG 中 testDevice 添加到该数值, 否则广告出不来   // 在Console找到测试设备的id  添加测试设备.
    [NPCommonConfig shareInstance].fbAdTestDevices = @[@"c245499da04a2451b94819bd5e4f73d2e99dbb62",
                                                       @"1a3bc305ebbfe4f0e0405b2169b3ad44b14d5a8c",
                                                       @"ccd1d5840904c792e74c2c052a1ce74f5bbd46cf", @"e31667dcf3a18cfe20f0c5dcf375ccd8c8701f4f"
                                                       ];
    
    
    //如果不设置facebook 该广告位，ID设为 nil 即可，内部会自动获取admob广告
    // banner view
    [NPCommonConfig shareInstance].fbBannerAdID =        nil;
    //native views
    // native 80H
    [NPCommonConfig shareInstance].fbNativeSmallAdID =            @"713787125498245_713842275492730";
    // native 132H
    [NPCommonConfig shareInstance].fbNativeMidAdID =     nil;
    // native 250H
    [NPCommonConfig shareInstance].fbNativeLargeAdID =   nil;
    // 开屏广告
    [NPCommonConfig shareInstance].fbNativeLaunchAdID =           @"713787125498245_713842735492684";
    // InterstitialAd 全屏广告
    [NPCommonConfig shareInstance].fbInterstitialAdID =  nil;
    
    // 如需自定义 广告优先策略，请继承 ‘CVAdPlatformPriorityStrategy’ 进行实现
    //    [NPCommonConfig shareInstance].adPlatformPriorityStrategy = [[CVAdPlatformPriorityStrategy alloc] init];
    
    // 配置提示评论相关信息
    [[NPCommonConfig shareInstance] initRateAppConfig];
    // 注意，必须在请求开屏广告之前执行‘initAdvertise’
    [[NPCommonConfig shareInstance] initAdvertise];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.statusBarStyle = UIStatusBarStyleLightContent;
    // 初始化 Firebase，注意在 AppDelegate 'didFinishLaunchingWithOptions' 中调用
    [[NPCommonConfig shareInstance] initAnalyticsWhenAppDidLaunch];
    
    // Override point for customization after application launch.
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self.window = [[UIWindow alloc] initWithFrame:screenBounds];
    self.window.backgroundColor =  [UIColor whiteColor];
    
    //------- 开屏广告植入 ------ //
    // 注意更换开屏广告中的icon 图标, 'AdvertiseImages.xcassets' 中 icon图片需要更换, ad_launch_bgimage 背景图需要和启动画面和主页风格保持一致
    
    BOOL shouldShowAD = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (shouldShowAD) {
        // 添加 【 开屏广告 】，建议背景图片的使用和 LaunchScreen 保持一致.
        __weak typeof(self) weakSelf = self;
        [[NPCommonConfig shareInstance] launchViewControllerWithKeyWindow:self.window forLaunch:^(NPLaunchAdViewController *launchAdViewController) {
            launchAdViewController.dismiss = ^(NPLaunchViewDismissType dismissType){

                // 开屏结束回调后，将原本的vc设为根控制器.
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                UINavigationController *vc = [story instantiateInitialViewController];
                weakSelf.window.rootViewController = vc;
            };
        }];
        
    }else{
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UINavigationController *vc = [story instantiateInitialViewController];
        self.window.rootViewController = vc;
    }
    
    
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
