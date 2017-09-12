//
//  RoundZoomInTransitionAnimation.h
//  AnimationDemo2
//
//  Created by hbl on 16/7/31.
//  Copyright © 2016年 hbl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoundZoomInTransitionAnimation : NSObject <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic)CGRect originalFrame;
@property (assign, nonatomic) NSTimeInterval transitionDuration;

@end
