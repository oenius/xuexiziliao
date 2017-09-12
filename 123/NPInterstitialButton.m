//
//  NPInterstitialButton.m
//  Common
//
//  Created by 陈杰 on 16/8/25.
//  Copyright © 2016年 NetPowerApps. All rights reserved.
//

#import "NPInterstitialButton.h"
#import "Macros.h"
#import "NPCommonConfig.h"

@interface NPInterstitialButton ()

@property (nonatomic, readwrite) NPInterstitialButtonType type;
@property (nonatomic, strong) UIColor *textColor;


@end

@implementation NPInterstitialButton

+ (instancetype)buttonWithType:(NPInterstitialButtonType)type viewController:(UIViewController *)viewControllerForPresentingAd {
    NPInterstitialButton *button = [self buttonWithType:UIButtonTypeSystem];
    
    [button configerationWithType:type viewController:viewControllerForPresentingAd textColor:nil];
    
    return button;
}

+ (instancetype)buttonWithType:(NPInterstitialButtonType)type buttonFrame:(CGRect)buttonFrame viewController:(UIViewController *)viewControllerForPresentingAd{
    NPInterstitialButton *button = [self buttonWithType:UIButtonTypeSystem];
    [button configerationWithType:type buttonFrame:buttonFrame viewController:viewControllerForPresentingAd textColor:nil];
    return button;
}


+ (instancetype)buttonWithType:(NPInterstitialButtonType)type viewController:(UIViewController *)viewControllerForPresentingAd textColor:(UIColor *)color{
    NPInterstitialButton *button = [self buttonWithType:UIButtonTypeSystem];
    [button configerationWithType:type viewController:viewControllerForPresentingAd textColor:color];
    return button;
}

+ (instancetype)buttonWithImage:(UIImage *)buttonImage viewController:(UIViewController *)viewControllerForPresentingAd{
    NPInterstitialButton *button = [self buttonWithType:UIButtonTypeCustom];
    [button configerationWithType:NPInterstitialButtonTypePic imageName:buttonImage viewController:viewControllerForPresentingAd];
    return button;
}

+ (instancetype)buttonWithImage:(UIImage *)buttonImage buttonFrame:(CGRect)buttonFrame viewController:(UIViewController *)viewControllerForPresentingAd{
    NPInterstitialButton *button = [self buttonWithType:UIButtonTypeCustom];
//    [button configerationWithType:NPInterstitialButtonTypePic imageName:buttonImage viewController:viewControllerForPresentingAd];
//    button.frame = buttonFrame;
    [button configerationWithType:NPInterstitialButtonTypePic buttonFrame:buttonFrame imageName:buttonImage viewController:viewControllerForPresentingAd];
    return button;
}


- (void)configerationWithType:(NPInterstitialButtonType)type viewController:(UIViewController *)viewControllerForPresentingAd textColor:(UIColor *)color {
    [self configerationWithType:type buttonFrame:CGRectZero viewController:viewControllerForPresentingAd textColor:color];
}

- (void)configerationWithType:(NPInterstitialButtonType)type buttonFrame:(CGRect)buttonFrame viewController:(UIViewController *)viewControllerForPresentingAd textColor:(UIColor *)color {
    if (buttonFrame.size.width == 0 || buttonFrame.size.height == 0) {
        self.frame = CGRectMake(0, 0, 35, 35);
    }else{
        self.frame = buttonFrame;
    }
    self.type = type;
    self.textColor = color;
    self.viewControllerForPresentingAd = viewControllerForPresentingAd;
    self.autoHiddenIfAdNotReady = YES;
    
    [self setTitle:@"Ad" forState:UIControlStateNormal];
    if (color) {
        self.titleLabel.textColor = color;
    }
    if (type == NPInterstitialButtonTypeText) {
        self.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    } else {
        CGFloat frameWidth = self.frame.size.width;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:(frameWidth * 0.4)];
    }
    
    [self addTarget:self action:@selector(showAd) forControlEvents:UIControlEventTouchUpInside];
    
    [self registNotification];
    
    if (self.autoHiddenIfAdNotReady) {
        BOOL isReady = [[NPCommonConfig  shareInstance] isInterstitialAdReady];
        self.hidden = !isReady;
    }
}


- (void)configerationWithType:(NPInterstitialButtonType)type buttonFrame:(CGRect)buttonFrame imageName:(UIImage *)buttonImage viewController:(UIViewController *)viewControllerForPresentingAd {
    if (buttonFrame.size.width == 0 || buttonFrame.size.height == 0) {
        self.frame = CGRectMake(0, 0, 35, 35);
    }else{
        self.frame = buttonFrame;
    }
    
    self.type = type;
    //    self.textColor = color;
    self.viewControllerForPresentingAd = viewControllerForPresentingAd;
    self.autoHiddenIfAdNotReady = YES;
    
    [self setImage:buttonImage forState:UIControlStateNormal];
    
    [self addTarget:self action:@selector(showAd) forControlEvents:UIControlEventTouchUpInside];
    
    [self registNotification];
    
    if (self.autoHiddenIfAdNotReady) {
        BOOL isReady = [[NPCommonConfig  shareInstance] isInterstitialAdReady];
        self.hidden = !isReady;
    }
}

