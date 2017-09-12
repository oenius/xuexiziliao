//
//  PDCFBAd_View.h
//  NativeAdSample
//
//  Created by 何驱之 on 2017/5/8.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>

//#define kScreenWidth    [UIScreen mainScreen].bounds.size.width
//#define kScreenHeight    [UIScreen mainScreen].bounds.size.height

typedef NS_ENUM(NSInteger, PDCAdFrameType) {
    PDCAdFrameType_Cell = 140,
    PDCAdFrameType_View = 300,
    //    PDCAdFrameType_Icon,
};

@interface PDCFBAd_View : UIView


@property (strong, nonatomic) UIImageView *adIconImageView;
@property (strong, nonatomic) FBAdChoicesView *adChoicesView;
@property (strong, nonatomic) UILabel *adTitleLabel;
@property (strong, nonatomic) UILabel *sponsoredLabel;
@property (strong, nonatomic) UIButton *adCallToActionButton;
@property (strong, nonatomic) UILabel *adBodyLabel;
@property (strong, nonatomic) UILabel *adSocialContextLabel;
@property (strong, nonatomic) FBMediaView *adCoverMediaView;


- (void)loadDataWithFBNaviveAd:(FBNativeAd *)nativeAd controller:(UIViewController *)controller;

- (void)registerInteractionForView:(UIView *)actionView;

- (void)reDrawRectWithHeight:(float)heightMax frameType:(PDCAdFrameType)frameType;

@end
