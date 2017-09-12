//
//  CVAdvertiseController.m
//  CloudPlayer
//
//  Created by Huaming.Zhu on 16/4/19.
//  Copyright © 2016年 __VideoApps___. All rights reserved.
//

#import "CVAdvertiseController.h"
#import "Macros.h"
#import "NPCommonConfig.h"
#import "iRate.h"
#import "SBPaymentLocalizeUtil.h"
#import "CVBaseAdController.h"
#import "CVAdmobAdController.h"
#import "CVFBAdController.h"


#define kProVersionBannerImageName   @"ProVersionBannerImageName.jpg"


@interface CVAdvertiseController(){
    
}

//TODO:
// 全屏广告重试Timer
@property(strong, nonatomic)NSTimer *interstitialErrorRetryTimer;


// 购买付费版 superView
@property(strong, nonatomic) UIView *proVersionBannerSuperView;
// 购买付费版 截屏imageView
@property (strong, nonatomic) UIImageView *upgradeProVersionView;
// 购买付费版 新建图片 image
@property (strong, nonatomic) UIImage *proVersionImage;
@property (strong, nonatomic) UIImage *proIconImage;
@property (strong, nonatomic) NSString *proTrackName;


// banner 广告 包装 父View
@property (strong, nonatomic) UIView *bannerWrapView;

@property (strong, nonatomic) UIView *nativeSmallView;
@property (strong, nonatomic) UIView *nativeMidView;
@property (strong, nonatomic) UIView *nativeLargeView;

@property (strong, nonatomic) UIView *nativeLaunchView;

@property (strong, nonatomic) UIView *nativeCustomHalfScrenAdView;

// 已加载完成的 interstitial Ad Controller;
@property (strong, nonatomic) CVBaseAdController *loadedInterstitialAdController;

@property (nonatomic, assign) BOOL isAdmobInterstitialReady;
@property (nonatomic, assign) BOOL isFacebookInterstitialReady;

@property (nonatomic, strong) CVBaseAdController *firstBannerAdController;
@property (nonatomic, strong) CVBaseAdController *currBannerAdController;

@property (nonatomic, strong) CVBaseAdController *firstNativeSmallAdController;
@property (nonatomic, strong) CVBaseAdController *currNativeSmallAdController;

@property (nonatomic, strong) CVBaseAdController *firstNativeMidAdController;
@property (nonatomic, strong) CVBaseAdController *currNativeMidAdController;

@property (nonatomic, strong) CVBaseAdController *firstNativeLargeAdController;
@property (nonatomic, strong) CVBaseAdController *currNativeLargeAdController;

@property (nonatomic, strong) CVBaseAdController *firstNativeLaunchAdController;
@property (nonatomic, strong) CVBaseAdController *currNativeLaunchAdController;

@property (nonatomic, strong) CVBaseAdController *firstInterstitialAdController;
@property (nonatomic, strong) CVBaseAdController *currInterstitialAdController;


@property (nonatomic, strong) CVAdmobAdController *admobHalfScreenAdController;

@end

static CVAdvertiseController *_advertise = nil;

@implementation CVAdvertiseController

+ (CVAdvertiseController *)shareInstance{
    if(_advertise != nil){
        return _advertise;
    }
    _advertise = [[CVAdvertiseController alloc] init];
    return _advertise;
}


