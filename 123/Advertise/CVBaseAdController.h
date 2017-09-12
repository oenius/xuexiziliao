//
//  CABaseAdController.h
//  Common
//
//  Created by mayuan on 2017/6/6.
//  Copyright © 2017年 camory. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CVAdvertiseViewController.h"

@class CVBaseAdController;

typedef void (^CompleteWithBannerView)(UIView *bannerWrapView, CVBaseAdController *adController);
typedef void (^CompleteWithNativeSmallView)(UIView *nativeSmallView, CVBaseAdController *adController);
typedef void (^CompleteWithNativeMidView)(UIView *nativeMidView, CVBaseAdController *adController);
typedef void (^CompleteWithNativeLargeView)(UIView *nativeLargeView, CVBaseAdController *adController);
typedef void (^CompleteWithNativeLaunchView)(UIView *nativeLaunchView, CVBaseAdController *adController);
typedef void (^CompleteWithInterstitial)(BOOL isLoaded, CVBaseAdController *adController);


@interface CVBaseAdController : NSObject

// 下一个广告平台，这里采用 责任链模式
@property (nonatomic, strong) CVBaseAdController *nextAdController;


@property(strong, nonatomic) CVAdvertiseViewController *viewController;

@property (nonatomic, copy) CompleteWithBannerView completeBannerView;

@property (nonatomic, copy) CompleteWithNativeSmallView completeNativeSmallView;
@property (nonatomic, copy) CompleteWithNativeMidView completeNativeMidView;
@property (nonatomic, copy) CompleteWithNativeLargeView completeNativeLargeView;

@property (nonatomic, copy) CompleteWithNativeLaunchView completeNativeLaunchView;

@property (nonatomic, copy) CompleteWithInterstitial completeInterstitial;

- (void)preLoadAds;

- (void)removeAllAds;

// 全屏广告 是否加载回来，并且可以显示（已显示中的全屏广告不可以重新present, fb会崩溃）
- (BOOL)isInterstitialCanShow;
//全屏广告 是否加载回来
- (BOOL)isInterstitialLoadedReady;

- (BOOL)isRewardVideoLoadedReady;

- (void)loadBannerViewComplete:(CompleteWithBannerView)complete;

- (void)loadNativeSmallViewComplete:(CompleteWithNativeSmallView)complete;
- (void)loadNativeMidViewComplete:(CompleteWithNativeMidView)complete;
- (void)loadNativeLargeViewComplete:(CompleteWithNativeLargeView)complete;

- (void)loadNativeLaunchViewComplete:(CompleteWithNativeLaunchView)complete;
- (void)clearNativeLaunchView;

- (void)loadInterstitialAdComplete:(CompleteWithInterstitial)complete;

- (void)showInterstitial:(UIViewController *)controller;


@end
