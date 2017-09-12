//
//  CVFBAdController.m
//  Common
//
//  Created by mayuan on 2017/6/6.
//  Copyright © 2017年 camory. All rights reserved.
//

#import "CVFBAdController.h"
#import <UIKit/UIKit.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "NPCommonConfig.h"
#import "Macros.h"
#import "PDCFBAd_View.h"
#import "AppDelegate.h"

//#import "ViewController.h"

@interface CVFBAdController ()<
FBAdViewDelegate,
FBNativeAdDelegate,
FBInterstitialAdDelegate
>

{
    
}


@property (nonatomic, strong) FBAdView *bannerView;

@property (nonatomic, strong) FBNativeAd *nativeSmallView;
@property (nonatomic, strong) FBNativeAd *nativeMidView;
@property (nonatomic, strong) FBNativeAd *nativeLargeView;

@property (nonatomic, strong) FBNativeAd *nativeLaunchView;

@property (nonatomic, strong) FBInterstitialAd *interstitialAd;


// banner 广告 包装 父View
@property(strong, nonatomic) UIView *bannerWrapView;
// banner广告  曾经加载成功
@property(assign, nonatomic) BOOL isBannerViewInLoading;


@property (nonatomic, strong) UIView *nativeSmallWrapView;
@property (assign, atomic) BOOL isNativeSmallViewInLoading;

@property (nonatomic, strong) UIView *nativeMidWrapView;
@property (atomic, assign) BOOL isNativeMidViewInLoading;

@property (nonatomic, strong) UIView *nativeLargeWrapView;
@property (atomic, assign) BOOL isNativeLargeViewInLoading;

@property (nonatomic, strong) UIView *nativeLaunchWrapView;
@property (atomic, assign) BOOL isNativeLaunchViewInLoading;

@property (atomic, assign) BOOL isInterstitialInLoading;

// 判断是否有广告已显示，如果当前 ‘FBInterstitialAd’ 已经调用 'showAdFromRootViewController', 再次调用会出现奔溃
@property (atomic, assign) BOOL isCurrentInterstitialShowed;

@end


@implementation CVFBAdController

+ (void)initAdConfig {
    // 打印fb信息.
#if DEBUG
    [FBAdSettings setLogLevel:FBAdLogLevelLog];
    
#else
//    [FBAdSettings clearTestDevices];
    [FBAdSettings setLogLevel:FBAdLogLevelWarning];
#endif
    NSArray *testDevices = [NPCommonConfig shareInstance].fbAdTestDevices;
    if (testDevices && testDevices.count > 0) {
        for (NSString *deviceHashId in testDevices) {
            [FBAdSettings addTestDevice:deviceHashId];
        }
    }
}

- (id)init{
    self = [super init];
    if(self != nil){
//        [self initPlaceholderViewController];
    }
    return self;
}

- (void)initPlaceholderViewController {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    UIViewController *rootViewController = delegate.window.rootViewController;
    self.viewController = rootViewController;
}


- (void)removeAllAds{
    
    [self.bannerWrapView removeFromSuperview];
    self.bannerWrapView = nil;
    [self.nativeSmallWrapView removeFromSuperview];
    self.nativeSmallWrapView = nil;
    [self.nativeMidWrapView removeFromSuperview];
    self.nativeMidWrapView = nil;
    [self.nativeLargeWrapView removeFromSuperview];
    self.nativeLargeWrapView = nil;
    
    self.bannerView.delegate = nil;
    self.nativeSmallView.delegate = nil;
    self.nativeMidView.delegate = nil;
    self.nativeLargeView.delegate = nil;
    self.nativeLaunchView.delegate = nil;
    self.interstitialAd.delegate = nil;
    
    self.bannerView = nil;
    self.nativeSmallView = nil;
    self.nativeMidView = nil;
    self.nativeLargeView = nil;
    self.nativeLaunchView = nil;
    self.interstitialAd = nil;
    
    NSNumber *enable = [NSNumber numberWithBool:false];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAdvertiseFacebookInterstitialNotification object:enable];
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
    [self loadNativeSmallView];
    __weak typeof(self) weakSelf = self;
    if(weakSelf.nativeSmallWrapView){
        self.completeNativeSmallView(weakSelf.nativeSmallWrapView, self);
    }
}