- (id)init{
    self = [super init];
    if(self != nil){
        [CVFBAdController initAdConfig];
        
        [self setupAdPlatformsAndConfigPrioritys];
       
        [self addNotifications];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Set Ad Platform Prioritys
- (void)setupAdPlatformsAndConfigPrioritys{
    CVAdPlatformPriorityStrategy *adPlatformPriorityStrategy = [NPCommonConfig shareInstance].adPlatformPriorityStrategy;
    
    //--- banner view --- //
    NPAdPlatform defaultFirstAdPlatform = [adPlatformPriorityStrategy defaultFirstAdPlatform];
    BOOL shouldDetectNetworkAndFixPriority = [adPlatformPriorityStrategy shouldFixAdPlatformPriority];
    
    NPAdPlatform bannerFirstAdPlatform = [adPlatformPriorityStrategy bannerViewFirstAdPlatform];
    if (bannerFirstAdPlatform == NPAdPlatformUnkown) {
        bannerFirstAdPlatform = defaultFirstAdPlatform;
    }
    if (shouldDetectNetworkAndFixPriority) {
        bannerFirstAdPlatform = [adPlatformPriorityStrategy fixedFirstAdPlatformForOriginalAdPlatform:bannerFirstAdPlatform];
    }
    switch (bannerFirstAdPlatform) {
        case NPAdPlatformAdmob:{
            // 初始化广告平台 加载类，及 他们的优先级，串成 责任链
            CVFBAdController *fbBannerAdController = [[CVFBAdController alloc] init];
            CVAdmobAdController *admobBannerAdController = [[CVAdmobAdController alloc] init];
            admobBannerAdController.nextAdController = fbBannerAdController;
            fbBannerAdController.nextAdController = nil;
            self.firstBannerAdController = admobBannerAdController;
        }
            break;
        case NPAdPlatformFacebook:{
            // 初始化广告平台 加载类，及 他们的优先级，串成 责任链
            CVFBAdController *fbBannerAdController = [[CVFBAdController alloc] init];
            CVAdmobAdController *admobBannerAdController = [[CVAdmobAdController alloc] init];
            fbBannerAdController.nextAdController = admobBannerAdController;
            admobBannerAdController.nextAdController = nil;
            self.firstBannerAdController = fbBannerAdController;
        }
            break;
        default:
            break;
    }
    
    //--- Native Small Ad ----//
    NPAdPlatform nativeSmallFirstAdPlatform = [adPlatformPriorityStrategy nativeSmallViewFirstAdPlatform];
    if (nativeSmallFirstAdPlatform == NPAdPlatformUnkown) {
        nativeSmallFirstAdPlatform = defaultFirstAdPlatform;
    }
    if (shouldDetectNetworkAndFixPriority) {
        nativeSmallFirstAdPlatform = [adPlatformPriorityStrategy fixedFirstAdPlatformForOriginalAdPlatform:nativeSmallFirstAdPlatform];
    }
    switch (nativeSmallFirstAdPlatform) {
        case NPAdPlatformAdmob:{
            // Native Small Ad Controller
            CVFBAdController *fbNativeSmallAdController = [[CVFBAdController alloc] init];
            CVAdmobAdController *admobNativeSmallAdController = [[CVAdmobAdController alloc] init];
            admobNativeSmallAdController.nextAdController = fbNativeSmallAdController;
            self.firstNativeSmallAdController = admobNativeSmallAdController;
        }
            break;
        case NPAdPlatformFacebook:{
            // Native Small Ad Controller
            CVFBAdController *fbNativeSmallAdController = [[CVFBAdController alloc] init];
            CVAdmobAdController *admobNativeSmallAdController = [[CVAdmobAdController alloc] init];
            fbNativeSmallAdController.nextAdController = admobNativeSmallAdController;
            self.firstNativeSmallAdController = fbNativeSmallAdController;
        }
            break;
        default:
            break;
    }
    
    //--- Native Mid Ad ----- //
    NPAdPlatform nativeMidFirstAdPlatform = [adPlatformPriorityStrategy nativeMidViewFirstAdPlatform];
    if (nativeMidFirstAdPlatform == NPAdPlatformUnkown) {
        nativeMidFirstAdPlatform = defaultFirstAdPlatform;
    }
    if (shouldDetectNetworkAndFixPriority) {
        nativeMidFirstAdPlatform = [adPlatformPriorityStrategy fixedFirstAdPlatformForOriginalAdPlatform:nativeMidFirstAdPlatform];
    }
    switch (nativeMidFirstAdPlatform) {
        case NPAdPlatformAdmob:{
            // Native Mid Ad Controller
            CVFBAdController *fbNativeMidAdController = [[CVFBAdController alloc] init];
            CVAdmobAdController *admobNativeMidAdController = [[CVAdmobAdController alloc] init];
            admobNativeMidAdController.nextAdController = fbNativeMidAdController;
            self.firstNativeMidAdController = admobNativeMidAdController;
        }
            break;
        case NPAdPlatformFacebook:{
            // Native Mid Ad Controller
            CVFBAdController *fbNativeMidAdController = [[CVFBAdController alloc] init];
            CVAdmobAdController *admobNativeMidAdController = [[CVAdmobAdController alloc] init];
            fbNativeMidAdController.nextAdController = admobNativeMidAdController;
            self.firstNativeMidAdController = fbNativeMidAdController;
        }
            break;
        default:
            break;
    }
    
    //----- Native Large Ad ------//
    
    NPAdPlatform nativeLargeFirstAdPlatform = [adPlatformPriorityStrategy nativeLargeViewFirstAdPlatform];
    if (nativeLargeFirstAdPlatform == NPAdPlatformUnkown) {
        nativeLargeFirstAdPlatform = defaultFirstAdPlatform;
    }
    if (shouldDetectNetworkAndFixPriority) {
        nativeLargeFirstAdPlatform = [adPlatformPriorityStrategy fixedFirstAdPlatformForOriginalAdPlatform:nativeLargeFirstAdPlatform];
    }
    switch (nativeLargeFirstAdPlatform) {
        case NPAdPlatformAdmob:{
            //Native Large Ad Controller
            CVFBAdController *fbNativeLargeAdController = [[CVFBAdController alloc] init];
            CVAdmobAdController *admobNativeLargeAdController = [[CVAdmobAdController alloc] init];
            admobNativeLargeAdController.nextAdController = fbNativeLargeAdController;
            self.firstNativeLargeAdController = admobNativeLargeAdController;
        }
            break;
        case NPAdPlatformFacebook:{
            //Native Large Ad Controller
            CVFBAdController *fbNativeLargeAdController = [[CVFBAdController alloc] init];
            CVAdmobAdController *admobNativeLargeAdController = [[CVAdmobAdController alloc] init];
            fbNativeLargeAdController.nextAdController = admobNativeLargeAdController;
            self.firstNativeLargeAdController = fbNativeLargeAdController;
        }
            break;
        default:
            break;
    }
    
    //-- Native Launch Ad ---- //
    
    NPAdPlatform nativeLaunchFirstAdPlatform = [adPlatformPriorityStrategy nativeLaunchViewFirstAdPlatform];
    if (nativeLaunchFirstAdPlatform == NPAdPlatformUnkown) {
        nativeLaunchFirstAdPlatform = defaultFirstAdPlatform;
    }
    if (shouldDetectNetworkAndFixPriority) {
        nativeLaunchFirstAdPlatform = [adPlatformPriorityStrategy fixedFirstAdPlatformForOriginalAdPlatform:nativeLaunchFirstAdPlatform];
    }
    switch (nativeLaunchFirstAdPlatform) {
        case NPAdPlatformAdmob:{
            // Native Launch Ad Controller
            CVFBAdController *fbNativeLaunchAdController = [[CVFBAdController alloc] init];
            CVAdmobAdController *admobNativeLaunchAdController = [[CVAdmobAdController alloc] init];
            admobNativeLaunchAdController.nextAdController = fbNativeLaunchAdController;
            self.firstNativeLaunchAdController = admobNativeLaunchAdController;
        }
            break;
        case NPAdPlatformFacebook:{
            // Native Launch Ad Controller
            CVFBAdController *fbNativeLaunchAdController = [[CVFBAdController alloc] init];
            CVAdmobAdController *admobNativeLaunchAdController = [[CVAdmobAdController alloc] init];
            fbNativeLaunchAdController.nextAdController = admobNativeLaunchAdController;
            self.firstNativeLaunchAdController = fbNativeLaunchAdController;
        }
            break;
        default:
            break;
    }
    
    //----- Interstitial --------//
    NPAdPlatform interstitialFirstAdPlatform = [adPlatformPriorityStrategy interstitialFirstAdPlatform];
    if (interstitialFirstAdPlatform == NPAdPlatformUnkown) {
        interstitialFirstAdPlatform = defaultFirstAdPlatform;
    }
    if (shouldDetectNetworkAndFixPriority) {
        interstitialFirstAdPlatform = [adPlatformPriorityStrategy fixedFirstAdPlatformForOriginalAdPlatform:interstitialFirstAdPlatform];
    }
    switch (interstitialFirstAdPlatform) {
        case NPAdPlatformAdmob:{
            // Interstitial
            CVFBAdController *fbInterstitialAdController = [[CVFBAdController alloc] init];
            CVAdmobAdController *admobInterstitialAdController = [[CVAdmobAdController alloc] init];
            admobInterstitialAdController.nextAdController = fbInterstitialAdController;
            self.firstInterstitialAdController = admobInterstitialAdController;
        }
            break;
        case NPAdPlatformFacebook:{
            // Interstitial
            CVFBAdController *fbInterstitialAdController = [[CVFBAdController alloc] init];
            CVAdmobAdController *admobInterstitialAdController = [[CVAdmobAdController alloc] init];
            fbInterstitialAdController.nextAdController = admobInterstitialAdController;
            self.firstInterstitialAdController = fbInterstitialAdController;
        }
            break;
        default:
            break;
    }
}



#pragma mark - Notifications
- (void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAdmobInterstitialNotification:) name:kAdvertiseGoogleInterstitialNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFacebookInterstitialNotification:) name:kAdvertiseFacebookInterstitialNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAdmobInterstitialWillPresnetNotification:) name:kAdvertiseGoogleInterstitialWillPresentNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFacebookInterstitialWillPresentNotification:) name:kAdvertiseFacebookInterstitialWillPresentNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAdmobInterstitialWillLiveAppNotification:) name:kAdvertiseGoogleInterstitialWillLiveApplicationNotification object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFacebookInterstitialWillLiveAppNotification:) name:kAdvertiseFacebookInterstitialWillLiveApplicationNotification object:nil];    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAdmobInterstitialDidDismissNotification:) name:kAdvertiseGoogleInterstitialDidDismisstNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFacebookInterstitialDidDismissNotification:) name:kAdvertiseFacebookInterstitialDidDismisstNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLaunchViewDismissNotification:) name:keyLaunchAdViewDismissNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFacebookNativeLaunchNetworkErrorNotification:) name:keyFacebookNativeLaunchNetworkErrorNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFacebookReachabilityNotification:) name:keyFacebookReachabilityNotification object:nil];

    
}

