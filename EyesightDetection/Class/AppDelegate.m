//
//  AppDelegate.m
//  EyesightDetection
//
//  Created by 何少博 on 16/9/27.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "AppDelegate.h"
#import "NPCommonConfig.h"
#import "CusTabBarController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


+ (void)initialize{
    // 显示测试广告，需要将LOG 中 testDevice 添加到该数值 // 无需修改
//    [NPCommonConfig shareInstance].adTestDevices = @[@"3fc6a8214059a94559c69eba7bd51ded", @"f4fc5e3d2750a685e7889c83c0524865"];
    // 免费版 appId
    [NPCommonConfig shareInstance].liteAppId = @"1166457029";
    // 付费版 appId
    [NPCommonConfig shareInstance].proAppId = @"1166457350";
    // 移除广告内购id
    [NPCommonConfig shareInstance].removeAdPurchaseProductId = @"Remove_Ads_for_VisionTest_Lite";
    // 用户反馈邮箱地址 // 无需修改
    [NPCommonConfig shareInstance].fadebackEmail = @"np2016.ant@gmail.com";
    // 应用推广作者 id // 无需修改
    [NPCommonConfig shareInstance].artistId = @"1124342842";
    //  请求广告关键词
//     [NPCommonConfig shareInstance].adKeyWords = @[@"eye", @"hospital" ,@"vision",@"color", @"blindness",
//                                                   @"treatment",@"glasses", @"nearsighted",@"optical",
//                                                   @"physical",@"health",@"doctor"];
    // 禁用自动显示全屏广告.设为： NSIntegerMax
    // 默认界面‘viewWillAppear’调用13次，自动弹出全屏广告
    // 如果需要设置其他值，请参考质数列表。‘NPCommonConfig.m’ 文件中有说明
    // 质数列表: 2、3、5、7、11、13、17、19、23、29、31、37、41、43、47、53、59、61、67、71、73、79、83、89、97
        [NPCommonConfig shareInstance].viewAppearUntilShowInterstitialAd = 5;   // 全屏广告
        [NPCommonConfig shareInstance].viewAppearUntilPromptRate = 17;          // 提示评论
//        [NPCommonConfig shareInstance].viewAppearUntilPromptPayment = 23;        // 提示购买
        [NPCommonConfig shareInstance].shouldShowNativeFullScreenAdWhenViewAppear = YES;

#ifndef DEBUG
    // 发布阶段使用真实广告ID
    [NPCommonConfig shareInstance].admobBannerAdID              = @"ca-app-pub-7028363992110677/7974800942";
    [NPCommonConfig shareInstance].admobInterstitialAdID        = @"ca-app-pub-7028363992110677/9451534140";
    [NPCommonConfig shareInstance].admobNativeExpressAdID       = @"ca-app-pub-7028363992110677/1928267340";
    [NPCommonConfig shareInstance].admobNativeExpress250HAdID   = @"ca-app-pub-7028363992110677/8288551741";
#endif
    // 配置提示评论相关信息
    [[NPCommonConfig shareInstance] initRateAppConfig];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     
     self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
     CusTabBarController * tabController = [[CusTabBarController alloc]init];
  
     self.window.rootViewController = tabController;
     NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
     if (![defaults boolForKey:@"NoFirstStart"]) {
          [defaults setBool:YES forKey:@"NoFirstStart"];
          [defaults setObject:@"1.0" forKey:ShiLiTableStyle];
          [defaults setObject:@"30cm" forKey:TestDistance];
          [defaults setBool:YES forKey:YaoYiYao];
     }
     [defaults synchronize];
     [self.window makeKeyAndVisible];
     
     return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
