//
//  CABaseAdController.m
//  Common
//
//  Created by mayuan on 2017/6/6.
//  Copyright © 2017年 camory. All rights reserved.
//

#import "CVBaseAdController.h"

@implementation CVBaseAdController

- (id)init{
    self = [super init];
    if(self != nil){
        self.viewController = [[CVAdvertiseViewController alloc]init];
    }
    return self;
}

- (void)preLoadAds{
    
}

- (void)removeAllAds{
    
}



- (void)loadBannerViewComplete:(CompleteWithBannerView)complete{
    
}

//- (void)loadInterstitialComplete:(CompleteWithInterstitial)complete{
//    
//}

- (void)loadNativeSmallViewComplete:(CompleteWithNativeSmallView)complete{
    
}
- (void)loadNativeMidViewComplete:(CompleteWithNativeMidView)complete{
    
}
- (void)loadNativeLargeViewComplete:(CompleteWithNativeLargeView)complete{
    
}

- (void)loadNativeLaunchViewComplete:(CompleteWithNativeLaunchView)complete{
    
}

- (void)clearNativeLaunchView{
    
}

- (void)loadInterstitial {
    // 子类实现
}

// 全屏广告 是否加载回来，并且可以显示（已显示中的全屏广告不可以重新present, fb会崩溃）
- (BOOL)isInterstitialCanShow{
    return NO;
}

- (BOOL)isInterstitialLoadedReady{
    return false;
}

- (BOOL)isRewardVideoLoadedReady{
    return false;
}

 
- (void)showInterstitial:(UIViewController *)controller{
    
}


- (void)showRewardVideoFromRootViewController:(UIViewController *)controller {
    
}


@end