- (void)configerationWithType:(NPInterstitialButtonType)type imageName:(UIImage *)buttonImage viewController:(UIViewController *)viewControllerForPresentingAd {
    [self configerationWithType:type buttonFrame:CGRectZero imageName:buttonImage viewController:viewControllerForPresentingAd];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    if (_type == NPInterstitialButtonTypePic) {
        
    }else{
        if (self.textColor) {
            self.titleLabel.textColor = _textColor;
        }
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        CGFloat width = self.frame.size.width -8;
        self.titleLabel.frame = CGRectMake(0, 0, width, width);
        self.titleLabel.center = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
        if (_type == NPInterstitialButtonTypeIcon) {
            self.titleLabel.layer.borderWidth = [UIScreen mainScreen].scale / 2.0f;
            self.titleLabel.layer.cornerRadius = self.titleLabel.frame.size.height / 2.0;
            self.titleLabel.layer.borderColor = self.titleLabel.textColor.CGColor;
        }
    }
  
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    [super setTitleColor:color forState:state];
    self.titleLabel.layer.borderColor = color.CGColor;
    self.textColor = color;
}

- (void)setTitleShadowColor:(UIColor *)color forState:(UIControlState)state {
    [super setTitleShadowColor:color forState:state];
    self.titleLabel.layer.shadowColor = color.CGColor;
}

#pragma mark - Show Ad
- (void)showAd {
    switch (_showAdType) {
        case NPInterstitialButtonShowADTypeFullScreen:{
            [[NPCommonConfig shareInstance] showInterstitialAdInViewController:_viewControllerForPresentingAd];
        }
            break;
        case NPInterstitialButtonShowADTypeNative250View:
//        {
//            [[NPCommonConfig shareInstance] showNavitveAdAlertViewWithFullScreenAdForController:_viewControllerForPresentingAd];
//        }
//            break;
        case NPInterstitialButtonShowADTypeFullScreenORNative250View:{
//            [[NPCommonConfig shareInstance] showFullScreenAdORNativeAdForController:_viewControllerForPresentingAd];
            [[NPCommonConfig shareInstance] showFullScreenAdWithNativeAdAlertViewForController:_viewControllerForPresentingAd];
        }
            break;
        default:{
//            [[NPCommonConfig shareInstance] showFullScreenAdORNativeAdForController:_viewControllerForPresentingAd];
            [[NPCommonConfig shareInstance] showFullScreenAdWithNativeAdAlertViewForController:_viewControllerForPresentingAd];
        }
            break;
    }
}

#pragma mark - Notification
- (void)registNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onInterstitialAdNotification:) name:keyInterstitialNotification object:nil];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNative250HAdViewNotification:) name:kAdvertiseGoogleNative250HADViewNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRemoveAdNotification:) name:kAdvertiseRemoveAdsNotification object:nil];
}

- (void)unRegistNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isInterstitialLoaded {
    BOOL isReady = [[NPCommonConfig  shareInstance] isInterstitialAdReady];
    return isReady;
}

- (BOOL)isNativeAdLoaded {
    BOOL isNativeLoaded = [[NPCommonConfig shareInstance] isNativeExpress250HAdReady];
    return isNativeLoaded;
}

- (void)onInterstitialAdNotification:(NSNotification *)notification {
//    NSNumber *enableInterstitial = notification.object;
//    if (enableInterstitial.boolValue) {
//        self.hidden = NO;
//        BOOL showAnimation = [NPCommonConfig shareInstance].enableBannerViewAnimation;
//        if (showAnimation) {
//            [self showAdsBtnAnimation:self];
//        }
//    }else{
//        self.hidden = YES;
//    }
    [self reflashButtonState];
}

- (void)onNative250HAdViewNotification:(NSNotification *)notification {
//    if (_showAdType == NPInterstitialButtonShowADTypeFullScreen) {
//        // 仅显示全屏广告
//        return;
//    }
//    NSNumber *enableInterstitial = notification.object;
//    if (enableInterstitial.boolValue) {
//        self.hidden = NO;
//    }else{
//        self.hidden = YES;
//    }
    [self reflashButtonState];
}

- (void)reflashButtonState {
    BOOL shouldShow = NO;
    if (_showAdType == NPInterstitialButtonShowADTypeFullScreen) {
        shouldShow = [self isInterstitialLoaded];
    }else{
        BOOL isInterstitialLoaded = [self isInterstitialLoaded];
        BOOL isNativeAdLoaded = [self isNativeAdLoaded];
        shouldShow =  isInterstitialLoaded || isNativeAdLoaded;
    }
    BOOL shouldShowAdvertise = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (shouldShowAdvertise == NO) {
        shouldShow = NO;
    }
    if (shouldShow) {
        self.hidden = NO;
        BOOL showAnimation = [NPCommonConfig shareInstance].enableBannerViewAnimation;
        if (showAnimation) {
            [self showAdsBtnAnimation:self];
        }
    }else{
        self.hidden = YES;
    }
}


- (void)onRemoveAdNotification:(NSNotification *)notification {
    self.hidden = YES;
}

//按钮点击  缩放弹簧动画
-(void)showAdsBtnAnimation:(UIButton *)button{
    button.transform=CGAffineTransformMakeScale(0.1f, 0.1f);
    [UIView animateWithDuration:1.0f delay:0.0f usingSpringWithDamping:0.3f initialSpringVelocity:10 options:UIViewAnimationOptionCurveLinear animations:^{
        button.transform=CGAffineTransformIdentity ;
    } completion:^(BOOL finished) {
    }];
}


#pragma mark - dealloc
- (void)dealloc {
    [self unRegistNotification];
}

@end
