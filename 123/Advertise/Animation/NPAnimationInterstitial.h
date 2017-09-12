//
//  NPAnimationInterstitial.h
//  Common
//
//  Created by 陈杰 on 16/8/30.
//  Copyright © 2016年 NetPowerApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macros.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface NPAnimationInterstitial : GADInterstitial

- (UIViewController *)internalViewController;


/* Default will use FadeInTransitionAnimation */
- (void)presentFromRootViewController:(UIViewController *)rootViewController;

- (void)presentFromRootViewController:(UIViewController *)rootViewController withAnimationTransitionForPresented:(id<UIViewControllerAnimatedTransitioning>)animationForPresentedController withAnimationTransitionForDismissed:(id<UIViewControllerAnimatedTransitioning>)animationForDismissedController;

@end
