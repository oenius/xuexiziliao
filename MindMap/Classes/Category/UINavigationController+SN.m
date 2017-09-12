//
//  UINavigationController+SN.m
//  MindMap
//
//  Created by 何少博 on 2017/8/22.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "UINavigationController+SN.h"

@implementation UINavigationController (SN)

-(void)defaultUI{
    UIImage * image = [[UIImage imageNamed:@"daohanglan"]resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
    [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

@end
