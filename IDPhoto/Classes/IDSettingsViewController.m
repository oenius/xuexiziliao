//
//  IDSettingsViewController.m
//  IDPhoto
//
//  Created by 何少博 on 17/5/9.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDSettingsViewController.h"

@interface IDSettingsViewController ()

@end

@implementation IDSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage * backImage = [UIImage imageNamed:@"iphonebg"]; ;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        backImage = [UIImage imageNamed:@"ipadbg"];
    }
    self.view.layer.contents = (__bridge id _Nullable)(backImage.CGImage);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIColor *)tableViewBackgroundColor{
    return [UIColor clearColor];
}
-(UIColor*)tableViewCellBackgroundColor{
    return [UIColor clearColor];
}
-(UIColor *)tableViewHeadViewBackgroundColor{
    return [UIColor colorWithWhite:1 alpha:0.45];
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
