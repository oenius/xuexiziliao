//
//  SBPurchaseRecordUtils.h
//  CommonNoArc
//
//  Created by zhouxingfa on 14-5-5.
//  Copyright (c) 2014年 zzf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBPurchaseRecordUtils : NSObject

+ (NSString *) getPasswordForUsername: (NSString *) username
					   andServiceName: (NSString *) serviceName
								error: (NSError **) error;


+ (BOOL) storeUsername: (NSString *) username
		   andPassword: (NSString *) password
		forServiceName: (NSString *) serviceName
		updateExisting: (BOOL) updateExisting
				 error: (NSError **) error;


+ (BOOL) deleteItemForUsername: (NSString *) username
				andServiceName: (NSString *) serviceName
						 error: (NSError **) error;

@end
