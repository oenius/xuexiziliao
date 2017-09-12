//
//  NPCommonConfig.m
//  Common
//
//  Created by mayuan on 16/8/3.
//  Copyright © 2016年 camory. All rights reserved.
//

#import "NPCommonConfig.h"
#import "iRate.h"
#import "Macros.h"
#import "CVAdvertiseController.h"
#import "SBPaymentManager.h"
#import "SettingsLocalizeUtil.h"
#import "SBPaymentLocalizeUtil.h"
#import "MBProgressHUD.h"
#import "NPNativeAdView.h"

#import "Reachability.h"
#import "CustomIOSAlertView.h"
#import "CWStatusBarNotification.h"


NSString *appURLFormat = @"itms-apps://itunes.apple.com/app/id%@";

// 当前版本是否已上线
#define keyCurrVersionShangXian         @"keyCurrVersionShangXian"


#define Tag_AlertView_Remind_WatchVideo     1001
#define Tag_AlertView_Remind_RemoveAds      1002

@interface NPCommonConfig ()<
iRateDelegate,
SBPaymentDelegate,
CustomIOSAlertViewDelegate
>


@property (nonatomic, assign) BOOL hasAppEnterBackground;

@property (nonatomic) Reachability *internetReachability;

@property (nonatomic, strong) UIView *currentDisplayingAlertView;

@property (nonatomic, strong) MBProgressHUD *loadingHUD;

// 是否已经展示过 提示看视频
@property (nonatomic, assign) BOOL hasShowRemindWatchVideoAferLauch;

// 上次计入后台是否是由于用户点击广告（全屏广告，原生250）
@property (nonatomic, assign) BOOL isEnterBackgroundByUserTouchAD;

@property (nonatomic, assign) BOOL isPlayingRewardVideo;

@property (nonatomic, copy) NPInterstitialDismissAction interstitialDismissAction;

@property (nonatomic, copy) NPPaymentCompleteAction paymentCompleteAction;

//  由 - (void)setLockStartDayStr:(NSString *)startDayStr endDayStr:(NSString *)endDayStr 完成设定
@property (nonatomic, strong) NSDate *lockStartDayTime;
@property (nonatomic, strong) NSDate *lockEndDayTime;

@property (strong, nonatomic) CWStatusBarNotification *networkErrorNotification;

@end

@implementation NPCommonConfig


+ (instancetype)shareInstance {
    static dispatch_once_t predicate;
    static NPCommonConfig *instance = nil;
    dispatch_once(&predicate, ^{
        instance = [[NPCommonConfig alloc] init];
    });
    return instance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    // 设置以下值时，请设置质数，避免弹窗和弹广告同时出现，而出现冲突。不可设置相等的数值
    // 质数列表: 2、3、5、7、11、13、17、19、23、29、31、37、41、43、47、53、59、61、67、71、73、79、83、89、97

    _viewAppearUntilPromptRate = 17;
    _viewAppearUntilShowInterstitialAd = 5;
    _showInterstitialAdCountForPromptRemoveAd = 10;
    _shouldShowMoreAppsInSettings = YES;
    _shouldShowFullscreenAdFromBackgroundToForeground = YES;
    _enableBannerViewAnimation = NO;
    _shouldPreloadNativeHalfScreenAd = YES;
    _shouldPreloadRewardVideoAd = NO;
    _nativeAdViewCloseType = NPNativeAdViewCloseTypeCoverAdLeftTop;
    _fullScreenType = NPViewAppearDisplayFullScreenTypeInterstitialWithNativeAd;
    _shouldAskUserWhenPressProButton = NO;
    _isNetworkConnected = NO;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat minWidth = MIN(screenWidth, screenHeight);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGFloat adWidth = minWidth * 0.7;
        _nativeHalfScreenAdViewSize = CGSizeMake(adWidth, adWidth * 0.7);
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        _nativeHalfScreenAdViewSize = CGSizeMake(320, 282);
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGFloat adWidth = minWidth * 0.7;
        _nativeLargeViewsize = CGSizeMake(adWidth, adWidth);
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        CGFloat adHeight = minWidth * 0.89f;
        if (adHeight < 250) {
            adHeight = 250;
        }
        _nativeLargeViewsize = CGSizeMake(minWidth, adHeight);
    }
    
    
    _nativeLaunchAdViewSize = CGSizeMake(minWidth, minWidth);
  
#ifdef DEBUG
    // 测试广告ID
    _admobBannerAdID =              @"ca-app-pub-3940256099942544/2934735716";
    _admobInterstitialAdID =        @"ca-app-pub-3940256099942544/4411468910";
    _admobNativeExpressAdID =       @"ca-app-pub-6332273367158890/5389650966";
    _admobNativeExpress132HAdID =   @"ca-app-pub-6332273367158890/6752072161";
    _admobNativeExpress250HAdID =   @"ca-app-pub-6332273367158890/8228805363";
    _admobRewardVideoAdID =         @"ca-app-pub-6332273367158890/5871383767";
    _admobNativeLaunchAdID =        @"ca-app-pub-7028363992110677/7000356544";
    _admobCustomHalfScreenAdID =    @"ca-app-pub-6332273367158890/9039354966";
    
    _fbBannerAdID =                 @"221536061675894_221537345009099";
    _fbNativeSmallAdID =            @"221536061675894_221537048342462";
    _fbNativeMidAdID =              @"798136443694584_798137680361127";
    _fbNativeLargeAdID =            @"221536061675894_221537271675773";
    _fbNativeLaunchAdID =           @"221536061675894_221536945009139";
    _fbInterstitialAdID =           @"221536061675894_228947734268060";
    
 #endif
    _adPlatformPriorityStrategy = [[CVAdPlatformPriorityStrategy alloc] init];
    
  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInterstitialWillPresentNotification:) name:keyInterstitialWillPresentNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackgroundNotificatioin:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInterstitialWillLeaveAppNotification:) name:keyInterstitialWillLiveApplicationNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInterstitialDidDismissNotification:) name:keyInterstitialDidDismisstNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNative250HAdViewWillLiveAppNotification:) name:kAdvertiseGoogleNative250HADViewWillLiveApplicationNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRewardBaseVideoDidOpenNotification:) name:kAdvertiseGoogleRewardBaseVideoDidOpenNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRewardBaseVideoDidCloseNotification:) name:kAdvertiseGoogleRewardBaseVideoDidCloseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGetPriceWhenInstallNotification:) name:kGetPriceWhenInstallNotification object:nil];
    [SBPaymentManager defaultManager];
    
    return self;
}

