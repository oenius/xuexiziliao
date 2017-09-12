//
//  CVAdmobAdController.h
//  Common
//
//  Created by mayuan on 2017/6/6.
//  Copyright © 2017年 camory. All rights reserved.
//

#import "CVBaseAdController.h"

typedef void (^CompleteWithCustomHalfScreenView)(UIView *nativeHalfScreenView, CVBaseAdController *adController);


@interface CVAdmobAdController : CVBaseAdController

@property (nonatomic, copy) CompleteWithCustomHalfScreenView completeCustomHalfScreenView;


//- (void)loadInterstitialAdComplete:(CompleteWithInterstitial)complete;

- (void) loadCustomHalfScreenAdComplete:(CompleteWithCustomHalfScreenView)complete;

@end
