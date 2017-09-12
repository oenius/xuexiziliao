//
//  GifShareController.m
//  LEDBanner
//
//  Created by 何少博 on 16/7/18.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "GifShareController.h"
#import "GifCreate.h"
@interface GifShareController ()

@end
@implementation GifShareController

-(instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}
+(NSURL *)startMakeGifWithImageArray:(NSArray *)imagePathArray andTimeInterval:(NSTimeInterval)time{
    NSMutableArray * imageArray = [NSMutableArray array];
    NSArray * tempPathArray = [NSArray arrayWithArray:imagePathArray];
    for (NSString * path in tempPathArray) {
        UIImage * image =[UIImage imageWithContentsOfFile:path];
        if (image!=nil) {
            [imageArray addObject:image];
        }
    }
    
    NSURL *GIFURL = [GifCreate makeAnimatedGif:imageArray Controller:nil Time:time];
    //删除截图
    NSFileManager * fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:GIF_directory error:nil];
    return GIFURL;
}


//制定View截图
+(NSString*)getImageWithFullViewShot:(UIView *)View{

    UIGraphicsBeginImageContextWithOptions(View.frame.size, NO, 0.0);
    //获取图像
    [View.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //压缩图片
    UIImage * newImage = [GifShareController imageCompressForWidth:image targetWidth:200];
    //保存图像
    //获取当前时间作为截图文件的名字
    NSDate *date=[NSDate date];
    
    NSDateFormatter*df2 = [[NSDateFormatter alloc]init];//格式化
    [df2 setDateFormat:@"yyyyMMddHHmmssSSSS"];
    NSString *strTime=[df2 stringFromDate:date];
    NSString *imageName=[NSString stringWithFormat:@"%@.png",strTime];
    
    NSFileManager * fm = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:GIF_directory withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *path = [GIF_directory stringByAppendingFormat:@"/%@",imageName];
    NSData * data = UIImagePNGRepresentation(newImage);
    NSError * error ;
    if ( [data writeToFile:path atomically:YES]) {

        LOG(@"Succeeded! %@",path);
    }
    else {
        LOG(@"Failed!%@",error);
    }
    return path;
}
//全屏截图
UIImage *getImageWithFullScreenshot(void)
{
    BOOL ignoreOrientation ; //SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0");
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    CGSize imageSize = CGSizeZero;
    if (UIInterfaceOrientationIsPortrait(orientation) || ignoreOrientation)
        imageSize = [UIScreen mainScreen].bounds.size;
    else
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        
        // Correct for the screen orientation
        if(!ignoreOrientation)
        {
            if(orientation == UIInterfaceOrientationLandscapeLeft)
            {
                CGContextRotateCTM(context, (CGFloat)M_PI_2);
                CGContextTranslateCTM(context, 0, -imageSize.width);
            }
            else if(orientation == UIInterfaceOrientationLandscapeRight)
            {
                CGContextRotateCTM(context, (CGFloat)-M_PI_2);
                CGContextTranslateCTM(context, -imageSize.height, 0);
            }
            else if(orientation == UIInterfaceOrientationPortraitUpsideDown)
            {
                CGContextRotateCTM(context, (CGFloat)M_PI);
                CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
            }
        }
        if([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:NO];
        else
            [window.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}
//压缩图片
+(UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        LOG(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}
-(void)dealloc{
     LOG(@"%s", __func__);
    
}
@end
