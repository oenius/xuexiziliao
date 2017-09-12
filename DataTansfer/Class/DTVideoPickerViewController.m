//
//  DTVideoPickerViewController.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/19.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTVideoPickerViewController.h"

@interface DTVideoPickerViewController ()

@end

@implementation DTVideoPickerViewController

-(void)setViewModel:(DTVideoViewModel *)viewModel{
    _viewModel = viewModel;
    self.baseViewModel = _viewModel;
}
//-(void)doneItemClick{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
