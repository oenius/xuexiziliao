//
//  SNRect.h
//  MindMap
//
//  Created by 何少博 on 2017/8/9.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SNRectAnchorPositionLeft,
    SNRectAnchorPositionRight,
    SNRectAnchorPositionTop,
    SNRectAnchorPositionBottom,
    SNRectAnchorPositionLeftTop,
    SNRectAnchorPositionRightTop,
    SNRectAnchorPositionLeftBottom,
    SNRectAnchorPositionRightBottom,
    SNRectAnchorPositionCenter,
} SNRectAnchorPosition;

@interface SNRect : NSObject

@property (nonatomic,readonly,assign)CGRect rect;

@property (nonatomic,assign) CGFloat left;
@property (nonatomic,assign) CGFloat right;
@property (nonatomic,assign) CGFloat top;
@property (nonatomic,assign) CGFloat bottom;
@property (nonatomic,assign) CGFloat centerX;
@property (nonatomic,assign) CGFloat centerY;

@property (nonatomic,assign) CGPoint center;
@property (nonatomic,assign) CGPoint leftCenter;
@property (nonatomic,assign) CGPoint rightCenter;

-(instancetype)initWithCGRect:(CGRect) rect;
+(instancetype)Rect:(CGRect)rect;


-(void)topDelta:(CGFloat)delta;
-(void)bottomDelta:(CGFloat)delta;
-(void)leftDelta:(CGFloat)delta;
-(void)rightDelta:(CGFloat)delta;


@end
