//
//  AppDelegate.m
//  MindMap
//
//  Created by 何少博 on 2017/8/4.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "AppDelegate.h"
#import "SNBaseNavigationController.h"
#import "SNMindFileViewController.h"
#import "NPCommonConfig+FeiFan.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)initialize{
    [[NPCommonConfig shareInstance] setProductInfoFromDeveloper:@[@[@"RemoveAds_MindMap_Subscription_Month",
                                                                    @(ProductInfoPerMonth),
                                                                    @(YES),
                                                                    @(ProductPeriodInfoTypeThreeDays),
                                                                    @"group1"],
                                                                  
                                                                  @[@"RemoveAds_MindMap_Subscription_ThreeMonth",
                                                                    @(ProductInfoThreeMonth),
                                                                    @(NO),
                                                                    @(ProductPeriodInfoTypeNone),
                                                                    @"group1"],
                                                                  
                                                                  @[@"RemoveAds_MindMap_Subscription_Year",
                                                                    @(ProductInfoPerYear),
                                                                    @(NO),
                                                                    @(ProductPeriodInfoTypeNone),
                                                                    @"group1"]
                                                                  ]];
    [NPCommonConfig shareInstance].shareSecrateString =@"bf76af2a3af842cba6dbb2858275df08";//App专用共享秘钥，在itunes后台可以看到
    //Vip 界面订阅商品ID
    [NPCommonConfig shareInstance].vipControllerProductId = @[@"RemoveAds_MindMap_Subscription_Month",
                                                              @"RemoveAds_MindMap_Subscription_ThreeMonth",
                                                              @"RemoveAds_MindMap_Subscription_Year"];
    
    //订阅描述
    [NPCommonConfig shareInstance].subscriptionDescription = @" Remove Ads;\n iCloud real-time synchronization;\n Unlimited to create mind maps.\n\n 1 month subscription：US$0.99\n 3 month subscription: US$$1.99\n 1 year subscription: US$$5.99 \n\n - Payment will be charged to iTunes Account at confirmation of purchase\n - Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period\n - Account will be charged for renewal within 24-hours prior to the end of the current period, and identify the cost of the renewal\n - Subscriptions may be managed by the user and auto-renewal may be turned off by going to the user's Account Settings after purchase\n - No cancellation of the current subscription is allowed during the active subscription period.";
    //服务条款 url
    [NPCommonConfig shareInstance].teamOfUseUrl = @"http://blog.csdn.net/bowang_liu_lbw/article/details/77648083";
    //隐私政策 url
    [NPCommonConfig shareInstance].privacyPolicyUrl = @"http://blog.csdn.net/bowang_liu_lbw/article/details/77647917";
    
   // 广告关键字定义
    //    [NPCommonConfig shareInstance].adKeyWords =  @[@"network", @"ping", @"dns"];
    // 免费版 appId
    [NPCommonConfig shareInstance].liteAppId = @"1275364206";
    // 付费版 appId
    [NPCommonConfig shareInstance].proAppId = @"1275364206";
    // 移除广告内购id
    [NPCommonConfig shareInstance].removeAdPurchaseProductId = @"";
    // 用户反馈邮箱地址 ,请修改为各组，对应账号下的反馈邮箱地址
    [NPCommonConfig shareInstance].fadebackEmail = @"wm.feifan@gmail.com";
    // 应用推广作者 id。 xinggui.zhang: '1124342842' ;  jingbing.yuan '743484976' ;  meiyan.chen '1209894980'
    
