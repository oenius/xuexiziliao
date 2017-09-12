//
//  SNPathLayer.m
//  MindMap
//
//  Created by 何少博 on 2017/8/9.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNPathLayer.h"

@implementation SNPathLayer

-(instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}
-(instancetype)initWithLayer:(id)layer{
    self = [super initWithLayer:layer];
    if (self) {
        
    }
    return self;
}


-(id<CAAction>)actionForKey:(NSString *)event{
    if ([event isEqualToString:@"path"]) {
        CABasicAnimation * ani = [CABasicAnimation animationWithKeyPath:@"path"];
        ani.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        ani.duration = 0.3;
        return ani;
    }
    else{
        return nil;
    }
}

-(void)setEndPoint:(CGPoint)endPoint{
    _endPoint = endPoint;
    [self update];
}

-(void)setMidPoint:(CGPoint)midPoint{
    _midPoint = midPoint;
    [self update];
}

-(void)setStartPoint:(CGPoint)startPoint{
    _startPoint = startPoint;
    [self update];
}

-(void)update{
    UIBezierPath * path = [UIBezierPath bezierPath];
    CGPoint A = self.startPoint;
    CGPoint B = self.midPoint;
    CGFloat handle = (B.x - A.x) * 0.3333;
    if (fabs(handle) < 20.0) {
        handle = handle <= 0 ? -20.0 : 20.0;
    }
    CGPoint C = CGPointMake(A.x + handle, A.y);
    CGPoint D = CGPointMake(B.x - handle, B.y);
    
    [path moveToPoint:A];
    [path addCurveToPoint:B controlPoint1:C controlPoint2:D];
    [path addLineToPoint:self.endPoint];
    self.path = path.CGPath;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
   self = [super initWithCoder:aDecoder];
    if (self) {
        _startPoint = ((NSValue *)[aDecoder decodeObjectForKey:@"startPoint"]).CGPointValue;
        _endPoint = ((NSValue *)[aDecoder decodeObjectForKey:@"endPoint"]).CGPointValue;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.startPoint] forKey:@"startPoint"];
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.endPoint] forKey:@"endPoint"];
    
}

@end
