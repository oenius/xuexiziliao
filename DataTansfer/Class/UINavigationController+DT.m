//
//  UINavigationController+DT.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/17.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "UINavigationController+DT.h"
#import "UIColor+x.h"
@implementation UINavigationController (DT)

-(void)defaultUI{
    NSDictionary * normal = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    self.navigationBar.barTintColor = [UIColor dt_tintColor];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.titleTextAttributes  = normal;
    self.navigationBar.translucent = NO;
    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[[UIImage alloc] init]];
}
-(void)clearUI{
     NSDictionary * normal = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.titleTextAttributes  = normal;
    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[[UIImage alloc] init]];
}
@end