- (void)onAdmobInterstitialNotification:(NSNotification *)notification {
    NSNumber *enableInterstitial = notification.object;
    if (enableInterstitial.boolValue) {
        self.isAdmobInterstitialReady = YES;
    }else{
        self.isAdmobInterstitialReady = NO;
    }
    BOOL isInterstitialReady = _isAdmobInterstitialReady || _isFacebookInterstitialReady;
    [[NSNotificationCenter defaultCenter] postNotificationName:keyInterstitialNotification object:@(isInterstitialReady)];
}

- (void)onFacebookInterstitialNotification:(NSNotification *)notification {
    NSNumber *enableInterstitial = notification.object;
    if (enableInterstitial.boolValue) {
        self.isFacebookInterstitialReady = YES;
    }else{
        self.isFacebookInterstitialReady = NO;
    }
    BOOL isInterstitialReady = _isAdmobInterstitialReady || _isFacebookInterstitialReady;
    [[NSNotificationCenter defaultCenter] postNotificationName:keyInterstitialNotification object:@(isInterstitialReady)];
}

- (void)onAdmobInterstitialWillPresnetNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:keyInterstitialWillPresentNotification object:nil];
}

- (void)onFacebookInterstitialWillPresentNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:keyInterstitialWillPresentNotification object:nil];
}

- (void)onAdmobInterstitialWillLiveAppNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:keyInterstitialWillLiveApplicationNotification object:nil];
}

- (void)onFacebookInterstitialWillLiveAppNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:keyInterstitialWillLiveApplicationNotification object:nil];
}

- (void)onAdmobInterstitialDidDismissNotification:(NSNotification *)notification {
//    [self reloadInterstitialAdStartFormCurrentAdController];
    [self loadInterstitialAdStartFromFirstAdController];
    [[NSNotificationCenter defaultCenter] postNotificationName:keyInterstitialDidDismisstNotification object:nil];
}

