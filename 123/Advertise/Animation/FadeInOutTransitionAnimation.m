//
//  FadeInOutTransitionAnimation.m
//  ViewControllerTransitions
//
//  Created by Colin Eberhardt on 09/09/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "FadeInOutTransitionAnimation.h"

@implementation FadeInOutTransitionAnimation

- (id)init {
    if (self = [super init]) {
        _transitionDuration = 0.05f;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toVC.view;
    UIView *fromView = fromVC.view;
    
    [self animateTransition:transitionContext fromVC:fromVC toVC:toVC fromView:fromView toView:toView];
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC fromView:(UIView *)fromView toView:(UIView *)toView {
    // Add the toView to the container
    UIView* containerView = [transitionContext containerView];
    toView.frame = [transitionContext finalFrameForViewController:toVC];
    [containerView addSubview:toView];
    [containerView sendSubviewToBack:toView];
    
    // animate
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        fromView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if ([transitionContext transitionWasCancelled]) {
            fromView.alpha = 1.0;
        } else {
            // reset from- view to its original state
            [fromView removeFromSuperview];
            fromView.alpha = 1.0;
        }
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}


@end
