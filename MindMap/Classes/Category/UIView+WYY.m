//
//  UIView+WYY.m
//  MindMap
//
//  Created by 王义元 on 2017/8/14.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "UIView+WYY.h"

@implementation UIView (WYY)

- (void)moveViewWithHeight:(CGFloat) heightChange{
    CGRect tempRect = self.frame;
    tempRect.origin.y += heightChange;
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = tempRect;
    }];
}

@end
