//
//  SNMoveFileViewController.m
//  MindMap
//
//  Created by 何少博 on 2017/8/19.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNMoveFileViewController.h"
#import "MBProgressHUD.h"
#import "SNMindFileViewModel.h"
@interface SNMoveFileViewController ()

@end

@implementation SNMoveFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"move to dir :%@", self.toDir);
    NSString *dir = [self.toDir lastPathComponent];
    self.title = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"move to", @"move to"),dir];
}

-(void)configItemAction{
    __weak SNMoveFileViewController * weakSelf = self;
    [[[SNMindFileViewModel alloc]init] moveFiles:self.fileArray toDir:self.toDir completed:^(BOOL success, NSString *errorMessage) {
        [weakSelf runAsyncOnMainThread:^{
            
            if (!success) {
                NSString * message = [NSString stringWithFormat:@"%@ %@",errorMessage,NSLocalizedString(@"Move Failed!", @"Move Failed!")];
                [self alertMessage:message];
            }else{
                UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow;
                MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:keyWindow animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = NSLocalizedString(@"GDRIVE_DOWNLOAD_SUCCESSFUL_TITLE", @"");
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
