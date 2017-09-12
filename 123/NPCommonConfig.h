//
//  NPCommonConfig.h
//  Common
//
//  Created by mayuan on 16/8/3.
//  Copyright © 2016年 camory. All rights reserved.
// version: 20170512  11:00

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NPNativeAdView.h"
#import "Firebase.h"
#import "NPLaunchAdViewController.h"
#import "CVAdPlatformPriorityStrategy.h"


typedef NS_ENUM(NSInteger, NPViewAppearDisplayFullScreenType) {
    //仅显示插屏广告
    NPViewAppearDisplayFullScreenTypeInterstitialOnly,
    //显示插屏广告，当没有加载到插屏广告时，以原生广告250H作为替补。原生广告样式在'NPNativeAdViewCloseType'定义
    NPViewAppearDisplayFullScreenTypeInterstitialWithNativeAd,
    //显示插屏广告，当没有加载到插屏广告时，以原生广告250H作为替补。原生广告样式在'NPNativeAdViewCloseType'定义; 同时概率性出现提示观看视频广告。 以上两种互为替补
    NPViewAppearDisplayFullScreenTypeInterstitialWithNativeAdORRemindWatchVideo
};


typedef void (^NPRewardVideoLoadState)(BOOL isSuccess, NSError *error);


// 观看视频广告回调  'rewardCount' 奖励额度， 当rewardCount>0 给予奖励 ；  'isPlayed' 是否成功播放， 'error' 一般请求出错
typedef void (^NPWatchVideoRewardResult)(NSInteger rewardCount, BOOL isPlayed, NSError *error);

typedef void (^NPInterstitialDismissAction)(void);

// 'productId' 内购产品ID； ‘isSuccess’ 是否购买成功
typedef void (^NPPaymentCompleteAction)(NSString *productId, BOOL isSuccess);


@interface NPCommonConfig : NSObject

// 免费版 appId
@property (nonatomic, copy) NSString *liteAppId;
// 付费版 appId
@property (nonatomic, copy) NSString *proAppId;

// 移除广告内购id
@property (nonatomic, copy) NSString *removeAdPurchaseProductId;

// 用户反馈邮箱地址
@property (nonatomic, copy) NSString *fadebackEmail;

// 应用推广作者 id
@property (nonatomic, copy) NSString *artistId;

//已废弃。 admob 显示测试广告，需要将LOG 中 testDevice 添加到该数值
@property (nonatomic, strong) NSArray *adTestDevices;
// admob 广告关键字指定，可能广告相关度会提高
@property (nonatomic, strong) NSArray *adKeyWords;

// 是否显示推荐更多APP，栏目, 默认NO
@property (nonatomic, assign) BOOL shouldShowMoreAppsInSettings;

// 应用从后台切换到前台，是否显示全屏广告，默认YES
@property (nonatomic, assign) BOOL shouldShowFullscreenAdFromBackgroundToForeground;


@property (nonatomic, assign) BOOL shouldPreloadRewardVideoAd;

// 是否开启 BannerView 刷新动画， 默认NO
@property (nonatomic, assign) BOOL enableBannerViewAnimation;

// 应用使用一段时间后会提示用户评论， 在提示之前，界面viewController 显示次数，默认30;
@property (nonatomic, assign) NSInteger viewAppearUntilPromptRate;

// 显示全屏广告前，viewController显示次数   默认20
@property (nonatomic, assign) NSInteger viewAppearUntilShowInterstitialAd;

// 显示提示购买前，全屏广告展示次数. 默认7，
@property (nonatomic, assign) NSInteger showInterstitialAdCountForPromptRemoveAd;


// 点击goPro 按钮时，是否需要询问用户，是否购买？ 如不询问，直接跳转appstore. 默认 NO
@property (nonatomic, assign) BOOL shouldAskUserWhenPressProButton;
// 当前网络是否连接
@property (nonatomic, assign) BOOL isNetworkConnected;
// 是否显示网络连接失败提示信息
@property (nonatomic, assign) BOOL shouldShowNetworkErrorNotification;

// 作为全屏广告替补的 原生广告250H 关闭按钮类型选择
@property (nonatomic, assign) NPNativeAdViewCloseType nativeAdViewCloseType;

// 界面切换时，全屏广告显示类型选择， 默认（NPViewAppearDisplayFullScreenTypeInterstitialWithNativeAd）显示插屏广告，以原始广告为替补
@property (nonatomic, assign) NPViewAppearDisplayFullScreenType fullScreenType;


