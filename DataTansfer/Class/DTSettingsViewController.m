//
//  DTSettingsViewController.m
//  DataTansfer
//
//  Created by 何少博 on 17/6/7.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTSettingsViewController.h"
#import "UINavigationController+DT.h"
@interface DTSettingsViewController ()

@end

@implementation DTSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController clearUI];
    self.title = [DTConstAndLocal settings];
    self.tableView.clipsToBounds = YES;
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"bg"].CGImage);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIColor *)tableViewCellBackgroundColor{
    return [UIColor clearColor];
}
-(UIColor *)tableViewBackgroundColor{
    return [UIColor clearColor];
}
-(UIColor *)tableViewCellTextColor{
    return [UIColor whiteColor];
}
-(UIColor *)tableViewHeadViewBackgroundColor{
    return [UIColor colorWithWhite:1 alpha:0.2];
}
-(UIColor *)tableViewHeadViewTextColor{
    return [UIColor whiteColor];
}
- (void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    
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
