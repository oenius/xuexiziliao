//
//  DeviceModel.h
//  BatteryDoctor
//

//  Copyright © 2016年 hj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceModel : NSObject

+ (instancetype)sharedModel;
+ (NSString *)platform ;


@property (nonatomic, assign) NSInteger device_no;
@property (nonatomic, copy)  NSString * device_name;
@property (nonatomic, copy)  NSString * battery_capacity;
@property (nonatomic, copy)  NSString * ramdom_access_memory;

@end