- (void)loadNativeMidViewComplete:(CompleteWithNativeMidView)complete {
    self.completeNativeMidView = complete;
    [self loadNativeMidView];
    __weak typeof(self) weakSelf = self;
    if(weakSelf.nativeMidWrapView){
        self.completeNativeMidView(weakSelf.nativeMidWrapView, self);
    }
}

- (void)loadNativeLargeViewComplete:(CompleteWithNativeLargeView)complete{
    self.completeNativeLargeView = complete;
    [self loadNativeLargeView];
    __weak typeof(self) weakSelf = self;
    if(weakSelf.nativeLargeWrapView){
        self.completeNativeLargeView(weakSelf.nativeLargeWrapView, self);
    }
}

- (void)loadNativeLaunchViewComplete:(CompleteWithNativeLaunchView)complete {
    self.completeNativeLaunchView = complete;
    [self loadNativeLaunchView];
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

- (BOOL)isInterstitialCanShow{
    if (self.interstitialAd && self.interstitialAd.isAdValid) {
        if (self.isCurrentInterstitialShowed) {
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}

- (BOOL)isInterstitialLoadedReady{
    if (self.interstitialAd && self.interstitialAd.isAdValid) {
        return YES;
    }
    return NO;
}

- (BOOL)needsShowAdView{
    BOOL shouldShowAd = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    return shouldShowAd;
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
        // Ad is ready, present it!
        self.isCurrentInterstitialShowed = YES;
        [self.interstitialAd showAdFromRootViewController:controller];
        NSNumber *enable = [NSNumber numberWithBool:false];
        [[NSNotificationCenter defaultCenter]postNotificationName:kAdvertiseFacebookInterstitialNotification object:enable];
    }
}
//- (void)showInterstitialOperation:(UIViewController *)controller{
//    BOOL needShowAD = [self needsShowAdView];
//    if (NO == needShowAD) {
//        return;
//    }
//    if(controller == nil){
//        controller = [UIApplication sharedApplication].keyWindow.rootViewController;
//    }
//    if ([self isInterstitialLoadedReady]) {
//        [self.interstitial presentFromRootViewController:controller];
//    }
//}

- (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
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
    NSString *fbBannerAdID = [NPCommonConfig shareInstance].fbBannerAdID;
    if (fbBannerAdID == nil || fbBannerAdID.length <= 0) {
         LOG(@"%s, fbBannerAdID can not be nil",__func__);
        if (self.completeBannerView) {
            self.completeBannerView(nil, self);
        }
        return;
    }
    if (self.isBannerViewInLoading) {
        return;
    }
    self.isBannerViewInLoading = YES;
    BOOL isIPAD = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    FBAdSize adSize = isIPAD ? kFBAdSizeHeight90Banner : kFBAdSizeHeight50Banner;
    self.bannerView = [[FBAdView alloc] initWithPlacementID:fbBannerAdID
                                                     adSize:adSize
                                         rootViewController:self.viewController];
    self.bannerView.delegate = self;
    [self.bannerView loadAd];
}

- (void)loadNativeSmallView{
    BOOL isNetworkConnected = [NPCommonConfig shareInstance].isNetworkConnected;
    if (NO == isNetworkConnected) {
        return;
    }
    if (self.nativeSmallWrapView) {
        return;
    }
    NSString *fbNativeSmallAdID = [NPCommonConfig shareInstance].fbNativeSmallAdID;
    if (fbNativeSmallAdID == nil || fbNativeSmallAdID.length == 0) {
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
    // Use different ID for each ad placement in your app.
    self.nativeSmallView = [[FBNativeAd alloc] initWithPlacementID:fbNativeSmallAdID];
    // Set a delegate to get notified when the ad was loaded.
    self.nativeSmallView.delegate = self;
    // Configure native ad to wait to call nativeAdDidLoad: until all ad assets are loaded
    self.nativeSmallView.mediaCachePolicy = FBNativeAdsCachePolicyAll;
    // Initiate a request to load an ad.
    [self.nativeSmallView loadAd];
}

- (void)loadNativeMidView {
    BOOL isNetworkConnected = [NPCommonConfig shareInstance].isNetworkConnected;
    if (NO == isNetworkConnected) {
        return;
    }
    if (self.nativeMidWrapView) {
        return;
    }
    NSString *fbNativeMidAdID = [NPCommonConfig shareInstance].fbNativeMidAdID;
    if (fbNativeMidAdID == nil || fbNativeMidAdID.length == 0) {
        NSLog(@"fbNativeMidAdID  be nil");
        if (self.completeNativeMidView) {
            self.completeNativeMidView(nil, self);
        }
        return;
    }
    if (self.isNativeMidViewInLoading) {
        return;
    }
    self.isNativeMidViewInLoading = YES;
    // Use different ID for each ad placement in your app.
    self.nativeMidView = [[FBNativeAd alloc] initWithPlacementID:fbNativeMidAdID];
    // Set a delegate to get notified when the ad was loaded.
    self.nativeMidView.delegate = self;
    // Configure native ad to wait to call nativeAdDidLoad: until all ad assets are loaded
    self.nativeMidView.mediaCachePolicy = FBNativeAdsCachePolicyAll;
    // Initiate a request to load an ad.
    [self.nativeMidView loadAd];
}

- (void)loadNativeLargeView {
    BOOL isNetworkConnected = [NPCommonConfig shareInstance].isNetworkConnected;
    if (NO == isNetworkConnected) {
        return;
    }
    if (self.nativeLargeWrapView) {
        return;
    }
    NSString *fbNativeLargeAdID = [NPCommonConfig shareInstance].fbNativeLargeAdID;
    if (fbNativeLargeAdID == nil || fbNativeLargeAdID.length == 0) {
        NSLog(@"fbNativeLargeAdID  be nil");
        if (self.completeNativeLargeView) {
            self.completeNativeLargeView(nil, self);
        }
        return;
    }
    if (self.isNativeLargeViewInLoading) {
        return;
    }
    self.isNativeLargeViewInLoading = YES;
    // Use different ID for each ad placement in your app.
    self.nativeLargeView = [[FBNativeAd alloc] initWithPlacementID:fbNativeLargeAdID];
    // Set a delegate to get notified when the ad was loaded.
    self.nativeLargeView.delegate = self;
    // Configure native ad to wait to call nativeAdDidLoad: until all ad assets are loaded
    self.nativeLargeView.mediaCachePolicy = FBNativeAdsCachePolicyAll;
    // Initiate a request to load an ad.
    [self.nativeLargeView loadAd];
}

- (void)loadNativeLaunchView {
    BOOL isNetworkConnected = [NPCommonConfig shareInstance].isNetworkConnected;
    if (NO == isNetworkConnected) {
        return;
    }
    if (self.nativeLaunchWrapView) {
        return;
    }
    NSString *fbNativeLaunchAdID = [NPCommonConfig shareInstance].fbNativeLaunchAdID;
    if (fbNativeLaunchAdID == nil || fbNativeLaunchAdID.length == 0) {
        NSLog(@"fbNativeLaunchAdID  be nil");
        if (self.completeNativeLaunchView) {
            self.completeNativeLaunchView(nil, self);
        }
        return;
    }
    if (self.isNativeLaunchViewInLoading) {
        return;
    }
    self.isNativeLaunchViewInLoading = YES;
    // Use different ID for each ad placement in your app.
    self.nativeLaunchView = [[FBNativeAd alloc] initWithPlacementID:fbNativeLaunchAdID];
    // Set a delegate to get notified when the ad was loaded.
    self.nativeLaunchView.delegate = self;
    // Configure native ad to wait to call nativeAdDidLoad: until all ad assets are loaded
    self.nativeLaunchView.mediaCachePolicy = FBNativeAdsCachePolicyAll;
    // Initiate a request to load an ad.
    [self.nativeLaunchView loadAd];

}

- (void)loadInterstitial{
    BOOL isNetworkConnected = [NPCommonConfig shareInstance].isNetworkConnected;
    if (NO == isNetworkConnected) {
        return;
    }
    NSString *fbInterstitialAdID = [NPCommonConfig shareInstance].fbInterstitialAdID;
    if (fbInterstitialAdID == nil || fbInterstitialAdID.length == 0) {
         LOG(@"%s, fbInterstitialAdID  be nil",__func__);
        if (self.completeInterstitial) {
            self.completeInterstitial(NO, self);
        }
        return;
    }
    if ([self isInterstitialLoadedReady]) {
        return;
    }
    
    if (self.isInterstitialInLoading) {
        return;
    }
    
    self.isInterstitialInLoading = YES;

    self.interstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:fbInterstitialAdID];
    // Set a delegate to get notified on changes or when the user interact with the ad.
    self.interstitialAd.delegate = self;
    // Initiate the request to load the ad.
    [self.interstitialAd loadAd];
}


#pragma mark - FBAdViewDelegate (BannerView)

- (void)adViewDidClick:(FBAdView *)adView{
     LOG(@"%s, bannerview did click",__func__);
    self.bannerWrapView = nil;
    [self loadBannerView];
}

- (void)adViewDidFinishHandlingClick:(FBAdView *)adView{
     LOG(@"%s",__func__);
}

- (void)adViewDidLoad:(FBAdView *)adView{
     LOG(@"%s, initView: %@, reback adview: %@",__func__, self.bannerView, adView);
    UIView *showView = [self bannerWrapViewForBannerView:adView];
    self.isBannerViewInLoading = NO;
    if(self.completeBannerView != nil){
        self.completeBannerView(showView, self);
    }
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


- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error{
     LOG(@"%s",__func__);
    self.isBannerViewInLoading = NO;
    if(self.completeBannerView != nil){
        self.completeBannerView(nil, self);
    }
}


- (void)adViewWillLogImpression:(FBAdView *)adView{
     LOG(@"%s",__func__);
}


#pragma mark - FBNativeAdDelegate

- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd{
    LOG(@"%s, initView: %@, reback nativeAd: %@",__func__, self.nativeSmallView, nativeAd);
    // Create native UI using the ad metadata.
    //  _ad_View = [[NSBundle mainBundle] loadNibNamed:@"PDCFBAd_View" owner:nil options:nil].firstObject;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat fixedScreenWidth = MIN(screenWidth, screenHeight);

    NSString *adPlacementID = nativeAd.placementID;
    NSString *nativeSmallAdID = [NPCommonConfig shareInstance].fbNativeSmallAdID;
    NSString *nativeMidAdID = [NPCommonConfig shareInstance].fbNativeMidAdID;
    NSString *nativeLargeAdID = [NPCommonConfig shareInstance].fbNativeLargeAdID;
    NSString *nativeLaunchAdID = [NPCommonConfig shareInstance].fbNativeLaunchAdID;
    
    if ([adPlacementID isEqualToString:nativeSmallAdID]) {
        CGFloat _height = 80;
        PDCFBAd_View *nativeSmallWrapView = [[PDCFBAd_View alloc] initWithFrame:CGRectMake(0, 0, fixedScreenWidth, _height)];
        [nativeSmallWrapView loadDataWithFBNaviveAd:nativeAd controller:self.viewController];
        
        if (_height <= PDCAdFrameType_Cell) {
            [nativeSmallWrapView reDrawRectWithHeight:_height frameType:PDCAdFrameType_Cell];
        }
        self.nativeSmallWrapView = nativeSmallWrapView;
        if(self.completeNativeSmallView != nil){
            self.completeNativeSmallView(nativeSmallWrapView, self);
        }
        self.isNativeSmallViewInLoading = NO;
    }else if ([adPlacementID isEqualToString:nativeMidAdID]) {
        CGFloat _height = 132;
        PDCFBAd_View *nativeMidWrapView = [[PDCFBAd_View alloc] initWithFrame:CGRectMake(0, 0, fixedScreenWidth, _height)];
        [nativeMidWrapView loadDataWithFBNaviveAd:nativeAd controller:self.viewController];
        
        if (_height <= PDCAdFrameType_Cell) {
            [nativeMidWrapView reDrawRectWithHeight:_height frameType:PDCAdFrameType_Cell];
        }
        self.nativeMidWrapView = nativeMidWrapView;
        if(self.completeNativeMidView != nil){
            self.completeNativeMidView(nativeMidWrapView, self);
        }
        self.isNativeMidViewInLoading = NO;
    }else if([adPlacementID isEqualToString:nativeLargeAdID]) {
        CGSize nativeSize = CGSizeMake(320, 250);
        CGSize configSize = [NPCommonConfig shareInstance].nativeLargeViewsize;
        nativeSize = configSize;
        CGFloat _height = configSize.height;
        PDCFBAd_View *nativeLargeWrapView = [[PDCFBAd_View alloc] initWithFrame:CGRectMake(0, 0, configSize.width, _height)];
        [nativeLargeWrapView loadDataWithFBNaviveAd:nativeAd controller:self.viewController];
        
        if (_height <= PDCAdFrameType_Cell) {
            [nativeLargeWrapView reDrawRectWithHeight:_height frameType:PDCAdFrameType_Cell];
        }
        self.nativeLargeWrapView = nativeLargeWrapView;
        if(self.completeNativeLargeView != nil){
            self.completeNativeLargeView(nativeLargeWrapView, self);
        }
        self.isNativeLargeViewInLoading = NO;
    }else if([adPlacementID isEqualToString:nativeLaunchAdID]) {
        CGSize nativeLaunchAdViewSize = [NPCommonConfig shareInstance].nativeLaunchAdViewSize;
        CGFloat minWidth = MIN(nativeLaunchAdViewSize.width, nativeLaunchAdViewSize.height);
        CGFloat _height = minWidth;
        PDCFBAd_View *nativeLaunchWrapView = [[PDCFBAd_View alloc] initWithFrame:CGRectMake(0, 0, minWidth, _height)];
        [nativeLaunchWrapView loadDataWithFBNaviveAd:nativeAd controller:self.viewController];
        
        if (_height <= PDCAdFrameType_Cell) {
            [nativeLaunchWrapView reDrawRectWithHeight:_height frameType:PDCAdFrameType_Cell];
        }
        self.nativeLaunchWrapView = nativeLaunchWrapView;
        if(self.completeNativeLaunchView != nil){
            self.completeNativeLaunchView(nativeLaunchWrapView, self);
        }
        self.isNativeLaunchViewInLoading = NO;
    }
   
}

- (void)nativeAdWillLogImpression:(FBNativeAd *)nativeAd{
    LOG(@"%s",__func__);

}


- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error{
    NSString *adPlacementID = nativeAd.placementID;
    NSString *nativeSmallAdID = [NPCommonConfig shareInstance].fbNativeSmallAdID;
    NSString *nativeMidAdID = [NPCommonConfig shareInstance].fbNativeMidAdID;
    NSString *nativeLargeAdID = [NPCommonConfig shareInstance].fbNativeLargeAdID;
    NSString *nativeLaunchAdID = [NPCommonConfig shareInstance].fbNativeLaunchAdID;
  
     LOG(@"%s, error: %@",__func__, error);
    
    if ([adPlacementID isEqualToString:nativeSmallAdID]) {
        self.isNativeSmallViewInLoading = NO;
        if(self.completeNativeSmallView != nil){
            self.completeNativeSmallView(nil, self);
        }
    }else if([adPlacementID isEqualToString:nativeMidAdID]) {
        self.isNativeMidViewInLoading = NO;
        if (self.completeNativeMidView) {
            self.completeNativeMidView(nil, self);
        }
    }else if([adPlacementID isEqualToString:nativeLargeAdID]){
        self.isNativeLargeViewInLoading = NO;
        if (self.completeNativeLargeView) {
            self.completeNativeLargeView(nil, self);
        }
    }else if([adPlacementID isEqualToString:nativeLaunchAdID]) {
        self.isNativeLaunchViewInLoading = NO;
        if (self.completeNativeLaunchView) {
            self.completeNativeLaunchView(nil, self);
        }
         LOG(@"%s, keyFacebookNativeLaunchNetworkErrorNotification",__func__);
        if (error.code == 1000) {
            [[NSNotificationCenter defaultCenter] postNotificationName:keyFacebookNativeLaunchNetworkErrorNotification object:nil];
        }
    }
    
}


- (void)nativeAdDidClick:(FBNativeAd *)nativeAd{
    LOG(@"%s",__func__);
    NSString *adPlacementID = nativeAd.placementID;
    NSString *nativeSmallAdID = [NPCommonConfig shareInstance].fbNativeSmallAdID;
    NSString *nativeMidAdID = [NPCommonConfig shareInstance].fbNativeMidAdID;
    NSString *nativeLargeAdID = [NPCommonConfig shareInstance].fbNativeLargeAdID;
    NSString *nativeLaunchAdID = [NPCommonConfig shareInstance].fbNativeLaunchAdID;
    
    if ([adPlacementID isEqualToString:nativeSmallAdID]) {
        self.nativeSmallWrapView = nil;
        [self loadNativeSmallView];
    }else if([adPlacementID isEqualToString:nativeMidAdID]) {
        self.nativeMidWrapView = nil;
        [self loadNativeMidView];
    }else if([adPlacementID isEqualToString:nativeLargeAdID]){
        self.nativeLargeWrapView = nil;
        [self loadNativeLargeView];
    }else if([adPlacementID isEqualToString:nativeLaunchAdID]) {
        // 开屏广告仅展示一次，无需重新请求
//        self.nativeLaunchWrapView = nil;
//        [self loadNativeLaunchView];
    }
}


- (void)nativeAdDidFinishHandlingClick:(FBNativeAd *)nativeAd{
    LOG(@"%s",__func__);

}


#pragma mark - FBInterstitialAdDelegate

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd {
     LOG(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] postNotificationName:kAdvertiseFacebookInterstitialWillLiveApplicationNotification object:nil];
}


- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd {
    LOG(@"%s",__func__);
    self.interstitialAd = nil;
    self.isCurrentInterstitialShowed = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kAdvertiseFacebookInterstitialDidDismisstNotification object:nil];

}


- (void)interstitialAdWillClose:(FBInterstitialAd *)interstitialAd {
     LOG(@"%s",__func__);
}


- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd {
     LOG(@"%s",__func__);
    self.interstitialAd = interstitialAd;
    self.isInterstitialInLoading = NO;
    if (self.completeInterstitial) {
        self.completeInterstitial(YES, self);
    }
    
    NSNumber *enable = [NSNumber numberWithBool:true];
    [[NSNotificationCenter defaultCenter]postNotificationName:kAdvertiseFacebookInterstitialNotification object:enable];
}


- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error{
     LOG(@"%s",__func__);
    self.isInterstitialInLoading = NO;
    if (self.completeInterstitial) {
        self.completeInterstitial(NO, self);
    }
}


- (void)interstitialAdWillLogImpression:(FBInterstitialAd *)interstitialAd{
     LOG(@"%s",__func__);
    [[NSNotificationCenter defaultCenter] postNotificationName:kAdvertiseFacebookInterstitialWillPresentNotification object:nil];
}

@end
