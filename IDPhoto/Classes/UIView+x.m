//
//  UIView+x.m
//  IDPhoto
//
//  Created by 何少博 on 17/5/2.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "UIView+x.h"

@implementation UIView (x)

-(void)setViewLayoutAnimation{
    [self setViewLayoutAnimationCompletion:nil];
}
-(void)setViewLayoutAnimationCompletion:(void(^)(BOOL finish))completion{
    [UIView animateWithDuration:0.3 animations:^{
       [self layoutIfNeeded];
    } completion:completion];
}
-(void)addGrayShadow{
    self.layer.shadowColor = [UIColor grayColor].CGColor;//阴影颜色
    self.layer.shadowOffset = CGSizeMake(0, 0);//偏移距离
    self.layer.shadowOpacity = 0.8;//不透明度
    self.layer.shadowRadius = 5.0;//半径
//    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//    gradientLayer.colors = @[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor yellowColor].CGColor, (__bridge id)[UIColor blueColor].CGColor];
//    gradientLayer.locations = @[@0.3, @0.5, @1.0];
//    gradientLayer.startPoint = CGPointMake(0, 0);
//    gradientLayer.endPoint = CGPointMake(0, 1);
//    gradientLayer.frame = self.bounds;
//    [self.layer addSublayer:gradientLayer];
}
@end
