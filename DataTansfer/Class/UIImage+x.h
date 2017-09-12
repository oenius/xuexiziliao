//
//  UIImage+x.h
//  UCompress
//
//  Created by mark's rmbp13 on 13-12-12.
//  Copyright (c) 2013年 mayuan. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface UIImage (x)

- (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;

-(UIImage *)resizeImageMaxWidth:(CGFloat)maxW maxHeight:(CGFloat)maxH;

-(UIImage *)scaleImageAspectFitSize:(CGSize)size;

-(UIImage *)scaleImageToSize:(CGSize)size;

/** 生成一张普通的二维码 */
+ (UIImage *)generateWithDefaultQRCodeData:(NSString *)data imageViewWidth:(CGFloat)imageViewWidth;
/** 生成一张带有logo的二维码（logoScaleToSuperView：相对于父视图的缩放比取值范围0-1；0，不显示，1，代表与父视图大小相同） */
+ (UIImage *)generateWithLogoQRCodeData:(NSString *)data logoImageName:(NSString *)logoImageName logoScaleToSuperView:(CGFloat)logoScaleToSuperView;
/** 生成一张彩色的二维码 */
+ (UIImage *)generateWithColorQRCodeData:(NSString *)data backgroundColor:(CIColor *)backgroundColor mainColor:(CIColor *)mainColor;

+ (UIImage*)createBarCodeWithString:(NSString*)text QRSize:(CGSize)size;
+ (UIImage*)createQRWithString:(NSString*)text QRSize:(CGSize)size QRColor:(UIColor*)qrColor bkColor:(UIColor*)bkColor;
+ (UIImage*)createQRWithString:(NSString*)text QRSize:(CGSize)size;


@end
