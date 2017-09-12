//
//  UIAlertController+SN.m
//  MindMap
//
//  Created by 何少博 on 2017/8/19.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "UIAlertController+SN.h"

@implementation UIAlertController (SN)


+(void)alertMessage:(NSString *)message controller:(UIViewController *)controller okHandler:(void (^)(UIAlertAction *))handler{
    UIAlertController * alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"layout_tips", @"") message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"MakeSure", @"") style:UIAlertActionStyleDefault handler:handler];
    [alertC addAction:ok];
    [controller presentViewController:alertC animated:YES completion:nil];
}

@end