//    [NPCommonConfig shareInstance].artistId = @"1209894980";
    
    // 禁用自动显示全屏广告.设为： NSIntegerMax
    // 默认界面‘viewWillAppear’调用13次，自动弹出全屏广告
    // 如果需要设置其他值，请参考质数列表。‘NPCommonConfig.m’ 文件中有说明
    // 质数列表: 2、3、5、7、11、13、17、19、23、29、31、37、41、43、47、53、59、61、67、71、73、79、83、89、97
    [NPCommonConfig shareInstance].viewAppearUntilShowInterstitialAd = 99999999;   // 全屏广告
    [NPCommonConfig shareInstance].viewAppearUntilPromptRate = 53;          // 提示评论
    [NPCommonConfig shareInstance].shouldShowNetworkErrorNotification = YES;    // 网络未连接时显示通知栏提示信息
    [NPCommonConfig shareInstance].shouldShowMoreAppsInSettings = NO;
    
    //    [NPCommonConfig shareInstance].shouldPreloadRewardVideoAd = YES;
    //    [NPCommonConfig shareInstance].nativeAdViewCloseType = NPNativeAdViewCloseTypeNotCoverAdLeftTop;
    
    
#ifndef DEBUG
    // 发布阶段使用真实广告ID
    // 横幅广告
//    [NPCommonConfig shareInstance].admobBannerAdID              = @"ca-app-pub-7028363992110677/2957754547";
    // 全屏广告
//    [NPCommonConfig shareInstance].admobInterstitialAdID        = @"ca-app-pub-7028363992110677/4434487745";
//    // 原生80H广告
//    [NPCommonConfig shareInstance].admobNativeExpressAdID       = @"ca-app-pub-7028363992110677/3748621402";
//    // 原生250H广告
//    [NPCommonConfig shareInstance].admobNativeExpress250HAdID   = @"ca-app-pub-7028363992110677/2463637507";
    //启动 开屏广告
    [NPCommonConfig shareInstance].admobNativeLaunchAdID        = @"ca-app-pub-7028363992110677/7352269586";
    // 原生250H 自定义半屏广告
    [NPCommonConfig shareInstance].admobCustomHalfScreenAdID    = @"ca-app-pub-7028363992110677/7791253285";
    
    // 激励视频广告, 暂不支持
    //    [NPCommonConfig shareInstance].admobRewardVideoAdID         = @"ca-app-pub-7028363992110677/1434419340";
