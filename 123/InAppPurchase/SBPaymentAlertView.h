//
//  SBPurchaseAlertView.h
//  Common
//
//  Created by jiechen on 13-3-5.
//  Copyright (c) 2013年 zzf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "SBPaymentManager.h"

@interface SBPaymentAlertView : NSObject

@property(nonatomic, strong) SKProduct *product;
@property(nonatomic, weak) id<SBPaymentDelegate> paymentDelegate;

- (id)initWithProduct:(SKProduct *)product paymentDelegate:(id<SBPaymentDelegate>)delegate;

- (void)show;

@end
