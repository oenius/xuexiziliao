//
//  UIImage+x.h
//  UCompress
//
//  Created by mark's rmbp13 on 13-12-12.
//  Copyright (c) 2013年 mayuan. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface UIImage (x)

-(UIImage *)imageToScale:(float)scaleSize;

-(UIImage *)resizeImageMaxWidth:(CGFloat)maxW maxHeight:(CGFloat)maxH;

-(UIImage *)scaleImageAspectFitSize:(CGSize)size;

-(UIImage *)scaleImageToSize:(CGSize)size;

- (UIImage *)trimmedBetterSize;

+(UIImage *)getGradientImageWithSize:(CGSize)size
                          startColor:(UIColor *)startColor
                            endColor:(UIColor *)endColor;
+ (UIImage *)jk_imageWithColor:(UIColor *)color;
- (UIImage *)imageClipRect:(CGRect)rect;
- (UIImage *)jk_resizedImage:(CGSize)newSize
        interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)jk_resizedImageWithContentMode:(UIViewContentMode)contentMode
                                     bounds:(CGSize)bounds
                       interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)jk_imageWithAlpha;
- (BOOL)jk_hasAlpha;
@end