//-------- 开屏广告页中 文案设置， 建议设置英文，也可以做国际化
// 开屏广告居中显示的文字内容
@property (nonatomic, strong) NSString *launchViewCenterContentStr;
// 开屏广告底部显示 app名称
@property (nonatomic, strong) NSString *launchViewAppTitle;
// 开屏广告底部显示 app副标题
@property (nonatomic, strong) NSString *launchViewAppSubtitle;

// 开屏广告是否自动消失，默认NO，倒计时结束后不自动消失
@property (nonatomic, assign) BOOL shouldLaunchViewAutoDismiss;

//--------Admobe ad ---------------//
//google admob 横幅广告ID
@property (nonatomic, copy) NSString *admobBannerAdID;

//google admob 全屏广告ID
@property (nonatomic, copy) NSString *admobInterstitialAdID;

// google admob NativeExpress 原生广告ID
@property (nonatomic, copy) NSString *admobNativeExpressAdID;

// google admob NativeExpress 132H 原生广告ID
@property (nonatomic, copy) NSString *admobNativeExpress132HAdID;

// google admob NativeExpress 250H 原生广告ID 高度区间(250~1200)， 都选择250
@property (nonatomic, copy) NSString *admobNativeExpress250HAdID;

@property (nonatomic, copy) NSString *admobNativeLaunchAdID;

// 自定义半屏广告ID, 使用原生250
@property (nonatomic, copy) NSString *admobCustomHalfScreenAdID;

// 激励视频广告 ID
@property (nonatomic, copy) NSString *admobRewardVideoAdID;

/// Custom Size
//半屏广告大小设置  
@property (nonatomic, assign) CGSize nativeHalfScreenAdViewSize;
// 开屏广告大小设置，已默认全屏
@property (nonatomic, assign) CGSize nativeLaunchAdViewSize;
// 大尺寸原生广告大小 配置
@property (nonatomic, assign) CGSize nativeLargeViewsize;
//  是否需要预加载  半屏 原生广告
@property (nonatomic, assign) BOOL shouldPreloadNativeHalfScreenAd;


// ----- FB ad -------//
@property (nonatomic, copy) NSString *fbBannerAdID;

@property (nonatomic, copy) NSString *fbNativeSmallAdID;
@property (nonatomic, copy) NSString *fbNativeMidAdID;
@property (nonatomic, copy) NSString *fbNativeLargeAdID;

@property (nonatomic, copy) NSString *fbNativeLaunchAdID;

@property (nonatomic, copy) NSString *fbInterstitialAdID;

//fb 显示测试广告，需要将LOG 中 testDevice 添加到该数值
@property (nonatomic, strong) NSArray *fbAdTestDevices;

@property (nonatomic, assign) BOOL isFacebookReachable;

////// 广告优先级策略选择类
@property (nonatomic, strong) CVAdPlatformPriorityStrategy *adPlatformPriorityStrategy;

+ (instancetype)shareInstance;

- (void)initRateAppConfig;

// 初始化广告，全局仅调用一次即可
- (void)initAdvertise;

// 初始化 Firebase，注意在 AppDelegate 'didFinishLaunchingWithOptions' 中调用
- (void)initAnalyticsWhenAppDidLaunch;

#pragma mark - 产品使用信息
// 是否应该显示广告，专业版 及 lite版已移除广告，不应该显示广告
- (BOOL)shouldShowAdvertise;

// 是否是Lite版
- (BOOL)isLiteApp;

// 当前版本是否已经评论
- (BOOL)isThisVersionRated;

// 历史版本是否曾经评论过
- (BOOL)isAnyVersionRated;

// app 已使用次数
- (NSUInteger)appUsesCount;

// APP 使用天数
- (NSUInteger)appUseDaysCount;

// 当前 appId
- (NSString *)currentAppID;

// 在appstore 中显示的标题名称
- (NSString *)appStoreTrackName;

// 应用名称，icon下显示名称
- (NSString *)applicationName;

// 当前版本是否上线
- (BOOL)isCurrentVersionOnline;

// 是否查询到上架（通过审核），或使用超过一天。则判断为安全，隐藏 功能 可开启
- (BOOL)isSafeForAppleReviewPeriod;

- (CGFloat)priceWhenInstall;


