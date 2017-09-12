//
//  DTTabBarController.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/17.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTTabBarController.h"
#import "NPCommonConfig.h"
#import "UIColor+x.h"
#import "DTSynDataViewController.h"
#import "DTInboxViewController.h"
#import "DTSettingsViewController.h"
#import "UINavigationController+DT.h"
#import "UIImage+x.h"
@interface DTTabBarController ()

@end

@implementation DTTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tabBar.backgroundColor = [UIColor colorWithHexString:@"292929"];
    self.tabBar.topLineColor = RGB_COLOR(33.0, 33.0, 33.0);
    DTSynDataViewController * synData = [[DTSynDataViewController alloc]init];
    [self setTabBarItemImage:@"huanji" title:[DTConstAndLocal shujuchuanshu] viewController:synData];
    UINavigationController *synDataNav = [[UINavigationController alloc]initWithRootViewController:synData];
    
    
    DTInboxViewController * indox = [[DTInboxViewController alloc]init];
    [self setTabBarItemImage:@"shoujianxiang" title:[DTConstAndLocal inbox] viewController:indox];
    UINavigationController *indoxNav = [[UINavigationController alloc]initWithRootViewController:indox];

    
    DTSettingsViewController * setting = [[DTSettingsViewController alloc]init];
    [self setTabBarItemImage:@"shezhi" title:[DTConstAndLocal settings] viewController:setting];
    UINavigationController *settingNav = [[UINavigationController alloc]initWithRootViewController:setting];
   
    
    self.viewControllers = @[synDataNav,indoxNav,settingNav];
    

}



//-(void)setTabBarItemImage:(NSString*)imageName title:(NSString*)title viewController:(UIViewController *)vc{
//    
//    NSDictionary * normal = @{NSForegroundColorAttributeName:[UIColor dt_grayColor]};
//    NSDictionary * heightLight = @{NSForegroundColorAttributeName:[UIColor dt_tintColor]};
//    UIImage * image = [UIImage imageNamed:imageName];
//    NSString * selecedImageName = [NSString stringWithFormat:@"%@_selected",imageName];
//    UIImage * selectedImage = [UIImage imageNamed:selecedImageName];
//    vc.tabBarItem = [[UITabBarItem alloc]init];
//    [vc.tabBarItem setTitle:title];
//    [vc.tabBarItem setTitleTextAttributes:normal forState:(UIControlStateNormal)];
//    [vc.tabBarItem setTitleTextAttributes:heightLight forState:(UIControlStateSelected)];
//    [vc.tabBarItem setImage:image];
//    [vc.tabBarItem setSelectedImage:selectedImage];
////    [vc.tabBarItem setSelectedTitleAttributes:heightLight widthUnselectedTitleAttributes:normal];
////    [vc.tabBarItem setSelectedImage:selectedImage withUnselectedImage:image];
//}
    
-(void)setTabBarItemImage:(NSString*)imageName title:(NSString*)title viewController:(UIViewController *)vc{
    
    NSDictionary * normal = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"545555"]};
    NSDictionary * heightLight = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"76f8b7"]};
    UIImage * image = [UIImage imageNamed:imageName];
    NSString * selecedImageName = [NSString stringWithFormat:@"%@_selected",imageName];
    
    UIImage * selectedImage = [UIImage imageNamed:selecedImageName];
    if (image == nil) {
        image = [selectedImage imageWithColor:[UIColor colorWithHexString:@"545555"]];
    }
    vc.st_tabBarItem = [[STBarItem alloc]initWithTitle:title image:image];
    [vc.st_tabBarItem setSelectedTitleAttributes:heightLight widthUnselectedTitleAttributes:normal];
    [vc.st_tabBarItem setSelectedImage:selectedImage withUnselectedImage:image];
    vc.st_tabBarItem.title = title;
}

@end
