//
//  CVFBConnectDetector.h
//  Common
//
//  Created by mayuan on 2017/6/9.
//  Copyright © 2017年 camory. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CVFBConnectDetector : NSObject


@property (nonatomic, assign) BOOL isFacebookReachable;
// 是否检测过网络
@property (atomic, assign) BOOL haveDetectNetwork;

+ (CVFBConnectDetector *)shareInstance;


- (void) detectFacebookAdReachability;



@end
