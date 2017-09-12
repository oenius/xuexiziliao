//
//  BLTabBarItem.h
//  BatteryLife
//
//  Created by vae on 16/11/16.
//  Copyright © 2016年 vae. All rights reserved.
//

#import <UIKit/UIKit.h>



/**
 角标类型

 - BLBadgeTypeText: 带有文字的角标
 - BlBadgeTypeDot:  圆点
 */
typedef NS_ENUM(NSUInteger, BLBadgeType){
    BLBadgeTypeText = 0,
    BlBadgeTypeDot
};

@interface BLTabBarItem : UITabBarItem

-(instancetype)initWithIcon:(NSString *)icon
               selectedIcon:(NSString *)selectedIcon;


-(void)showBadge;
-(void)hideBadge;


@end
