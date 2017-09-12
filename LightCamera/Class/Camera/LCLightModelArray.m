//
//  LCLightModelArray.m
//  LightCamera
//
//  Created by 何少博 on 16/12/15.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "LCLightModelArray.h"

@implementation LCLightModelArray

+(NSArray *)lightModelArrayFrontCamera:(BOOL)isFront{
    
    NSMutableArray * array = [NSMutableArray array];
    
    //调整ISO
    if (isFront) {
        [array addObject:[NSNumber numberWithFloat:0.0]];
        
        [array addObject:[NSNumber numberWithFloat:0.73]];
        
        [array addObject:[NSNumber numberWithFloat:0.95]];
    }else{
        [array addObject:[NSNumber numberWithFloat:0.0]];
        
        [array addObject:[NSNumber numberWithFloat:0.75]];
        
        [array addObject:[NSNumber numberWithFloat:1.0]];
    }
    
    
    return array;
}

@end
