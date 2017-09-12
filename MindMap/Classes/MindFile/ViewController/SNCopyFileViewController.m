//
//  SNCopyFileViewController.m
//  MindMap
//
//  Created by 何少博 on 2017/8/19.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNCopyFileViewController.h"
#import "MBProgressHUD.h"
#import "SNMindFileViewModel.h"
@interface SNCopyFileViewController ()

@end

@implementation SNCopyFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"copy to dir :%@", self.toDir);
    NSString *dir = [self.toDir lastPathComponent];
    self.title = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Copy To", @"Copy To"),dir];
}

-(void)configItemAction{
    __weak SNCopyFileViewController * weakSelf = self;
    [[[SNMindFileViewModel alloc]init] copyFiles:self.fileArray toDir:self.toDir completed:^(BOOL success, NSString *errorMessage) {
       [weakSelf runAsyncOnMainThread:^{
           if (!success) {
               NSString * message = [NSString stringWithFormat:@"%@%@",errorMessage,NSLocalizedString(@"Copying failed", @"Copy Failed!")];
               [self alertMessage:message];
           }else{
               UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow;
               MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:keyWindow animated:YES];
               hud.mode = MBProgressHUDModeText;
               hud.label.text = NSLocalizedString(@"copy successfully", @"copy successfully");
               [hud hideAnimated:YES afterDelay:1];
               if (weakSelf.finishCallBack) {
                   weakSelf.finishCallBack(nil);
               }
               [self.navigationController dismissViewControllerAnimated:YES completion:nil];
           }
       }];
    }];
    
}

@end
