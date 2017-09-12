//
//  GifShareController.h
//  LEDBanner
//
//  Created by 何少博 on 16/7/18.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface GifShareController : NSObject

UIImage *getImageWithFullScreenshot(void);
+(NSString*)getImageWithFullViewShot:(UIView *)View;
+(NSURL *)startMakeGifWithImageArray:(NSArray *)imagePathArray andTimeInterval:(NSTimeInterval)time;

@end
