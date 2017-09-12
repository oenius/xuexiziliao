//
//  NPAnimationInterstitial.m
//  Common
//
//  Created by 陈杰 on 16/8/30.
//  Copyright © 2016年 NetPowerApps. All rights reserved.
//

#import "NPAnimationInterstitial.h"
#import "FadeInOutTransitionAnimation.h"

@interface NPAnimationInterstitial () <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> animationForPresentedController;
@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> animationForDismissedController;

@end

@implementation NPAnimationInterstitial

- (UIViewController *)internalViewController {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    
    if ([self respondsToSelector:@selector(viewController)]) {
        UIViewController *vc = [self performSelector:@selector(viewController)];
        if ([vc isKindOfClass:[UIViewController class]]) {
            return vc;
        }
    }
    
    return nil;
#pragma clang diagnostic pop
}


/* Default will use FadeInTransitionAnimation */
- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    FadeInOutTransitionAnimation *fadeInOutAnimation = [[FadeInOutTransitionAnimation alloc]init];
    
    [self presentFromRootViewController:rootViewController withAnimationTransitionForPresented:fadeInOutAnimation withAnimationTransitionForDismissed:fadeInOutAnimation];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController withAnimationTransitionForPresented:(id<UIViewControllerAnimatedTransitioning>)animationForPresentedController withAnimationTransitionForDismissed:(id<UIViewControllerAnimatedTransitioning>)animationForDismissedController {
    
    self.animationForPresentedController = animationForPresentedController;
    self.animationForDismissedController = animationForDismissedController;
    
    UIViewController *internalViewController = [self internalViewController];
    internalViewController.transitioningDelegate = self;
    
    NSAssert(rootViewController != nil, @"property: rootViewController can not be nil, please set value!");
    
    [super presentFromRootViewController:rootViewController];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return self.animationForPresentedController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return self.animationForDismissedController;
}

@end
