//
//  AppDelegate.m
//  LightCamera
//
//  Created by 何少博 on 16/12/9.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "AppDelegate.h"
#import "LCMainViewController.h"
#import "NPCommonConfig.h"
#import "LCCameraViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)initialize{
    // 广告关键字定义
    //    [NPCommonConfig shareInstance].adKeyWords =  @[@"network", @"ping", @"dns"];
    // 免费版 appId
    [NPCommonConfig shareInstance].liteAppId = @"1187803028";
    // 付费版 appId
    [NPCommonConfig shareInstance].proAppId = @"1187803902";
    // 移除广告内购id
    [NPCommonConfig shareInstance].removeAdPurchaseProductId = @"Remove_Ads_for_NightCamera_Lite";
    // 用户反馈邮箱地址 // 无需修改
    [NPCommonConfig shareInstance].fadebackEmail = @"np2016.ant@gmail.com";
    // 应用推广作者 id。 xinggui.zhang: '1124342842' ;  jingbing.yuan '743484976' ;
    
    [NPCommonConfig shareInstance].artistId = @"743484976";
    
    // 禁用自动显示全屏广告.设为： NSIntegerMax
    // 默认界面‘viewWillAppear’调用13次，自动弹出全屏广告
    // 如果需要设置其他值，请参考质数列表。‘NPCommonConfig.m’ 文件中有说明
    // 质数列表: 2、3、5、7、11、13、17、19、23、29、31、37、41、43、47、53、59、61、67、71、73、79、83、89、97
    [NPCommonConfig shareInstance].viewAppearUntilShowInterstitialAd = 999999;   // 全屏广告
    [NPCommonConfig shareInstance].viewAppearUntilPromptRate = 17;          // 提示评论
    //    [NPCommonConfig shareInstance].viewAppearUntilPromptPayment = 11;        // 提示购买
    [NPCommonConfig shareInstance].shouldShowNativeFullScreenAdWhenViewAppear = YES;
    [NPCommonConfig shareInstance].shouldShowFullscreenAdFromBackgroundToForeground = YES;
    
#ifndef DEBUG
    // 发布阶段使用真实广告ID
    [NPCommonConfig shareInstance].admobBannerAdID              = @"ca-app-pub-7028363992110677/2342431747";
    [NPCommonConfig shareInstance].admobInterstitialAdID        = @"ca-app-pub-7028363992110677/3819164945";
    [NPCommonConfig shareInstance].admobNativeExpressAdID       = @"ca-app-pub-7028363992110677/5295898141";
    [NPCommonConfig shareInstance].admobNativeExpress250HAdID   = @"ca-app-pub-7028363992110677/6772631345";
#endif
    // 配置提示评论相关信息
    [[NPCommonConfig shareInstance] initRateAppConfig];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    LCCameraViewController * main = [[LCCameraViewController alloc]init];
    self.window.rootViewController = main;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
