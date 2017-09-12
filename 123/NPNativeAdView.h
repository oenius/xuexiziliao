//
//  NPNativeAdView.h
//  Common
//
//  Created by mayuan on 16/10/24.
//  Copyright © 2016年 camory. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NPNativeAdViewCloseType) {
    NPNativeAdViewCloseTypeCoverAdLeftTop,                          //关闭按钮覆盖广告左上角，可点击
    NPNativeAdViewCloseTypeNotCoverAd,                              //关闭按钮不覆盖广告，在底部
    NPNativeAdViewCloseTypeWithBottomRmoveAds,                       //关闭按钮在底部，以及移除广告按钮
    NPNativeAdViewCloseTypeNotCoverAdLeftTop                                  // 关闭按钮在左上角，不覆盖广告
};

@interface NPNativeAdView : UIView

- (void)loadAndShowNativeViewInView:(UIView *)superView;


@end
