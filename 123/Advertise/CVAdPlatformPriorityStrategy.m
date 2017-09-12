//
//  CVAdPlatformPriorityStrategy.m
//  Common
//
//  Created by mayuan on 2017/6/8.
//  Copyright © 2017年 camory. All rights reserved.
//

#import "CVAdPlatformPriorityStrategy.h"
#import "Macros.h"
#import "CVFBConnectDetector.h"

@implementation CVAdPlatformPriorityStrategy

- (NPAdPlatform) defaultFirstAdPlatform{
   NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    NSString *countryCodeLowercaseStr = countryCode.lowercaseString;
     LOG(@"%s, countryCode: %@",__func__, countryCode);
    if ([countryCodeLowercaseStr isEqualToString:@"cn"] || [countryCodeLowercaseStr isEqualToString:@"zh"]) {
        return NPAdPlatformAdmob;
    }
    
    return NPAdPlatformFacebook;
}

- (NPAdPlatform) bannerViewFirstAdPlatform{
    return NPAdPlatformUnkown;
}

- (NPAdPlatform) nativeSmallViewFirstAdPlatform{
    return NPAdPlatformUnkown;

}

- (NPAdPlatform) nativeMidViewFirstAdPlatform{
    return NPAdPlatformUnkown;

}

- (NPAdPlatform) nativeLargeViewFirstAdPlatform{
    return NPAdPlatformUnkown;

}

- (NPAdPlatform) nativeLaunchViewFirstAdPlatform{
    return NPAdPlatformUnkown;

}

- (NPAdPlatform) interstitialFirstAdPlatform{
    return NPAdPlatformUnkown;
}

- (NPAdPlatform) fixedFirstAdPlatformForOriginalAdPlatform:(NPAdPlatform)originalAdPlatform {
    if (originalAdPlatform == NPAdPlatformAdmob) {
        return NPAdPlatformAdmob;
    }
    // 非 Admob 检测网络状态后，重置优先级
    BOOL haveDetectNetwork = [CVFBConnectDetector shareInstance].haveDetectNetwork;
    if (haveDetectNetwork) {
        BOOL isFacebookConnect = [CVFBConnectDetector shareInstance].isFacebookReachable;
        if (NO ==isFacebookConnect) {
            return NPAdPlatformAdmob;
        }
    }
    return NPAdPlatformFacebook;
}


// 是否需要根据 FB 链接状态修正优先级
- (BOOL) shouldFixAdPlatformPriority{
    NPAdPlatform defaultAdPlatform = [self defaultFirstAdPlatform];
    if (defaultAdPlatform == NPAdPlatformAdmob) {
        return NO;
    }
    return YES;
}

@end
