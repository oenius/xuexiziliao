//
//  HSPresentAnimaion.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/26.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "HSPresentAnimaion.h"

@interface HSPresentAnimaion ()

@property (nonatomic,assign) BOOL isPresent;

@end

static NSTimeInterval duration = 0.3f;

@implementation HSPresentAnimaion

+ (instancetype)shareInstance {
    static dispatch_once_t predicate;
    static HSPresentAnimaion *instance = nil;
    dispatch_once(&predicate, ^{
        instance = [[HSPresentAnimaion alloc] init];
    });
    return instance;
}

#pragma mark - UIViewControllerTransitioningDelegate
//返回一个继承UIPresentationController的对象
-(UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source{
    return [[HSPresentController alloc]initWithPresentedViewController:presented presentingViewController:presenting];
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
    return duration;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    if (_isPresent) {//present动画
        UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
        toView.alpha = 0;
        [UIView animateWithDuration:duration animations:^{
            toView.alpha = 1;
        } completion:^(BOOL finished) {
            //完成动画之后要设置为YES,不设置可能会出现未知错误
           [transitionContext completeTransition:YES];
        }];
        
        
    }else{//dismiss 动画
        UIView * fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        [UIView animateWithDuration:duration animations:^{
            fromView.alpha = 0;
        } completion:^(BOOL finished) {
           
            //完成动画之后要设置为YES,不设置可能会出现未知错误
            [transitionContext completeTransition:YES];
        }];
    }
}
@end

@interface HSPresentController ()
//过渡的view
@property (nonatomic, strong) UIView *guoDuView;

@end

@implementation HSPresentController

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
