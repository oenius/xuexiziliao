//
//  ViewAnimation.m
//  MemoryTurnCard
//
//  Created by 何少博 on 16/10/25.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "ViewAnimation.h"
@interface ViewAnimation ()<CAAnimationDelegate>

@property(copy,nonatomic) completion block;

@end
@implementation ViewAnimation

Singleton_M(Instance);

-(void)animationCompletion{
    if (self.block) {
        self.block(YES);
    }
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (self.block) {
        self.block(flag);
    }
}
//@"cube"  @"rippleEffect"
+(void)animatioCube:(UIView *)view duration:(NSTimeInterval)duration completion:(completion)block{
    [ViewAnimation sharedInstance].block = block;
    CATransition * animation = [CATransition animation];
    [animation setDuration:duration];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:@"cube"];
    [animation setFillMode:kCAFillModeForwards];
    [animation setDelegate:[ViewAnimation sharedInstance]];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [view.layer addAnimation:animation forKey:nil];
}
+(void)animationRevealFromRight:(UIView *)view duration:(NSTimeInterval)duration completion:(completion)block{
    [ViewAnimation sharedInstance].block = block;
    CATransition * animation = [CATransition animation];
    [animation setDuration:duration];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromRight];
    [animation setFillMode:kCAFillModeForwards];
    [animation setDelegate:[ViewAnimation sharedInstance]];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [view.layer addAnimation:animation forKey:nil];
}
//+(void)animationRevealFromRight:(UIView *)view duration:(NSTimeInterval)duration completion:(completion)block{
//    [ViewAnimation sharedInstance].block = block;
//    CATransition * animation = [CATransition animation];
//    [animation setDuration:duration];
//    [animation setType:kCATransitionReveal];
//    [animation setSubtype:kCATransitionFromRight];
//    [animation setFillMode:kCAFillModeForwards];
//    [animation setDelegate:[ViewAnimation sharedInstance]];
//    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
//    [view.layer addAnimation:animation forKey:nil];
//}
+(void)animationRevealFromLeft:(UIView *)view duration:(NSTimeInterval)duration completion:(completion)block{
    [ViewAnimation sharedInstance].block = block;
    CATransition * animation = [CATransition animation];
    [animation setDuration:duration];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setFillMode:kCAFillModeForwards];
    [animation setDelegate:[ViewAnimation sharedInstance]];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [view.layer addAnimation:animation forKey:nil];
}
+(void)animationRevealFromTop:(UIView *)view duration:(NSTimeInterval)duration completion:(completion)block{
    [ViewAnimation sharedInstance].block = block;
    CATransition * animation = [CATransition animation];
    [animation setDuration:duration];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromTop];
    [animation setFillMode:kCAFillModeForwards];
    [animation setDelegate:[ViewAnimation sharedInstance]];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [view.layer addAnimation:animation forKey:nil];
}
+(void)animationRevealFromBottom:(UIView *)view duration:(NSTimeInterval)duration completion:(completion)block{
    [ViewAnimation sharedInstance].block = block;
    CATransition * animation = [CATransition animation];
    [animation setDuration:duration];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromBottom];
    [animation setFillMode:kCAFillModeForwards];
    [animation setDelegate:[ViewAnimation sharedInstance]];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [view.layer addAnimation:animation forKey:nil];
}
//渐隐渐消
+(void)animationEaseOut:(UIView *)view duration:(NSTimeInterval)duration completion:(completion)block{
    [ViewAnimation sharedInstance].block = block;
    CATransition * animation = [ CATransition animation];
    [animation setDuration:duration];
    [animation setType:kCATransitionFade];
    [animation setFillMode:kCAFillModeForwards];
    [animation setDelegate:[ViewAnimation sharedInstance]];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [view.layer addAnimation:animation forKey:nil];
}

