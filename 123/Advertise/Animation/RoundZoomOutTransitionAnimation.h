//
//  RoundZoomOutTransitionAnimation.h
//  AnimationDemo2
//
//  Created by hbl on 16/7/31.
//  Copyright © 2016年 hbl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoundZoomOutTransitionAnimation : NSObject <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic) CGRect targetFrame;
@property (assign, nonatomic) NSTimeInterval transitionDuration;

@end