- (void)onFacebookInterstitialDidDismissNotification:(NSNotification *)notification {
    [self loadInterstitialAdStartFromFirstAdController];
    [[NSNotificationCenter defaultCenter] postNotificationName:keyInterstitialDidDismisstNotification object:nil];
}

- (void)onFacebookNativeLaunchNetworkErrorNotification:(NSNotification *)notification {
    
}

- (void)onLaunchViewDismissNotification:(NSNotification *)notification {
    [self.currNativeLaunchAdController clearNativeLaunchView];
}


//- (void)onFacebookReachabilityNotification:(NSNotification *)notification {
//    [self setupAdPlatformsAndConfigPrioritys];
//}

#pragma mark - Fetch Ads

- (void)initAdvertise{
//    [self loadBannerViewStartFromFirstAdController];
//    [self loadNativeSmallViewStartFromFirstAdController];
    
    [self loadInterstitialAdStartFromFirstAdController];
    BOOL shouldPreloadNativeHalfScreenAd = [NPCommonConfig shareInstance].shouldPreloadNativeHalfScreenAd;
    if (shouldPreloadNativeHalfScreenAd) {
        [self performSelector:@selector(loadNativeHalfScreenAdView) withObject:nil afterDelay:2.0];
    }
}

- (void)closeAdvertise{
    [self.bannerWrapView removeFromSuperview];
    self.bannerWrapView = nil;
    [self.nativeSmallView removeFromSuperview];
    self.nativeSmallView = nil;
    [self.nativeMidView  removeFromSuperview];
    self.nativeMidView = nil;
    [self.nativeLargeView removeFromSuperview];
    self.nativeLargeView = nil;
    [self.nativeLaunchView removeFromSuperview];
    self.nativeLaunchView = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAdvertiseRemoveAdsNotification object:nil];
}


- (void)achieveBannerView:(BannerViewLoadHandler)handler{
    self.bannerViewHandler = handler;
    [self loadBannerViewStartFromFirstAdController];
    __weak typeof(self) weakSelf = self;
    if(self.bannerWrapView){
        self.bannerViewHandler(weakSelf.bannerWrapView);
    }
}


- (void)achieveNativeExpressView:(NativeExpressViewLoadHandler)handler{
    self.nativeHandler = handler;
    [self loadNativeSmallViewStartFromFirstAdController];
    __weak typeof(self) weakSelf = self;
    if(self.nativeSmallView){
        self.nativeHandler(weakSelf.nativeSmallView);
    }
}

- (void)achieveNativeExpress132HView:(NativeExpressView132HLoadHandler)handler {
    self.native132HHandler = handler;
    [self loadNativeMidViewStartFromFirstAdController];
    __weak typeof(self) weakSelf = self;
    if(self.nativeMidView){
        self.native132HHandler(weakSelf.nativeMidView);
    }
}

- (void)achieveNativeExpress250HView:(NativeExpressView250HLoadHandler)handler {
    self.native250HHandler = handler;
    [self loadNativeLargeViewStartFromFirstAdController];
    __weak typeof(self) weakSelf = self;
    if(self.nativeLargeView){
        self.native250HHandler(weakSelf.nativeLargeView);
    }
}

- (void)achieveNativeLaunchAdView:(NativeExpressLaunchViewLoadHandler)handler {
    self.nativeLaunchHandler = handler;
    [self loadNativeLaunchViewStartFromFirstAdController];
    __weak typeof(self) weakSelf = self;
    if(self.nativeLaunchView){
        self.nativeLaunchHandler(weakSelf.nativeLaunchView);
    }
}

- (void)achieveNativeCustomHalfScreenView:(NativeExpressHalfScreenViewLoadHandler)handler{
    self.nativeHalfScreenHandler = handler;
    [self loadNativeHalfScreenAdView];
    __weak typeof(self) weakSelf = self;
    if(self.nativeCustomHalfScrenAdView){
        self.nativeHalfScreenHandler(weakSelf.nativeCustomHalfScrenAdView);
    }
}


- (CVAdmobAdController *)admobHalfScreenAdController {
    if (_admobHalfScreenAdController == nil) {
        self.admobHalfScreenAdController = [[CVAdmobAdController alloc] init];
    }
    return _admobHalfScreenAdController;
}

- (void)achieveInterstitial {
    [self loadInterstitialAdStartFromFirstAdController];
}

- (BOOL)showInterstitialLoadingState{
    if (self.loadedInterstitialAdController) {
        BOOL isInterstitialCanShow = [self.loadedInterstitialAdController isInterstitialCanShow];
        return isInterstitialCanShow;
    }
    return NO;
}

// 原生广告 自定义的半屏广告 是否曾经加载成功
- (BOOL)isCustomHalfScreenAdReady{
    if (self.nativeCustomHalfScrenAdView) {
        return YES;
    }
    return NO;
}

- (BOOL)isRewardVideoReady{
    return NO;
}

- (void)showInterstitial:(UIViewController *)controller{
    if (self.loadedInterstitialAdController) {
        [self.loadedInterstitialAdController showInterstitial:controller];
    }
}

#pragma mark - Load Ads

//----- Load Bannner Ad  ---- //
- (void)loadBannerViewStartFromFirstAdController{
    if (self.bannerWrapView) {
        return;
    }
    self.currBannerAdController = self.firstBannerAdController;
    [self loadBannerViewStartFormCurrentAdController];
}