+(void)animationEaseIn:(UIView *)view duration:(NSTimeInterval)duration completion:(completion)block{
    [ViewAnimation sharedInstance].block = block;
    CATransition * animation = [CATransition animation];
    [animation setDuration:duration];
    [animation setType:kCATransitionFade];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [animation setDelegate:[ViewAnimation sharedInstance]];
    [view.layer addAnimation:animation forKey:nil];
}
//从中心变大
+(void)animationOfScaleBig:(UIView*)view duration:(NSTimeInterval)duration completion:(completion)block
{
    [ViewAnimation sharedInstance].block = block;
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, .01f, .01f);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:[ViewAnimation sharedInstance]];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:duration];
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
    [UIView setAnimationDidStopSelector:@selector(animationCompletion)];
    [UIView commitAnimations];
    //    //创建一个CABasicAnimation对象
    //    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    //    view.layer.anchorPoint = CGPointMake(.5,.5);
    //    animation.fromValue = @0.0f;
    //    animation.toValue = @1.0f;
    //    //动画时间
    //    animation.duration=0.3;
    //    //是否反转变为原来的属性值
    //    // animation.autoreverses=YES;
    //    //把animation添加到图层的layer中，便可以播放动画了。forKey指定要应用此动画的属性
    //    [view.layer addAnimation:animation forKey:@"scale"];
}
//从中心变小
+(void)animationOfScaleSmall:(UIView*)view duration:(NSTimeInterval)duration completion:(completion)block
{
    [ViewAnimation sharedInstance].block = block;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:[ViewAnimation sharedInstance]];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:duration];
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01f, 0.01f);
    [UIView setAnimationDidStopSelector:@selector(animationCompletion)];
    [UIView commitAnimations];
    //    self.view.transform = CGAffineTransformMakeScale(1.0f, 1.0f);//将要显示的view按照正常比例显示出来
    //    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    //    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; //InOut 表示进入和出去时都启动动画
    //    [UIView setAnimationDuration:0.5f];//动画时间
    //    self.view.transform=CGAffineTransformMakeScale(0.01f, 0.01f);//先让要显示的view最小直至消失
    //    [UIView commitAnimations]; //启动动画
    //    //相反如果想要从小到大的显示效果，则将比例调换
    //    //UIGraphicsGetCurrentContext 里面东西很丰富。
}
//翻转动画
+(void)animationFilpFromLeft:(UIView*)view duration:(NSTimeInterval)duration completion:(completion)block{
    [ViewAnimation sharedInstance].block = block;
    [UIView beginAnimations:nil context:NULL ];
    [UIView setAnimationDelegate:[ViewAnimation sharedInstance]];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:view cache:NO];
    [UIView setAnimationDidStopSelector:@selector(animationCompletion)];
    [UIView commitAnimations];
}
+(void)animationFilpFromRight:(UIView*)view duration:(NSTimeInterval)duration completion:(completion)block{
    [ViewAnimation sharedInstance].block = block;
    [UIView beginAnimations:nil context:NULL ];
    [UIView setAnimationDelegate:[ViewAnimation sharedInstance]];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:view cache:NO];
    [UIView setAnimationDidStopSelector:@selector(animationCompletion)];
    [UIView commitAnimations];
}