#endif
    //
    
    //-------------------------Facebook 广告配置 ------------------------------------//
    // fb 显示测试广告，需要将LOG 中 testDevice 添加到该数值, 否则广告出不来   // 在Console找到测试设备的id  添加测试设备.
    [NPCommonConfig shareInstance].fbAdTestDevices = @[@"c245499da04a2451b94819bd5e4f73d2e99dbb62",
                                                       @"1a3bc305ebbfe4f0e0405b2169b3ad44b14d5a8c",
                                                       @"ccd1d5840904c792e74c2c052a1ce74f5bbd46cf"
                                                       ];
    
    
    //如果不设置facebook 该广告位，ID设为 nil 即可，内部会自动获取admob广告
    // banner view
    [NPCommonConfig shareInstance].fbBannerAdID =                 nil;
    //native views
    // native 80H
    [NPCommonConfig shareInstance].fbNativeSmallAdID =            nil;
    // native 132H
    [NPCommonConfig shareInstance].fbNativeMidAdID =              nil;
    // native 250H
    [NPCommonConfig shareInstance].fbNativeLargeAdID =            @"165658080660242_165658493993534";
    // 开屏广告
    [NPCommonConfig shareInstance].fbNativeLaunchAdID =           @"165658080660242_165658257326891";
    // InterstitialAd 全屏广告
    [NPCommonConfig shareInstance].fbInterstitialAdID =           nil;
    
    // ====== 设置facebook 原生广告 颜色样式 ===========
    [NPCommonConfig shareInstance].fbNativeAdBackgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    //    [NPCommonConfig shareInstance].fbNativeAdTitleColor =  [UIColor blackColor];
    //    [NPCommonConfig shareInstance].fbNativeAdSubtitleColor = [UIColor colorWithRed:85/255. green:85/255. blue:85/255. alpha:1.];
    //    [NPCommonConfig shareInstance].fbNativeAdButtonBackgroundColor = [UIColor colorWithRed:91/255. green:147/255. blue:252/255. alpha:1.];
    //    [NPCommonConfig shareInstance].fbNativeAdButtonTitleColor = [UIColor whiteColor];
    // =================================

    // 配置提示评论相关信息
    [[NPCommonConfig shareInstance] initRateAppConfig];
    // 注意，必须在请求开屏广告之前执行‘initAdvertise’
    [[NPCommonConfig shareInstance] initAdvertise];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    
    
    
    // 初始化 Firebase，注意在 AppDelegate 'didFinishLaunchingWithOptions' 中调用
    [[NPCommonConfig shareInstance] initAnalyticsWhenAppDidLaunch];
    
    // Override point for customization after application launch.
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self.window = [[UIWindow alloc] initWithFrame:screenBounds];
    self.window.backgroundColor =  [UIColor whiteColor];

    //------- 开屏广告植入 ------ //
    //------- 开屏广告植入 ------ //
    //------- 开屏广告植入 ------ //
    //------- 开屏广告植入 ------ //
    // 注意更换开屏广告中的icon 图标, 'AdvertiseImages.xcassets' 中 icon图片需要更换, ad_launch_bgimage 背景图需要和启动画面和主页风格保持一致
    BOOL isSafeForShenHe = YES;
    
    // 如果因开屏广告被拒，请开启以下代码,设置审核通过截至时间 例如 ：'2017-07-27'
    //    [[NPCommonConfig shareInstance] setShenHeJiezhiShijianStr:@"2017-07-14"];
    //    isSafeForShenHe = [[NPCommonConfig shareInstance] isSafeForShenHePeriod];
    
    BOOL shouldShowAD = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (isSafeForShenHe && shouldShowAD) {
        // 添加 【 开屏广告 】，建议背景图片的使用和 LaunchScreen 保持一致.
        __weak typeof(self) weakSelf = self;
        [[NPCommonConfig shareInstance] launchViewControllerWithKeyWindow:self.window forLaunch:^(NPLaunchAdViewController *launchAdViewController) {
            launchAdViewController.dismiss = ^(NPLaunchViewDismissType dismissType){
                UIStoryboard * stroy = [UIStoryboard storyboardWithName:@"MindFile" bundle:[NSBundle mainBundle]];
                SNMindFileViewController *mindMap = stroy.instantiateInitialViewController;
                SNBaseNavigationController * navi = [[SNBaseNavigationController alloc]initWithRootViewController:mindMap];;
                weakSelf.window.rootViewController = navi;
            };
        }];
        
    }else{
        UIStoryboard * stroy = [UIStoryboard storyboardWithName:@"MindFile" bundle:[NSBundle mainBundle]];
        SNMindFileViewController *mindMap = stroy.instantiateInitialViewController;
        SNBaseNavigationController * navi = [[SNBaseNavigationController alloc]initWithRootViewController:mindMap];
        self.window.rootViewController = navi;
    }
//    CGRect screenBounds = [UIScreen mainScreen].bounds;
//    self.window = [[UIWindow alloc] initWithFrame:screenBounds];
//    self.window.backgroundColor =  [UIColor whiteColor];
//    UIStoryboard * stroy = [UIStoryboard storyboardWithName:@"MindFile" bundle:[NSBundle mainBundle]];
//    SNMindFileViewController *mindMap = stroy.instantiateInitialViewController;
//    SNBaseNavigationController * navi = [[SNBaseNavigationController alloc]initWithRootViewController:mindMap];
//    self.window.rootViewController = navi;
    [self.window makeKeyAndVisible];
    [self cleanTmp];
    return YES;
}



-(void)cleanTmp{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * tempDir = NSTemporaryDirectory();
        NSError * error ;
        NSArray * contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempDir error:&error];
        if (error) {
            NSLog(@"获取tmp目录失败:%@",error);
            return;
        }
        for (NSString * fileName in contents) {
            NSString * filePath = [tempDir stringByAppendingPathComponent:fileName];
            BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
            if (isExist) {
                NSError * removeError;
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:&removeError];
                if (removeError) {
                    NSLog(@"删除文件失败:%@",removeError);
                    continue;
                }
            }
        }
    });
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
