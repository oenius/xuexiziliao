//
//  NPGoProButton.m
//  Common
//
//  Created by mayuan on 16/10/11.
//  Copyright © 2016年 camory. All rights reserved.
//

#import "NPGoProButton.h"
#import "SettingsLocalizeUtil.h"
#import "SBPaymentLocalizeUtil.h"
#import "NPCommonConfig.h"
NSString *appLinkIniTunesURLFormat = @"itms-apps://itunes.apple.com/app/id%@";


@implementation NPGoProButton

+(instancetype)goProButton{
    NPGoProButton *button = [self buttonWithType:UIButtonTypeSystem];
    [button configWithFrame:CGRectZero];
    return button;
}

+(instancetype)goProButtonWithFrame:(CGRect)buttonFrame{
    NPGoProButton *button = [self buttonWithType:UIButtonTypeSystem];
    [button configWithFrame:buttonFrame];
    return button;
}

+(instancetype)goProButtonWithImage:(UIImage *)buttonImage Frame:(CGRect)buttonFrame{
    NPGoProButton *button = [self buttonWithType:UIButtonTypeCustom];
    [button configWithImage:buttonImage buttonFrame:buttonFrame];
    return button;
}

- (void)configWithFrame:(CGRect)buttonFrame {
    if (buttonFrame.size.width == 0 || buttonFrame.size.height == 0) {
        self.frame = CGRectMake(0, 0, 35, 35);
    }else{
        self.frame = buttonFrame;
    }
    [self setTitle:@"Pro" forState:UIControlStateNormal];
    CGFloat frameWidth = self.frame.size.width;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:(frameWidth * 0.35)];
    [self addTarget:self action:@selector(onGoProButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configWithImage:(UIImage *)image buttonFrame:(CGRect)buttonFrame {
    if (buttonFrame.size.width == 0 || buttonFrame.size.height == 0) {
        self.frame = CGRectMake(0, 0, 35, 35);
    }else{
        self.frame = buttonFrame;
    }
    [self setImage:image forState:UIControlStateNormal];
    [self addTarget:self action:@selector(onGoProButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
}


- (void)onGoProButtonTouched:(id)sender {
    BOOL shouldAsk = [NPCommonConfig shareInstance].shouldAskUserWhenPressProButton;
    if (shouldAsk) {
        NSString *upgradeToProStr = [SettingsLocalizeUtil localizedStringForKey:@"Upgrade to Pro Version" withDefault:@"Upgrade to Pro Version"];
        NSString *noAdsMessage = [SBPaymentLocalizeUtil localizedStringForKey:@"No ads for perfect experience" withDefault:@"No ads for perfect experience"];
        NSString *cancelStr = [SBPaymentLocalizeUtil localizedStringForKey:@"cancel" withDefault:@"Cancel"];
        NSString *okStr = [SettingsLocalizeUtil localizedStringForKey:@"Sure" withDefault:@"OK"];
        //    NSString *remindStr = [SBPaymentLocalizeUtil localizedStringForKey:@"Remind info" withDefault:@"Remind info"];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:upgradeToProStr message:noAdsMessage preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:cancelStr style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:okStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self goToProVersionInAppStore];
        }]];
        [[self topMostController] presentViewController:alertController animated:YES completion:nil];
    }else{
        [self goToProVersionInAppStore];
    }
}

- (void)goToProVersionInAppStore {
    NSString *proAppID = [NPCommonConfig shareInstance].proAppId;;
    NSString *proAppLink = [NSString stringWithFormat:appLinkIniTunesURLFormat, proAppID];
    NSURL * url = [NSURL URLWithString:proAppLink];
    [[UIApplication sharedApplication] openURL:url];
}


- (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    CGFloat width = self.frame.size.width -8;
    self.titleLabel.frame = CGRectMake(0, 0, width, width);
    self.titleLabel.center = CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
    //        if (_type == NPInterstitialButtonTypeIcon) {
    self.titleLabel.layer.borderWidth = [UIScreen mainScreen].scale / 2.0f;
    self.titleLabel.layer.cornerRadius = self.titleLabel.frame.size.height / 2.0;
    self.titleLabel.layer.borderColor = self.titleLabel.textColor.CGColor;
    //        }
}

@end