/*
//+ (UIImage *)imageWithColor:(UIColor *)color
//{
//    CGRect rect = CGRectMake(0.0f, 0.0f, 2.0f, 2.0f);
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextSetFillColorWithColor(context, [color CGColor]);
//    CGContextFillRect(context, rect);
//    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return image;
//}
//- (void)showFireWorksEmitter{
//    CAEmitterLayer *fireworksEmitter = [CAEmitterLayer layer];
//    CGRect viewBounds = self.layer.bounds;
//    fireworksEmitter.emitterPosition = CGPointMake(viewBounds.size.width/2.0, viewBounds.size.height);
//    fireworksEmitter.emitterSize	= CGSizeMake(1, 0.0);
//    fireworksEmitter.emitterMode	= kCAEmitterLayerOutline;
//    fireworksEmitter.emitterShape	= kCAEmitterLayerLine;
//    fireworksEmitter.renderMode		= kCAEmitterLayerAdditive;
//    fireworksEmitter.seed = (arc4random()%100)+1;
//    
//    // Create the rocket
//    CAEmitterCell* rocket = [CAEmitterCell emitterCell];
//    
//    rocket.birthRate		= 5.0;
//    rocket.emissionRange	= 0.25 * M_PI;  // some variation in angle
//    rocket.velocity			= 380;
//    rocket.velocityRange	= 380;
//    rocket.yAcceleration	= 75;
//    rocket.lifetime			= 1.02;	// we cannot set the birthrate < 1.0 for the burst
//    
//    rocket.contents			= (id) [[UIImage imageNamed:@"ball"] CGImage];
//    rocket.scale			= 0.2;
//    //    rocket.color			= [[UIColor colorWithRed:1 green:0 blue:0 alpha:1] CGColor];
//    rocket.greenRange		= 1.0;		// different colors
//    rocket.redRange			= 1.0;
//    rocket.blueRange		= 1.0;
//    
//    rocket.spinRange		= M_PI;		// slow spin
//    
//    
//    
//    // the burst object cannot be seen, but will spawn the sparks
//    // we change the color here, since the sparks inherit its value
//    CAEmitterCell* burst = [CAEmitterCell emitterCell];
//    
//    burst.birthRate			= 1.0;		// at the end of travel
//    burst.velocity			= 0;
//    burst.scale				= 2.5;
//    burst.redSpeed			=-1.5;		// shifting
//    burst.blueSpeed			=+1.5;		// shifting
//    burst.greenSpeed		=+1.0;		// shifting
//    burst.lifetime			= 0.35;
//    
//    // and finally, the sparks
//    CAEmitterCell* spark = [CAEmitterCell emitterCell];
//    
//    spark.birthRate			= 400;
//    spark.velocity			= 125;
//    spark.emissionRange		= 2* M_PI;	// 360 deg
//    spark.yAcceleration		= 75;		// gravity
//    spark.lifetime			= 3;
//    
//    spark.contents			= (id) [[UIImage imageNamed:@"fire"] CGImage];
//    spark.scale		        =0.5;
//    spark.scaleSpeed		=-0.2;
//    spark.greenSpeed		=-0.1;
//    spark.redSpeed			= 0.4;
//    spark.blueSpeed			=-0.1;
//    spark.alphaSpeed		=-0.5;
//    spark.spin				= 2* M_PI;
//    spark.spinRange			= 2* M_PI;
//    
//    // putting it together
//    fireworksEmitter.emitterCells	= [NSArray arrayWithObject:rocket];
//    rocket.emitterCells				= [NSArray arrayWithObject:burst];
//    burst.emitterCells				= [NSArray arrayWithObject:spark];
//    [self.layer addSublayer:fireworksEmitter];
//    
//    //    // Cells spawn in the bottom, moving up
//    //    CAEmitterLayer *fireworksEmitter = [CAEmitterLayer layer];
//    //    CGRect viewBounds = self.layer.bounds;
//    //    fireworksEmitter.emitterPosition = CGPointMake(viewBounds.size.width/2.0, viewBounds.size.height);
//    //    fireworksEmitter.emitterSize	= CGSizeMake(1, 0.0);
//    //    fireworksEmitter.emitterMode	= kCAEmitterLayerOutline;
//    //    fireworksEmitter.emitterShape	= kCAEmitterLayerLine;
//    //    fireworksEmitter.renderMode		= kCAEmitterLayerAdditive;
//    //    //fireworksEmitter.seed = 500;//(arc4random()%100)+300;
//    //
//    //    // Create the rocket
//    //    CAEmitterCell* rocket = [CAEmitterCell emitterCell];
//    //
//    //    rocket.birthRate		= 2.0;
//    //    rocket.emissionRange	= 0.12 * M_PI;  // some variation in angle
//    //    rocket.velocity			= 500;
//    //    rocket.velocityRange	= 150;
//    //    rocket.yAcceleration	= 0;
//    //    rocket.lifetime			= 2.02;	// we cannot set the birthrate < 1.0 for the burst
//    //
//    //    rocket.contents			= (id) [[UIImage imageNamed:@"ball"] CGImage];
//    //    rocket.scale			= 0.2;
//    //    //    rocket.color			= [[UIColor colorWithRed:1 green:0 blue:0 alpha:1] CGColor];
//    //    rocket.greenRange		= 1.0;		// different colors
//    //    rocket.redRange			= 1.0;
//    //    rocket.blueRange		= 1.0;
//    //
//    //    rocket.spinRange		= M_PI;		// slow spin
//    //
//    //
//    //
//    //    // the burst object cannot be seen, but will spawn the sparks
//    //    // we change the color here, since the sparks inherit its value
//    //    CAEmitterCell* burst = [CAEmitterCell emitterCell];
//    //
//    //    burst.birthRate			= 1.0;		// at the end of travel
//    //    burst.velocity			= 0;
//    //    burst.scale				= 2.5;
//    //    burst.redSpeed			=-1.5;		// shifting
//    //    burst.blueSpeed			=+1.5;		// shifting
//    //    burst.greenSpeed		=+1.0;		// shifting
//    //    burst.lifetime			= 0.35;
//    //
//    //    // and finally, the sparks
//    //    CAEmitterCell* spark = [CAEmitterCell emitterCell];
//    //
//    //    spark.birthRate			= 666;
//    //    spark.velocity			= 125;
//    //    spark.emissionRange		= 2* M_PI;	// 360 deg
//    //    spark.yAcceleration		= 75;		// gravity
//    //    spark.lifetime			= 3;
//    //
//    //
//    //    spark.contents			= (id) [[UIImage imageNamed:@"fire"] CGImage];
//    //    spark.scale		        =0.5;
//    //    spark.scaleSpeed		=-0.2;
//    //    spark.greenSpeed		=-0.1;
//    //    spark.redSpeed			= 0.4;
//    //    spark.blueSpeed			=-0.1;
//    //    spark.alphaSpeed		=-0.5;
//    //    spark.spin				= 2* M_PI;
//    //    spark.spinRange			= 2* M_PI;
//    //    
//    //    // putting it together
//    //    fireworksEmitter.emitterCells	= [NSArray arrayWithObject:rocket];
//    //    rocket.emitterCells				= [NSArray arrayWithObject:burst];
//    //    burst.emitterCells				= [NSArray arrayWithObject:spark];
//    //    [self.layer addSublayer:fireworksEmitter];
//}
 */
@end
