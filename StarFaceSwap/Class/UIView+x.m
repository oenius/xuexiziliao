//
//  UIView+x.m
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/10.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "UIView+x.h"

@implementation UIView (x)

- (UIViewController*)supviewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

@end
