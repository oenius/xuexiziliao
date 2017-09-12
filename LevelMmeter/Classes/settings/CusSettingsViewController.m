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
    
    
}
// default whiteColor
- (UIColor *)tableViewBackgroundColor{
    return [UIColor clearColor];
}
// default whiteColor
- (UIColor *)tableViewCellBackgroundColor{
    return [UIColor clearColor];
}
// default blackColor
//- (UIColor *)tableViewCellTextColor;
- (UIColor *)tableViewHeadViewBackgroundColor{
    return [UIColor colorWithWhite:1 alpha:0.1];
}
//- (UIColor *)tableViewHeadViewTextColor;
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)removeViewFormSupView{
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.view removeFromSuperview];
//    CATransition *animation = [CATransition animation];
//    animation.type = @"push";
//    animation.subtype =  kCATransitionFromLeft;
//    animation.duration = 0.35;
//    [self.navigationController.view.layer addAnimation:animation forKey:nil];
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
