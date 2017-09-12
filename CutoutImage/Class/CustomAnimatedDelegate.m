//
//  CustomAnimatedDelegate.m
//  MemoryTurnCard
//
//  Created by 何少博 on 16/10/25.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "CustomAnimatedDelegate.h"
#import "CustomPresentationController.h"
#import "ViewAnimation.h"
@interface CustomAnimatedDelegate ()

@property (nonatomic,assign) BOOL isPresent;

@end

static NSTimeInterval shichang = 0.5f;

@implementation CustomAnimatedDelegate

Singleton_M(Instance);

#pragma mark - UIViewControllerTransitioningDelegate
//返回一个继承UIPresentationController的对象
-(UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source{
    return [[CustomPresentationController alloc]initWithPresentedViewController:presented presentingViewController:presenting];
}
//返回一个遵守UIViewControllerAnimatedTransitioning的对象，这里是self
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    _isPresent = YES;//用于标记是Present还是dismiss
    return self;
}
//返回一个遵守UIViewControllerAnimatedTransitioning的对象，这里是self
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    _isPresent = NO;
    return self;
}
#pragma mark - UIViewControllerAnimatedTransitioning
//动画时长
-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return shichang;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    if (_isPresent) {//present动画
        UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        toView.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            toView.alpha = 1;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];

    }else{//dismiss 动画
        UIView * fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        fromView.alpha = 1;
        [UIView animateWithDuration:0.5 animations:^{
            fromView.alpha = 0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];

    }
}

@end
