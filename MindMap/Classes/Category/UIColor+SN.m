//
//  UIColor+SN.m
//  MindMap
//
//  Created by 何少博 on 2017/8/9.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "UIColor+SN.h"

@implementation UIColor (SN)

+(UIColor *)Hex4B5065{
    return [UIColor colorWithRed:75/255.0 green:80/255.0 blue:101/255.0 alpha:1];
}

+(UIColor *)SoftBlueColor{
    return [UIColor colorWithRed: 128.0 / 255.0 green: 116.0 / 255.0 blue: 235.0 / 255.0 alpha: 1.0];
}

+(UIColor *)LightblueColor{
    return [UIColor colorWithRed: 81.0 / 255.0 green: 202.0 / 255.0 blue: 236.0 / 255.0 alpha: 1.0];
}

+(UIColor *)LightMustardColor{
    return [UIColor colorWithRed: 250.0 / 255.0 green: 217.0 / 255.0 blue: 98.0 / 255.0 alpha: 1.0];
}

+(UIColor *)OrangeColor{
    return [UIColor colorWithRed: 246.0 / 255.0 green: 107.0 / 255.0 blue: 27.0 / 255.0 alpha: 1.0];
}

+(UIColor *)ClearBlueColor{
    return [UIColor colorWithRed: 46.0 / 255.0 green: 111.0 / 255.0 blue: 253.0 / 255.0 alpha: 1.0];
}

+(UIColor *)BrightCyanColor{
    return [UIColor colorWithRed: 71.0 / 255.0 green: 204.0 / 255.0 blue: 252.0 / 255.0 alpha: 1.0];
}

+(UIColor *)MossyGreenColor{
    return [UIColor colorWithRed: 85.0 / 255.0 green: 141.0 / 255.0 blue: 38.0 / 255.0 alpha: 1.0];
}

+(UIColor *)LipstickColor{
    return [UIColor colorWithRed: 220.0 / 255.0 green: 32.0 / 255.0 blue: 103.0 / 255.0 alpha: 1.0];
}

+(UIColor *)TangerineColor{
    return [UIColor colorWithRed: 247.0 / 255.0 green: 154.0 / 255.0 blue: 0.0 alpha: 1.0];
}

+(UIColor *)VioletColor{
    return [UIColor colorWithRed: 173.0 / 255.0 green: 36.0 / 255.0 blue: 239.0 / 255.0 alpha: 1.0];
}

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

//默认alpha值为1
+ (UIColor *)colorWithHexString:(NSString *)color
{
    return [self colorWithHexString:color alpha:1.0f];
}


@end
