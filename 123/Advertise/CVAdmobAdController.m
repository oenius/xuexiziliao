//
//  CVAdmobAdController.m
//  Common
//
//  Created by mayuan on 2017/6/6.
//  Copyright © 2017年 camory. All rights reserved.
//

#import "CVAdmobAdController.h"
#import <UIKit/UIKit.h>

#import <GoogleMobileAds/GoogleMobileAds.h>
#import "Macros.h"
#import "NPCommonConfig.h"
#import "iRate.h"
#import "SBPaymentLocalizeUtil.h"
#import "NPAnimationInterstitial.h"

// if project build in OC
#import "AppDelegate.h"
// if project build in swift
//#import "CalCulator-Swift.h"


// 专业版如不包含广告，可不关联此类，取消‘GoogleMobileAds’ 的关联，避免审核风险



@interface CVAdmobAdController ()<
GADBannerViewDelegate,
GADInterstitialDelegate,
GADNativeContentAdLoaderDelegate,
GADNativeAppInstallAdLoaderDelegate,
GADNativeAdDelegate,
GADNativeExpressAdViewDelegate,
GADRewardBasedVideoAdDelegate
>


// 原生半屏广告 重试Timer
@property(strong, nonatomic)NSTimer *nativeAdErrorRetryTimer;

@property(strong, nonatomic)GADBannerView *bannerView;
@property(strong, nonatomic)NPAnimationInterstitial *interstitial;

@property(nonatomic, strong) GADNativeExpressAdView *nativeExpressView;
@property(nonatomic, strong) GADNativeExpressAdView *nativeExpress132HView;
@property(nonatomic, strong) GADNativeExpressAdView *nativeExpress250HView;

// 开屏
@property(nonatomic, strong) GADNativeExpressAdView *nativeLaunchView;

// 半屏
@property (nonatomic, strong) GADNativeExpressAdView *nativeHalfScreenView;

@property(nonatomic, strong) GADRewardBasedVideoAd *rewardViewAd;

@property(strong, nonatomic) NSArray *testDevices; //测试设备号,仅用于测试

// banner 广告 包装 父View
@property(strong, nonatomic) UIView *bannerWrapView;
// banner广告  曾经加载成功
@property(assign, atomic) BOOL isBannerViewInLoading;


// 原生广告包装 super View
@property(strong, nonatomic) UIView *nativeSmallWrapView;
@property(assign, atomic) BOOL isNativeSmallViewInLoading;

// 原生广告包装 132H super View
@property (nonatomic, strong) UIView *nativeMidWrapView;
@property (atomic, assign) BOOL isNativeMidViewInLoading;


// 原生广告包装 250H super View
@property (nonatomic, strong) UIView *nativeLargeWrapView;
@property (atomic, assign) BOOL isNativeLargeViewInLoading;

@property (nonatomic, strong) UIView *nativeLaunchWrapView;
@property (atomic, assign) BOOL isNativeLaunchViewInLoading;

//// 购买付费版 superView
//@property(strong, nonatomic) UIView *proVersionBannerSuperView;
//// 购买付费版 截屏imageView
//@property (strong, nonatomic) UIImageView *upgradeProVersionView;
//
//// 购买付费版 新建图片 image
//@property (strong, nonatomic) UIImage *proVersionImage;
//@property (strong, nonatomic) UIImage *proIconImage;
//@property (strong, nonatomic) NSString *proTrackName;








@property(assign, atomic, readwrite) BOOL isRewardVideoLoaded;


//@property (strong, nonatomic) UIView *nativeExpressLaunchAdView;
//@property (assign, atomic, readwrite) BOOL isNativeExpressLaunchAdViewLoaded;


@property (strong, nonatomic) UIView *nativeHalfScreenWrapView;
@property (atomic, assign) BOOL isNativeHalfScreenInLoading;


@property (assign, atomic) BOOL isInterstitialAdInLoading;

// 判断是否有广告已显示，如果当前 ‘NPAnimationInterstitial’ 已经调用 'showAdFromRootViewController', 再次调用会出现广告无法弹出
@property (atomic, assign) BOOL isCurrentInterstitialShowed;


@end



@implementation CVAdmobAdController


- (void)dealloc
{
    [self invalidateNativeAdErrorRetryTimer];

//    [self invalidateInterstitialErrorRetryTimer];
}


