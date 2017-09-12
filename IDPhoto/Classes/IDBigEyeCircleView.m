//
//  IDBigEyeCircleView.m
//  IDPhoto
//
//  Created by 何少博 on 17/5/3.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDBigEyeCircleView.h"

@implementation IDBigEyeCircleView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.layer.cornerRadius = 8;
        self.layer.masksToBounds = YES;
        self.radius = 10;
    }
    return self;
}

-(void)setRadius:(CGFloat)radius{
    _radius = radius;
    [self setNeedsDisplay];
}

-(void)setCenterPoint:(CGPoint)centerPoint{
    _centerPoint = centerPoint;
    self.center = centerPoint;
    [self setNeedsDisplay];
}

-(void)setIsShowMask:(BOOL)isShowMask{
    _isShowMask = isShowMask;
    if (_isShowMask) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }else{
        self.backgroundColor = [UIColor clearColor];
    }
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
 
    CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
    CGContextSetLineWidth(context, 1);
    CGContextAddArc(context, rect.size.width/2, rect.size.height/2, _radius, 0, M_PI * 2, 0);
    CGContextDrawPath(context, kCGPathStroke);
    
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    CGContextAddArc(context, rect.size.width/2, rect.size.height/2, 1.5, 0, M_PI * 2, 0);
    CGContextDrawPath(context, kCGPathFill);
}


@end
