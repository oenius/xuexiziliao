//
//  NPInterstitialButton.h
//  Common
//
//  Created by 陈杰 on 16/8/25.
//  Copyright © 2016年 NetPowerApps. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NPInterstitialButtonType) {
    NPInterstitialButtonTypeText, //显示Ad文本
    NPInterstitialButtonTypeIcon, //显示Ad图标
    NPInterstitialButtonTypePic,
    NPInterstitialButtonTypeDefault = NPInterstitialButtonTypeIcon
};

typedef NS_ENUM(NSInteger, NPInterstitialButtonShowADType) {
    NPInterstitialButtonShowADTypeFullScreenORNative250View,  // 全屏广告 native250H 交替显示
    NPInterstitialButtonShowADTypeFullScreen, // 仅显示全屏广告
    NPInterstitialButtonShowADTypeNative250View, //显示 native 250H，以全屏广告作为替补
    NPInterstitialButtonShowADTypeDefault = NPInterstitialButtonShowADTypeFullScreenORNative250View
};



@interface NPInterstitialButton : UIButton

@property (nonatomic, assign) NPInterstitialButtonShowADType showAdType;

@property (nonatomic, readonly) NPInterstitialButtonType type;

@property (nonatomic, assign) BOOL autoHiddenIfAdNotReady;

@property (nonatomic, weak) UIViewController *viewControllerForPresentingAd;

// 不设置color 默认使用tinColor
+ (instancetype)buttonWithType:(NPInterstitialButtonType)type viewController:(UIViewController *)viewControllerForPresentingAd;

// 不设置color 默认使用tinColor
+ (instancetype)buttonWithType:(NPInterstitialButtonType)type buttonFrame:(CGRect)buttonFrame viewController:(UIViewController *)viewControllerForPresentingAd;

+ (instancetype)buttonWithImage:(UIImage *)buttonImage viewController:(UIViewController *)viewControllerForPresentingAd;

+ (instancetype)buttonWithImage:(UIImage *)buttonImage buttonFrame:(CGRect)buttonFrame viewController:(UIViewController *)viewControllerForPresentingAd;

@end