- (void)preLoadAds {
    LOG(@"%s",__func__);
//    [self loadBannerView];
//    [self loadInterstitial];
    
    
//    if (self.proVersionImage == nil) {
//        [self loadProVersionData];
//    }
//    BOOL shouldPreloadRewardVideoAd = [NPCommonConfig shareInstance].shouldPreloadRewardVideoAd;
//    if (shouldPreloadRewardVideoAd) {
//        //        [self loadRewardVideoAd];
//    }
}

- (void)removeAllAds{
    [self.bannerView removeFromSuperview];
    self.bannerView = nil;
    [self.nativeExpressView removeFromSuperview];
    self.nativeExpressView = nil;
    [self.nativeExpress132HView removeFromSuperview];
    self.nativeExpress132HView = nil;
    [self.nativeExpress250HView removeFromSuperview];
    self.nativeExpress250HView = nil;
    
    NSNumber *enable = [NSNumber numberWithBool:false];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAdvertiseGoogleInterstitialNotification object:enable];
}


- (id)init{
    self = [super init];
    if(self != nil){
#ifdef DEBUG
        self.testDevices = @[@"d62706e8dc3153cc02ab7f7f45de20c1",
                             @"8e30d770384352bc44a841f8d2cce9df",
                             kGADSimulatorID];
#else
        self.testDevices = @[@"d62706e8dc3153cc02ab7f7f45de20c1",
                             kGADSimulatorID];
#endif
    }
    return self;
}

#pragma mark - Public Load Ads Interface
- (void)loadBannerViewComplete:(CompleteWithBannerView)complete{
    self.completeBannerView = complete;
    [self loadBannerView];
    __weak typeof(self) weakSelf = self;
    if(self.bannerWrapView){
        self.completeBannerView(weakSelf.bannerWrapView, self);
    }
}

- (void)loadNativeSmallViewComplete:(CompleteWithNativeSmallView)complete{
    self.completeNativeSmallView = complete;
    [self loadNativeExpressAdView];
    __weak typeof(self) weakSelf = self;
    if(weakSelf.nativeSmallWrapView){
        self.completeNativeSmallView(weakSelf.nativeSmallWrapView, self);
    }
}


- (void)loadNativeMidViewComplete:(CompleteWithNativeMidView)complete{
    self.completeNativeMidView = complete;
    [self loadNativeExpress132HAdView];
    __weak typeof(self) weakSelf = self;
    if(weakSelf.nativeMidWrapView){
        self.completeNativeMidView(weakSelf.nativeMidWrapView, self);
    }
}

- (void)loadNativeLargeViewComplete:(CompleteWithNativeLargeView)complete{
    self.completeNativeLargeView = complete;
    [self loadNativeExpress250HAdView];
    __weak typeof(self) weakSelf = self;
    if(weakSelf.nativeLargeWrapView){
        self.completeNativeLargeView(weakSelf.nativeLargeWrapView, self);
    }
}

- (void)loadNativeLaunchViewComplete:(CompleteWithNativeLaunchView)complete{
    //TODO: launch view not link strong
    self.completeNativeLaunchView = complete;
    [self loadNativeLaunchAdView];
    __weak typeof(self) weakSelf = self;
    if(weakSelf.nativeLaunchWrapView){
        self.completeNativeLaunchView(weakSelf.nativeLaunchWrapView, self);
    }
}

- (void)clearNativeLaunchView{
    self.completeNativeLaunchView = nil;
    self.nativeLaunchWrapView = nil;
    self.nativeLaunchView = nil;
    self.isNativeLaunchViewInLoading = NO;
}

- (void)loadInterstitialAdComplete:(CompleteWithInterstitial)complete {
    self.completeInterstitial = complete;
    __weak typeof(self) weakSelf = self;
    if ([self isInterstitialLoadedReady]) {
        weakSelf.completeInterstitial(YES, self);
    }
    [self loadInterstitial];
   
}

- (void) loadCustomHalfScreenAdComplete:(CompleteWithCustomHalfScreenView)complete{
    self.completeCustomHalfScreenView = complete;
    [self loadCustomHalfScreenAd];
    __weak typeof(self) weakSelf = self;
    if (weakSelf.nativeHalfScreenWrapView) {
        if (weakSelf.completeCustomHalfScreenView) {
            weakSelf.completeCustomHalfScreenView(weakSelf.nativeHalfScreenWrapView, self);
        }
    }
}


