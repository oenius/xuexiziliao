//
//  UIDevice+x.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/12.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "UIDevice+x.h"

@implementation UIDevice (x)

+(BOOL)systemVersionGreaterThan9_3{
    NSString *s = [UIDevice currentDevice].systemVersion;
    NSInteger firstNum = [[[s componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    NSInteger secondNum = [[[s componentsSeparatedByString:@"."] objectAtIndex:1] intValue];
    
    if (firstNum >= 10) {
        return YES;
    }
    if(firstNum == 9){
        if (secondNum > 3) {
            return YES;
        }else{
            return NO;
        }
    }
    return NO;
}

@end
