//
//  CVAdvertiseController.h
//  CloudPlayer
//
//  Created by Huaming.Zhu on 16/4/19.
//  Copyright © 2016年 __VideoApps___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef void (^BannerViewLoadHandler)(UIView *bannerView);
typedef void (^InterstitialLoadHandler)(BOOL);

typedef void (^NativeExpressViewLoadHandler)(UIView *nativeView);
typedef void (^NativeExpressView250HLoadHandler)(UIView *native250HView);
typedef void (^NativeExpressView132HLoadHandler)(UIView *native132HView);

typedef void (^NativeExpressLaunchViewLoadHandler)(UIView *launchAdView);

typedef void (^NativeExpressHalfScreenViewLoadHandler)(UIView *nativeHalfScreenAdView);

typedef void (^RewardVideoLoadComplete)(BOOL isSuccess, NSError *error);



@interface CVAdvertiseController : NSObject{
    NSTimer *_timer;
    NSInteger _operationNum;
}



@property (assign, nonatomic) NSInteger bannerViewAnimationCount;

@property(copy, nonatomic) BannerViewLoadHandler bannerViewHandler;
@property(copy, nonatomic) InterstitialLoadHandler intHandler;

@property(copy, nonatomic) NativeExpressViewLoadHandler nativeHandler;
@property(copy, nonatomic) NativeExpressView132HLoadHandler native132HHandler;
@property(copy, nonatomic) NativeExpressView250HLoadHandler native250HHandler;

@property(copy, nonatomic) NativeExpressLaunchViewLoadHandler nativeLaunchHandler;

@property(copy, nonatomic) NativeExpressHalfScreenViewLoadHandler nativeHalfScreenHandler;

@property(copy, nonatomic) RewardVideoLoadComplete rewardVideoHandler;

// 原生广告 自定义的半屏广告 是否曾经加载成功
//@property(assign, atomic, readonly) BOOL isCustomHalfScreenAdReady;

//@property(assign, atomic, readonly) BOOL isNativeExpress250HAdViewLoaded;

@property(assign, atomic, readonly) BOOL isRewardVideoLoaded;


+ (CVAdvertiseController *)shareInstance;

- (void)setupAdPlatformsAndConfigPrioritys;


- (void)initAdvertise;
- (void)closeAdvertise;

- (void)achieveBannerView:(BannerViewLoadHandler)handler;
- (void)achieveNativeExpressView:(NativeExpressViewLoadHandler)handler;
- (void)achieveNativeExpress132HView:(NativeExpressView132HLoadHandler)handler;
    // 用于界面植入，不作为半屏广告
- (void)achieveNativeExpress250HView:(NativeExpressView250HLoadHandler)handler;
- (void)achieveNativeLaunchAdView:(NativeExpressLaunchViewLoadHandler)handler;

- (void)achieveNativeCustomHalfScreenView:(NativeExpressHalfScreenViewLoadHandler)handler;

- (void)achieveInterstitial;

//TODO: not imple
- (void)requestRewardVideoAD:(RewardVideoLoadComplete)handler;


//- (id)getNativeAds;
// 全屏广告 是否加载回来，并且可以显示（已显示中的全屏广告不可以重新present, fb会崩溃）
- (BOOL)showInterstitialLoadingState;

// 原生广告 自定义的半屏广告 是否曾经加载成功
- (BOOL)isCustomHalfScreenAdReady;


- (BOOL)isRewardVideoReady;
- (void)loadRewardVideoAd;


- (void)showInterstitial:(UIViewController *)controller;


//- (void)changedShowInterstitialOperationNum;
//
//- (void)showInterstitialOperation:(UIViewController *)controller;
//
//- (void)showInterstitialWithLaunching:(UIViewController *)controller;
//- (void)showInterstitialWithTime:(UIViewController *)controller;

- (void)showRewardVideoFromRootViewController:(UIViewController *)controller;
- (void)requestAndShowRewardVideoFromRootViewController:(UIViewController *)controller;

@end
