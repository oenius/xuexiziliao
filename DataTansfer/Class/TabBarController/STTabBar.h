//
//  STTabBar.h
//  Common
//
//  Created by 何少博 on 17/3/27.
//  Copyright © 2017年 camory. All rights reserved.
//

#import <UIKit/UIKit.h>


@class STBarItem;
@protocol STTabBarDelegate;

extern CGFloat const STTabBarSelectionIndicatorAnimationDuration;

@interface STTabBar : UIView

@property (nonatomic,weak) id<STTabBarDelegate>delegate;

@property(nonatomic,weak) STBarItem * selectedItem;

@property(nonatomic,strong) NSArray *items;

@property (nonatomic,strong) UIColor * tintColor;

@property (nonatomic,strong) UIColor * selectedImageTintColor;

@property (nonatomic,strong) UIImage * backgroundImage;

@property (nonatomic,strong) UIImage * selectionIndicatorImage;//暂未处理

@property (nonatomic,strong) UIImage *shadowImage;//暂未处理

@property (nonatomic,assign) BOOL selectionIndicatorAnimable;//暂未处理

@property (nonatomic,strong) UIColor *topLineColor;

@end


@protocol STTabBarDelegate <NSObject>

@optional

-(BOOL)tabBar:(STTabBar *)tabBar shouldSelectItem:(STBarItem *)item;

-(void)tabBar:(STTabBar *)tabBar didSelectItem:(STBarItem *)item;

@end
















