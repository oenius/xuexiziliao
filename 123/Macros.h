//
//  Macros.h
//  Common
//
//  Created by mayuan on 16/7/15.
//  Copyright © 2016年 camory. All rights reserved.
//

#ifndef Macros_h
#define Macros_h


// 用户是否内购移除广告，默认为 NO
#define  Key_User_Have_Removed_AD       @"Key_User_Have_Removed_AD"

#define  Key_User_ViewAppear_BeforePrompt_Count                     @"Key_User_ViewAppear_BeforePrompt_Count"
#define  Key_User_ViewAppear_Before_FullscreenAd                    @"Key_User_ViewAppear_Before_FullscreenAd"

#define  Key_Total_InterstitialShowAndDismissCount                  @"Key_Total_InterstitialShowAndDismissCount"

#define kAdvertiseGoogleNativeLaunchViewWillLiveApplicationNotification         @"kAdvertiseGoogleNativeLaunchViewWillLiveApplicationNotification"

#define kAdvertiseRemoveAdsNotification                             @"kAdvertiseRemoveAdsNotification"




#define kAdvertiseGoogleRewardBaseVideoDidOpenNotification                     @"kAdvertiseGoogleRewardBaseVideoDidOpenNotification"
#define kAdvertiseGoogleRewardBaseVideoDidCloseNotification                     @"kAdvertiseGoogleRewardBaseVideoDidCloseNotification"

#define kNetworkStateChangedNotification                            @"kNetworkStateChangedNotification"
#define keyNotificationNetworkState                                 @"keyNotificationNetworkState"


#define kGetPriceWhenInstallNotification                            @"kGetPriceWhenInstallNotification"

// Admobe interstitial ad Notification , 仅内部使用
#define kAdvertiseGoogleInterstitialNotification                            @"kAdvertiseGoogleInterstitialNotification"
#define kAdvertiseGoogleInterstitialWillPresentNotification                 @"kAdvertiseGoogleInterstitialWillPresentNotification"
#define kAdvertiseGoogleInterstitialWillLiveApplicationNotification         @"kAdvertiseGoogleInterstitialWillLiveApplicationNotification"
#define kAdvertiseGoogleInterstitialDidDismisstNotification                 @"kAdvertiseGoogleInterstitialDidDismisstNotification"

// Facebook interstitial ad Notification， 仅内部使用
#define kAdvertiseFacebookInterstitialNotification                            @"kAdvertiseFacebookInterstitialNotification"
#define kAdvertiseFacebookInterstitialWillPresentNotification                 @"kAdvertiseFacebookInterstitialWillPresentNotification"
#define kAdvertiseFacebookInterstitialWillLiveApplicationNotification         @"kAdvertiseFacebookInterstitialWillLiveApplicationNotification"
#define kAdvertiseFacebookInterstitialDidDismisstNotification                 @"kAdvertiseFacebookInterstitialDidDismisstNotification"


// facebook launch view  network error
#define keyFacebookNativeLaunchNetworkErrorNotification         @"keyFacebookNativeLaunchNetworkErrorNotification"
// Both interstitial ad Notification， 对外使用
#define keyInterstitialNotification                             @"keyInterstitialNotification"
#define keyInterstitialWillPresentNotification                  @"keyInterstitialWillPresentNotification"
#define keyInterstitialWillLiveApplicationNotification          @"keyInterstitialWillLiveApplicationNotification"
#define keyInterstitialDidDismisstNotification                  @"keyInterstitialDidDismisstNotification"

#define keyFacebookReachabilityNotification                 @"keyFacebookReachabilityNotification"

#define keyLaunchAdViewDismissNotification                  @"keyLaunchAdViewDismissNotification"

// 半屏 广告加载后的通知
#define kAdvertiseGoogleNative250HADViewNotification                    @"kAdvertiseGoogleNative250HADViewNotification"
// 半屏广告 被点击后跳出应用
#define kAdvertiseGoogleNative250HADViewWillLiveApplicationNotification         @"kAdvertiseGoogleNative250HADViewWillLiveApplicationNotification"


#ifdef DEBUG
#define LOG(...) NSLog(__VA_ARGS__)
#define LOG_METHOD NSLog(@"%s", __func__)
#else
#define LOG(...);
#define LOG_METHOD
#endif

#define LOCALIZED(...)      NSLocalizedString(__VA_ARGS__, @"")

#define FORMAT(format, ...) [NSString stringWithFormat: (format), ##__VA_ARGS__]
#define FORMAT_INT(...)     [NSString stringWithFormat: @"%d", __VA_ARGS__]

#endif /* Macros_h */
