//
//  NPNativeAdView.m
//  Common
//
//  Created by mayuan on 16/10/24.
//  Copyright © 2016年 camory. All rights reserved.
//

#import "NPNativeAdView.h"
#import "CVAdvertiseController.h"
#import "NPCommonConfig.h"

@interface NPNativeAdView ()


@property (strong, nonatomic) UIView *nativeAdView;
@property (strong, nonatomic) UIButton *closeButton;
@property (assign, nonatomic) CGSize nativeAdViewSize;

@property (nonatomic, assign) NPNativeAdViewCloseType closeType;

@end

static BOOL hasDisableCloseButton = NO;

@implementation NPNativeAdView


- (void)dealloc
{
     NSLog(@"%s",__func__);
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
//        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onBackgroundViewTouched)];
//        doubleTapGesture.numberOfTapsRequired = 3;
//        doubleTapGesture.numberOfTouchesRequired = 1;
//        [self addGestureRecognizer:doubleTapGesture];
        
        _closeType = [NPCommonConfig shareInstance].nativeAdViewCloseType;
    }
    return self;
}

- (void)loadAndShowNativeViewInView:(UIView *)superView {
#ifndef ISPRO
    BOOL shouldShowAd = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (NO == shouldShowAd) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[CVAdvertiseController shareInstance] achieveNativeCustomHalfScreenView:^(UIView *native250HView) {
        if(native250HView == nil){
            return ;
        }
        CGSize nativeAdViewSize = native250HView.frame.size;
        native250HView.frame = CGRectMake(0, 0, nativeAdViewSize.width, nativeAdViewSize.height);
        native250HView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        //        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        //        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        weakSelf.nativeAdViewSize = nativeAdViewSize;
        native250HView.center = CGPointMake(weakSelf.frame.size.width/2, weakSelf.frame.size.height/2);
        
        if (weakSelf.nativeAdView) {
            [weakSelf.nativeAdView removeFromSuperview];
            [weakSelf addSubview:native250HView];
            [weakSelf bringSubviewToFront:_closeButton];
        }else{
            [weakSelf addSubview:native250HView];
            
            UIImage *removeAdImage = [weakSelf closeButtonImage];
            
            UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [closeButton setImage:removeAdImage forState:UIControlStateNormal];
            [closeButton addTarget:self action:@selector(onCloseButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
            weakSelf.closeButton = closeButton;
            
            CGFloat buttonWith = [weakSelf closeButtonWidth];
            closeButton.userInteractionEnabled = [weakSelf userInteractionEnabledForCloseButton];
            closeButton.frame = [weakSelf closeButtonFrameFromNativeAdSize:nativeAdViewSize buttonWith:buttonWith];
            
            [weakSelf addSubview:closeButton];
            
            if (!superView) {
                UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
                [keyWindow addSubview:weakSelf];
            }else{
                [superView addSubview:weakSelf];
            }
            weakSelf.layer.opacity = 0.5f;
            //            weakSelf.layer.transform = CATransform3DMakeScale(1.2f, 1.2f, 1.0);
            weakSelf.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
            [UIView animateWithDuration:0.15f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 weakSelf.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9f];
                                 weakSelf.layer.opacity = 1.0f;
                                 //                                 weakSelf.layer.transform = CATransform3DMakeScale(1, 1, 1);
                             }
                             completion:NULL
             ];
        }
        
        weakSelf.nativeAdView = native250HView;
    }];

#endif
}

- (UIImage *)closeButtonImage{
    UIImage *closeImage;
    switch (_closeType) {
        case NPNativeAdViewCloseTypeCoverAdLeftTop:{
            closeImage = [UIImage imageNamed:@"npcommon_ad_close"];
        }
            break;
        case NPNativeAdViewCloseTypeNotCoverAdLeftTop:{
            closeImage = [UIImage imageNamed:@"npcommon_ad_close2"];
        }
            break;
        case NPNativeAdViewCloseTypeNotCoverAd:{
            closeImage = [UIImage imageNamed:@"npcommon_ad_close2"];
        }
            break;
        case NPNativeAdViewCloseTypeWithBottomRmoveAds:{
            closeImage = [UIImage imageNamed:@"npcommon_ad_close2"];
        }
            break;
        default:
            closeImage = [UIImage imageNamed:@"npcommon_ad_close"];
            break;
    }
    return closeImage;
}

- (CGFloat)closeButtonWidth {
    return 20;
}

- (BOOL)userInteractionEnabledForCloseButton {
    BOOL userEnable = YES;
    switch (_closeType) {
        case NPNativeAdViewCloseTypeCoverAdLeftTop:{
            userEnable = YES;
        }
            break;
//        case NPNativeAdViewCloseTypeCoverAdLeftTopRandomCannotTouched:{
//            BOOL isSafe = NO;
//            NSUInteger days = [[NPCommonConfig shareInstance] appUseDaysCount];
//            if (days > 0) {
//                isSafe = YES;
//            }
//            if ((YES == isSafe) && (NO == hasDisableCloseButton)) {
//               userEnable = NO;
//                hasDisableCloseButton = YES;
//            }else{
//                userEnable = YES;
//            }
//        }
//            break;
        case NPNativeAdViewCloseTypeNotCoverAd:{
            userEnable = YES;
        }
            break;
        default:
            userEnable = YES;
            break;
    }
    return userEnable;
}

- (CGRect)closeButtonFrameFromNativeAdSize:(CGSize)nativeAdViewSize buttonWith:(CGFloat)buttonWith {
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGRect closeButtonFrame = CGRectMake((screenWidth - nativeAdViewSize.width)/2.0 + 6, (screenHeight- nativeAdViewSize.height)/2.0 + 18, buttonWith, buttonWith);
    switch (_closeType) {
        case NPNativeAdViewCloseTypeCoverAdLeftTop:{
        }
            break;
        case NPNativeAdViewCloseTypeNotCoverAdLeftTop:{
            CGFloat frameX = buttonWith;
            CGFloat frameY = buttonWith;
            closeButtonFrame = CGRectMake(frameX, frameY, buttonWith, buttonWith);
        }
            break;
        case NPNativeAdViewCloseTypeNotCoverAd:{
            CGFloat frameX = (screenWidth - buttonWith)/2.0;
            CGFloat frameY = (screenHeight - nativeAdViewSize.height)/2.0 + nativeAdViewSize.height + 10;
            closeButtonFrame = CGRectMake(frameX, frameY, buttonWith, buttonWith);
        }
            break;
        default:
            break;
    }
    return closeButtonFrame;
}

// Handle device orientation changes
- (void)deviceOrientationDidChange: (NSNotification *)notification{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat buttonWith = [self closeButtonWidth];
    CGRect closeButtonFrame = [self closeButtonFrameFromNativeAdSize:_nativeAdViewSize buttonWith:buttonWith];
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.frame = CGRectMake(0, 0, screenWidth, screenHeight);
                         self.nativeAdView.center = CGPointMake(screenWidth/2, screenHeight/2);
                         self.closeButton.frame = closeButtonFrame;
                     }
                     completion:nil
     ];
}


- (void)onCloseButtonTouched:(id)sender {
    [self removeFromSuperview];
}


- (void)onBackgroundViewTouched{
    [self removeFromSuperview];
}

- (void)onAppDidBecomeActiveNotification:(NSNotification *)notification {
    [self removeFromSuperview];

}


@end
