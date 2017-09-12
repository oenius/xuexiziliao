//
//  RoundZoomInTransitionAnimation.m
//  AnimationDemo2
//
//  Created by hbl on 16/7/31.
//  Copyright © 2016年 hbl. All rights reserved.
//

#import "RoundZoomInTransitionAnimation.h"

@interface RoundZoomInTransitionAnimation()

@property (nonatomic, strong)id transitionContext;

@end

@implementation RoundZoomInTransitionAnimation

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
    //UIButton *btn = fromVc.btn;
    CGFloat mainW = [UIScreen mainScreen].bounds.size.width;
    CGFloat mainH = [UIScreen mainScreen].bounds.size.height;

    UIBezierPath *beginPath = [UIBezierPath bezierPathWithOvalInRect:self.originalFrame];
    [contentView addSubview:fromVc.view];
    //toVc.view.frame = CGRectMake(0, 0, mainW, mainH /2);
    [contentView addSubview:toVc.view];
    
    CGFloat R = sqrt(mainH * mainH + mainW * mainW);
    UIBezierPath *finishPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.originalFrame, -R, -R)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = finishPath.CGPath;
    toVc.view.layer.mask = maskLayer;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.fromValue = (__bridge id _Nullable)(beginPath.CGPath);
    animation.toValue = (__bridge id _Nullable)(finishPath.CGPath);
    animation.duration = [self transitionDuration:transitionContext];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.delegate = self;
    [maskLayer addAnimation:animation forKey:@"aeee"];
    
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
    [self.transitionContext completeTransition:![self.transitionContext transitionWasCancelled]];
    [self.transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view.layer.mask = nil;
    [self.transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view.layer.mask = nil;
}



@end
