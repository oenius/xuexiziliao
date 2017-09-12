//
//  SKTProductRequester.h
//  StoreKitTest
//
//  Created by jiechen on 13-3-2.
//  Copyright (c) 2013年 NetPowerApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef enum {
    SBProductRequestStatusCancel, //请求取消
    SBProductRequestStatusSuccess, //请求成功
    SBProductRequestStatusFailure, //请求失败
}SBProductRequestStatus;

typedef void (^SBProductRequestHandler)(SKProduct *product, SBProductRequestStatus status, NSError *error);

@interface SBProductRequester : NSObject<SKProductsRequestDelegate>

- (id)initWithProductIdentifier:(NSString *)productIdentifier withHandler:(SBProductRequestHandler)handler;

- (void)request;

- (NSString *)requestingProductIdentifier;

@end