- (void)loadBannerViewStartFormCurrentAdController {
    [self.currBannerAdController loadBannerViewComplete:^(UIView *bannerWrapView, CVBaseAdController *adController) {
        if(bannerWrapView){
            self.bannerWrapView = bannerWrapView;
            if(self.bannerViewHandler != nil){
                self.bannerViewHandler(bannerWrapView);
            }
        }else{
            CVBaseAdController *nextAdController = self.currBannerAdController.nextAdController;
            if (nextAdController) {
                self.currBannerAdController = nextAdController;
                [self loadBannerViewStartFormCurrentAdController];
            }else{
                self.bannerViewHandler(nil);
            }
        }
    }];
}

//-----------Load Native Small View Ad ---------//
- (void)loadNativeSmallViewStartFromFirstAdController{
    if (self.nativeSmallView) {
        return;
    }
    self.currNativeSmallAdController = self.firstNativeSmallAdController;
    [self loadNativeSmallViewStartFormCurrentAdController];
}


- (void)loadNativeSmallViewStartFormCurrentAdController {
    [self.currNativeSmallAdController loadNativeSmallViewComplete:^(UIView *nativeSmallView, CVBaseAdController *adController) {
        if(nativeSmallView){
            self.nativeSmallView = nativeSmallView;
            if(self.nativeHandler != nil){
                self.nativeHandler(nativeSmallView);
            }
        }else{
            CVBaseAdController *nextAdController = self.currNativeSmallAdController.nextAdController;
            if (nextAdController) {
                self.currNativeSmallAdController = nextAdController;
                [self loadNativeSmallViewStartFormCurrentAdController];
            }else{
                if (self.nativeHandler) {
                    self.nativeHandler(nil);
                }
            }
        }
    }];
}

//-------------Load Native Mid View Ad ----------------//
- (void)loadNativeMidViewStartFromFirstAdController {
    if (self.nativeMidView) {
        return;
    }
    self.currNativeMidAdController = self.firstNativeMidAdController;
    [self loadNativeMidViewStartFormCurrentAdController];
}

- (void)loadNativeMidViewStartFormCurrentAdController {
    [self.currNativeMidAdController loadNativeMidViewComplete:^(UIView *nativeMidView, CVBaseAdController *adController) {
        if (nativeMidView) {
            self.nativeMidView = nativeMidView;
            if (self.native132HHandler) {
                self.native132HHandler(nativeMidView);
            }
        }else{
            CVBaseAdController *nextAdController = self.currNativeMidAdController.nextAdController;
            if (nextAdController) {
                self.currNativeMidAdController = nextAdController;
                [self loadNativeMidViewStartFormCurrentAdController];
            }else{
                if (self.native132HHandler) {
                    self.native132HHandler(nil);
                }
            }
        }
    }];
}

//---------- Load Native Large Ad View ---------------------//

- (void)loadNativeLargeViewStartFromFirstAdController {
    if (self.nativeLargeView) {
        return;
    }
    self.currNativeLargeAdController = self.firstNativeLargeAdController;
    [self loadNativeLargeViewStartFormCurrentAdController];
}

- (void)loadNativeLargeViewStartFormCurrentAdController {
    [self.currNativeLargeAdController loadNativeLargeViewComplete:^(UIView *nativeLargeView, CVBaseAdController *adController) {
        if (nativeLargeView) {
            self.nativeLargeView = nativeLargeView;
            if (self.native250HHandler) {
                self.native250HHandler(nativeLargeView);
            }
        }else{
            CVBaseAdController *nextAdController = self.currNativeLargeAdController.nextAdController;
            if (nextAdController) {
                self.currNativeLargeAdController = nextAdController;
                [self loadNativeLargeViewStartFormCurrentAdController];
            }else{
                if (self.native250HHandler) {
                    self.native250HHandler(nil);
                }
            }
        }
    }];
}

//---------- Load Native Launch Ad View ------------//

- (void)loadNativeLaunchViewStartFromFirstAdController {
    if (self.nativeLaunchView) {
        return;
    }
    self.currNativeLaunchAdController = self.firstNativeLaunchAdController;
    [self loadNativeLaunchViewStartFormCurrentAdController];
}

- (void)loadNativeLaunchViewStartFormCurrentAdController {
    [self.currNativeLaunchAdController loadNativeLaunchViewComplete:^(UIView *nativeLaunchView, CVBaseAdController *adController) {
        if (nativeLaunchView) {
            self.nativeLaunchView = nativeLaunchView;
            if (self.nativeLaunchHandler) {
                self.nativeLaunchHandler(nativeLaunchView);
            }
        }else{
            CVBaseAdController *nextAdController = self.currNativeLaunchAdController.nextAdController;
            if (nextAdController) {
                self.currNativeLaunchAdController = nextAdController;
                [self loadNativeLaunchViewStartFormCurrentAdController];
            }else{
                if (self.nativeLaunchHandler) {
                    self.nativeLaunchHandler(nil);
                }
            }
        }
    }];
}

//------------ Load Interstitial Ad --------------------//

- (void)loadInterstitialAdStartFromFirstAdController {
    if (self.loadedInterstitialAdController.isInterstitialLoadedReady) {
        return;
    }
    self.currInterstitialAdController = self.firstInterstitialAdController;
    [self loadInterstitialAdStartFormCurrentAdController];
}

