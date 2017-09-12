//
//  CusTabBarController.m
//  EyesightDetection
//
//  Created by 何少博 on 16/9/27.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "CusTabBarController.h"
#import "EyeViewController.h"
#import "CusSettingsViewController.h"
#import "SeMangViewController.h"

@interface CusTabBarController ()

@property(assign,nonatomic)NSInteger indexFlag;

@end

@implementation CusTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    EyeViewController * eye = [[EyeViewController alloc]init];
    UINavigationController * eyeNav = [[UINavigationController alloc]initWithRootViewController:eye];
    eye.tabBarItem.image = [[UIImage imageNamed:@"eye"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    eye.tabBarItem.selectedImage = [[UIImage imageNamed:@"eye-choosed"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    eye.tabBarItem.title = NSLocalizedString(@"eyesight test", @"Vision detection");
    
    
    SeMangViewController * seMang = [[SeMangViewController alloc]init];
    UINavigationController * seMangNav = [[UINavigationController alloc]initWithRootViewController:seMang];
    seMang.tabBarItem.image = [[UIImage imageNamed:@"sight-test"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    seMang.tabBarItem.selectedImage = [[UIImage imageNamed:@"sight-test-choosed"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    seMang.tabBarItem.title = NSLocalizedString(@"color blindness test", @"Color blindness detection");
    
    CusSettingsViewController * settings = [[CusSettingsViewController alloc]init];
    UINavigationController * settingsNav = [[UINavigationController alloc]initWithRootViewController:settings];
    settings.tabBarItem.image = [[UIImage imageNamed:@"setting"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
         settings.tabBarItem.selectedImage = [[UIImage imageNamed:@"setting－choosed"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    settings.tabBarItem.title = NSLocalizedString(@"Setting", @"Settings");
    
    self.viewControllers = @[eyeNav,seMangNav,settingsNav];
    self.tabBar.tintColor = color_2bc083;
    self.tabBar.barTintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
//    
//    NSInteger index = [self.tabBar.items indexOfObject:item];
//    if (self.indexFlag != index) {
//        [self animationWithIndex:index];
//    }
//    
//}

- (void)animationWithIndex:(NSInteger) index {
    NSMutableArray * tabbarbuttonArray = [NSMutableArray array];
    
    for (UIView *tabBarButton in self.tabBar.subviews) {
        if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [tabbarbuttonArray addObject:tabBarButton];
        }
    }
    CABasicAnimation*pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulse.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulse.duration = 0.1;
    pulse.repeatCount= 1;
    pulse.autoreverses= YES;
    pulse.fromValue= [NSNumber numberWithFloat:0.7];
    pulse.toValue= [NSNumber numberWithFloat:1.3];
    [[tabbarbuttonArray[index] layer]
     addAnimation:pulse forKey:nil];
    
    self.indexFlag = index;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
