//
//  SNPathView.m
//  MindMap
//
//  Created by 何少博 on 2017/8/8.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNPathView.h"
#import "SNPathLayer.h"
@interface SNPathView ()

@property (assign, nonatomic) CGFloat lineWidth;
@property (strong, nonatomic) SNPathLayer * shapeLayer;

@end

static BOOL shouldAnimation = NO;

static NSString *KeyNameStartPoint = @"startPoint";
static NSString *KeyNameMidPoint = @"midPoint";
static NSString *KeyNameEndPoint = @"endPoint";
static NSString *KeyNameStyle = @"style";
static NSString *KeyNameShapeLayer = @"shapeLayer";

@implementation SNPathView


#pragma mark - setter getter

-(SNPathLayer *)shapeLayer{
    if (_shapeLayer == nil) {
        _shapeLayer = [SNPathLayer layer];
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        _shapeLayer.lineCap = kCALineCapRound;
        _shapeLayer.lineJoin = kCALineJoinRound;
    }
    return _shapeLayer;
}

-(void)setStartPoint:(CGPoint)startPoint{
    _startPoint = startPoint;
    [self update];
    [CATransaction begin];
    [CATransaction setDisableActions:!shouldAnimation];
    self.shapeLayer.startPoint = self.startPoint;
    [CATransaction commit];
}

-(void)setMidPoint:(CGPoint)midPoint{
    _midPoint = midPoint;
    [self update];
    [CATransaction begin];
    [CATransaction setDisableActions:!shouldAnimation];
    self.shapeLayer.midPoint = self.midPoint;
    [CATransaction commit];
}

-(void)setEndPoint:(CGPoint)endPoint{
    _endPoint = endPoint;
    [self update];
    [CATransaction begin];
    [CATransaction setDisableActions:!shouldAnimation];
    self.shapeLayer.endPoint = self.endPoint;
    [CATransaction commit];
}

-(void)setStyle:(SNLineStyle)style{
    _style = style;
    [self update];
    
}

-(UIColor *)strokeColor{
    CGColorRef sc = self.shapeLayer.strokeColor;
    if (sc == nil) {
        return [UIColor clearColor];
    }
    return [UIColor colorWithCGColor:sc];
    
}

-(void)setStrokeColor:(UIColor *)strokeColor{
    self.shapeLayer.strokeColor = strokeColor.CGColor;
}

-(CGFloat)lineWidth{
    return self.shapeLayer.lineWidth;
}
-(void)setLineWidth:(CGFloat)lineWidth{
    self.shapeLayer.lineWidth = lineWidth;
}

#pragma mark - init

-(instancetype)init{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self configure];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self update];
}

#pragma mark - methos

-(void)configure{
    self.lineWidth = LINE_WIDTH;
    self.userInteractionEnabled = NO;
    [self.layer addSublayer:self.shapeLayer];
    [self update];
}

-(void)update{
    switch (self.style) {
        case SNLineStyleLine:
            self.shapeLayer.lineDashPattern = nil;
            break;
        case  SNLineStyleDash4:
            self.shapeLayer.lineDashPattern = @[@(12),@(10)];
            break;
        case SNLineStyleDash6:
            self.shapeLayer.lineDashPattern = @[@(6),@(10)];
            break;
        case SNLineStyleDash4_1:
            self.shapeLayer.lineDashPattern = @[@(12),@(10),@(0),@(10)];
            break;
        default:
            break;
    }
    self.frame = CGRectMake(0,
                            0,
                            fabs(self.endPoint.x - self.startPoint.y),
                            fabs(self.endPoint.y - self.startPoint.y));
    
}


#pragma mark - animation

+(void)animateWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations{
    shouldAnimation = YES;
    [CATransaction begin];
    [CATransaction setAnimationDuration:duration];
    CAMediaTimingFunction * func = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [CATransaction setAnimationTimingFunction:func];
    [UIView animateWithDuration:duration animations:animations];
    [CATransaction commit];
    shouldAnimation = NO;
}

#pragma mark - archive

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.startPoint = [aDecoder decodeCGPointForKey:KeyNameStartPoint];
        self.midPoint = [aDecoder decodeCGPointForKey:KeyNameMidPoint];
        self.endPoint = [aDecoder decodeCGPointForKey:KeyNameEndPoint];
        self.style = [aDecoder decodeIntegerForKey:KeyNameStyle];
        self.shapeLayer = [aDecoder decodeObjectForKey:KeyNameShapeLayer];
        [self configure];
    }
    return self;
    
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeCGPoint:self.startPoint forKey:KeyNameStartPoint];
    [aCoder encodeCGPoint:self.midPoint forKey:KeyNameMidPoint];
    [aCoder encodeCGPoint:self.endPoint forKey:KeyNameEndPoint];
    [aCoder encodeInteger:self.style forKey:KeyNameStyle];
    [aCoder encodeObject:self.shapeLayer forKey:KeyNameShapeLayer];
}


@end



