#pragma mark - Private Load Ads Implements
- (void)loadBannerView{
    BOOL isNetworkConnected = [NPCommonConfig shareInstance].isNetworkConnected;
    if (NO == isNetworkConnected) {
        return;
    }
    if(self.bannerWrapView != nil){
        return;
    }
    
    NSString *admobBannerAdID = [NPCommonConfig shareInstance].admobBannerAdID;
    if (admobBannerAdID == nil || admobBannerAdID.length == 0) {
         LOG(@"%s，admobBannerAdID can not be nil",__func__);
//        NSAssert((admobBannerAdID != nil) && (admobBannerAdID.length > 0), @"admobBannerAdID can not be nil");
        if (self.completeBannerView) {
            self.completeBannerView(nil, self);
        }
        return;
    }
    if (self.isBannerViewInLoading) {
        return;
    }
    self.isBannerViewInLoading = YES;
    
    GADAdSize size = kGADAdSizeSmartBannerPortrait;
    self.bannerView = [[GADBannerView alloc]initWithAdSize:size];
    self.bannerView.adUnitID = admobBannerAdID;
    self.bannerView.delegate = self;
    self.bannerView.rootViewController = self.viewController;
    
    GADRequest *request = [GADRequest request];
    request.testDevices = self.testDevices;
    //    request.gender = kGADGenderMale;
    //    request.gender = kGADGenderMale;
    //    request.keywords = @[@"game", @"job", @"sport", @"social", @"education"];
    NSArray *keywords = [NPCommonConfig shareInstance].adKeyWords;
    if (keywords && keywords.count > 0) {
        request.keywords = keywords;
    }
    [self.bannerView loadRequest:request];
}




// 原生广告250H 重试
- (void)invalidateNativeAdErrorRetryTimer{
    if (self.nativeAdErrorRetryTimer) {
        [self.nativeAdErrorRetryTimer invalidate];
        self.nativeAdErrorRetryTimer = nil;
    }
}

- (void)initNativeAdErrorRetryTimer{
    [self invalidateNativeAdErrorRetryTimer];
    self.nativeAdErrorRetryTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(reloadNativeAds) userInfo:nil repeats:NO];
}

- (void)reloadNativeAds{
    [self invalidateNativeAdErrorRetryTimer];
    [self loadCustomHalfScreenAd];
}

#warning Todo
//TODO: 重试机制放入总体调度
// 全屏广告 重试
//- (void)invalidateInterstitialErrorRetryTimer{
//    if (self.interstitialErrorRetryTimer) {
//        [self.interstitialErrorRetryTimer invalidate];
//        self.interstitialErrorRetryTimer = nil;
//    }
//}
//
//- (void)initInterstitialErrorRetryTimer{
//    [self invalidateInterstitialErrorRetryTimer];
//    self.interstitialErrorRetryTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(reloadInterstitialAds) userInfo:nil repeats:NO];
//}
//
//- (void)reloadInterstitialAds{
//    [self invalidateInterstitialErrorRetryTimer];
//    [self loadInterstitial];
//}



- (void)loadNativeExpressAdView{
    BOOL isNetworkConnected = [NPCommonConfig shareInstance].isNetworkConnected;
    if (NO == isNetworkConnected) {
        return;
    }
    if (self.nativeSmallWrapView) {
        return;
    }
    NSString *nativeExpressAdId = [NPCommonConfig shareInstance].admobNativeExpressAdID;
    if (nativeExpressAdId == nil || nativeExpressAdId.length == 0) {
        NSLog(@"nativeExpressAdId  be nil");
        if (self.completeNativeSmallView) {
            self.completeNativeSmallView(nil, self);
        }
        return;
    }
    if (self.isNativeSmallViewInLoading) {
        return;
    }
    self.isNativeSmallViewInLoading = YES;
    
    //  NSAssert((nativeExpressAdId != nil) && (nativeExpressAdId.length > 0), @"nativeExpressAdId can not be nil");
    self.nativeExpressView = [[GADNativeExpressAdView alloc]initWithAdSize:GADAdSizeFullWidthPortraitWithHeight(80)];
    self.nativeExpressView.adUnitID = nativeExpressAdId;
    self.nativeExpressView.rootViewController = self.viewController;
    self.nativeExpressView.delegate = self;
    
    GADRequest *request = [GADRequest request];
    request.testDevices =  self.testDevices;
    [self.nativeExpressView loadRequest:request];
}

