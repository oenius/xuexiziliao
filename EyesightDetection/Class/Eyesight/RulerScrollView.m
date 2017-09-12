//
//  RulerScrollView.m
//  numberChoose
//
//  Created by 何少博 on 16/9/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "RulerScrollView.h"

@implementation RulerScrollView

- (void)setRulerValue:(CGFloat)rulerValue {
    _rulerValue = rulerValue;
}
-(CGFloat)distanceValue{
    return DISTANCEVALUE;
}
- (void)drawRuler {
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
 
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = 1.f;
    shapeLayer.lineCap = kCALineCapButt;
    self.offsetArray = [NSMutableArray array];
    CGFloat firstOffset = - self.bounds.size.width;
    for (int i = 0; i < self.numberArray.count; i++) {
        UILabel *rule = [[UILabel alloc] init];
        rule.textColor = [UIColor blackColor];
        rule.text = [NSString stringWithFormat:@"%g",[self.numberArray[i] floatValue]];
        rule.font = [UIFont systemFontOfSize:12];
        CGSize textSize = [rule.text sizeWithAttributes:@{ NSFontAttributeName : rule.font }];
        CGPathMoveToPoint(pathRef, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i , DISTANCETOPANDBOTTOM + 8);
        
        [self.offsetArray addObject:[NSNumber numberWithFloat:firstOffset/2+DISTANCELEFTANDRIGHT + DISTANCEVALUE * i]];
        CGPathAddLineToPoint(pathRef, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i, self.rulerHeight - DISTANCETOPANDBOTTOM - textSize.height - 8);
        rule.frame = CGRectMake(DISTANCELEFTANDRIGHT + DISTANCEVALUE * i - textSize.width / 2, self.rulerHeight - DISTANCETOPANDBOTTOM - textSize.height, 0, 0);
        [rule sizeToFit];
        [self addSubview:rule];
    }
    shapeLayer.path = pathRef;
    [self.layer addSublayer:shapeLayer];
//    self.contentOffset = CGPointMake(firstOffset, 0);
    self.contentInset = UIEdgeInsetsMake(0, self.rulerWidth/2, 0, self.rulerWidth/2);
    self.contentSize = CGSizeMake((self.numberArray.count-1)*DISTANCEVALUE, self.rulerHeight);
}


@end
