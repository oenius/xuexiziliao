//
//  CustomSettingsViewController.m
//  LEDBanner
//
//  Created by 何少博 on 16/12/29.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "CustomSettingsViewController.h"
#import "UIColor+x.h"
@interface CustomSettingsViewController ()

@end

@implementation CustomSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorColor = color_303844;
    self.tableView.backgroundColor = color_000000;
    self.navigationController.navigationBar.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIColor *)tableViewHeadViewBackgroundColor {
    return color_000000;//[UIColor colorWithRed:(231.0/255.0) green:(231.0/255.0)  blue:(231.0/255.0)  alpha:1.0];
}
- (UIColor *)tableViewHeadViewTextColor {
    return [UIColor lightGrayColor];
}
-(UIColor *)tableViewCellBackgroundColor{
    return color_131a20;
}
-(UIColor *)tableViewCellTextColor{
    return color_ffffff;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.textColor = color_ffffff;
    cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = color_000000;
    return cell;
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
