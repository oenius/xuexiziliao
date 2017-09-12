//
//  SNPathLayer.h
//  MindMap
//
//  Created by 何少博 on 2017/8/9.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface SNPathLayer : CAShapeLayer

@property (assign, nonatomic) CGPoint startPoint;
@property (assign, nonatomic) CGPoint midPoint;
@property (assign, nonatomic) CGPoint endPoint;

@end