#pragma mark - 内购相关
// 内购移除广告
- (void)paymentForRemoveAd;
// 内购移除广告
- (void)restorePaymentForRemoveAd;

// 内购商品，传入商品id; // 'productId' 内购产品ID； ‘isSuccess’ 是否购买成功
- (void)paymentForProductIdentifier:(NSString *)productIdentifier withPaymentComplete:(NPPaymentCompleteAction)paymentCompleteAction;

// 判断该商品是否已购买
- (BOOL)havePurchasedForProductIdentifier:(NSString *)productIdentifier;

- (void)gotoBuyProVersion;

#pragma mark - 评论相关
 

//显示评论解锁提示框，无五星，无明显解锁文案。 ‘请去评分支持我们，即可流畅的使用功能。感谢您的支持！’
//- (void)showGoodLuckForPinlunView;

// 功能限制，请购买专业版引导
- (void)showFeatureLockedForGoProAlertView;

// 去评论
- (void)openRatingsPageInAppStore;

//  弹出提示评论框，建议弹出前先判断用户是否已经评论过
- (void)promptForRating;

// 设置当前版本是否已经评论
- (void)setRatedStateForThisVersion:(BOOL)rated;


#pragma mark - 全屏广告相关

// 获取概率结果，  numerator/denominator , 分子/分母。 比如 1/4， 则有1/4机会返回 YES, 分母不能为0
- (BOOL)getProbabilityFor:(NSInteger)numerator from:(NSInteger)denominator;

// 显示全屏广告
- (void)showInterstitialAdInViewController:(UIViewController *)viewController;
// 全屏广告是否加载准备好
- (BOOL)isInterstitialAdReady;



// ===== 显示全屏广告，推荐使用该接口 =====
// 优先显示 全屏广告 以 大尺寸原生广告 作为替补
- (void)showFullScreenAdWithNativeAdAlertViewForController:(UIViewController *)viewController;


//   全屏广告 或者提示 显示 激励广告提醒框
//显示插屏广告，当没有加载到插屏广告时，以原生广告250H作为替补。原生广告样式在'NPNativeAdViewCloseType'定义; 同时概率性出现提示观看视频广告。 以上两种互为替补
- (void)showFullScreenAdORRemindRewardVideoAdForController:(UIViewController *)viewController;

// 优先展示视频广告，以全屏广告作为替补，如无全屏广告，以原生250作替补
- (void)showRewardVideoWithFullScreenADWithNativeAdForController:(UIViewController *)viewController;

// 用于点击按钮即弹出全屏广告， 全屏广告关闭后，执行相关操作。 操作在‘NPInterstitialDismissAction’中定义
- (void)showInterstitialADWithDismissAction:(NPInterstitialDismissAction)dismissAction;

#pragma mark - 激励视频广告

// 激励广告是否已加载准备好
- (BOOL)isRewardViewLoadReady;

// 询问用户是否观看 视频广告
- (void)showRemindUserToWatchVideoView;

// 显示观看视频 解锁功能的弹窗
- (void)showWatchVideoToUnlockViewWithUnlockResult:(NPWatchVideoRewardResult)rewardResult;


// 如果已经请求到了激励视频广告,显示激励广告
- (void)showRewardVideoAdOnViewController:(UIViewController *)viewController;

- (void)requestRewardVideoAdWithComplete:(NPRewardVideoLoadState)handler;

// 观看视频广告获取奖励，block 回调是否获得奖励，如未请求到广告，显示error
- (void)watchRewardVideoWithReward:(NPWatchVideoRewardResult)rewardResult;


/// ================   废弃，请勿用  =====================
// 因原生广告收入较低，只能作为替补
//// 显示 大原生广告
- (void)showNativeAdAlertViewInView:(UIView *)superView;

// 原生250H广告是否加载准备好
- (BOOL)isNativeExpress250HAdReady;

//
//// 大原生广告 和 全屏广告 交替显示
//- (void)showFullScreenAdORNativeAdForController:(UIViewController *)viewController;
//// 优先显示 大尺寸原生广告 以 全屏广告 作为替补
/// ================   废弃，请勿用  =====================
- (void)showNavitveAdAlertViewWithFullScreenAdForController:(UIViewController *)viewController;

#pragma mark - 开屏广告相关
- (void)launchViewControllerWithKeyWindow:(UIWindow *)window forLaunch:(void(^)(NPLaunchAdViewController *))launchBlock;


@end