// large native size
- (void)loadNativeExpress250HAdView{
    BOOL isNetworkConnected = [NPCommonConfig shareInstance].isNetworkConnected;
    if (NO == isNetworkConnected) {
        return;
    }
    if (self.nativeExpress250HView) {
        return;
    }
    NSString *nativeExpressAdId = [NPCommonConfig shareInstance].admobNativeExpress250HAdID;
    if (nativeExpressAdId == nil || nativeExpressAdId.length == 0) {
        NSLog(@"nativeExpressAdId  be nil");
        if (self.completeNativeLargeView) {
            self.completeNativeLargeView(nil, self);
        }
        return;
    }
    CGSize nativeSize = CGSizeMake(320, 250);
    CGSize configSize = [NPCommonConfig shareInstance].nativeLargeViewsize;
    nativeSize = configSize;

    //  NSAssert((nativeExpressAdId != nil) && (nativeExpressAdId.length > 0), @"nativeExpressAdId can not be nil");
    // GADAdSizeFullWidthPortraitWithHeight(250)
    
    self.nativeExpress250HView = [[GADNativeExpressAdView alloc]initWithAdSize:GADAdSizeFromCGSize(nativeSize)];
    self.nativeExpress250HView.adUnitID = nativeExpressAdId;
    self.nativeExpress250HView.rootViewController = self.viewController;
    self.nativeExpress250HView.delegate = self;
    
    GADRequest *request = [GADRequest request];
    request.testDevices =  self.testDevices;
    [self.nativeExpress250HView loadRequest:request];
}

- (void)loadNativeLaunchAdView {
    BOOL isNetworkConnected = [NPCommonConfig shareInstance].isNetworkConnected;
    if (NO == isNetworkConnected) {
        return;
    }
    if (self.nativeLaunchView) {
        return;
    }
    NSString *nativeExpressAdId = [NPCommonConfig shareInstance].admobNativeLaunchAdID;
    if (nativeExpressAdId == nil || nativeExpressAdId.length == 0) {
        NSLog(@"admobNativeLaunchAdID  be nil");
        if (self.completeNativeLaunchView) {
            self.completeNativeLaunchView(nil, self);
        }
        return;
    }
    
    if (self.isNativeLaunchViewInLoading) {
        return;
    }
    self.isNativeLaunchViewInLoading = YES;
    
    CGSize nativeSize =[NPCommonConfig shareInstance].nativeLaunchAdViewSize;
    if (nativeSize.height < 250) {
        NSLog(@"native ad size is too small");
    }
    //  NSAssert((nativeExpressAdId != nil) && (nativeExpressAdId.length > 0), @"nativeExpressAdId can not be nil");
    // GADAdSizeFullWidthPortraitWithHeight(250)
    
    self.nativeLaunchView = [[GADNativeExpressAdView alloc]initWithAdSize:GADAdSizeFromCGSize(nativeSize)];
    self.nativeLaunchView.adUnitID = nativeExpressAdId;
    self.nativeLaunchView.rootViewController = self.viewController;
    self.nativeLaunchView.delegate = self;
    
    GADRequest *request = [GADRequest request];
    request.testDevices =  self.testDevices;
    [self.nativeLaunchView loadRequest:request];
    
}

// Mid View size
- (void)loadNativeExpress132HAdView{
    BOOL isNetworkConnected = [NPCommonConfig shareInstance].isNetworkConnected;
    if (NO == isNetworkConnected) {
        return;
    }
    if (self.nativeExpress132HView) {
        return;
    }
    NSString *nativeExpressAdId = [NPCommonConfig shareInstance].admobNativeExpress132HAdID;
    if (nativeExpressAdId == nil || nativeExpressAdId.length == 0) {
        if (self.completeCustomHalfScreenView) {
            self.completeCustomHalfScreenView(nil, self);
        }
        NSLog(@"nativeExpressAdId  be nil");
        return;
    }
    
    if (self.isNativeMidViewInLoading) {
        return;
    }
    self.isNativeMidViewInLoading = YES;
    
    //  NSAssert((nativeExpressAdId != nil) && (nativeExpressAdId.length > 0), @"nativeExpressAdId can not be nil");
    self.nativeExpress132HView = [[GADNativeExpressAdView alloc]initWithAdSize:GADAdSizeFullWidthPortraitWithHeight(132)];
    self.nativeExpress132HView.adUnitID = nativeExpressAdId;
    self.nativeExpress132HView.rootViewController = self.viewController;
    self.nativeExpress132HView.delegate = self;
    
    GADRequest *request = [GADRequest request];
    request.testDevices =  self.testDevices;
    [self.nativeExpress132HView loadRequest:request];
}


