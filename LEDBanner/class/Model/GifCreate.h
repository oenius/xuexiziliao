//
//  GifCreate.h
//  GifMaker
//
//  Created by 石钊 on 16/6/16.
//  Copyright © 2016年 camory. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface GifCreate : NSObject

+ (NSURL *) makeAnimatedGif:(NSArray *)tabImage Controller:(UIViewController *)vc Time:(CGFloat)time;
+ (NSURL *) makeTempAnimatedGif:(NSArray *)tabImage Controller:(UIViewController *)vc Time:(CGFloat)time;

@end
