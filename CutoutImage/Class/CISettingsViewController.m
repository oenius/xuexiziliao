//
//  CISettingsViewController.m
//  CutoutImage
//
//  Created by 何少博 on 17/2/5.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "CISettingsViewController.h"

@interface CISettingsViewController ()

@end

@implementation CISettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = CI_Settings;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:CI_Back style:(UIBarButtonItemStylePlain) target:self action:@selector(disMissSelf)];
    NSDictionary * attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationController.navigationBar.titleTextAttributes = attributes;
}


-(void)disMissSelf{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(BOOL)needLoadBannerAdView{
    return YES;
}
-(BOOL)needLoadNative250HAdView{
    return NO;
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
