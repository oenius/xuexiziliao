//
//  SNRect.m
//  MindMap
//
//  Created by 何少博 on 2017/8/9.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNRect.h"

@interface SNRect ()

@property (nonatomic,readwrite,assign)CGRect rect;

@end

@implementation SNRect

-(instancetype)initWithCGRect:(CGRect) rect{
    self = [super init];
    if (self) {
        self.rect = rect;
    }
    return self;
}

+(instancetype)Rect:(CGRect)rect{
    return [[self alloc]initWithCGRect:rect];
}

#pragma mark - setter getter
//---------------------------
-(CGFloat)left{
    return self.rect.origin.x;
}
-(void)setLeft:(CGFloat)left{
    CGRect rect = self.rect;
    rect.origin.x = left;
    self.rect = rect;
}
//---------------------------
-(CGFloat)right{
    return self.rect.origin.x + self.rect.size.width;
}
-(void)setRight:(CGFloat)right{
    CGRect rect = self.rect;
    rect.origin.x = right - rect.size.width;
    self.rect = rect;
}
//---------------------------
-(CGFloat)top{
    return self.rect.origin.y;
}
-(void)setTop:(CGFloat)top{
    CGRect rect = self.rect;
    rect.origin.y = top;
    self.rect = rect;
}
//---------------------------
-(CGFloat)bottom{
    return self.rect.origin.y + self.rect.size.height;
}
-(void)setBottom:(CGFloat)bottom{
    CGRect rect = self.rect;
    rect.origin.y = bottom - rect.size.height;
    self.rect = rect;
}
//---------------------------
-(CGPoint)center{
    return CGPointMake(CGRectGetMidX(self.rect), CGRectGetMidY(self.rect));
}
-(void)setCenter:(CGPoint)center{
    self.rect = CGRectOffset(self.rect, center.x - self.center.x, center.y - self.center.y);
}
//---------------------------
-(CGPoint)leftCenter{
    return CGPointMake(self.rect.origin.x,
                       (CGRectGetMinY(self.rect)+CGRectGetMaxY(self.rect))/2);
}
-(void)setLeftCenter:(CGPoint)leftCenter{
    CGPoint offset = CGPointMake(leftCenter.x - self.leftCenter.x, leftCenter.y - self.leftCenter.y);
    self.rect = CGRectOffset(self.rect, offset.x, offset.y);
}
//---------------------------
-(CGPoint)rightCenter{
    return CGPointMake(self.rect.origin.x + self.rect.size.width,
                       (CGRectGetMinY(self.rect) + CGRectGetMaxY(self.rect))/2);
}
-(void)setRightCenter:(CGPoint)rightCenter{
    CGPoint offset = CGPointMake(rightCenter.x - self.rightCenter.x, rightCenter.y - self.rightCenter.y);
    self.rect = CGRectOffset(self.rect, offset.x, offset.y);
}
//---------------------------
-(CGFloat)centerX{
    return (CGRectGetMinX(self.rect) + CGRectGetMaxX(self.rect))/2;
}
-(void)setCenterX:(CGFloat)centerX{
    self.rect = CGRectOffset(self.rect, centerX - self.centerX, 0);
}
//---------------------------
-(CGFloat)centerY{
    return (CGRectGetMinY(self.rect) + CGRectGetMaxY(self.rect))/2;
}
-(void)setCenterY:(CGFloat)centerY{
    self.rect = CGRectOffset(self.rect, 0, centerY - self.centerY);
}
//---------------------------
-(void)topDelta:(CGFloat)delta{
    self.top = self.top + delta;
}
//---------------------------
-(void)bottomDelta:(CGFloat)delta{
    self.bottom = self.bottom + delta;
}
//---------------------------
-(void)leftDelta:(CGFloat)delta{
    self.left = self.left + delta;
}
//---------------------------
-(void)rightDelta:(CGFloat)delta{
    self.right = self.right + delta;
}
//----------------------------

@end























