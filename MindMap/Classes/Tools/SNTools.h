//
//  SNTools.h
//  MindMap
//
//  Created by 何少博 on 2017/8/7.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString * const kAssetSuffix;
FOUNDATION_EXTERN NSString * const kMapSuffix;


@interface SNTools : NSObject

+(void)showADRandom:(NSInteger) random forController:(UIViewController *)controller;
//获取document路径
+(NSString *)documentPath;



@end