- (void)loadInterstitial{
    BOOL isNetworkConnected = [NPCommonConfig shareInstance].isNetworkConnected;
    if (NO == isNetworkConnected) {
        return;
    }
    NSString *admobInterstitialAdID = [NPCommonConfig shareInstance].admobInterstitialAdID;
    //    NSAssert((admobInterstitialAdID != nil) && (admobInterstitialAdID.length > 0), @"admobInterstitialAdID can not be nil");
    if (admobInterstitialAdID == nil || admobInterstitialAdID.length == 0) {
        if (self.completeInterstitial) {
            self.completeInterstitial(NO, self);
        }
        NSLog(@"admobInterstitialAdID  be nil");
        return;
    }
    
    if ([self isInterstitialLoadedReady]) {
        return;
    }
    
    if (self.isInterstitialAdInLoading) {
        return;
    }
    self.isInterstitialAdInLoading = YES;
    
    self.interstitial = [[NPAnimationInterstitial alloc] initWithAdUnitID:admobInterstitialAdID];
    self.interstitial.delegate = self;
    GADRequest *request = [GADRequest request];
    request.testDevices = self.testDevices;
    //    request.gender = kGADGenderMale;
    //    request.keywords = @[@"game", @"job", @"sport", @"social", @"education"];
    NSArray *keywords = [NPCommonConfig shareInstance].adKeyWords;
    if (keywords && keywords.count > 0) {
        request.keywords = keywords;
    }
    [self.interstitial loadRequest:request];
}


- (void)loadCustomHalfScreenAd {
    BOOL isNetworkConnected = [NPCommonConfig shareInstance].isNetworkConnected;
    if (NO == isNetworkConnected) {
        return;
    }
    if (self.nativeHalfScreenWrapView) {
        return;
    }
    NSString *nativeHalfScreenAdID = [NPCommonConfig shareInstance].admobCustomHalfScreenAdID;
    if (nativeHalfScreenAdID == nil || nativeHalfScreenAdID.length == 0) {
        NSLog(@"nativeHalfScreenAdID  be nil");
        if (self.completeCustomHalfScreenView) {
            self.completeCustomHalfScreenView(nil, self);
        }
        return;
    }
    
    CGSize nativeSize = CGSizeMake(320, 250);
    CGSize configSize = [NPCommonConfig shareInstance].nativeHalfScreenAdViewSize;
    if (configSize.width == 0 || configSize.height == 0) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            nativeSize = CGSizeMake(640, 500);
        }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            nativeSize = CGSizeMake(320, 250);
        }
    }else{
        nativeSize = configSize;
    }
    //  NSAssert((nativeExpressAdId != nil) && (nativeExpressAdId.length > 0), @"nativeExpressAdId can not be nil");
    // GADAdSizeFullWidthPortraitWithHeight(250)
    self.nativeHalfScreenView = [[GADNativeExpressAdView alloc]initWithAdSize:GADAdSizeFromCGSize(nativeSize)];
    self.nativeHalfScreenView.adUnitID = nativeHalfScreenAdID;
    self.nativeHalfScreenView.rootViewController = self.viewController;
    self.nativeHalfScreenView.delegate = self;
    
    GADRequest *request = [GADRequest request];
    request.testDevices =  self.testDevices;
    [self.nativeHalfScreenView loadRequest:request];
}

- (void)loadRewardVideoAd{
    NSString *admobRewardVideoAdID = [NPCommonConfig shareInstance].admobRewardVideoAdID;
    if (admobRewardVideoAdID.length == 0) {
        //        NSAssert((admobRewardVideoAdID != nil) && (admobRewardVideoAdID.length > 0), @"admobRewardVideoAdID can not be nil");
        LOG(@"%s, admobRewardVideoAdID is nil, can not load reward video",__func__);
        return;
    }
    
    BOOL isNetworkConnected = [NPCommonConfig shareInstance].isNetworkConnected;
    if (NO == isNetworkConnected) {
        [self dealWithRewardVideoLoadFailed:nil];
        return;
    }
    
    [GADRewardBasedVideoAd sharedInstance].delegate = self;
    GADRequest *request = [GADRequest request];
    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request
                                           withAdUnitID:admobRewardVideoAdID];
}



- (BOOL)needsShowAdView{
    BOOL shouldShowAd = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    return shouldShowAd;
}

