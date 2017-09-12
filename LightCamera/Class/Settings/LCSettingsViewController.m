//
//  LCSettingsViewController.m
//  LightCamera
//
//  Created by 何少博 on 16/12/17.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "LCSettingsViewController.h"

@interface LCSettingsViewController ()

@end

@implementation LCSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}


-(UIColor *)tableViewCellTextColor{
    return [UIColor whiteColor];
}
-(UIColor *)tableViewBackgroundColor{
    return [UIColor colorWithRed:24.0/255.0 green:24.0/255.0 blue:24.0/255.0 alpha:1];
}
-(UIColor *)tableViewCellBackgroundColor{
    return [UIColor colorWithRed:24.0/255.0 green:24.0/255.0 blue:24.0/255.0 alpha:1];
}
-(UIColor *)tableViewHeadViewTextColor{
    return [UIColor whiteColor];
}
-(UIColor *)tableViewHeadViewBackgroundColor{
    return [UIColor blackColor];
}
-(void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
