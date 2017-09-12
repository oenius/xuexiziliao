//
//  BannerTableViewCell.h
//  LEDBanner
//
//  Created by 何少博 on 16/6/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@protocol BannerTableViewCellDelegate <NSObject>
/* 默认提供颜色的设置 */
- (void)setDefaultChooseColorClick:(UIColor *)color ;
/* 形状选择 */
- (void)setXingzhuangChange:(NSDotModel)dotModel;
/* 清晰度选择 */
- (void)setQingxiduChange:(NSShowModel)showModel;
/*  */
- (void)setCustomColorClick:(UIColor*)color;
/*  */
- (void)ADSBttonClick;
@end

@interface BannerTableViewCell : UITableViewCell
//@property (nonatomic,strong) MainViewController * mainViewController;
@property (weak, nonatomic) id<BannerTableViewCellDelegate> delegate;

@end
