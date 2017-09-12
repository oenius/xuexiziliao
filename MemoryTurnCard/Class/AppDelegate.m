//
//  AppDelegate.m
//  MemoryTurnCard
//
//  Created by 何少博 on 16/10/20.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "NPCommonConfig.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)initialize{
    // 广告关键字定义
    //    [NPCommonConfig shareInstance].adKeyWords =  @[@"network", @"ping", @"dns"];
    // 免费版 appId
    [NPCommonConfig shareInstance].liteAppId = @"1173796596";
    // 付费版 appId
    [NPCommonConfig shareInstance].proAppId = @"1173797682";
    // 移除广告内购id
    [NPCommonConfig shareInstance].removeAdPurchaseProductId = @"Remove_Ads_for_MemoryPoker_Lite";
    // 用户反馈邮箱地址 // 无需修改
    [NPCommonConfig shareInstance].fadebackEmail = @"np2016.ant@gmail.com";
    // 应用推广作者 id // 无需修改
    [NPCommonConfig shareInstance].artistId = @"1124342842";
    
    // 禁用自动显示全屏广告.设为： NSIntegerMax
    // 默认界面‘viewWillAppear’调用13次，自动弹出全屏广告
    // 如果需要设置其他值，请参考质数列表。‘NPCommonConfig.m’ 文件中有说明
    // 质数列表: 2、3、5、7、11、13、17、19、23、29、31、37、41、43、47、53、59、61、67、71、73、79、83、89、97
    [NPCommonConfig shareInstance].viewAppearUntilShowInterstitialAd =  20000000;   // 全屏广告
    [NPCommonConfig shareInstance].viewAppearUntilPromptRate = 17;          // 提示评论
    //    [NPCommonConfig shareInstance].viewAppearUntilPromptPayment = 11;        // 提示购买
    [NPCommonConfig shareInstance].shouldShowNativeFullScreenAdWhenViewAppear = YES;
    
    //-----------------------设置250的尺寸------------------------------
    if (!([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)) {
        CGFloat W = [UIScreen mainScreen].bounds.size.width/6*5;
        CGFloat H = [UIScreen mainScreen].bounds.size.height/3*2;
        //广告高度最小280x250
        W = W<280 ? 280 : W;
        //如果是Pro 没加载到广告，去广告要进行判断
        CGSize adSize = CGSizeMake(W-20, H/2 - 20);
        float adW = adSize.width;
        float adH = adSize.height;
        adSize.width = adW<280 ? 280 : adW;
        adSize.height = adH<250 ? 250 : adH;
        if ([[NPCommonConfig shareInstance]shouldShowAdvertise]) {
            //有接口可以调
            [NPCommonConfig shareInstance].nativeExpress250HViewSize = adSize;
        }

    }
        //-----------------------------------------------------------------
    
#ifndef DEBUG
    // 发布阶段使用真实广告ID
    [NPCommonConfig shareInstance].admobBannerAdID              = @"ca-app-pub-7028363992110677/7485496145";
    [NPCommonConfig shareInstance].admobInterstitialAdID        = @"ca-app-pub-7028363992110677/1438962544";
    [NPCommonConfig shareInstance].admobNativeExpressAdID       = @"ca-app-pub-7028363992110677/7345895343";
    [NPCommonConfig shareInstance].admobNativeExpress250HAdID   = @"ca-app-pub-7028363992110677/2776094940";
#endif
    // 配置提示评论相关信息
    [[NPCommonConfig shareInstance] initRateAppConfig];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    MainViewController *main = [[MainViewController alloc]init];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:main];
    self.window.rootViewController = nav;
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