- (BOOL)isInterstitialCanShow{
    if (self.interstitial && self.interstitial.isReady) {
        if (self.isCurrentInterstitialShowed) {
            return NO;
        }else{
            return YES;
        }
    }else{
        return NO;
    }
}

- (BOOL)isInterstitialLoadedReady{
    if (self.interstitial) {
        return self.interstitial.isReady;
    }else{
        return NO;
    }
}


- (BOOL)isRewardVideoReady{
    BOOL isReady = [[GADRewardBasedVideoAd sharedInstance] isReady];
    return isReady;
}


- (void)showInterstitial:(UIViewController *)controller{
    BOOL needShowAD = [self needsShowAdView];
    if (NO == needShowAD) {
        return;
    }
    if(controller == nil){
        controller =[self topMostController];
    }
    if ([self isInterstitialCanShow]) {
        self.isCurrentInterstitialShowed = YES;
        [self.interstitial presentFromRootViewController:controller];
    }
}


- (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

- (void)showRewardVideoFromRootViewController:(UIViewController *)controller {
    BOOL needShowAD = [self needsShowAdView];
    if (NO == needShowAD) {
        return;
    }
    if(controller == nil){
        controller = [self topMostController]; //[UIApplication sharedApplication].delegate.window.rootViewController;
    }
    
    //   if(controller == nil){
    //     controller = [UIApplication sharedApplication].delegate.window.rootViewController;
    //  }
    
    if ([self isRewardVideoReady]) {
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:controller];
    }
}

#pragma mark - GADNativeExpressAdViewDelegate

- (void)nativeExpressAdViewDidReceiveAd:(GADNativeExpressAdView *)nativeExpressAdView{
#ifdef DEBUG
    NSLog(@"%@ nativeExpressAdView = %@", NSStringFromSelector(_cmd), nativeExpressAdView);
#endif
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGSize adSize =  CGSizeFromGADAdSize(nativeExpressAdView.adSize);
    UIView *nativeSuperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, adSize.width, adSize.height)];
    nativeSuperView.backgroundColor = [UIColor clearColor];
    [nativeSuperView addSubview:nativeExpressAdView];
    NSString *adUnitId = nativeExpressAdView.adUnitID;
    NSString *native80HAdId = [NPCommonConfig shareInstance].admobNativeExpressAdID;
    NSString *native250HAdId = [NPCommonConfig shareInstance].admobNativeExpress250HAdID;
    NSString *native132HAdId = [NPCommonConfig shareInstance].admobNativeExpress132HAdID;
    NSString *nativeLaunchAd = [NPCommonConfig shareInstance].admobNativeLaunchAdID;
    NSString *nativeHalfScreenAdID = [NPCommonConfig shareInstance].admobCustomHalfScreenAdID;

    if ([adUnitId isEqualToString:native80HAdId]) {
        self.nativeSmallWrapView = nativeSuperView;
        if(self.completeNativeSmallView != nil){
            self.completeNativeSmallView(nativeSuperView, self);
        }
        self.isNativeSmallViewInLoading = NO;
    }else if ([adUnitId isEqualToString:native250HAdId]){
        
        self.nativeLargeWrapView = nativeSuperView;
        if(self.completeNativeLargeView != nil){
            self.completeNativeLargeView(nativeSuperView, self);
        }
        self.isNativeLargeViewInLoading = NO;
    }else if ([adUnitId isEqualToString:native132HAdId]) {
        
        self.nativeMidWrapView = nativeSuperView;
        if(self.completeNativeMidView != nil){
            self.completeNativeMidView(nativeSuperView, self);
        }
        self.isNativeMidViewInLoading = NO;
    }else if([adUnitId isEqualToString:nativeLaunchAd]) {
        self.nativeLaunchWrapView = nativeSuperView;
        if(self.completeNativeLaunchView != nil){
            self.completeNativeLaunchView(nativeSuperView, self);
        }
        self.isNativeLaunchViewInLoading = NO;
    }else if([adUnitId isEqualToString:nativeHalfScreenAdID]) {
        self.nativeHalfScreenWrapView = nativeSuperView;
        self.isNativeHalfScreenInLoading = NO;
        if(self.completeCustomHalfScreenView){
            self.completeCustomHalfScreenView(nativeSuperView, self);
        }
        NSNumber *enable = [NSNumber numberWithBool:true];
        [[NSNotificationCenter defaultCenter]postNotificationName:kAdvertiseGoogleNative250HADViewNotification object:enable];
    }
}

