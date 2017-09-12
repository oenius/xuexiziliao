//
//  LCLightModelArray.h
//  LightCamera
//
//  Created by 何少博 on 16/12/15.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kShutter   @"shutterKey"

@interface LCLightModelArray : NSObject

+(NSArray *)lightModelArrayFrontCamera:(BOOL)isFront;

@end
