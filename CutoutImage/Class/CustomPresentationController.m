//
//  CustomPresentationController.m
//  MemoryTurnCard
//
//  Created by 何少博 on 16/10/25.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "CustomPresentationController.h"

@interface CustomPresentationController ()
//过渡的view
@property (nonatomic, strong) UIView *guoDuView;

@end

@implementation CustomPresentationController

- (void)presentationTransitionWillBegin{
    self.guoDuView = [[UIView alloc]init];
    _guoDuView.frame = self.containerView.bounds;
    _guoDuView.alpha = .0f;
//    _guoDuView addSubview:[]
    [self.containerView addSubview:_guoDuView];
    self.presentedView.frame = self.containerView.bounds;
    [self.containerView addSubview:self.presentedView];
    // 与过渡效果一起执行背景 View 的淡入效果
    [[self.presentedViewController transitionCoordinator] animateAlongsideTransitionInView:_guoDuView animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        _guoDuView.alpha = 1.0f;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}
- (void)presentationTransitionDidEnd:(BOOL)completed{
    if (!completed) {
        [_guoDuView removeFromSuperview];
    }
}
- (void)dismissalTransitionWillBegin{
    // 与过渡效果一起执行背景 View 的淡入效果
    [[self.presentingViewController transitionCoordinator] animateAlongsideTransitionInView:_guoDuView animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        _guoDuView.alpha = 0.0;
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}
- (void)dismissalTransitionDidEnd:(BOOL)completed{
    if (completed) {
        [self.presentedView removeFromSuperview];
        [_guoDuView removeFromSuperview];
    }
}
@end
