//
//  GifCreate.m
//  GifMaker
//
//  Created by 石钊 on 16/6/16.
//  Copyright © 2016年 camory. All rights reserved.
//

#import "GifCreate.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface GifCreate ()

@end



@implementation GifCreate


//制作动态图并存储到沙盒library中
+ (NSURL *) makeAnimatedGif:(NSArray *)tabImage Controller:(UIViewController *)vc Time:(CGFloat)time
{
    
    
    NSUInteger kFrameCount = [tabImage count];
    NSDictionary *fileProperties = @{
                                     (__bridge id)kCGImagePropertyGIFDictionary: @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount: @0, // 0 means loop forever
                                             }
                                     };
    NSDictionary *frameProperties = @{
                                      (__bridge id)kCGImagePropertyGIFDictionary: @{
                                              (__bridge id)kCGImagePropertyGIFDelayTime: @(time), //时间参数
                                              }
                                      };
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    //沙盒中library的路径
    NSURL *libraryDirectoryURL = [fileManager URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSURL *createPath=[libraryDirectoryURL URLByAppendingPathComponent:@"GifFile"];
    NSString *libStr=[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath=[libStr stringByAppendingPathComponent:@"/GifFile"];
    
    // 判断文件夹是否存在，如果不存在，则创建
    if (![fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        [fileManager createDirectoryAtURL:createPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(error)
        {
            LOG(@"%@",error);
        }
    } else {
        LOG(@"FileDir is existed.");
    }
    //获取当前时间作为GIF文件的名字
    NSDate *date=[NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeInterval=[date timeIntervalSince1970];
    NSString *strTime=[NSString stringWithFormat:@"%.0f",timeInterval];
    NSString *gifName=[NSString stringWithFormat:@"%@.gif",strTime];
    
    NSURL *fileURL = [createPath URLByAppendingPathComponent:gifName];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF, kFrameCount, NULL);
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    
    for (NSUInteger i = 0; i < kFrameCount; i++) {
        @autoreleasepool {
            //循环将数组中的照片与destination建立关系
            CGImageDestinationAddImage(destination, ((UIImage *)[tabImage objectAtIndex:i]).CGImage, (__bridge CFDictionaryRef)frameProperties);
        }
    }

    if (!CGImageDestinationFinalize(destination)) {
        LOG(@"failed to finalize image destination");
    }
    CFRelease(destination);
    return fileURL;
}

//创建一个文件夹，放用户打算分享但不存储到应用中的GIF图
+ (NSURL *) makeTempAnimatedGif:(NSArray *)tabImage Controller:(UIViewController *)vc Time:(CGFloat)time
{
    
    NSUInteger kFrameCount = [tabImage count];
    
    NSDictionary *fileProperties = @{
                                     (__bridge id)kCGImagePropertyGIFDictionary: @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount: @0, // 0 means loop forever
                                             }
                                     };
    
    NSDictionary *frameProperties = @{
                                      (__bridge id)kCGImagePropertyGIFDictionary: @{
                                              (__bridge id)kCGImagePropertyGIFDelayTime: @(time), //时间参数
                                              }
                                      };
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    //沙盒中library的路径
    NSURL *libraryDirectoryURL = [fileManager URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    
    NSURL *createPath=[libraryDirectoryURL URLByAppendingPathComponent:@"GifTempFile"];
        
    NSString *createStr=[NSString stringWithFormat:@"%@",createPath];
    // 判断文件夹是否存在，如果不存在，则创建
    if (![fileManager fileExistsAtPath:createStr]) {
        NSError *error;
        [fileManager createDirectoryAtURL:createPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        if(error)
        {
            LOG(@"%@",error);
        }
        
    } else {
        LOG(@"FileDir is existed.");
    }
    
    //临时文件的名字
    NSURL *fileURL = [createPath URLByAppendingPathComponent:@"temp.gif"];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF, kFrameCount, NULL);
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    for (NSUInteger i = 0; i < kFrameCount; i++) {
        @autoreleasepool {
            
            //循环将数组中的照片与destination建立关系
            CGImageDestinationAddImage(destination, ((UIImage *)[tabImage objectAtIndex:i]).CGImage, (__bridge CFDictionaryRef)frameProperties);
        }
    }
    
    if (!CGImageDestinationFinalize(destination)) {
        LOG(@"failed to finalize image destination");
    }
    CFRelease(destination);
    return fileURL;
}

@end
