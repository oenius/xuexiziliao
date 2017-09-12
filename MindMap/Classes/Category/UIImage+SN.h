//
//  UIImage+SN.h
//  MindMap
//
//  Created by 何少博 on 2017/8/9.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SN)
-(UIImage *)fit;
-(CGFloat)preQuality;
+(UIImage *)groupIcon:(NSArray *)images;
-(UIImage *)imageToSquare:(CGFloat)square bgColor:(UIColor *)bgColor;
- (UIImage *)imageWithCornerRadius:(CGFloat)radius;
-(UIImage *)getProperResized:(CGFloat) resize;
+(UIImage *)coreBlurImage:(UIImage *)image withBlurNumber:(CGFloat)blur;
@end
