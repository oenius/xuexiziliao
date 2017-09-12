//
//  SettingsViewController.h
//  Common
//
//  Created by mayuan on 16/6/30.
//  Copyright © 2016年 camory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SettingsViewController : BaseViewController

@property (strong, nonatomic, readonly) NSMutableArray<NSString *> *productSectionDataArray;
@property (strong, nonatomic, readonly) NSMutableArray<NSString *> *purchaseSectionDataArray;
@property (strong, nonatomic, readonly) NSMutableArray<NSString *> *generalSectionDataArray;

@property (strong, nonatomic, readonly) UITableView *tableView;

// 如果需要修改设置界面的颜色风格，重写以下方法
// default whiteColor
- (UIColor *)tableViewBackgroundColor;
// default whiteColor
- (UIColor *)tableViewCellBackgroundColor;
// default blackColor
- (UIColor *)tableViewCellTextColor;
- (UIColor *)tableViewHeadViewBackgroundColor;
- (UIColor *)tableViewHeadViewTextColor;

- (void)reloadTableViewData;

// 是否显示恢复购买单元格，default NO, 默认不显示。如果被拒，可重写修改后提交
- (BOOL)needShowRestorePaymentCell;

// 产品相关设置，子类重写，重写时需要调用父类方法
- (void)setProductSectionItems;

// 内购相关设置，子类重写，重写时需要调用父类方法
- (void)setPaymentSectionItems;

// 通用相关设置，子类重写，重写时需要调用父类方法
- (void)setGeneralSectionItems;

// tableViewCell 点击相应事件，子类重写，重写时需要调用父类方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

// 重写该方法 以实现自定义单元格cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

// 不需要重写，tableViewCell显示的文字
- (NSString *)titleForIndexPath:(NSIndexPath *)indexPath;
@end
