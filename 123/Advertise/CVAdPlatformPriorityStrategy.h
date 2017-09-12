//
//  CVAdPlatformPriorityStrategy.h
//  Common
//
//  Created by mayuan on 2017/6/8.
//  Copyright © 2017年 camory. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, NPAdPlatform) {
    NPAdPlatformUnkown,
    NPAdPlatformAdmob,
    NPAdPlatformFacebook
};


// 如果需要自定义 优先级，请之类化 该 策略类
@interface CVAdPlatformPriorityStrategy : NSObject


- (NPAdPlatform) defaultFirstAdPlatform;

// if return 'NPAdPlatformUnkown', use 'defaultFirstAdPlatform''s return value
- (NPAdPlatform) bannerViewFirstAdPlatform;

// if return 'NPAdPlatformUnkown', use 'defaultFirstAdPlatform''s return value
- (NPAdPlatform) nativeSmallViewFirstAdPlatform;

- (NPAdPlatform) nativeMidViewFirstAdPlatform;

- (NPAdPlatform) nativeLargeViewFirstAdPlatform;

- (NPAdPlatform) nativeLaunchViewFirstAdPlatform;

- (NPAdPlatform) interstitialFirstAdPlatform;


- (NPAdPlatform) fixedFirstAdPlatformForOriginalAdPlatform:(NPAdPlatform)originalAdPlatform;

- (BOOL) shouldFixAdPlatformPriority;


@end
