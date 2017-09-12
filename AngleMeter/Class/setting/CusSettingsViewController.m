//
//  CusSettingsViewController.m
//  AngleMeter
//
//  Created by 何少博 on 16/9/19.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "CusSettingsViewController.h"

@interface CusSettingsViewController ()

@end

@implementation CusSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(removeViewFormSupView)];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)removeViewFormSupView{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(UIColor *)tableViewCellBackgroundColor{
    return [UIColor colorWithWhite:0.85 alpha:1];
}
-(UIColor *)tableViewBackgroundColor{
    return [UIColor colorWithWhite:0.8 alpha:1];
}
-(UIColor *)tableViewHeadViewBackgroundColor{
    return [UIColor colorWithWhite:0.8 alpha:1];
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