/// Tells the delegate that an ad request failed. The failure is normally due to network
/// connectivity or ad availablility (i.e., no fill).
- (void)nativeExpressAdView:(GADNativeExpressAdView *)nativeExpressAdView
didFailToReceiveAdWithError:(GADRequestError *)error{
#ifdef DEBUG
    NSLog(@"%@ error = %@", NSStringFromSelector(_cmd), error);
#endif
    NSString *adUnitId = nativeExpressAdView.adUnitID;
    NSString *native80HAdId = [NPCommonConfig shareInstance].admobNativeExpressAdID;
    NSString *native132HAdId = [NPCommonConfig shareInstance].admobNativeExpress132HAdID;
    NSString *native250HAdId = [NPCommonConfig shareInstance].admobNativeExpress250HAdID;
    NSString *nativeLaunchAd = [NPCommonConfig shareInstance].admobNativeLaunchAdID;
    NSString *nativeHalfScreenAdID = [NPCommonConfig shareInstance].admobCustomHalfScreenAdID;
    
    if ([adUnitId isEqualToString:native80HAdId]) {
        self.isNativeSmallViewInLoading = NO;
        if(self.completeNativeSmallView != nil){
            self.completeNativeSmallView(nil, self);
        }
    }else if([adUnitId isEqualToString:native132HAdId]) {
        self.isNativeMidViewInLoading = NO;
        if (self.completeNativeMidView) {
            self.completeNativeMidView(nil, self);
        }
    }else if([adUnitId isEqualToString:native250HAdId]) {
        self.isNativeLargeViewInLoading = NO;
        if (self.completeNativeLargeView) {
            self.completeNativeLargeView(nil, self);
        }
    }else if([adUnitId isEqualToString:nativeLaunchAd]) {
        self.isNativeLaunchViewInLoading = NO;
        if (self.completeNativeLaunchView) {
            self.completeNativeLaunchView(nil, self);
        }
    }
    else if([adUnitId isEqualToString:nativeHalfScreenAdID]){
        self.isNativeHalfScreenInLoading = NO;
        if(self.completeCustomHalfScreenView){
            self.completeCustomHalfScreenView(nil, self);
            self.completeCustomHalfScreenView = nil;
        }
        [self initNativeAdErrorRetryTimer];
    }
}

- (void)nativeExpressAdViewWillLeaveApplication:(GADNativeExpressAdView *)nativeExpressAdView{
    NSString *nativeHalfScreenAdID = [NPCommonConfig shareInstance].admobCustomHalfScreenAdID;
    NSString *nativeLaunchId = [NPCommonConfig shareInstance].admobNativeLaunchAdID;
    NSString *adUnitId = nativeExpressAdView.adUnitID;
    if ([adUnitId isEqualToString:nativeHalfScreenAdID]){
        [[NSNotificationCenter defaultCenter]postNotificationName:kAdvertiseGoogleNative250HADViewWillLiveApplicationNotification  object:nil];
    }
    if ([adUnitId isEqualToString:nativeLaunchId]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:kAdvertiseGoogleNativeLaunchViewWillLiveApplicationNotification  object:nil];
    }
}


#pragma mark - GADBannerViewDelegate
/// Tells the delegate that an ad request successfully received an ad. The delegate may want to add
/// the banner view to the view hierarchy if it hasn't been added yet.
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView{
#ifdef DEBUG
    NSLog(@"%s",__func__);
#endif
    UIView *showView = [self bannerWrapViewForBannerView:bannerView];
    self.isBannerViewInLoading = NO;
    if(self.completeBannerView != nil){
        self.completeBannerView(showView, self);
    }
    
//    LOG(@"%s, initView: %@, reback adview: %@",__func__, self.bannerView, adView);
//    UIView *showView = [self bannerWrapViewForBannerView:adView];
//    self.isBannerViewInLoading = NO;
//    if(self.completeBannerView != nil){
//        self.completeBannerView(showView, self);
//    }
}

- (UIView *)bannerWrapViewForBannerView:(UIView *)adView{
    CGSize adViewSize = adView.frame.size;
    UIView *bannerWrapView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, adViewSize.width, adViewSize.height)];
    adView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    [bannerWrapView addSubview:adView];
    bannerWrapView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.bannerWrapView = bannerWrapView;
    return bannerWrapView;
}


/// Tells the delegate that an ad request failed. The failure is normally due to network
/// connectivity or ad availablility (i.e., no fill).
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error{
    LOG(@"%s",__func__);
    self.isBannerViewInLoading = NO;
    if(self.completeBannerView != nil){
        self.completeBannerView(nil, self);
    }
}

