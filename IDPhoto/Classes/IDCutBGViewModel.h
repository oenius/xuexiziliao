//
//  IDCutBGViewModel.h
//  IDPhoto
//
//  Created by 何少博 on 17/4/27.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IDCutBGViewModel : NSObject

///限制图片大小提高处理效率
-(UIImage *)getProperResizedImage:(UIImage*)original;
///根据mask合成图片
-(UIImage *)masking:(UIImage*)sourceImage mask:(UIImage*) maskImage;
- (UIImage *)masked:(UIImage *)image_ WithMask:(UIImage *)maskImage;

-(UIImage*)resizeImage:(UIImage*)image size:(CGSize)size;

-(CGRect)getTouchedRect:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

-(CGRect)getTouchedRectWithImageSize:(CGSize) size atView:(UIView *)atView andRect:(CGRect)rect;
///获得合适的IamgeView尺寸
-(CGSize)getProperImageViewSize:(CGSize)imageSize maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight;
///获得合适Rect
-(CGRect)covertRect:(CGRect)rect fromView:(UIView*)fromView toView:(UIView *)toView;
///截取VIew某一区域的图
- (UIImage *)imageFromView:(UIView *)view rect:(CGRect)rect;
///检查rect
-(BOOL)isUnderMinimumRect:(CGRect)rect;
///获得maskImage
- (UIImage *)getMaskImageFromImageAlpha:(UIImage *)souceImage;
///根据遮罩获取图片
-(UIImage*)maskimageSourceImage:(UIImage *)sourceImage maskImage:(UIImage *)maskImage;
///除去边缘透明区域
- (UIImage *)trimmedBetterSize:(UIImage *)image;
///合成两张图片
-(UIImage *)drawImage:(UIImage *) drawImage atImage:(UIImage *)sourceImage;
///获取view图片
-(UIImage *)getImageAtView:(UIView *)view;
///合成两张图片
-(UIImage *)drawImage:(UIImage *) drawImage atImage:(UIImage *)sourceImage withRect:(CGRect) rect;
//枪黑色变为透明
- (UIImage*)getNewMaskFrom:(UIImage*)oldMask;
//添加背景颜色
-(UIImage *)image:(UIImage *)orimage addBGColor:(UIColor *)color;
@end
