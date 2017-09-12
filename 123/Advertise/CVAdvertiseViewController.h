//
//  CVAdvertiseViewController.h
//  CloudPlayer
//
//  Created by Huaming.Zhu on 16/4/21.
//  Copyright © 2016年 __VideoApps___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface CVAdvertiseViewController : UIViewController
<
FBNativeAdDelegate
>



- (void)loadAdvertiseData;

- (void)advertiseDidLoad:(UIView *)adView;

- (void)advertiseFailedToLoadWithError:(NSError *)error;

- (void)advertiseDidClick:(FBNativeAd *)nativeAd;

- (void)advertiseDidFinishHandlingClick:(FBNativeAd *)nativeAd;

@end
