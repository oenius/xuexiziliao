//
//  NPLaunchAdViewController.h
//  Common
//
//  Created by mayuan on 2017/6/2.
//  Copyright © 2017年 camory. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NPLaunchViewDismissType) {
    NPLaunchViewDismissTypeTimeout,
    NPLaunchViewDismissTypeSkipButtonTouched,
    NPLaunchViewDismissTypeAdViewTouched
};

typedef void (^DismissComplete) (NPLaunchViewDismissType dismissType);


@interface NPLaunchAdViewController : UIViewController

@property (copy, nonatomic) DismissComplete dismiss;

@property (weak, nonatomic) IBOutlet UILabel *launchViewAdTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *iconTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *iconSubtitleLabel;


@end
