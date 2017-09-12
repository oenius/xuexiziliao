//
//  SBProductManager.h
//  StoreKitTest
//
//  Created by jiechen on 13-3-2.
//  Copyright (c) 2013年 NetPowerApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol SBPaymentDelegate;

@interface SBPaymentManager : NSObject<SKPaymentTransactionObserver>

+ (id)defaultManager;

/**
 * @description 判断指定的商品编号是否在本地已经有购买成功的记录。用于非消耗性内购商品，其他类型一律返回NO
 *
 * @params productIdentifier 要进行判断的商品编号
 *
 * @return 如果本地已经有该商品的购买成功记录，返回YES，表示不需要购买或者恢复，否则返回NO，表示需要购买或者恢复
 */
+ (BOOL)hasRecord:(NSString *)productIdentifier;

- (void)clearProductRecord:(NSString *)productIdentifier;

/**
 * @description 购买指定编号的内购商品。如果该编号的内购商品是非消耗性并且已经被当前Apple ID购买过， 则不会另行扣款，而是会恢复该内购商品。在调用本方法之前，应该先调用hasRecord方法判断一下本地是否已经有该商品记录
 *
 * @params productIdentifier 要购买的商品编号
 *
 * @params delegate 用于交易过程中进行回调的接口
 */
- (void)purchaseWithProductIdentifier:(NSString *)productIdentifier delegate:(id<SBPaymentDelegate>)delegate;

/**
 * @description 购买指定的内购商品。如果该编号的内购商品是非消耗性并且已经被当前Apple ID购买过， 则不会另行扣款，而是会恢复该内购商品。
 *
 * @params productIdentifier 要购买的商品
 *
 * @params delegate 用于交易过程中进行回调的接口
 */
- (void)purchaseWithProduct:(SKProduct *)product delegate:(id<SBPaymentDelegate>)delegate;

/**
 * @description 恢复指定编号的非消耗性内购商品。在调用本方法之前，应该先调用hasRecord方法判断一下本地是否已经有该商品记录
 *
 * @params productIdentifier 要恢复的商品编号
 *
 * @params delegate 用于交易过程中进行回调的接口
 */
- (void)restoreWithProductIdentifier:(NSString *)productIdentifier delegate:(id<SBPaymentDelegate>)delegate;

/**
 * @description 恢复指定的非消耗性内购商品。
 *
 * @params productIdentifier 要恢复的商品
 *
 * @params delegate 用于交易过程中进行回调的接口
 */
- (void)restoreWithProduct:(SKProduct *)product delegate:(id<SBPaymentDelegate>)delegate;

@end

typedef enum {
    SBPaymentTypePurchase, //新购买
    SBPaymentTypeRestore, //从应用商店恢复
}SBPaymentType;

@protocol SBPaymentDelegate <NSObject>

@optional
- (void)paymentSuccessed:(NSString *)productIdentifier type:(SBPaymentType)type;

- (void)paymentFailed:(NSString *)productIdentifier type:(SBPaymentType)type withError:(NSError *)error;

@end