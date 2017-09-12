//
//  UIImage+st.m
//  PDFReader
//
//  Created by 何少博 on 17/3/29.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "UIImage+st.h"

@implementation UIImage (st)

- (UIImage *)imageWithColor:(UIColor *)color{
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



@end
