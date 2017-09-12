//
//  LCMultipleStateButton.m
//  LightCamera
//
//  Created by 何少博 on 16/12/12.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "LCMultipleStateButton.h"



IB_DESIGNABLE
@implementation LCMultipleStateButton

-(NSString *)semicolonSeparatedStateLabels{
    NSString * r;
    for (NSString* str in self.stateLabels) {
        [r stringByAppendingFormat:@"%@;",str];
        if (![r isEqualToString:""]) {
            r remov
        }
    }
}

@end
