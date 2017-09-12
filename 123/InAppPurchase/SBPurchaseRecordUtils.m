//
//  SBPurchaseRecordUtils.m
//  CommonNoArc
//
//  Created by zhouxingfa on 14-5-5.
//  Copyright (c) 2014年 zzf. All rights reserved.
//

#import "SBPurchaseRecordUtils.h"
//#import "CCPreference.h"
//#import "CCMacros.h"

/*
 * 内购项购买记录，购买与否记录于此字典 其内容形如
 */
#define kSBInAppPurchaseRecordList @"SBInAppPurchaseRecordList"

//内购项数据key，兼容以前存在钥匙串中的数据结构
#define kSBInAppPurchaseRecordItemUsername     @"SBInAppPurchaseRecordItemUsername"
#define kSBInAppPurchaseRecordItemServiceName  @"SBInAppPurchaseRecordItemServiceName"
#define kSBInAppPurchaseRecordItemPassword     @"SBInAppPurchaseRecordItemPassword"

@implementation SBPurchaseRecordUtils


+ (NSString *) getPasswordForUsername: (NSString *) username
					   andServiceName: (NSString *) serviceName
     						error: (NSError **) error{
    
    if (username== nil || serviceName == nil) {
        *error = [NSError errorWithDomain:[self description] code:-2000 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"username or serviceName Can not be nil for get password",NSLocalizedDescriptionKey,nil]];
        return nil;
    }
    
    NSDictionary * purchaseListDic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kSBInAppPurchaseRecordList];   // [[CCPreference sharedPreference] objectForKey:kSBInAppPurchaseRecordList];
    
    //本地配置项中没有相关记录
    if (purchaseListDic == nil) {
       return  nil;
    }
    
    // 本地配置项中内购项名为username的内购记录字典
    NSDictionary *purchaseDic = [purchaseListDic objectForKey:username];
    
    if (purchaseDic == nil) {
        return nil;
    }
    
    //
    NSString *theUseName = [purchaseDic objectForKey:kSBInAppPurchaseRecordItemUsername];
    NSString *theServiceName = [purchaseDic objectForKey:kSBInAppPurchaseRecordItemServiceName];
    NSString *thePassword = [purchaseDic objectForKey:kSBInAppPurchaseRecordItemPassword];
    
    if ([theUseName isEqualToString:username] && [theServiceName isEqualToString:serviceName]) {
        return thePassword ;
    }else{
#ifdef DEBUG
        NSLog(@"purchaseListDic = %@ , purchaseDic = %@",purchaseListDic,purchaseDic);
#endif
    }
    
    return nil ;
}

+ (BOOL) storeUsername: (NSString *) username
		   andPassword: (NSString *) password
		forServiceName: (NSString *) serviceName
		updateExisting: (BOOL) updateExisting
				 error: (NSError **) error{
    
    if (!username ||  !password || !serviceName) {
        *error = [NSError errorWithDomain:[self description] code:-2000 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"username or serviceName  or password Can not be nil",NSLocalizedFailureReasonErrorKey ,@"username or serviceName or password Can not be nil",NSLocalizedDescriptionKey,nil]];

        return NO ;
    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:1];
    NSDictionary *oldList = [userDefault dictionaryForKey:kSBInAppPurchaseRecordList];
    if (oldList) {
        [result addEntriesFromDictionary:oldList];
    }
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:username,kSBInAppPurchaseRecordItemUsername,password,kSBInAppPurchaseRecordItemPassword,serviceName,kSBInAppPurchaseRecordItemServiceName,nil];
    [result setValue:dic forKey:username];
    
    [userDefault setObject:result forKey:kSBInAppPurchaseRecordList];
    [userDefault synchronize];
#ifdef DEBUG
    NSLog(@"after store item SBInAppPurchaseRecordList = %@",[userDefault objectForKey:kSBInAppPurchaseRecordList]);
#endif
    return YES;
}


+ (BOOL) deleteItemForUsername: (NSString *) username
				andServiceName: (NSString *) serviceName
						 error: (NSError **) error{
    if (!username || !serviceName) {
        *error = [NSError errorWithDomain:[self description] code:-2000 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"username or serviceName Can not be nil for delete purchase item",NSLocalizedFailureReasonErrorKey ,@"username or serviceName Can not be nil delete purchase item",NSLocalizedDescriptionKey,nil]];
        return NO ;
    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:1];
    NSDictionary *oldList = [userDefault dictionaryForKey:kSBInAppPurchaseRecordList];
    if (oldList) {
        [result addEntriesFromDictionary:oldList];
    }
    if ([result objectForKey:username]) {
        [result removeObjectForKey:username];
        
        [userDefault setObject:result forKey:kSBInAppPurchaseRecordList];
        [userDefault synchronize];
#ifdef DEBUG
        NSLog(@"after delete item SBInAppPurchaseRecordList = %@",[userDefault objectForKey:kSBInAppPurchaseRecordList]);
#endif
        return YES;
    }
    return NO;
}


@end