- (void)loadInterstitialAdStartFormCurrentAdController {
    [self.currInterstitialAdController loadInterstitialAdComplete:^(BOOL isLoaded, CVBaseAdController *adController) {
        if (isLoaded) {
            self.loadedInterstitialAdController = adController;
        }else{
            CVBaseAdController *nextAdController = self.currInterstitialAdController.nextAdController;
            if (nextAdController) {
                self.currInterstitialAdController = nextAdController;
                [self loadInterstitialAdStartFormCurrentAdController];
            }else{
                // not loaded ad
            }

        }
    }];
}

- (void)reloadInterstitialAdStartFormCurrentAdController {
    if (self.loadedInterstitialAdController.isInterstitialLoadedReady) {
        return;
    }
    [self loadInterstitialAdStartFormCurrentAdController];
}

//----------- Custom Half Screen Ad ----------------- //
- (void)loadNativeHalfScreenAdView {
    if (self.nativeCustomHalfScrenAdView) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.admobHalfScreenAdController loadCustomHalfScreenAdComplete:^(UIView *nativeHalfScreenView, CVBaseAdController *adController) {
        if (nativeHalfScreenView) {
            weakSelf.nativeCustomHalfScrenAdView = nativeHalfScreenView;
        }else{
            
        }
    }];
}

#pragma mark - Load Pro version banner View

