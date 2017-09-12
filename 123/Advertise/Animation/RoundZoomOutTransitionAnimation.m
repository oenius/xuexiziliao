//
//  RoundZoomOutTransitionAnimation.m
//  AnimationDemo2
//
//  Created by hbl on 16/7/31.
//  Copyright © 2016年 hbl. All rights reserved.
//

#import "RoundZoomOutTransitionAnimation.h"

@interface RoundZoomOutTransitionAnimation()

@property (nonatomic, strong)id transitionContext;

@end

@implementation RoundZoomOutTransitionAnimation

- (instancetype)init {
    self = [super init];
    if (self) {
        _transitionDuration = 0.25f;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return self.transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    self.transitionContext = transitionContext;
    UIViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *contentView = [transitionContext containerView];
   
    UIBezierPath *beginPath = [UIBezierPath bezierPathWithOvalInRect:self.targetFrame];
    
    [contentView addSubview:toVc.view];
    [contentView addSubview:fromVc.view];
    
    CGFloat mainW = [UIScreen mainScreen].bounds.size.width;
    CGFloat mainH = [UIScreen mainScreen].bounds.size.height;
    CGFloat R = sqrt(mainH * mainH + mainW * mainW);
    UIBezierPath *finishPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.targetFrame, -R, -R)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = finishPath.CGPath;
    fromVc.view.layer.mask = maskLayer;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.fromValue = (__bridge id _Nullable)(finishPath.CGPath);
    animation.toValue = (__bridge id _Nullable)(beginPath.CGPath);
    animation.duration = [self transitionDuration:transitionContext];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.delegate = self;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [maskLayer addAnimation:animation forKey:@"aeee"];

}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
    
    [self.transitionContext completeTransition:![self.transitionContext transitionWasCancelled]];
    [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
    [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.layer.mask = nil;
}

@end
