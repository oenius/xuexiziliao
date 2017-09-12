//
//  UIAlertController+show.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/27.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "UIAlertController+show.h"

@implementation UIAlertController (show)

+(void)showMessageOKAndCancel:(NSString *)message action:(void (^)(AlertActionType))block{
    UIAlertController * alerC = [UIAlertController alertControllerWithTitle:[IDConst instance].Reminder message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:[IDConst instance].Cancel style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        block(AlertActionTypeCancel);
    }];
    
    UIAlertAction * ok = [UIAlertAction actionWithTitle:[IDConst instance].Resume style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        block(AlertActionTypeOK);
    }];
    [alerC addAction:cancel];
    [alerC addAction:ok];
    [[self topMostController] presentViewController:alerC animated:YES completion:nil];
}
+(UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}


@end