- (void)loadProVersionData {
    if (self.proVersionImage) {
        return;
    }
    NSString *imageFilePath = [self filePathInLibrary:kProVersionBannerImageName];
    UIImage *libProVersionImage = [UIImage imageWithContentsOfFile:imageFilePath];
    if (libProVersionImage) {
        self.proVersionImage = libProVersionImage;
        return;
    }
    if ([NSThread isMainThread])
    {
        [self performSelectorInBackground:@selector(loadProVersionData) withObject:nil];
        return;
    }
    
    @autoreleasepool
    {
        //prevent concurrent checks
        static BOOL checking = NO;
        if (checking) return;
        checking = YES;
        
        //first check iTunes
        NSString *appStoreCountry = [iRate sharedInstance].appStoreCountry;
        NSString *proAppId = [NPCommonConfig shareInstance].proAppId;
        NSString *iTunesServiceURL = [NSString stringWithFormat:@"https://itunes.apple.com/%@/lookup", appStoreCountry];
        iTunesServiceURL = [iTunesServiceURL stringByAppendingFormat:@"?id=%@", proAppId];
        
        NSError *error = nil;
        NSURLResponse *response = nil;
        NSURL *url = [NSURL URLWithString:iTunesServiceURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:50];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
        if (data && statusCode == 200)
        {
            //in case error is garbage...
            error = nil;
            
            id json = nil;
            if ([NSJSONSerialization class])
            {
                json = [[NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)0 error:&error][@"results"] lastObject];
            }else {
                //convert to string
                json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            
            if (!error)
            {
                //check bundle ID matches
                NSString *bundleID = [self valueForKey:@"bundleId" inJSON:json];
                if (bundleID){
                    CGSize bannerProVersionSize = CGSizeMake(320, 50);
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        bannerProVersionSize = CGSizeMake(728, 90);
                    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
                        bannerProVersionSize = CGSizeMake(320, 50);
                    }
                    
                    NSString *trackName = [self valueForKey:@"trackName" inJSON:json];
                    self.proTrackName = trackName;
                    NSString *formattedPrice = [self valueForKey:@"formattedPrice" inJSON:json];
                    NSString *artworkUrl100 =  [self valueForKey:@"artworkUrl100" inJSON:json];
                    NSString *artworkUrl512 = [self valueForKey:@"artworkUrl512" inJSON:json];
                    
                    NSString *iconUrlString = (artworkUrl100.length ? artworkUrl100 : artworkUrl512);
                    NSURL *iconURL = [[NSURL alloc] initWithString:iconUrlString];
                    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:iconURL
                                                                cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                            timeoutInterval:15.0f];
                    NSData *iconData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                             returningResponse:NULL
                                                                         error:NULL];
                    UIImage *iconImage = [UIImage imageWithData:iconData];
                    if (iconImage && (trackName != nil && trackName.length > 0)) {
                        
                        CGSize finalSize = CGSizeMake(100, 100);  //_iconView.bounds.size;
                        UIGraphicsBeginImageContextWithOptions(finalSize, YES, 0.0f);
                        [iconImage drawInRect:(CGRect) {
                            .size = finalSize
                        }];
                        
                        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        CGImageRef maskRef = [UIImage imageNamed:@"DAAppsViewController.bundle/DAMaskImage"].CGImage;
                        CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                                            CGImageGetHeight(maskRef),
                                                            CGImageGetBitsPerComponent(maskRef),
                                                            CGImageGetBitsPerPixel(maskRef),
                                                            CGImageGetBytesPerRow(maskRef),
                                                            CGImageGetDataProvider(maskRef), NULL, false);
                        CGImageRef maskedImageRef = CGImageCreateWithMask([resizedImage CGImage], mask);
                        UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
                        CGImageRelease(mask);
                        CGImageRelease(maskedImageRef);
                        if (maskedImage) {
                            self.proIconImage = maskedImage;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                CGSize proVersionSize = bannerProVersionSize;
                                CGFloat bannerWidth = proVersionSize.width;
                                CGFloat bannerHeight = proVersionSize.height;
                                UIView *proVersionView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, bannerWidth, bannerHeight)];
                                proVersionView.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1]; //[UIColor grayColor];
                                proVersionView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                                
                                CGFloat heightEdge = 10.0f;
                                CGFloat iconWidth = bannerHeight- heightEdge;
                                CGFloat downloadButtonWith = 56;
                                CGFloat downloadButtonHeight = bannerHeight/2.0;
                                
                                UIImageView *iconView = [[UIImageView alloc] init];
                                iconView.frame = CGRectMake(12.0f, heightEdge/2.0f, iconWidth, iconWidth);
                                iconView.contentMode = UIViewContentModeScaleAspectFit;
                                iconView.image = self.proIconImage;
                                [proVersionView addSubview:iconView];
                                
                                UILabel *nameLabel = [[UILabel alloc] init];
                                nameLabel.font = [UIFont systemFontOfSize:12.0f];
                                nameLabel.backgroundColor = [UIColor clearColor];
                                nameLabel.textColor = [UIColor blackColor];
                                nameLabel.text = self.proTrackName;
                                nameLabel.frame = CGRectMake(iconWidth + 12 + 8, heightEdge/2.0f, bannerWidth -12-8-iconWidth-downloadButtonWith -12-8 , iconWidth/2);
                                [proVersionView addSubview:nameLabel];
                                
                                UILabel *descriptionLabel = [[UILabel alloc] init];
                                descriptionLabel.font = [UIFont systemFontOfSize:12.0f];
                                descriptionLabel.backgroundColor = [UIColor clearColor];
                                descriptionLabel.textColor = [UIColor blackColor];
                                NSString *descriptionStr = [SBPaymentLocalizeUtil localizedStringForKey:@"No ads for perfect experience" withDefault:@"No ads for perfect experience"];
                                descriptionLabel.text = descriptionStr;// @"No ads, perfect experience";
                                descriptionLabel.frame = CGRectMake(iconWidth + 12 + 8, heightEdge/2.0f + iconWidth/2, bannerWidth -12-8-iconWidth-downloadButtonWith -12-8 , iconWidth/2);
                                [proVersionView addSubview:descriptionLabel];
                                
                                
                                UIButton *purchaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
                                purchaseButton.frame = CGRectMake(bannerWidth-downloadButtonWith-12, (bannerHeight - downloadButtonHeight)/2.0f, downloadButtonWith, downloadButtonHeight);
                                //                                   (CGRect) {
                                //                                        .origin.x = self.frame.size.width - 67.0f,
                                //                                        .origin.y = 28.0f,
                                //                                        .size.width = 56.0f,
                                //                                        .size.height = (DA_IS_IOS7 ? 26.0f : 25.0f)
                                //                                    };
                                purchaseButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
                                
                                UIColor *titleColor = [UIColor colorWithRed:0.0f green:0.49f blue:0.96f alpha:1.0f];
                                [purchaseButton setTitleColor:titleColor forState:UIControlStateNormal];
                                [purchaseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                                
                                purchaseButton.layer.borderColor = titleColor.CGColor;
                                purchaseButton.layer.borderWidth = 1.0f;
                                purchaseButton.layer.cornerRadius = 4.0f;
                                purchaseButton.layer.masksToBounds = YES;
                                
                                CGRect rect = CGRectMake(0.0f, 0.0f, 2.0f, 2.0f);
                                UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
                                CGContextRef context = UIGraphicsGetCurrentContext();
                                CGContextSetFillColorWithColor(context, titleColor.CGColor);
                                CGContextFillRect(context, rect);
                                UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
                                UIGraphicsEndImageContext();
                                [purchaseButton setBackgroundImage:coloredImage forState:UIControlStateHighlighted];
                                
                                [purchaseButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
                                //TODO: donwload
                                if (formattedPrice == nil || formattedPrice.length == 0) {
                                    [purchaseButton setTitle:@"Get" forState:UIControlStateNormal];
                                }else{
                                    [purchaseButton setTitle:[formattedPrice uppercaseString] forState:UIControlStateNormal];
                                }
                                [proVersionView addSubview:purchaseButton];
                                
                                UIGraphicsBeginImageContextWithOptions(proVersionView.frame.size, YES, [UIScreen mainScreen].scale);
                                [proVersionView.layer renderInContext:UIGraphicsGetCurrentContext()];
                                UIImage *drawImage=UIGraphicsGetImageFromCurrentImageContext();
                                UIGraphicsEndImageContext();
                                
                                self.proVersionImage = drawImage;
                                NSData *imageData = UIImageJPEGRepresentation(drawImage, 0.7);// UIImagePNGRepresentation(drawImage);
                                NSString *imageFilePath = [self filePathInLibrary:kProVersionBannerImageName];
                                [imageData writeToFile:imageFilePath atomically:YES];
                            });
                        }
                    }
                }
            }
        }
        else if (statusCode >= 400)
        {
            //http error
            NSString *message = [NSString stringWithFormat:@"The server returned a %@ error", @(statusCode)];
            error = [NSError errorWithDomain:@"HTTPResponseErrorDomain" code:statusCode userInfo:@{NSLocalizedDescriptionKey: message}];
        }
        
        //handle errors (ignoring sandbox issues)
        if (error && !(error.code == EPERM && [error.domain isEqualToString:NSPOSIXErrorDomain]))
        {
            //            [self performSelectorOnMainThread:@selector(connectionError:) withObject:error waitUntilDone:YES];
        }
        else
        {
            //show prompt
            //            [self performSelectorOnMainThread:@selector(connectionSucceeded) withObject:nil waitUntilDone:YES];
            //success
        }
        
        //finished
        checking = NO;
    }
}

