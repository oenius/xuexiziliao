//
//  UIImage+x.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/11.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "UIImage+x.h"

@implementation UIImage (x)
//画圆的方法（使用带颜色的背景作为图片）
+(UIImage*)createCircleImageWithColor:(UIColor*) color andX:(NSInteger)x andY:(NSInteger)y
{
    //CGRect rect=CGRectMake(0.0f, 0.0f, 10.0f, 10.0f);
//    CGFloat scale = [UIScreen mainScreen].scale;
//    x = x*scale;
//    y = y*scale;
    UIGraphicsBeginImageContext(CGSizeMake(x, y));
//    UIGraphicsBeginImageContextWithOptions(CGSizeMake(x, y), NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // CGContextMoveToPoint(context, 0, 0);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextAddArc(context, x/2, y/2, x/2, 0, M_PI*2, 0);
    CGContextFillPath(context);
    //CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end
