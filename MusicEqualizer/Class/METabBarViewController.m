//
//  METabBarViewController.m
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/26.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "METabBarViewController.h"
#import "MEMusicListViewController.h"
#import "MESongsViewController.h"
#import "MESettingsViewController.h"
#import "UIColor+x.h"
#import "NPCommonConfig.h"
@interface METabBarViewController ()

@end

@implementation METabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar.backgroundColor = RGB_COLOR(0.0, 0.0, 0.0);
    self.tabBar.topLineColor = RGB_COLOR(33.0, 33.0, 33.0);
    NSDictionary * normal = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    MESongsViewController * songs = [[MESongsViewController alloc]init];
    [self setTabBarItemImage:@"musicSongs" title:MEL_songs viewController:songs];
    UINavigationController *songsNav = [[UINavigationController alloc]initWithRootViewController:songs];
    songsNav.navigationBar.barTintColor = [UIColor colorWithHexString:@"a20707"];
    songsNav.navigationBar.tintColor = [UIColor whiteColor];
    songsNav.navigationBar.titleTextAttributes  = normal;
    songsNav.navigationBar.translucent = YES;
    
    MEMusicListViewController * list = [[MEMusicListViewController alloc]init];
    [self setTabBarItemImage:@"musicList" title:MEL_SongList viewController:list];
    UINavigationController * listNav = [[UINavigationController alloc]initWithRootViewController:list];
    listNav.navigationBar.barTintColor = [UIColor colorWithHexString:@"a20707"];
    listNav.navigationBar.tintColor = [UIColor whiteColor];
    listNav.navigationBar.titleTextAttributes  = normal;
    listNav.navigationBar.translucent = YES;
    
    MESettingsViewController * settings = [[MESettingsViewController alloc]init];
    [self setTabBarItemImage:@"settins" title:MEL_setting viewController:settings];
    UINavigationController * settingsNav = [[UINavigationController alloc]initWithRootViewController:settings];
    settingsNav.navigationBar.barTintColor = [UIColor colorWithHexString:@"a20707"];
    settingsNav.navigationBar.tintColor = [UIColor whiteColor];
    settingsNav.navigationBar.titleTextAttributes  = normal;
    settingsNav.navigationBar.translucent = YES;
    
    self.viewControllers = @[songsNav,listNav,settingsNav];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)setTabBarItemImage:(NSString*)imageName title:(NSString*)title viewController:(UIViewController *)vc{
    vc.st_tabBarItem.title = title;
    NSDictionary * normal = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    NSDictionary * heightLight = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"a20707"]};
    UIImage * image = [UIImage imageNamed:imageName];
    NSString * selecedImageName = [NSString stringWithFormat:@"%@Seleced",imageName];
    UIImage * selectedImage = [UIImage imageNamed:selecedImageName];
    vc.st_tabBarItem = [[STBarItem alloc]initWithTitle:title image:image];
    [vc.st_tabBarItem setSelectedTitleAttributes:heightLight widthUnselectedTitleAttributes:normal];
    [vc.st_tabBarItem setSelectedImage:selectedImage withUnselectedImage:image];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
