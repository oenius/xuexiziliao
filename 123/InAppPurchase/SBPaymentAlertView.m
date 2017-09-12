//
//  SBPurchaseAlertView.m
//  Common
//
//  Created by jiechen on 13-3-5.
//  Copyright (c) 2013年 zzf. All rights reserved.
//

#import "SBPaymentAlertView.h"
//#import "CCLocalizedMessage.h"
#import "SBPaymentLocalizeUtil.h"
@interface SBPaymentAlertView ()

@end

@implementation SBPaymentAlertView

- (id)initWithProduct:(SKProduct *)product paymentDelegate:(id<SBPaymentDelegate>)delegate{
    self = [super init];
    if(self) {
        self.product = product;
        self.paymentDelegate = delegate;
    }
    return self;
}

- (void)show {
    NSString *title = [SBPaymentLocalizeUtil localizedStringForKey:@"Product info" withDefault:@"Product info"];
    NSString *strProductName = [SBPaymentLocalizeUtil localizedStringForKey:@"Name" withDefault:@"Name"];
    NSString *strPrice = [SBPaymentLocalizeUtil localizedStringForKey:@"Price" withDefault:@"Price"];
    NSString *strDescription = [SBPaymentLocalizeUtil localizedStringForKey:@"Description" withDefault:@"Description"];
    NSString *msg = [NSString stringWithFormat:@"%@:%@\n%@:%@\n%@:%@", strProductName, self.product.localizedTitle, strPrice, localPrice(self.product), strDescription, self.product.localizedDescription];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;    //以下block中不能使用weakSelf，因为回调的时候weakSelf为nil，会导致闪退
    NSString *buyStr =  [SBPaymentLocalizeUtil localizedStringForKey:@"Buy" withDefault:@"Buy"];
    [alertController addAction:[UIAlertAction actionWithTitle:buyStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //购买
        [[SBPaymentManager defaultManager] purchaseWithProduct:self.product delegate:self.paymentDelegate];
    }]];
    NSString *restoreStr =  [SBPaymentLocalizeUtil localizedStringForKey:@"Restore" withDefault:@"Restore"];
    [alertController addAction:[UIAlertAction actionWithTitle:restoreStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //恢复
        [[SBPaymentManager defaultManager] restoreWithProduct:self.product delegate:self.paymentDelegate];
    }]];
    NSString *cancelStr = [SBPaymentLocalizeUtil localizedStringForKey:@"cancel" withDefault:@"Cancel"];
    [alertController addAction:[UIAlertAction actionWithTitle:cancelStr style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //取消
    }]];

    [[self topMostController] presentViewController:alertController animated:YES completion:nil];
}

- (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

NSString *localPrice(SKProduct *product) {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    return formattedString;
}


@end