- (void)observerNetworkChange{
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
}

/*!
 * Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable: {
            self.isNetworkConnected = NO;
            [self showNetworkInfoNotification];
            break;
        }
            
        case ReachableViaWWAN: {
            self.isNetworkConnected = YES;
            [self loadAdvertise];
            [self dismissNetworkInfoNotification];
            break;
        }
        case ReachableViaWiFi:  {
            self.isNetworkConnected = YES;
            [self loadAdvertise];
            [self dismissNetworkInfoNotification];
            break;
        }
    }
    NSNumber *enable = [NSNumber numberWithBool:self.isNetworkConnected];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkStateChangedNotification object:enable];
    LOG(@"%s, netStatus: %ld",__func__, netStatus);
}

- (void)showNetworkInfoNotification{
    BOOL shouldShow = self.shouldShowNetworkErrorNotification;
    if (NO == shouldShow) {
        return;
    }
    
    if (self.networkErrorNotification == nil) {
        self.networkErrorNotification = [CWStatusBarNotification new];
        // set default blue color (since iOS 7.1, default window tintColor is black)
        self.networkErrorNotification.notificationLabelBackgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        self.networkErrorNotification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
        self.networkErrorNotification.notificationAnimationOutStyle = CWNotificationAnimationStyleBottom;
        self.networkErrorNotification.notificationStyle = CWNotificationStyleStatusBarNotification;
//        __weak typeof(self) weakSelf = self;
        self.networkErrorNotification.notificationTappedBlock = ^(void) {
            LOG(@"notification tapped, go to network settings");
            // more code here
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//            [weakSelf dismissNetworkInfoNotification];
        };
    }
    NSString *networkErroMsg= [SettingsLocalizeUtil localizedStringForKey:@"Network connection failed, please turn on wireless data" withDefault:@"Network connection failed, please turn on wireless data"];
    [self.networkErrorNotification displayNotificationWithMessage:networkErroMsg completion:nil];
}

- (void)dismissNetworkInfoNotification {
    [self.networkErrorNotification dismissNotification];
    self.networkErrorNotification = nil;
}

- (void)clearRecordingCounts {
    [iRate sharedInstance].eventCount = 0;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setInteger:0 forKey:Key_User_ViewAppear_Before_FullscreenAd];
    [userDefault setInteger:0 forKey:Key_User_ViewAppear_BeforePrompt_Count];
    [userDefault synchronize];    
}


- (void)initRateAppConfig {
    LOG(@"%s, LiteAppID: %@, ProAppID: %@, 请检查是否配置正确",__func__, _liteAppId, _proAppId);
#ifdef ISPRO
    if (_proAppId.length > 0) {
        [iRate sharedInstance].appStoreID = _proAppId.integerValue;
    }
#else
    if (_liteAppId.length > 0) {
        [iRate sharedInstance].appStoreID = _liteAppId.integerValue;
    }
#endif
    [iRate sharedInstance].delegate = self;
    
    //set events count (default is 10)
    [iRate sharedInstance].eventsUntilPrompt = _viewAppearUntilPromptRate;
    //disable minimum day limit and reminder periods
    [iRate sharedInstance].daysUntilPrompt = 0;
    [iRate sharedInstance].usesUntilPrompt = 2;
    //    [iRate sharedInstance].remindPeriod = 0;
    [iRate sharedInstance].promptAtLaunch = NO;
    
    [iRate sharedInstance].remindButtonLabel = @"";
    // 使用时间超过1天后，提示评论为5星
    NSInteger appUseDays = [self appUseDaysCount];
 
#ifndef DEBUG
    // 此处修正弹出250H 弹窗，
    if (appUseDays < 1) {
        if (_nativeAdViewCloseType == NPNativeAdViewCloseTypeCoverAdLeftTop) {
            _nativeAdViewCloseType = NPNativeAdViewCloseTypeNotCoverAdLeftTop;
        }
    }
#endif
    
}

// 初始化 Firebase，注意在 AppDelegate 'didFinishLaunchingWithOptions' 中调用
- (void)initAnalyticsWhenAppDidLaunch{
    [FIRApp configure];
}

- (void)initAdvertise {
    static dispatch_once_t predic;
    dispatch_once(&predic, ^{
        [self performSelector:@selector(observerNetworkChange) withObject:nil afterDelay:0.5];
    });

}

- (void)loadAdvertise {
#ifndef ISPRO
    BOOL shouldShowAd = [self shouldShowAdvertise];
    if (YES == shouldShowAd) {
        if (self.isNetworkConnected) {
            static dispatch_once_t loadAd;
            dispatch_once(&loadAd, ^{
                [[CVAdvertiseController shareInstance] initAdvertise];
            });
        }
    }
   
#endif
}


- (void)setRatedStateForThisVersion:(BOOL)rated{
    [[iRate sharedInstance] setRatedThisVersion:rated];
}

// 去评论
- (void)openRatingsPageInAppStore{
    [[iRate sharedInstance] openRatingsPageInAppStore];
    [self setRatedStateForThisVersion:YES];
}

- (BOOL)isThisVersionRated{
    return [[iRate sharedInstance] ratedThisVersion];
}

- (BOOL)isAnyVersionRated {
    return [[iRate sharedInstance] ratedAnyVersion];
}

// 使用次数
- (NSUInteger)appUsesCount{
    return [[iRate sharedInstance] usesCount];
}

// 使用天数
- (NSUInteger)appUseDaysCount {
    NSDate *firstUsedTime = [iRate sharedInstance].firstUsed;
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:firstUsedTime];
    NSUInteger days = (NSUInteger)(seconds / 54000.0);
    return days;
}

- (CGFloat)priceWhenInstall{
    CGFloat price = [[iRate sharedInstance] priceWhenInstall];
    return price;
}

// 是否查询到上架（通过审核），或使用超过一天。则判断为安全，隐藏 功能 可开启
- (BOOL)isSafeForAppleReviewPeriod{
    BOOL isShangXian = [self isCurrentVersionOnline];
    NSUInteger days = [self appUseDaysCount];
    BOOL isSafe = NO;
    if (isShangXian || (days > 0)) {
        isSafe = YES;
    }
#ifdef DEBUG
    isSafe = YES;
#endif
    return isSafe;
}

- (BOOL)shouldJiaShuoForPinlun{
    //  已上线，未评论过的，需要加锁。否则，不加锁
//    BOOL isLiteApp = [self isLiteApp];
//    if (NO == isLiteApp) {
//        // 付费版不加锁
//        return NO;
//    }
    if (self.lockStartDayTime && self.lockEndDayTime) {
        NSDate *currentDayTime = [NSDate date];
        if (([currentDayTime compare:self.lockStartDayTime] == NSOrderedDescending ) &&  ([currentDayTime compare:self.lockEndDayTime] == NSOrderedAscending) ) {
            // 'currentDayTime' is later than 'lockStartDayTime' &&  'currentDayTime' is earlier than 'lockEndDayTime'
        }else{
            // 如果设置了 加锁时间限制，而不再时间区域内，则不应该加锁
            return NO;
        }
    }
    
    BOOL haseRated = [self isAnyVersionRated];
    
    BOOL isShangXian = [self isCurrentVersionOnline];
    NSUInteger days = [self appUseDaysCount];
    BOOL isSafe = NO;
    if (isShangXian && (days > 1)) {
        isSafe = YES;
    }
#ifdef DEBUG
    isSafe = YES;
#endif
//    LOG(@"%s, isShangXian: %d, usedDays: %ld, haseRated: %d",__func__, isShangXian, days, haseRated);
#ifdef DEBUG
    if (NO == haseRated) {
        return YES;
    }
#else
    if (isSafe && (NO == haseRated)) {
        return YES;
    }
#endif
    return NO;
}

//  弹出提示评论框，建议弹出前先判断用户是否已经评论过
- (void)promptForRating{
    [[iRate sharedInstance] promptForRating];
}

- (NSString *)currentAppID {
    NSString *appId = [NSString stringWithFormat:@"%lu", (unsigned long)[iRate sharedInstance].appStoreID];
    return appId;
}

// 在appstore 中显示的标题名称
- (NSString *)appStoreTrackName{
    NSString *trackName = [iRate sharedInstance].appStoreTrackName;
    return trackName;
}

// 应用名称，icon下显示名称
- (NSString *)applicationName {
    NSString *appName = [iRate sharedInstance].applicationName;
    return appName;
}

// 当前版本是否上线
- (BOOL)isCurrentVersionOnline {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    BOOL isOnline = [userDefault boolForKey:keyCurrVersionShangXian];
    if (isOnline) {
        return YES;
    }
    
    NSString *latestVersion = [iRate sharedInstance].latestVersion;
    NSString *applicationVersion = [iRate sharedInstance].applicationVersion;
    if (latestVersion != nil && latestVersion.length > 0) {
        if ([applicationVersion compare:latestVersion options:NSNumericSearch] == NSOrderedDescending){
            // applicationVersion > latestVersion
            return NO;
        }else{
            // applicationVersion <= latestVersion
            [userDefault setBool:YES forKey:keyCurrVersionShangXian];
            [userDefault synchronize];
            return YES;
        }
    }else{
        return NO;
    }
    return NO;
}

// 是否应该显示广告，专业版 及 lite版已移除广告，不应该显示广告
- (BOOL)shouldShowAdvertise {
#ifdef ISPRO
    return NO;
#else
    BOOL haveRemovedAD = [[NSUserDefaults standardUserDefaults] boolForKey:Key_User_Have_Removed_AD];
    NSString *removeAdPurchaseProductId = self.removeAdPurchaseProductId;
    BOOL haveRecord = [SBPaymentManager hasRecord:removeAdPurchaseProductId];
    if (haveRemovedAD) {
        return NO;
    }
    if (haveRecord) {
        return NO;
    }
    CGFloat priceWhenInstall = [self priceWhenInstall];
    if (priceWhenInstall > 0) {
        return NO;
    }
    
#endif    
    return YES;


}

- (BOOL)isLiteApp {
#ifdef ISPRO
    return NO;
#endif
    return YES;
}


// 获取概率结果，  numerator/denominator , 分子/分母。 比如 1/4， 则有1/4机会返回 YES
- (BOOL)getProbabilityFor:(NSInteger)numerator from:(NSInteger)denominator{
    //    获取一个随机整数范围在：[0,100)包括0，不包括100
    //  int x = arc4random() % 100;
    NSInteger index = arc4random() % denominator;   // 0,1,2,3
    if (index < numerator) {
        return YES;
    }else{
        return NO;
    }
}


- (void)showInterstitialAdInViewController:(UIViewController *)viewController{
    LOG(@"%s",__func__);
#ifndef ISPRO
    if ([[CVAdvertiseController shareInstance] showInterstitialLoadingState]) {
        [[CVAdvertiseController shareInstance] showInterstitial:viewController];
    }
#endif
}

- (BOOL)isInterstitialAdReady {
#ifndef ISPRO
    if ([[CVAdvertiseController shareInstance] showInterstitialLoadingState]) {
        return YES;
    }else{
        return NO;
    }
#endif
    return NO;
}

// 原生250H广告是否加载准备好
- (BOOL)isNativeExpress250HAdReady{
#ifndef ISPRO
    if ([[CVAdvertiseController shareInstance] isCustomHalfScreenAdReady]) {
        return YES;
    }else{
        return NO;
    }
#endif
    return NO;
}

static NSInteger fullScreenCount = 1;
- (void)showFullScreenAdORNativeAdForController:(UIViewController *)viewController{
     LOG(@"%s, ！！！！！！注意！！！！不推荐使用该方法， 请使用 showFullScreenAdWithNativeAdAlertViewForController",__func__);
#ifndef ISPRO
    NSInteger index = fullScreenCount % 3;
    switch (index) {
        case 0:{
            if ([[CVAdvertiseController shareInstance] isCustomHalfScreenAdReady]) {
                [self showNativeAdAlertViewInView:nil];
            }else{
                if ([[CVAdvertiseController shareInstance] showInterstitialLoadingState]) {
                    [[CVAdvertiseController shareInstance] showInterstitial:viewController];
                }
            }
        }
            break;
        case 1:{
            if ([[CVAdvertiseController shareInstance] showInterstitialLoadingState]) {
                [[CVAdvertiseController shareInstance] showInterstitial:viewController];
            }else{
                if ([[CVAdvertiseController shareInstance] isCustomHalfScreenAdReady]) {
                    [self showNativeAdAlertViewInView:nil];
                }
            }
        }
            break;
        default:{
            if ([[CVAdvertiseController shareInstance] showInterstitialLoadingState]) {
                [[CVAdvertiseController shareInstance] showInterstitial:viewController];
            }else{
                if ([[CVAdvertiseController shareInstance] isCustomHalfScreenAdReady]) {
                    [self showNativeAdAlertViewInView:nil];
                }
            }
        }
            break;
    }
    fullScreenCount ++;
#endif
}

- (void)showFullScreenAdORRemindRewardVideoAdForController:(UIViewController *)viewController{
//    获取一个随机整数范围在：[0,100)包括0，不包括100
//  int x = arc4random() % 100;
    NSInteger index = arc4random() % 3;   // 0,1,2
    switch (index) {
        case 0:{
            BOOL isRewardAdReady = [self isRewardViewLoadReady];
            if (isRewardAdReady) {
                [self showRemindUserToWatchVideoView];
            }else{
                [self showFullScreenAdWithNativeAdAlertViewForController:viewController];
            }
        }
            break;
        case 1:{
            [self showFullScreenAdWithNativeAdAlertViewForController:viewController];
        }
            break;
        default:{
            [self showFullScreenAdWithNativeAdAlertViewForController:viewController];
        }
            break;
    }
}

// 优先展示视频广告，以全屏广告作为替补，如无全屏广告，以原生250作替补
- (void)showRewardVideoWithFullScreenADWithNativeAdForController:(UIViewController *)viewController{
    BOOL isRewardAdReady = [self isRewardViewLoadReady];
    if (isRewardAdReady) {
        [self showRewardVideoAdOnViewController:viewController];
    }else{
        [self showFullScreenAdWithNativeAdAlertViewForController:viewController];
    }
}



- (void)showNativeAdAlertViewInView:(UIView *)superView{
#ifndef ISPRO
    if ([[CVAdvertiseController shareInstance] isCustomHalfScreenAdReady]) {
        NPNativeAdViewCloseType closeType = self.nativeAdViewCloseType;
        if (closeType == NPNativeAdViewCloseTypeWithBottomRmoveAds) {
            __weak typeof(self) weakSelf = self;
            [[CVAdvertiseController shareInstance] achieveNativeCustomHalfScreenView:^(UIView *nativeHalfScreenAdView) {
                if(nativeHalfScreenAdView == nil){
                    return ;
                }
                CGSize nativeAdViewSize = nativeHalfScreenAdView.frame.size;
                nativeHalfScreenAdView.frame = CGRectMake(0, 0, nativeAdViewSize.width, nativeAdViewSize.height);
                nativeHalfScreenAdView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                
                if (weakSelf.currentDisplayingAlertView) {
                    CustomIOSAlertView *alertView = (CustomIOSAlertView *)weakSelf.currentDisplayingAlertView;
                    [alertView resetContainerView:nativeHalfScreenAdView];
                }else{
                    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
                    alertView.tag = Tag_AlertView_Remind_RemoveAds;
                    [alertView setContainerView:nativeHalfScreenAdView];
                    NSString *cancelStr = [SBPaymentLocalizeUtil localizedStringForKey:@"cancel" withDefault:@"Cancel"];
                    NSString *removeAdsStr = [SettingsLocalizeUtil localizedStringForKey:@"Remove Ads" withDefault:@"Remove Ads"];
                    //                    alertView.titleStr = remindMessageStr;
                    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:cancelStr, removeAdsStr, nil]];
                    [alertView setDelegate:weakSelf];
                    [alertView show];
                    weakSelf.currentDisplayingAlertView = alertView;
                }
            }];
        }else{
            NPNativeAdView *nativeAdView =  [[NPNativeAdView alloc] init];
            [nativeAdView loadAndShowNativeViewInView:superView];
        }
    }
#endif
}

- (void)showNavitveAdAlertViewWithFullScreenAdForController:(UIViewController *)viewController {
#ifndef ISPRO
    if ([[CVAdvertiseController shareInstance] isCustomHalfScreenAdReady]) {
        [self showNativeAdAlertViewInView:nil];
    }else{
        if ([[CVAdvertiseController shareInstance] showInterstitialLoadingState]) {
            [[CVAdvertiseController shareInstance] showInterstitial:viewController];
        }
    }
#endif
}

- (void)showFullScreenAdWithNativeAdAlertViewForController:(UIViewController *)viewController{
#ifndef ISPRO
    if ([[CVAdvertiseController shareInstance] showInterstitialLoadingState]) {
        [[CVAdvertiseController shareInstance] showInterstitial:viewController];
    }else{
        if ([[CVAdvertiseController shareInstance] isCustomHalfScreenAdReady]) {
            [self showNativeAdAlertViewInView:nil];
        }
    }
#endif
}

- (void)showInterstitialADWithDismissAction:(NPInterstitialDismissAction)dismissAction{
#ifndef ISPRO
    if ([[CVAdvertiseController shareInstance] showInterstitialLoadingState]) {
        self.interstitialDismissAction = dismissAction;
        [[CVAdvertiseController shareInstance] showInterstitial:nil];
    }else{
        if (dismissAction) {
            dismissAction();
        }
    }
#else
    if (dismissAction) {
        dismissAction();
    }
#endif
}



#pragma mark  - InApp Purchase

// 内购移除广告
- (void)paymentForRemoveAd{
    NSString *removeAdProductId = [NPCommonConfig shareInstance].removeAdPurchaseProductId;
    NSLog(@"移除广告内购ID = %@",removeAdProductId);
    [[SBPaymentManager defaultManager] purchaseWithProductIdentifier:removeAdProductId delegate:self];
}

- (void)restorePaymentForRemoveAd{
    NSString *removeAdProductId = [NPCommonConfig shareInstance].removeAdPurchaseProductId;
    LOG(@"移除广告内购ID = %@",removeAdProductId);
    [[SBPaymentManager defaultManager] restoreWithProductIdentifier:removeAdProductId delegate:self];
}

// 内购商品，传入商品id; // 'productId' 内购产品ID； ‘isSuccess’ 是否购买成功
- (void)paymentForProductIdentifier:(NSString *)productIdentifier withPaymentComplete:(NPPaymentCompleteAction)paymentCompleteAction{
    self.paymentCompleteAction = paymentCompleteAction;
    [self paymentForProductIdentifier:productIdentifier];
}


// 内购商品，传入商品id
- (void)paymentForProductIdentifier:(NSString *)productIdentifier{
    [[SBPaymentManager defaultManager] purchaseWithProductIdentifier:productIdentifier delegate:self];
}

- (void)gotoBuyProVersion{
    NSString *proAppID = self.proAppId;;
    NSString *proAppLink = [NSString stringWithFormat:appURLFormat, proAppID];
    NSURL * url = [NSURL URLWithString:proAppLink];
    [[UIApplication sharedApplication] openURL:url];
}

// 判断该商品是否已购买
- (BOOL)havePurchasedForProductIdentifier:(NSString *)productIdentifier{
    BOOL haveRecord = [SBPaymentManager hasRecord:productIdentifier];
    return haveRecord;
}


- (void)promptProVersionAndRemoveAdPayment{
    LOG(@"%s",__func__);
    NSString *paymentPromptMessage = [SBPaymentLocalizeUtil localizedStringForKey:@"Remove ad or upgrade to pro version fro a better experience." withDefault:@"Remove advertisement or upgrade to pro version for better experience"];
    NSString *applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if ([applicationName length] == 0){
        applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey];
    }
    paymentPromptMessage = [paymentPromptMessage stringByReplacingOccurrencesOfString:@"%@" withString:applicationName];
    
    UIViewController *topController = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (topController.presentedViewController){
        topController = topController.presentedViewController;
    }
    if ([UIAlertController class] && topController){
//        NSString *remindStr = [SBPaymentLocalizeUtil localizedStringForKey:@"Buy" withDefault:@"Purchase"];
        NSString *remindStr = [SBPaymentLocalizeUtil localizedStringForKey:@"Remind info" withDefault:@"Remind info"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:remindStr message:paymentPromptMessage preferredStyle:UIAlertControllerStyleAlert];
        
        //upgrade action
        NSString *upgradeToProStr = [SettingsLocalizeUtil localizedStringForKey:@"Upgrade to Pro Version" withDefault:@"Upgrade to Pro Version"];
        [alert addAction:[UIAlertAction actionWithTitle:upgradeToProStr style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
            [self gotoBuyProVersion];
        }]];
        
        //upgrade action
        NSString *removeAdsStr = [SettingsLocalizeUtil localizedStringForKey:@"Remove Ads" withDefault:@"Remove Ads"];
        [alert addAction:[UIAlertAction actionWithTitle:removeAdsStr style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
            [self paymentForRemoveAd];
        }]];
        
        NSString *cancelStr = [SBPaymentLocalizeUtil localizedStringForKey:@"cancel" withDefault:@"Cancel"];
        //rate action
        [alert addAction:[UIAlertAction actionWithTitle:cancelStr style:UIAlertActionStyleCancel handler:^(__unused UIAlertAction *action) {
        }]];
        
        //get current view controller and present alert
        [topController presentViewController:alert animated:YES completion:NULL];
    }
}


#pragma mark - SBPaymentDelegate
- (void)paymentSuccessed:(NSString *)productIdentifier type:(SBPaymentType)type {
    NSString *removeAdProductId = [NPCommonConfig shareInstance].removeAdPurchaseProductId;
    if ([removeAdProductId isEqualToString:productIdentifier]) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setBool:YES forKey:Key_User_Have_Removed_AD];
        [userDefault synchronize];
#ifndef ISPRO
        [[CVAdvertiseController shareInstance] closeAdvertise];
#endif
    }
    
    if (_paymentCompleteAction) {
        _paymentCompleteAction(productIdentifier, YES);
        self.paymentCompleteAction = nil;
    }
    
    LOG(@"%s, 购买或恢复商品成功, productIdentifier: %@",__func__, productIdentifier);
    NSString *operateSuccessStr = [SettingsLocalizeUtil localizedStringForKey:@"common.Operating Successed" withDefault:@"Success"];
    [self showTipViewWithMessage:operateSuccessStr];
}

- (void)paymentFailed:(NSString *)productIdentifier type:(SBPaymentType)type withError:(NSError *)error {
#ifdef DEBUG
    NSLog(@"购买或恢复商品(%@)失败：%@", productIdentifier, [error localizedDescription]);
#endif
    NSString *operateFailedStr = [SBPaymentLocalizeUtil localizedStringForKey:@"The purchase failed. Please try again later" withDefault:@"The purchase failed,Please try again later."];
#ifdef DEBUG
    operateFailedStr = [SettingsLocalizeUtil localizedStringForKey:@"task.fail" withDefault:@"Failed"];
    NSString *errorDescription = error.localizedDescription;
    if (errorDescription != nil && errorDescription.length > 0) {
        operateFailedStr = [NSString stringWithFormat:@"%@: %@", operateFailedStr, errorDescription];
    }
#endif
    [self showTipViewWithMessage:operateFailedStr];
    
    if (_paymentCompleteAction) {
        _paymentCompleteAction(productIdentifier, NO);
        self.paymentCompleteAction = nil;
    }
}



#pragma mark -iRateDelegate
- (void)iRateUserDidDeclineToRateApp{
    [iRate sharedInstance].eventCount = 0;
    [iRate sharedInstance].declinedThisVersion = NO;
}



//显示评论解锁提示框，无五星，无明显解锁文案。 ‘请去评分支持我们，即可流畅的使用功能。感谢您的支持！’
- (void)showGoodLuckForPinlunView {
    // title: 好运活动   message: 请去评分支持我们，即可流畅的使用功能。感谢您的支持！ 以后再说， 确认
    NSString *title = [SettingsLocalizeUtil localizedStringForKey:@"setting.goodluck for rate" withDefault:@"Good Luck!"];
    NSString *okStr = [SettingsLocalizeUtil localizedStringForKey:@"Sure" withDefault:@"OK"];
//    NSString *commentStr = [SettingsLocalizeUtil localizedStringForKey:@"setting.comment" withDefault:@"Rate Us"];
    NSString *cancelStr = [SBPaymentLocalizeUtil localizedStringForKey:@"cancel" withDefault:@"Cancel"];
     NSString *commentMessageStr = [SettingsLocalizeUtil localizedStringForKey:@"Please rate to support us, you can smooth the use of function. thank you for your support!" withDefault:@"Please go to rate us to get the more smooth function.Thank you for your supporting"];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:okStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openRatingsPageInAppStore];
    }];
    UIAlertAction *canleAction = [UIAlertAction actionWithTitle:cancelStr style:UIAlertActionStyleCancel handler:nil];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:commentMessageStr preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:confirmAction];
    [alertController addAction:canleAction];
    [[self topMostController] presentViewController:alertController animated:YES completion:nil];
}


// 功能限制，请购买专业版引导
- (void)showFeatureLockedForGoProAlertView{
    NSString *remindStr = [SBPaymentLocalizeUtil localizedStringForKey:@"Remind info" withDefault:@"Remind info"];
     NSString *cancelStr = [SBPaymentLocalizeUtil localizedStringForKey:@"cancel" withDefault:@"Cancel"];
    NSString *goProStr = [SBPaymentLocalizeUtil localizedStringForKey:@"locked for go pro version message" withDefault:@"Sorry. This feature is only available in Pro Version. Would you like to Upgrade to Pro Version now?"];
    NSString *okStr = [SettingsLocalizeUtil localizedStringForKey:@"Sure" withDefault:@"OK"];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:okStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self gotoBuyProVersion];
    }];
    UIAlertAction *canleAction = [UIAlertAction actionWithTitle:cancelStr style:UIAlertActionStyleCancel handler:nil];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:remindStr message:goProStr preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:okAction];
    [alertController addAction:canleAction];
    [[self topMostController] presentViewController:alertController animated:YES completion:nil];
}

- (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

// 设置锁定时间段 ：'startDayStr' 开始日期，例如 ：'2017-03-27', 'endDayStr' 结束日期，例如 '2017-04-15'
- (void)setLockStartDayStr:(NSString *)startDayStr endDayStr:(NSString *)endDayStr{
    NSDate *startDayTime = [[self class] dateFromString:startDayStr];
    NSDate *endDayTime = [[self class] dateFromString:endDayStr];
    NSAssert(startDayStr != nil, @"startDayStr 设置错误");
    NSAssert(endDayTime != nil, @"endDayStr 设置错误");
    self.lockStartDayTime = startDayTime;
    self.lockEndDayTime = endDayTime;
}


#pragma mark - 激励视频广告

// 激励广告是否已加载准备好
- (BOOL)isRewardViewLoadReady{
#ifndef ISPRO
    BOOL isReady = [[CVAdvertiseController shareInstance] isRewardVideoReady];
    return isReady;
#else
    return NO;
#endif
}

// 询问用户是否观看全屏广告, 前置条件: 视频广告已加载回来
- (void)showRemindUserToWatchVideoView{
    BOOL isRewardAdReady = [self isRewardViewLoadReady];
    if (NO == isRewardAdReady) {
         LOG(@"%s, ========== 错误=====",__func__);
        return;
    }
    
    if ([self isNativeExpress250HAdReady]) {
           [self showRemindUserToWatchVideoWithNativeAdView];
    }else{
        NSString *remindStr = [SBPaymentLocalizeUtil localizedStringForKey:@"Remind info" withDefault:@"Remind info"];
        NSString *cancelStr = [SBPaymentLocalizeUtil localizedStringForKey:@"cancel" withDefault:@"Cancel"];
        NSString *remindMessageStr = [SettingsLocalizeUtil localizedStringForKey:@"Watch a video to support us" withDefault:@"Watch a video to support us"];
        NSString *okStr = [SettingsLocalizeUtil localizedStringForKey:@"Sure" withDefault:@"OK"];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:okStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //        [self showRewardVideoAdOnViewController:nil];
            [self requestRewardVideoAdWithComplete:^(BOOL isSuccess, NSError *error) {
                if (isSuccess) {
                    [self showRewardVideoAdOnViewController:nil];
                }
            }];
        }];
        UIAlertAction *canleAction = [UIAlertAction actionWithTitle:cancelStr style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            [self showInterstitialAdInViewController:nil];
        }];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:remindStr message:remindMessageStr preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:okAction];
        [alertController addAction:canleAction];
        [[self topMostController] presentViewController:alertController animated:YES completion:nil];
    }
    self.hasShowRemindWatchVideoAferLauch = YES;
}

- (void)showRemindUserToWatchVideoWithNativeAdView{
    
    return;
    
#ifndef ISPRO
    __weak typeof(self) weakSelf = self;
    [[CVAdvertiseController shareInstance] achieveNativeExpress250HView:^(UIView *native250HView) {
        if(native250HView == nil){
            return ;
        }
        CGSize nativeAdViewSize = native250HView.frame.size;
        native250HView.frame = CGRectMake(0, 0, nativeAdViewSize.width, nativeAdViewSize.height);
        native250HView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        if (weakSelf.currentDisplayingAlertView) {
            CustomIOSAlertView *alertView = (CustomIOSAlertView *)weakSelf.currentDisplayingAlertView;
            [alertView resetContainerView:native250HView];
        }else{
            CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
            alertView.tag = Tag_AlertView_Remind_WatchVideo;
            [alertView setContainerView:native250HView];
            NSString *remindMessageStr = [SettingsLocalizeUtil localizedStringForKey:@"Watch a video to support us" withDefault:@"Watch a video to support us"];
            NSString *cancelStr = [SBPaymentLocalizeUtil localizedStringForKey:@"cancel" withDefault:@"Cancel"];
            NSString *okStr = [SettingsLocalizeUtil localizedStringForKey:@"Sure" withDefault:@"OK"];
            alertView.titleStr = remindMessageStr;
            [alertView setButtonTitles:[NSMutableArray arrayWithObjects:cancelStr, okStr, nil]];
            [alertView setDelegate:weakSelf];
            [alertView show];
            weakSelf.currentDisplayingAlertView = alertView;
        }
    }];
#endif
}

// 显示观看视频 解锁功能的弹窗
- (void)showWatchVideoToUnlockViewWithUnlockResult:(NPWatchVideoRewardResult)rewardResult{
    __weak typeof(self) weakSelf = self;
    NSString *remindStr = [SBPaymentLocalizeUtil localizedStringForKey:@"Remind info" withDefault:@"Remind info"];
    NSString *cancelStr = [SBPaymentLocalizeUtil localizedStringForKey:@"cancel" withDefault:@"Cancel"];
    NSString *remindMessageStr = [SettingsLocalizeUtil localizedStringForKey:@"Watch a video to unlock" withDefault:@"Watch a video to unlock"];
    NSString *okStr = [SettingsLocalizeUtil localizedStringForKey:@"Sure" withDefault:@"OK"];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:okStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf watchRewardVideoWithReward:^(NSInteger rewardCount, BOOL isPlayed, NSError *error) {
            if (rewardResult) {
                rewardResult(rewardCount, isPlayed, error);
            }
        }];
    }];
    UIAlertAction *canleAction = [UIAlertAction actionWithTitle:cancelStr style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // [self showInterstitialAdInViewController:nil];
    }];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:remindStr message:remindMessageStr preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:okAction];
    [alertController addAction:canleAction];
    [[self topMostController] presentViewController:alertController animated:YES completion:nil];
}



- (void)showRewardVideoAdOnViewController:(UIViewController *)viewController {
#ifndef ISPRO
    if ([self isRewardViewLoadReady]) {
        [[CVAdvertiseController shareInstance] showRewardVideoFromRootViewController:viewController];
    }
#endif
}

- (void)requestRewardVideoAdWithComplete:(NPRewardVideoLoadState)handler{
#ifndef ISPRO
    [[CVAdvertiseController shareInstance] requestRewardVideoAD:^(BOOL isSuccess, NSError *error) {
        handler(isSuccess, error);
    }];
#endif
}

- (void)watchRewardVideoWithReward:(NPWatchVideoRewardResult)rewardResult{
#ifndef ISPRO
    [self showLoadingState];
    __weak typeof(self) weakSelf = self;
    [[CVAdvertiseController shareInstance] requestRewardVideoAD:^(BOOL isSuccess, NSError *error) {
        [weakSelf hideLoadingState];
        if (isSuccess) {
            [self showRewardVideoAdOnViewController:nil];
            if (rewardResult) {
                rewardResult(1, YES, nil);
            }
        }else{
            NSString *errorInfo = [SBPaymentLocalizeUtil localizedStringForKey:@"DK_dialog_title_net_error" withDefault:@"No network connection is detected, please check and retry later"];
            [self showTipViewWithMessage:errorInfo];
            if (rewardResult) {
                rewardResult(0 ,NO, error);
            }
        }
    }];
#endif
}

// CustomIOSAlertViewDelegate
- (void)customIOS7dialogButtonTouchUpInside: (CustomIOSAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex{
    self.currentDisplayingAlertView = nil;
    [alertView close];
    NSInteger alertViewTag = alertView.tag;
    if (alertViewTag ==  Tag_AlertView_Remind_WatchVideo) {
        if (buttonIndex == 1) {
            [self showRewardVideoAdOnViewController:nil];
        }
    }else if(alertViewTag == Tag_AlertView_Remind_RemoveAds) {
        if (buttonIndex == 1) {
            [self paymentForRemoveAd];
        }
    }
}


#pragma mark - Tools

//NSDate转NSString
+ (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateString = [dateFormatter stringFromDate:date];
     LOG(@"%@",currentDateString);
    return currentDateString;
}

//NSString转NSDate
+ (NSDate *)dateFromString:(NSString *)string
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date=[formatter dateFromString:string];
    return date;
}


#pragma mark  - App Notifications
// 应用从后台到前台。 （注意，购买弹窗，系统提示弹出等，后会触发）
- (void)onAppDidBecomeActiveNotification:(NSNotification *)notification {
    LOG(@"%s", __func__);
    if (self.currentDisplayingAlertView != nil) {
        CustomIOSAlertView *alertView = (CustomIOSAlertView *)self.currentDisplayingAlertView;
        [alertView close];
        self.currentDisplayingAlertView = nil;
    }else{
        if (_shouldShowFullscreenAdFromBackgroundToForeground &&
            _hasAppEnterBackground &&
            (NO == _isEnterBackgroundByUserTouchAD) &&
            (NO == _isPlayingRewardVideo)) {
            BOOL shouldShowAD = [[NPCommonConfig shareInstance] shouldShowAdvertise];
            if (shouldShowAD) {
                double delayInSeconds = 0.8;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    BOOL isRewardVideoAdReady = [self isRewardViewLoadReady];
                    if(isRewardVideoAdReady){
                        [self showRewardVideoAdOnViewController:nil];
                    }else{
                        [self showFullScreenAdWithNativeAdAlertViewForController:nil];
                    }
                });
            }
        }
    }
    // 重置
    _hasAppEnterBackground = NO;
    self.isEnterBackgroundByUserTouchAD = NO;
}

//- (void)onInterstitialAdNotification:(NSNotification *)notification {
//    NSNumber *enableInterstitial = notification.object;
//    if (enableInterstitial.boolValue) {
//        [self triggerShowRemindWatchVideo];
//    }
//}

//- (void)onNative250HAdViewNotification:(NSNotification *)notification {
//    NSNumber *enableInterstitial = notification.object;
//    if (enableInterstitial.boolValue) {
//        [self triggerShowRemindWatchVideo];
//    }
//}

- (void)triggerShowRemindWatchVideo{
    return;
    NSDate *launchDate = [[iRate sharedInstance] currentLaunchedTime];
    NSTimeInterval lauchedPaste = [[NSDate date] timeIntervalSinceDate:launchDate];
    if (lauchedPaste < 4 ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showRemindUserToWatchVideoViewAtLaunchTime];
        });
    }
}

// 首次启动 加载到广告后，展示原生广告
- (void)showRemindUserToWatchVideoViewAtLaunchTime {
    if (NO == _hasShowRemindWatchVideoAferLauch) {
        BOOL isNativeAdReady = [self isNativeExpress250HAdReady];
        BOOL isRewardVideoAdReady = [self isRewardViewLoadReady];
        if (isNativeAdReady && isRewardVideoAdReady) {
            [self showRemindUserToWatchVideoView];
            _hasShowRemindWatchVideoAferLauch = YES;
        }
    }
}

- (void)onAppDidEnterBackgroundNotificatioin:(NSNotification *)notification {
     LOG(@"%s",__func__);
    _hasAppEnterBackground = YES;
    self.interstitialDismissAction = nil;
}


- (void)onInterstitialWillPresentNotification:(NSNotification *)notificaiton {
     LOG(@"%s",__func__);
//    界面切换次数计算 减一, 修正界面切换次数，可能导致的连续弹出全屏广告
    [self decreaseViewAppearCountForShowFullscreenAd];
    
}

- (void)onInterstitialWillLeaveAppNotification:(NSNotification *)notification {
     LOG(@"%s",__func__);
    self.isEnterBackgroundByUserTouchAD = YES;
   
}

- (void)onNative250HAdViewWillLiveAppNotification:(NSNotification *)notification {
    LOG(@"%s",__func__);
    self.isEnterBackgroundByUserTouchAD = YES;
}


- (void)onInterstitialDidDismissNotification:(NSNotification *)notification {
    LOG(@"%s",__func__);
    NSInteger interstitialShowCount = [self increaseTotalInterstitialShowCount];
    
    if (self.interstitialDismissAction) {
        self.interstitialDismissAction();
        self.interstitialDismissAction = nil;
        return;
    }
    
    NSInteger adCountForPromptRemoveAd = self.showInterstitialAdCountForPromptRemoveAd;
    if (adCountForPromptRemoveAd <=0) {
        adCountForPromptRemoveAd = 10;
    }
    if (interstitialShowCount % adCountForPromptRemoveAd == 0) {
        [self promptProVersionAndRemoveAdPayment];
    }
}

- (void)onRewardBaseVideoDidOpenNotification:(NSNotification *)notification {
    //    界面切换次数计算 减一, 修正界面切换次数，可能导致的连续弹出全屏广告
    [self decreaseViewAppearCountForShowFullscreenAd];
    self.isPlayingRewardVideo = YES;
}

- (void)onRewardBaseVideoDidCloseNotification:(NSNotification *)notification {
    self.isPlayingRewardVideo = NO;
}

- (void)onGetPriceWhenInstallNotification:(NSNotification *)notification {
    CGFloat price = [self priceWhenInstall];
    if (price > 0) {
#ifndef ISPRO
        [[CVAdvertiseController shareInstance] closeAdvertise];
#endif
    }
}

- (NSInteger)totalInterstitialShowCount {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger currentCount = [userDefault integerForKey:Key_Total_InterstitialShowAndDismissCount];
    return currentCount;
}

- (NSInteger)increaseTotalInterstitialShowCount {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger currentCount = [userDefault integerForKey:Key_Total_InterstitialShowAndDismissCount];
    currentCount ++;
    [userDefault setInteger:currentCount forKey:Key_Total_InterstitialShowAndDismissCount];
    [userDefault synchronize];
    return currentCount;
}


// 全屏广告出现频率，界面切换次数计算 减一。用于全屏广告弹出导致界面切换次数加一，可能出现连续出现全屏广告的情况，导致产品被拒。
- (void)decreaseViewAppearCountForShowFullscreenAd {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger currentCount = [userDefault integerForKey:Key_User_ViewAppear_Before_FullscreenAd];
    currentCount --;
    [userDefault setInteger:currentCount forKey:Key_User_ViewAppear_Before_FullscreenAd];
    LOG(@"%s, currentCount: %ld",__func__, currentCount);
}


#pragma mark - 开屏广告
- (void)launchViewControllerWithKeyWindow:(UIWindow *)window forLaunch:(void(^)(NPLaunchAdViewController *))launchBlock{
    NPLaunchAdViewController *vc = [[NPLaunchAdViewController alloc] init];
    window.rootViewController = vc;
    if (launchBlock) {
        launchBlock(vc);
    }
}

#pragma mark - Display messages 
- (void)showTipViewWithMessage:(NSString *)message {
    UIView *view = [UIApplication sharedApplication].delegate.window;
    //[[UIApplication sharedApplication].key firstObject];
//    UIViewController *topController = [UIApplication sharedApplication].delegate.window.rootViewController;
//    while (topController.presentedViewController)
//    {
//        topController = topController.presentedViewController;
//    }
//    UIView *view = topController.view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.detailsLabel.text = message;
    hud.mode = MBProgressHUDModeText;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2];
    //    [hud hide:YES afterDelay:1];
}

- (void)showLoadingState {
    UIView *view = [UIApplication sharedApplication].delegate.window;
//    UIViewController *topController = [UIApplication sharedApplication].delegate.window.rootViewController;
//    while (topController.presentedViewController)
//    {
//        topController = topController.presentedViewController;
//    }
//    UIView *view = topController.view;
    if (self.loadingHUD != nil) {
        return;
    }
    self.loadingHUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    // Set determinate mode
    _loadingHUD.mode = MBProgressHUDModeIndeterminate;
    
    //    hud.delegate = self;
    _loadingHUD.label.text = @"Loading...";
    //    // myProgressTask uses the HUD instance to update progress
    //    [HUD showWhileExecuting:@selector(myProgressTask) onTarget:self withObject:nil animated:YES];
    
    //    hud.detailsLabel.text = @"Laing";
    //    hud.mode = MBProgressHUDModeText;
    // 隐藏时候从父控件中移除
    _loadingHUD.removeFromSuperViewOnHide = YES;
//    [hud hideAnimated:YES afterDelay:2];
}


- (void)hideLoadingState {
    [self.loadingHUD hideAnimated:NO];
    self.loadingHUD = nil;
}

@end