//- (UIView *)showInBannerView:(UIView *)bannerView{
//    GADAdSize gadAdSize = kGADAdSizeSmartBannerPortrait;
//    CGSize size = CGSizeFromGADAdSize(gadAdSize);
//    //    CGSize size = [UIScreen mainScreen].bounds.size;
//    UIView *showView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, size.width, bannerView.frame.size.height)];
//    CGRect frame = bannerView.frame;
//    frame.origin.x = (size.width - frame.size.width)/2;
//    bannerView.frame = frame;
//    bannerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//    [showView addSubview:bannerView];
//    self.bannerWrapView = showView;
//    return showView;
//}


- (void)adViewWillPresentScreen:(GADBannerView *)bannerView{
     LOG(@"%s",__func__);
}


- (void)adViewWillDismissScreen:(GADBannerView *)bannerView{
    LOG(@"%s",__func__);
}


- (void)adViewDidDismissScreen:(GADBannerView *)bannerView{
    LOG(@"%s",__func__);
}


- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView{
    LOG(@"%s",__func__);

}

#pragma mark - GADInterstitialDelegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad{
    LOG(@"%s",__func__);
    self.interstitial = ad;
    self.isInterstitialAdInLoading = NO;
    // call reback block
    if(self.completeInterstitial != nil){
        self.completeInterstitial(YES, self);
    }
    
    NSNumber *enable = [NSNumber numberWithBool:true];
    [[NSNotificationCenter defaultCenter]postNotificationName:kAdvertiseGoogleInterstitialNotification object:enable];
}


- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error{
    LOG(@"%s",__func__);
//    [self initInterstitialErrorRetryTimer];
    self.isInterstitialAdInLoading = NO;
    if(self.completeInterstitial != nil){
        self.completeInterstitial(NO, self);
    }
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad{
    LOG(@"%s",__func__);
    //插页广告被显示, 通知其他viewController,暂时不能显示插页广告
    NSNumber *enable = [NSNumber numberWithBool:false];
    [[NSNotificationCenter defaultCenter]postNotificationName:kAdvertiseGoogleInterstitialNotification object:enable];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAdvertiseGoogleInterstitialWillPresentNotification object:nil];
    // clean present count
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad{
    LOG(@"%s",__func__);
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad{
    LOG(@"%s",__func__);
    self.interstitial = nil;
    self.isCurrentInterstitialShowed = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kAdvertiseGoogleInterstitialDidDismisstNotification object:nil];
//    [self loadInterstitial];
}


- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad{
    LOG(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] postNotificationName:kAdvertiseGoogleInterstitialWillLiveApplicationNotification object:nil];
}

#pragma mark GADRewardBasedVideoAdDelegate implementation

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    self.isRewardVideoLoaded = YES;
//    if (self.rewardVideoHandler != nil) {
//        self.rewardVideoHandler(YES, nil);
//        self.rewardVideoHandler = nil;
//    }
    LOG(@"%s",__func__);
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didFailToLoadWithError:(NSError *)error {
    LOG(@"%s, error: %@",__func__, error);
    [self dealWithRewardVideoLoadFailed:error];
}

- (void)dealWithRewardVideoLoadFailed:(NSError *)error {
    self.isRewardVideoLoaded = NO;
//    if (self.rewardVideoHandler != nil) {
//        self.rewardVideoHandler(NO, error);
//        self.rewardVideoHandler = nil;
//    }
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    self.isRewardVideoLoaded = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kAdvertiseGoogleRewardBaseVideoDidOpenNotification object:nil];
    
    LOG(@"%s",__func__);
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    LOG(@"%s",__func__);
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    LOG(@"%s",__func__);
    // 关闭视频广告后，取消自动重复请求
    //    [self loadRewardVideoAd];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAdvertiseGoogleRewardBaseVideoDidCloseNotification object:nil];
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
   didRewardUserWithReward:(GADAdReward *)reward {
    NSString *rewardMessage =
    [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf", reward.type,
     [reward.amount doubleValue]];
    LOG(@"%s",__func__);
    NSLog(@"%@", rewardMessage);
    // Reward the user for watching the video.
    //    [self earnCoins:[reward.amount integerValue]];
    //    self.showVideoButton.hidden = YES;
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    LOG(@"%s",__func__);
}



@end
