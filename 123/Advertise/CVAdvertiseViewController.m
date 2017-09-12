//
//  CVAdvertiseViewController.m
//  CloudPlayer
//
//  Created by Huaming.Zhu on 16/4/21.
//  Copyright © 2016年 __VideoApps___. All rights reserved.
//

#import "CVAdvertiseViewController.h"

// 专业版如不包含广告，可不关联此类，取消‘GoogleMobileAds’ 的关联，避免审核风险

@interface CVAdvertiseViewController ()

@end

@implementation CVAdvertiseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadAdvertiseData{
    
}

- (void)advertiseDidLoad:(UIView *)adView{
    
}

- (void)advertiseFailedToLoadWithError:(NSError *)error{
    
}

- (void)advertiseDidClick:(FBNativeAd *)nativeAd{
    
}

- (void)advertiseDidFinishHandlingClick:(FBNativeAd *)nativeAd{
    
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
