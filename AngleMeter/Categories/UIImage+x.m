//
//  UIImage+x.m
//  UCompress
//
//  Created by mark's rmbp13 on 13-12-12.
//  Copyright (c) 2013年 mayuan. All rights reserved.
//

#import "UIImage+x.h"

@implementation UIImage (x)

+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
