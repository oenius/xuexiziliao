//
//  DTPhotoPickerViewController.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/19.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTPhotoPickerViewController.h"

@interface DTPhotoPickerViewController ()

@end

@implementation DTPhotoPickerViewController

-(void)setViewModel:(DTPhotoViewModel *)viewModel{
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



@end
