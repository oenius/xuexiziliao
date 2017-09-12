//
//  SKTProductRequester.m
//  StoreKitTest
//
//  Created by jiechen on 13-3-2.
//  Copyright (c) 2013年 NetPowerApps. All rights reserved.
//

#import "SBProductRequester.h"
#import "SBPaymentLocalizeUtil.h"

@interface SBProductRequester ()

@property(nonatomic, strong) NSString *productIdentifier;
@property(nonatomic, copy) SBProductRequestHandler handler;
@property(nonatomic, weak) UIAlertController *msgAlertController;
@property(nonatomic, strong) SKProductsRequest *productRequest;

@end

@implementation SBProductRequester

- (id)initWithProductIdentifier:(NSString *)productIdentifier withHandler:(SBProductRequestHandler)handler {
    self = [super init];
    if(self) {
        self.productIdentifier = productIdentifier;
        self.handler = handler;
    }
    return self;
}

- (void)request {
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:self.productIdentifier]];
    request.delegate = self;
    [request start];
    self.productRequest = request;
    NSString *msg = [SBPaymentLocalizeUtil localizedStringForKey:@"Requesting for product info..." withDefault:@"Requesting for product info..."];
    NSString *remindStr = [SBPaymentLocalizeUtil localizedStringForKey:@"Remind info" withDefault:@"Remind info"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:remindStr message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    NSString *cancelStr = [SBPaymentLocalizeUtil localizedStringForKey:@"cancel" withDefault:@"Cancel"];
    [alertController addAction:[UIAlertAction actionWithTitle:cancelStr style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.productRequest cancel];
        weakSelf.handler(nil, SBProductRequestStatusCancel, nil);
    }]];
    
    
    [[self topMostController] presentViewController:alertController animated:YES completion:nil];
    
    self.msgAlertController = alertController;
}

- (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

- (NSString *)requestingProductIdentifier {
    return self.productIdentifier;
}

#warning 存在一个bug，请求对话框未结束时，产品对话框出现，导致产品对话框无法正常显示，需要在请求对话框结束后调用显示产品对话框.\
 相应问题描述:http://stackoverflow.com/questions/14453001/meaning-of-warning-while-a-presentation-is-in-progress

#pragma mark - SKProductsRequestDelegate methods
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    [self.msgAlertController dismissViewControllerAnimated:YES completion:^{
        SKProduct *product = nil;
        NSArray *products = response.products;
        if(products.count == 1 && [(product = [products objectAtIndex:0]).productIdentifier isEqualToString:self.productIdentifier]) {
            self.handler(product, SBProductRequestStatusSuccess, nil);
        } else {
            NSString *description = [NSString stringWithFormat:@"The product with identifier:\"%@\" not found!", self.productIdentifier];
            NSError *error = [NSError errorWithDomain:SKErrorDomain
                                                 code:SKErrorStoreProductNotAvailable
                                             userInfo:[NSDictionary dictionaryWithObject:description
                                                                                  forKey:NSLocalizedDescriptionKey]];
            self.handler(nil, SBProductRequestStatusFailure, error);
        }
    }];
    
//    SKProduct *product = nil;
//    NSArray *products = response.products;
//    if(products.count == 1 && [(product = [products objectAtIndex:0]).productIdentifier isEqualToString:self.productIdentifier]) {
//        self.handler(product, SBProductRequestStatusSuccess, nil);
//    } else {
//        NSString *description = [NSString stringWithFormat:@"The product with identifier:\"%@\" not found!", self.productIdentifier];
//        NSError *error = [NSError errorWithDomain:SKErrorDomain
//                                             code:SKErrorStoreProductNotAvailable
//                                         userInfo:[NSDictionary dictionaryWithObject:description
//                                                                              forKey:NSLocalizedDescriptionKey]];
//        self.handler(nil, SBProductRequestStatusFailure, error);
//    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
#ifdef DEBUG
    NSLog(@"Product request error:%@", error);
#endif
    [self.msgAlertController dismissViewControllerAnimated:YES completion:^{
        self.handler(nil, SBProductRequestStatusFailure, error);
    }];
}

@end
