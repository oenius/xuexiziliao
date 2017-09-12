//
//  CVBaseViewController.h
//  CloudPlayer
//
//  Created by zhouxingfa on 16/4/19.
//  Copyright © 2016年 __VideoApps___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NPInterstitialButton.h"

@interface BaseViewController : UIViewController


@property (strong, nonatomic)  NPInterstitialButton *interstitialButton;


@property(strong, nonatomic, readonly) UIView *bannerView;
@property(strong, nonatomic, readonly) UIView *nativeAdView;
@property(strong, nonatomic, readonly) UIView *native132HAdView;

// Size: iphone (320, 250)  (640, 500)
@property(strong, nonatomic, readonly) UIView *native250HAdView;

// 是否应该显示广告，默认实现，付费版不显示广告，免费版未移除广告 显示广告
- (BOOL)needsShowAdView;


// ///////////////////// Banner Ad View //////////////////////////////
// 对于有些不要显示在视图最低端的，需要特别定义距离底部的偏移，由子类重写，默认返回0
-(float)adViewBottomOffsetFromSuperViewBottom;

//子类可以重写该方法自已选择横幅广告
- (void)achieveBannerView;
/*
 * 扩展baseviewcontroller中广告窗口的定制功能。
 */
//可以改写条状广告的尺寸，例如在ipad上某个界面想添加小尺寸的广告可以改写此方法，目前集成的广告sdk会根据此方法返回的size的宽度决定是用320*50还是768*50的广告条
- (CGSize)sizeOfAdsView;
- (void)setAdViewHiden:(BOOL)hiden;

- (void)setAdEdgeInsets:(UIEdgeInsets)contentInsets;
- (void)adjustAdview;

// 是否加载Banner广告，当该页面需要加载banner广告时，且‘needsShowAdView’返回真时，加载banner广告。
// 默认加载banner广告
- (BOOL)needLoadBannerAdView;

// ///////////////// Native View //////////////////////////
- (void)showNativeAdView:(UIView *)nativeAdView;

// 是否加载原生广告，当该页面需要加载原生广告时，且‘needsShowAdView’返回真时，加载原生广告。
// 默认不加载原生广告
- (BOOL)needLoadNativeAdView;
// 原生广告80H 设置隐藏
- (void)setNativeAdViewHiden:(BOOL)hiden;



// 是否加载原生广告250H，当该页面需要加载原生广告时，且‘needsShowAdView’返回真时，加载原生广告。
// 默认不加载原生广告
- (BOOL)needLoadNative250HAdView;

- (void)showNative250HAdView:(UIView *)nativeAdView;

// 原生广告250H 设置隐藏
- (void)setNative250HAdViewHiden:(BOOL)hiden;

// 是否加载原生广告132H，当该页面需要加载原生广告时，且‘needsShowAdView’返回真时，加载原生广告。
// 默认不加载原生广告
- (BOOL)needLoadNative132HAdView;

- (void)showNative132HAdView:(UIView *)nativeAdView;

// 原生广告132H 设置隐藏
- (void)setNative132HAdViewHiden:(BOOL)hiden;

//// 切换到该界面时，是否显示250原生广告
//- (BOOL)shouldShowNative250ViewForCurrentViewAppear;

// /////////////////// FullScreen View ///////////////////////
- (void)advertiseInterstitialNotification:(NSNotification *)notification;


- (void)removeAdNotification:(NSNotification *)notification;

// 是否需要 全屏广告界面切换计数， 默认YES.
- (BOOL)shouldIncreaseViewAppearCountForShowFullscreenAd;

- (NSString *)screemName;

#pragma mark - 广告动画接口
// 全屏广告按钮动画
-(void)showAdsBtnAnimation:(UIButton *)button;

//左右抖动
-(void)leftRightShakeAnimateForView:(UIView *)view;

//上下抖动
-(void)topBottomShakeAnimateForView:(UIView *)view;

// 放大缩小动画
- (void)scaleAnimationForView:(UIView *)view;

// 旋转震动动画
- (void)rotationShakeAnimationInView:(UIView *)view;

#pragma mark - CASINO  暂不提供使用后

- (void)CASINO_ShowPlanet7_InView:(UIView *)view frame:(CGRect)frame isCenter:(BOOL)isCenter;
- (void)CASINO_ShowRoyalAce_InView:(UIView *)view frame:(CGRect)frame isCenter:(BOOL)isCenter;

- (void)CASINO_Planet7;
- (void)CASINO_RoyalAce;

@end
