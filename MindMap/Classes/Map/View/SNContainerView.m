//
//  SNContainerView.m
//  MindMap
//
//  Created by 何少博 on 2017/8/8.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNContainerView.h"

@implementation SNContainerView

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return YES;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView * hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return nil;
    }else{
        return hitView;
    }
}

@end
