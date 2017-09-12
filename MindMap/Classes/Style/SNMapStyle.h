//
//  SNMapStyle.h
//  MindMap
//
//  Created by 何少博 on 2017/8/23.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIColor+SN.h"

/**
 此类不可直接用，添加新的Style 请继承此类
 */
@interface SNMapStyle : NSObject<NSCoding>

@property (assign, nonatomic) NSInteger depth;

@property (strong, nonatomic) UIImage *openImage;
@property (strong, nonatomic) UIImage *closeImage;
@property (strong, nonatomic) UIImage *KnobImage;
@property (strong, nonatomic) UIColor *lineColor;
@property (strong, nonatomic) UIColor *startColor;
@property (strong, nonatomic) UIColor *endColor;
@property (strong, nonatomic) UIColor *borderColor;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIColor *nodeBgColor;
@property (strong, nonatomic) UIColor *mapBgColor;

-(instancetype)init;

@end