- (NSString *)filePathInLibrary:(NSString *)filename {
    NSArray *libPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libPath = [libPaths objectAtIndex:0];
    return [libPath stringByAppendingPathComponent:filename];
}

- (NSString *)valueForKey:(NSString *)key inJSON:(id)json
{
    if ([json isKindOfClass:[NSString class]])
    {
        //use legacy parser
        NSRange keyRange = [json rangeOfString:[NSString stringWithFormat:@"\"%@\"", key]];
        if (keyRange.location != NSNotFound)
        {
            NSInteger start = keyRange.location + keyRange.length;
            NSRange valueStart = [json rangeOfString:@":" options:(NSStringCompareOptions)0 range:NSMakeRange(start, [(NSString *)json length] - start)];
            if (valueStart.location != NSNotFound)
            {
                start = valueStart.location + 1;
                NSRange valueEnd = [json rangeOfString:@"," options:(NSStringCompareOptions)0 range:NSMakeRange(start, [(NSString *)json length] - start)];
                if (valueEnd.location != NSNotFound)
                {
                    NSString *value = [json substringWithRange:NSMakeRange(start, valueEnd.location - start)];
                    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    while ([value hasPrefix:@"\""] && ![value hasSuffix:@"\""])
                    {
                        if (valueEnd.location == NSNotFound)
                        {
                            break;
                        }
                        NSInteger newStart = valueEnd.location + 1;
                        valueEnd = [json rangeOfString:@"," options:(NSStringCompareOptions)0 range:NSMakeRange(newStart, [(NSString *)json length] - newStart)];
                        value = [json substringWithRange:NSMakeRange(start, valueEnd.location - start)];
                        value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    }
                    
                    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
                    value = [value stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
                    value = [value stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\f" withString:@"\f"];
                    value = [value stringByReplacingOccurrencesOfString:@"\\b" withString:@"\f"];
                    
                    while (YES)
                    {
                        NSRange unicode = [value rangeOfString:@"\\u"];
                        if (unicode.location == NSNotFound || unicode.location + unicode.length == 0)
                        {
                            break;
                        }
                        
                        uint32_t c = 0;
                        NSString *hex = [value substringWithRange:NSMakeRange(unicode.location + 2, 4)];
                        NSScanner *scanner = [NSScanner scannerWithString:hex];
                        [scanner scanHexInt:&c];
                        
                        if (c <= 0xffff)
                        {
                            value = [value stringByReplacingCharactersInRange:NSMakeRange(unicode.location, 6) withString:[NSString stringWithFormat:@"%C", (unichar)c]];
                        }
                        else
                        {
                            //convert character to surrogate pair
                            uint16_t x = (uint16_t)c;
                            uint16_t u = (c >> 16) & ((1 << 5) - 1);
                            uint16_t w = (uint16_t)u - 1;
                            unichar high = 0xd800 | (w << 6) | x >> 10;
                            unichar low = (uint16_t)(0xdc00 | (x & ((1 << 10) - 1)));
                            
                            value = [value stringByReplacingCharactersInRange:NSMakeRange(unicode.location, 6) withString:[NSString stringWithFormat:@"%C%C", high, low]];
                        }
                    }
                    return value;
                }
            }
        }
    }
    else
    {
        return json[key];
    }
    return nil;
}


- (UIView *)bannerViewWithUpgradeProVersionForSize:(CGSize)bannerSize {
    if (self.proVersionImage == nil) {
        return nil;
    }
    GADAdSize gadAdSize = kGADAdSizeSmartBannerPortrait;
    CGSize size = CGSizeFromGADAdSize(gadAdSize);
    //    CGSize size = [UIScreen mainScreen].bounds.size;
    UIView *showView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, size.width, bannerSize.height)];
    UIImageView *upgradeProVersionView = [self getUpgradeProVersionViewForSize:bannerSize];
    [showView addSubview:upgradeProVersionView];
    CGRect frame = upgradeProVersionView.frame;
    frame.origin.x = (size.width - frame.size.width)/2;
    upgradeProVersionView.frame = frame;
    if (self.proVersionImage) {
        upgradeProVersionView.image = _proVersionImage;
        self.proVersionBannerSuperView = showView;
        return showView;
    }
    return nil;
}


- (void)onUpgradeProVersonTouched:(id)sender {
    //    NSLog(@"%s", __func__);
    [[NPCommonConfig shareInstance] gotoBuyProVersion];
}

- (UIImageView *)getUpgradeProVersionViewForSize:(CGSize)size{
    if (_upgradeProVersionView == nil) {
        self.upgradeProVersionView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
        _upgradeProVersionView.backgroundColor = [UIColor whiteColor];
        _upgradeProVersionView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _upgradeProVersionView.userInteractionEnabled = YES;
        UITapGestureRecognizer *oneTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onUpgradeProVersonTouched:)];
        oneTapGestureRecognizer.numberOfTapsRequired = 1;
        [_upgradeProVersionView addGestureRecognizer:oneTapGestureRecognizer];
    }
    return _upgradeProVersionView;
}

- (void)setTimerShowInterstitial{
    //    _timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timerShowInterstitial) userInfo:nil repeats:true];
}
- (void)timerShowInterstitial{
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [self showInterstitial:viewController];
}

@end



