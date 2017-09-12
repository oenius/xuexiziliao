//
//  UINavigationController+x.m
//  IDPhoto
//
//  Created by 何少博 on 17/5/6.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "UINavigationController+x.h"

@implementation UINavigationController (x)

-(void)usingTheGradient{
    UIImage * naviImage = [UIImage imageNamed:@"daohang"];
//    [UIImage getGradientImageWithSize:CGSizeMake(100, 64)
//                           startColor:[UIColor colorWithHexString:@"fe73aa"] endColor:[UIColor colorWithHexString:@"fc507d"]];
    naviImage = [naviImage resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:(UIImageResizingModeStretch)];
    [self.navigationBar setBackgroundImage:naviImage forBarMetrics:(UIBarMetricsDefault)];
    self.navigationController.navigationBar.clipsToBounds = NO;
    
}
-(void)usingWhiteColor{
    self.navigationBar.tintColor = [UIColor whiteColor];
    NSDictionary * attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationBar.titleTextAttributes = attributes;
}
@end
