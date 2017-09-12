//
//  SBProductManager.m
//  StoreKitTest
//
//  Created by jiechen on 13-3-2.
//  Copyright (c) 2013年 NetPowerApps. All rights reserved.
//

#import "SBPaymentManager.h"
#import "SBProductRequester.h"
#import "SBPaymentAlertView.h"
#import "SBPurchaseRecordUtils.h"
#import "NPCommonConfig.h"

//#define  SAVE_RECORD_IN_KEYCHAIN
//定义此宏的话将使用老的密码锁存储方式（存储在钥匙串中）；屏蔽此宏的话密码锁会改为新的，即存储在sbprefence中

@interface SBPaymentManager ()

@property(nonatomic, strong) NSMutableDictionary *productRequesterDict;
@property(nonatomic, strong) NSMutableDictionary *paymentDelegateDict;

@end

@implementation SBPaymentManager

@synthesize productRequesterDict = _productRequesterDict;
@synthesize paymentDelegateDict = _paymentDelegateDict;
//@synthesize paymentRecoder = _paymentRecoder;

+ (id)defaultManager {
    static SBPaymentManager *mgr = nil;
    if(mgr == nil) {
        mgr = [[SBPaymentManager alloc] init];
    }
    return mgr;
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (id)init {
    self = [super init];
    if(self) {
        //监视整个交易过程
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)purchaseWithProductIdentifier:(NSString *)productIdentifier delegate:(id<SBPaymentDelegate>)delegate {
    [self.paymentDelegateDict setObject:delegate forKey:productIdentifier];
    SBProductRequestHandler handle = ^(SKProduct *product, SBProductRequestStatus status, NSError *error) {
        switch (status) {
            case SBProductRequestStatusCancel:
                
                break;
            case SBProductRequestStatusSuccess:
            {
//                [self purchaseWithProduct:product delegate:delegate];
                NSString *removeAdIdentifier = [NPCommonConfig shareInstance].removeAdPurchaseProductId;
                if ([removeAdIdentifier isEqualToString:productIdentifier]) {
                    [self purchaseWithProduct:product delegate:delegate];
                }else{
                    SBPaymentAlertView *alertView = [[SBPaymentAlertView alloc]initWithProduct:product paymentDelegate:delegate];
                    [alertView show];
                }
            }
                break;
            case SBProductRequestStatusFailure:
            {
                if([delegate respondsToSelector:@selector(paymentFailed:type:withError:)]) {
                    [delegate paymentFailed:productIdentifier type:SBPaymentTypePurchase withError:error];
                }
            }
                break;
            default:
                break;
        }
    };
    SBProductRequester *requester = [[SBProductRequester alloc]initWithProductIdentifier:productIdentifier withHandler:handle];
    [self.productRequesterDict setObject:requester forKey:productIdentifier];
    [requester request];
}

- (void)purchaseWithProduct:(SKProduct *)product delegate:(id<SBPaymentDelegate>)delegate {
    [self.paymentDelegateDict setObject:delegate forKey:product.productIdentifier];
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restoreWithProductIdentifier:(NSString *)productIdentifier delegate:(id<SBPaymentDelegate>)delegate {
    [self.paymentDelegateDict setObject:delegate forKey:productIdentifier];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)restoreWithProduct:(SKProduct *)product delegate:(id<SBPaymentDelegate>)delegate {
    [self restoreWithProductIdentifier:product.productIdentifier delegate:delegate];
}

#pragma mark - SKPaymentTransactionObserver methods
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing:
                [self purchasingTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchased:
                [self purchasedTransaction:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    NSString *errorMsg = error.localizedDescription;
    switch (error.code) {
        case SKErrorPaymentNotAllowed:
            errorMsg = @"this device is not allowed to make the payment"; //@"不允许内购";
            break;
        case SKErrorStoreProductNotAvailable:
            errorMsg = @"Product is not available in the current storefront"; //@"内购商品不存在";
            break;
        case SKErrorPaymentCancelled:
            errorMsg = @"user cancelled payment"; //@"用户取消了购买";
            break;
        case SKErrorClientInvalid:
            errorMsg = @"client is not allowed to issue the request"; //@"客户端错误";
            break;
        case SKErrorPaymentInvalid:
            errorMsg = @"purchase identifier was invalid"; //@"不合法的内购";
            break;
        case SKErrorUnknown:
            
            break;
        default:
            break;
    }
    NSError *fixError = [NSError errorWithDomain:error.domain code:error.code userInfo:@{NSLocalizedDescriptionKey: errorMsg }];
#ifdef DEBUG
    NSLog(@"恢复内购商品失败：%@", error);
#endif
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        NSString *productIdentifier = transaction.payment.productIdentifier;
        id<SBPaymentDelegate> delegate = [self.paymentDelegateDict objectForKey:productIdentifier];
        if([delegate respondsToSelector:@selector(paymentFailed:type:withError:)]) {
            [delegate paymentFailed:productIdentifier type:SBPaymentTypeRestore withError:fixError];
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    for(SKPaymentTransaction *transaction in queue.transactions) {
        NSString *productIdentifier = transaction.payment.productIdentifier;
#ifdef DEBUG
        NSLog(@"恢复内购商品\"%@\" 成功!", productIdentifier);
#endif
        //保存购买记录
        [self storeProduct:productIdentifier];
        //回调
        id<SBPaymentDelegate> delegate = [self.paymentDelegateDict objectForKey:productIdentifier];
        if([delegate respondsToSelector:@selector(paymentSuccessed:type:)]) {
            [delegate paymentSuccessed:productIdentifier type:SBPaymentTypeRestore];
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        NSString *productIdentifier = transaction.payment.productIdentifier;
        [self.productRequesterDict removeObjectForKey:productIdentifier];
        [self.paymentDelegateDict removeObjectForKey:productIdentifier];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads {
    
}

#pragma mark - PaymentStatusUpdate
- (void) purchasingTransaction: (SKPaymentTransaction *)transaction {
#ifdef DEBUG
    NSLog(@"正在购买");
#endif
}

- (void) purchasedTransaction: (SKPaymentTransaction *)transaction
{
#ifdef DEBUG
    NSLog(@"购买成功");
#endif
    NSString *productIdentifier = transaction.payment.productIdentifier;
    //保存购买记录
    [self storeProduct:productIdentifier];
    //回调
    id<SBPaymentDelegate> delegate = [self.paymentDelegateDict objectForKey:productIdentifier];
    if([delegate respondsToSelector:@selector(paymentSuccessed:type:)]) {
        [delegate paymentSuccessed:productIdentifier type:SBPaymentTypePurchase];
    }
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
#ifdef DEBUG
    NSLog(@"已恢复购买");
#endif
    // 从applstore或者桌面等外部完成购买后，下次启动会调用此方法，需要存储相关信息。
//    NSLog(@"恢复内购商品\"%@\" 成功!  %@", transaction.payment.productIdentifier,transaction.transactionIdentifier);

    [self storeProduct:transaction.payment.productIdentifier];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    NSError *error = transaction.error;
    NSString *errorMsg = error.localizedDescription;
    switch (error.code) {
        case SKErrorPaymentNotAllowed:
            //
            errorMsg = @"this device is not allowed to make the payment"; //@"不允许内购";
            break;
        case SKErrorStoreProductNotAvailable:
            errorMsg = @"Product is not available in the current storefront"; //@"内购商品不存在";
            break;
        case SKErrorPaymentCancelled:
            errorMsg = @"user cancelled payment"; //@"用户取消了购买";
            break;
        case SKErrorClientInvalid:
            errorMsg = @"client is not allowed to issue the request"; //@"客户端错误";
            break;
        case SKErrorPaymentInvalid:
            errorMsg = @"purchase identifier was invalid"; //@"不合法的内购";
            break;
        case SKErrorUnknown:
            
            break;
        default:
            break;
    }
    NSError *fixError = [NSError errorWithDomain:error.domain code:error.code userInfo:@{NSLocalizedDescriptionKey: errorMsg }];
#ifdef DEBUG
    NSLog(@"购买失败：%@", errorMsg);
#endif
    NSString *productIdentifier = transaction.payment.productIdentifier;
    id<SBPaymentDelegate> delegate = [self.paymentDelegateDict objectForKey:productIdentifier];
    if([delegate respondsToSelector:@selector(paymentFailed:type:withError:)]) {
        [delegate paymentFailed:productIdentifier type:SBPaymentTypePurchase withError:fixError];
    }
}

#pragma mark - Keychain record
//添加类方法，可以不用初始化实例。在+ (BOOL)hasRecord:(NSString *)productIdentifier中用到可以节省性能
+ (void)storeTheProduct:(NSString *)productIdentifier {
    NSError *error = nil;
    [SBPurchaseRecordUtils storeUsername:productIdentifier
                             andPassword:defaultValue()
                          forServiceName:keychainServiceName()
                          updateExisting:YES
                                   error:&error];
#ifdef DEBUG
    if(error) {
        NSLog(@"Store product error:%@", error);
    }
#endif
}

- (void)storeProduct:(NSString *)productIdentifier {
//    NSError *error = nil;
//    
//#ifdef SAVE_RECORD_IN_KEYCHAIN
//    [SFHFKeychainUtils storeUsername:productIdentifier
//                         andPassword:defaultValue()
//                      forServiceName:keychainServiceName()
//                      updateExisting:YES
//                               error:&error];
//#else
//    [SBPurchaseRecordUtils storeUsername:productIdentifier
//                             andPassword:defaultValue()
//                          forServiceName:keychainServiceName()
//                          updateExisting:YES
//                                   error:&error];
//#endif
//    
//#ifdef DEBUG
//    if(error) {
//        NSLog(@"Store product error:%@", error);
//    }
//#endif

    //上面的实现已经挪到+ (void)storeTheProduct:(NSString *)productIdentifier中
    [SBPaymentManager storeTheProduct:productIdentifier];
}

- (void)clearProductRecord:(NSString *)productIdentifier {
    NSError *error = nil;
     [SBPurchaseRecordUtils deleteItemForUsername:productIdentifier andServiceName:keychainServiceName() error:&error];
    
#ifdef DEBUG
    if(error) {
        NSLog(@"Clear product error:%@", error);
    }
#endif
}

NSString * keychainServiceName() {
    return [[NSBundle mainBundle] bundleIdentifier];
}

NSString * defaultValue() {
    return @"YES";
}

+ (BOOL)hasRecord:(NSString *)productIdentifier {
    NSError *error = nil;
    NSString *password = [SBPurchaseRecordUtils getPasswordForUsername:productIdentifier
                                                    andServiceName:keychainServiceName()
                                                             error:&error];
    
    if (![password isEqualToString:defaultValue()]) {
        //如果SBPurchaseRecordUtils没从本地配置文件中取到购买记录，则从老方案中取一遍
//        password = [SFHFKeychainUtils getPasswordForUsername:productIdentifier
//                                              andServiceName:keychainServiceName()
//                                                       error:&error];
        if ([password isEqualToString:defaultValue()]) {
            // 钥匙串中如果取到购买记录，则存储到本地配置文件中
//            [[SBPaymentManager defaultManager] storeProduct:productIdentifier]; //本方法会初始化defaultManager 影响性能
            [SBPaymentManager storeTheProduct:productIdentifier];
            NSLog(@"get purchase state from SFHFKeychainUtils");
        }
    }    
    
#ifdef DEBUG
    if(error) {
        NSLog(@"Read product error:%@", error);
    }
#endif
    return [password isEqualToString:defaultValue()];
}

#pragma mark - Accessory
- (NSMutableDictionary *)productRequesterDict {
    if(_productRequesterDict == nil) {
        _productRequesterDict = [[NSMutableDictionary alloc]initWithCapacity:5];
    }
    return _productRequesterDict;
}

- (NSMutableDictionary *)paymentDelegateDict {
    if(_paymentDelegateDict == nil) {
        _paymentDelegateDict = [[NSMutableDictionary alloc]initWithCapacity:5];
    }
    return _paymentDelegateDict;
}

//- (KeychainItemWrapper *)paymentRecoder {
//    if(_paymentRecoder == nil) {
//        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
//        NSString *accessGroup = bundleID;
//        _paymentRecoder = [[KeychainItemWrapper alloc] initWithIdentifier:bundleID accessGroup:accessGroup];
//    }
//    return _paymentRecoder;
//}

@end
