//
//  UIColor+SN.h
//  MindMap
//
//  Created by 何少博 on 2017/8/9.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (SN)

+ (UIColor *)colorWithHexString:(NSString *)color;
///color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

+(UIColor *)Hex4B5065;

+(UIColor *)SoftBlueColor;

+(UIColor *)LightblueColor;

+(UIColor *)LightMustardColor;

+(UIColor *)OrangeColor;

+(UIColor *)ClearBlueColor;

+(UIColor *)BrightCyanColor;

+(UIColor *)MossyGreenColor;

+(UIColor *)LipstickColor;

+(UIColor *)TangerineColor;

+(UIColor *)VioletColor;
@end
