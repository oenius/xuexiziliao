//
//  STTabBarController.h
//  Common
//
//  Created by 何少博 on 17/3/27.
//  Copyright © 2017年 camory. All rights reserved.
//

#import "BaseViewController.h"

#import "STBarItem.h"
#import "STTabBar.h"

@protocol STTabBarControllerDelegate ;

@interface STTabBarController : BaseViewController

@property (nonatomic,weak) id<STTabBarControllerDelegate>delegate;

@property (nonatomic,copy) NSArray * viewControllers;

@property (nonatomic,weak) UIViewController * selectedViewController;

@property (nonatomic,assign) NSUInteger selectedIndex;

@property (nonatomic,strong,readonly) UINavigationController * moreNavigationController;

@property (nonatomic,strong) STTabBar * tabBar;

@property (nonatomic,assign) BOOL isTabBarHidden;

@property (nonatomic,copy) NSArray * customizableViewControllers;

@property (nonatomic,assign) BOOL selectedControllerNavigationItem;

@property (nonatomic,assign) BOOL shouldAdjustSelectedViewContentInsets;

@property (nonatomic,assign,readonly) CGFloat tabBarHeight;

-(void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

-(void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

-(void)adjustSelectedViewControllerInsetsIfNeeded;


@end


@protocol STTabBarControllerDelegate <NSObject>

@optional

-(BOOL)tabBarController:(STTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;

-(void)tabBarController:(STTabBarController *)tabBarController willSelectViewController:(UIViewController *)viewContoller;

-(void)tabbarController:(STTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;

@end

@protocol STTabBarDatasource <NSObject>

@optional
@property (nonatomic,readonly) BOOL tabTitleHidden;

@property (nonatomic,readonly) UIImage  *selectedTabImage;

@property (nonatomic,readonly) UIImage  *unselectedTabImage;

@property (nonatomic,readonly) NSString *tabTitle;

@end

@interface UIViewController (STTabBarControllerItem)<STTabBarDatasource>

@property (nonatomic,strong) STBarItem *st_tabBarItem;

@property (nonatomic,strong,readonly) STTabBarController *st_tabBarController;

@end





















