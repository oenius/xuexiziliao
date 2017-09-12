//
//  ViewAnimation.h
//  MemoryTurnCard
//
//  Created by 何少博 on 16/10/25.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SingletonHelp.h"

typedef void(^completion)(BOOL finish);

@interface ViewAnimation : NSObject

Singleton_H(Instance);
//cube
+(void)animatioCube:(UIView *)view duration:(NSTimeInterval)duration completion:(completion)block;
//Reveal
+(void)animationRevealFromLeft:(UIView *)view duration:(NSTimeInterval)duration completion:(completion)block;

+(void)animationRevealFromRight:(UIView *)view duration:(NSTimeInterval)duration completion:(completion)block;

+(void)animationRevealFromTop:(UIView *)view duration:(NSTimeInterval)duration completion:(completion)block;

+(void)animationRevealFromBottom:(UIView *)view duration:(NSTimeInterval)duration completion:(completion)block;

//渐隐渐消
+(void)animationEaseIn:(UIView *)view duration:(NSTimeInterval)duration completion:(completion)block;

+(void)animationEaseOut:(UIView *)view duration:(NSTimeInterval)duration completion:(completion)block;

//从中心变大变小
+(void)animationOfScaleSmall:(UIView*)view duration:(NSTimeInterval)duration completion:(completion)block;

+(void)animationOfScaleBig:(UIView*)view duration:(NSTimeInterval)duration completion:(completion)block;
//翻转动画
+(void)animationFilpFromLeft:(UIView*)view duration:(NSTimeInterval)duration completion:(completion)block;

+(void)animationFilpFromRight:(UIView*)view duration:(NSTimeInterval)duration completion:(completion)block;

//- (void)showFireWorksEmitter;

//+ (UIImage *)imageWithColor:(UIColor *)color;

@end
