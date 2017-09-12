//
//  NPLaunchAdViewController.m
//  Common
//
//  Created by mayuan on 2017/6/2.
//  Copyright © 2017年 camory. All rights reserved.
//

#import "NPLaunchAdViewController.h"
#import "CVAdvertiseController.h"
#import "NPCommonConfig.h"
#import "Macros.h"
#import "CVFBConnectDetector.h"
#import "PDCFBAd_View.h"


@interface NPLaunchAdViewController (){
    
}

@property (weak, nonatomic) IBOutlet UIView *admobNativeLaunchView;

@property (weak, nonatomic) IBOutlet UIView *bottomIconNameView;

@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@property (assign, nonatomic) NPLaunchViewDismissType dismissType;

@property (assign,nonatomic) NSInteger timeCount;

@property (assign, nonatomic) BOOL skipButtonEnable;
@property (assign, nonatomic) BOOL isAdLoaded;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (nonatomic, strong) UIView *launchAdView;

@end

@implementation NPLaunchAdViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat adViewHeight = screenHeight * 0.8125f;
    CGFloat bottomViewHeight = screenHeight * 0.1875f;
    
    self.admobNativeLaunchView.frame = CGRectMake(0, 0, screenWidth, adViewHeight);
    self.bottomIconNameView.frame = CGRectMake(0, adViewHeight, screenWidth, bottomViewHeight);
    
    // set skip button frame
    CVAdPlatformPriorityStrategy *adPlatformPriorityStrategy = [NPCommonConfig shareInstance].adPlatformPriorityStrategy;
    NPAdPlatform adPlatform = [adPlatformPriorityStrategy defaultFirstAdPlatform];
    if (adPlatform == NPAdPlatformAdmob) {
        // 竖屏
        if (screenWidth < adViewHeight) {
            CGFloat skipButtonPointX = screenWidth  - 50;
            CGFloat skipButtonPointY = (adViewHeight - screenWidth)/2.0 - 10;
            self.skipButton.center = CGPointMake(skipButtonPointX, skipButtonPointY);
        }else{
            // 横屏
            CGFloat skipButtonPointX = screenWidth  - 50;
            CGFloat skipButtonPointY = 70;
            self.skipButton.center = CGPointMake(skipButtonPointX, skipButtonPointY);
        }
    }else{
        // 竖屏
        if (screenWidth < adViewHeight) {
            CGFloat skipButtonPointX = screenWidth  - 50;
            CGFloat skipButtonPointY = (adViewHeight - screenWidth)/2.0 + screenWidth + 10;
            self.skipButton.center = CGPointMake(skipButtonPointX, skipButtonPointY);
        }else{
            // 横屏
        }
    }
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

//- (void)dealloc {
////    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    _timeCount = 6;
    NSString *launchViewCenterContentStr = [NPCommonConfig shareInstance].launchViewCenterContentStr;
    if (launchViewCenterContentStr.length > 0) {
        self.launchViewAdTitleLabel.text = launchViewCenterContentStr;
    }
    
    NSString *launchViewAppTitleStr  = [NPCommonConfig shareInstance].launchViewAppTitle;
    if (launchViewAppTitleStr.length > 0) {
        self.iconTitleLabel.text = launchViewAppTitleStr;
    }
    NSString *launchViewAppSubtitleStr  = [NPCommonConfig shareInstance].launchViewAppSubtitle;
    if (launchViewAppSubtitleStr.length > 0) {
        self.iconSubtitleLabel.text = launchViewAppSubtitleStr;
    }
    
    self.admobNativeLaunchView.hidden = NO;
    [self startCountdownTiming];
    self.skipButtonEnable = YES;
    self.closeButton.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkStateChanged:) name:kNetworkStateChangedNotification object:nil];
    
    CGSize admobViewSize = self.admobNativeLaunchView.frame.size;
    CGFloat adViewWidth = admobViewSize.width;
    if (adViewWidth > 1200) {
        adViewWidth = 1200;
    }
    CGFloat adViewHeight = admobViewSize.height;
    if (adViewHeight > 1200) {
        adViewHeight = 1200;
    }
//    CGFloat minWidth = MIN(adViewWidth, adViewHeight);
    [NPCommonConfig shareInstance].nativeLaunchAdViewSize = CGSizeMake(adViewWidth, adViewHeight);
    
    CVAdPlatformPriorityStrategy *adPlatformPriorityStrategy = [NPCommonConfig shareInstance].adPlatformPriorityStrategy;
    BOOL shouldDetectNetworkAndFixPriority = [adPlatformPriorityStrategy shouldFixAdPlatformPriority];
    if (NO == shouldDetectNetworkAndFixPriority) {
        [self loadAdvertise];
    }else{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFacebookReachabilityNotification:) name:keyFacebookReachabilityNotification object:nil];
        BOOL isNetConnect = [NPCommonConfig shareInstance].isNetworkConnected;
        if (isNetConnect) {
            [[CVFBConnectDetector shareInstance] detectFacebookAdReachability];
        }
    }
}


- (void)loadAdvertise {
    #ifndef ISPRO
    __weak __typeof(self)weakSelf = self;
    [[CVAdvertiseController shareInstance] achieveNativeLaunchAdView:^(UIView *launchAdView) {
        launchAdView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        __strong __typeof(weakSelf)strongSelf = weakSelf;
         LOG(@"%s, timeCount: %d",__func__, strongSelf.timeCount);
        if (strongSelf) {
//            if (strongSelf.timeCount <3) {
//                strongSelf.timeCount = 3;
//            }
            strongSelf.isAdLoaded = YES;
            strongSelf.launchAdView = launchAdView;
            strongSelf.skipButtonEnable = NO;
            strongSelf.admobNativeLaunchView.hidden = NO;
            strongSelf.launchViewAdTitleLabel.hidden = YES;
            launchAdView.center = strongSelf.admobNativeLaunchView.center;
            [strongSelf.admobNativeLaunchView addSubview:launchAdView];
            [strongSelf.admobNativeLaunchView bringSubviewToFront:strongSelf.skipButton];
            
            if ([launchAdView isKindOfClass:[PDCFBAd_View class]]) {
                PDCFBAd_View *fbAdView = (PDCFBAd_View *)launchAdView;
                [fbAdView registerInteractionForView:strongSelf.admobNativeLaunchView];
            }
            
            launchAdView.alpha = 0;
            [UIView animateWithDuration:0.1 animations:^{
                launchAdView.alpha = 1;//逐渐变为透明
            } completion:^(BOOL finished) {
            }];
        }
    }];
    #endif
}

- (void)onFacebookReachabilityNotification:(NSNotification *)notification {
    NSNumber *enableFacebook = notification.object;
    if (NO == enableFacebook.boolValue) {
        //默认可以连接，当不可以连接时需要重新配置优先级
#ifndef ISPRO
        [[CVAdvertiseController shareInstance] setupAdPlatformsAndConfigPrioritys];
#endif
    }

    [self loadAdvertise];

}

- (void)onNetworkStateChanged:(NSNotification *)notification {
    NSNumber *enableNetwork = notification.object;
    if (enableNetwork.boolValue) {
         LOG(@"%s, detect times",__func__);
        CVAdPlatformPriorityStrategy *adPlatformPriorityStrategy = [NPCommonConfig shareInstance].adPlatformPriorityStrategy;
        BOOL shouldDetectNetworkAndFixPriority = [adPlatformPriorityStrategy shouldFixAdPlatformPriority];
        if (NO == shouldDetectNetworkAndFixPriority) {
            [self loadAdvertise];
        }else{
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFacebookReachabilityNotification:) name:keyFacebookReachabilityNotification object:nil];
            BOOL isNetConnect = [NPCommonConfig shareInstance].isNetworkConnected;
            if (isNetConnect) {
                [[CVFBConnectDetector shareInstance] detectFacebookAdReachability];
            }
        }
    }
}

- (void)onAdmobNativeLaunchViewNotification:(NSNotification *)notification {
    self.dismissType = NPLaunchViewDismissTypeAdViewTouched;
    [self dissmissWithType:self.dismissType];
}


- (void)startCountdownTiming{
    //全局队列    默认优先级
    dispatch_queue_t quene = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //定时器模式  事件源
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, quene);
    //NSEC_PER_SEC是秒，＊1是每秒
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), NSEC_PER_SEC * 1, 0);
    //设置响应dispatch源事件的block，在dispatch源指定的队列上运行
    BOOL shouldAutoDismiss = [NPCommonConfig shareInstance].shouldLaunchViewAutoDismiss;
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{
        //回调主线程，在主线程中操作UI
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.timeCount >= 0) {
                    [weakSelf.skipButton setTitle:[NSString stringWithFormat:@"%ld",weakSelf.timeCount] forState:UIControlStateNormal];
                weakSelf.timeCount--;
            }else{
                //这句话必须写否则会出问题
                dispatch_source_cancel(timer);

                if (weakSelf.presentedViewController) {
                    weakSelf.skipButtonEnable = YES;
                    weakSelf.skipButton.hidden = YES;
                    weakSelf.closeButton.hidden = NO;
                }else{
                    if ((NO == shouldAutoDismiss) && weakSelf.isAdLoaded){
                        weakSelf.skipButtonEnable = YES;
                        weakSelf.skipButton.hidden = YES;
                        weakSelf.closeButton.hidden = NO;
                    }else{
                        weakSelf.dismissType = NPLaunchViewDismissTypeTimeout;
                        [weakSelf dissmissWithAnimation];
                    }
                }
            }
        });
    });
    //启动源
    dispatch_resume(timer);
}

- (void)dissmissWithAnimation{
    [UIView animateWithDuration:0.2 animations:^{
        self.view.backgroundColor = [UIColor purpleColor];//颜色渐变为紫色
        self.view.alpha = 0.2;//逐渐变为透明
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
        [self.view removeFromSuperview];
        [self dissmissWithType:self.dismissType];
    }];
}

-(void)dissmissWithType:(NPLaunchViewDismissType)dismissType
{
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
    if (self.dismiss) {
        self.dismiss(dismissType);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:keyLaunchAdViewDismissNotification object:nil];
}

- (IBAction)onSkipButtonTouched:(id)sender {
    if (self.skipButtonEnable == NO) {
        return;
    }
    self.dismissType = NPLaunchViewDismissTypeSkipButtonTouched;
    [self dissmissWithType:self.dismissType];
}

- (IBAction)onCloseButtonTouched:(id)sender {
    self.dismissType = NPLaunchViewDismissTypeSkipButtonTouched;
    [self dissmissWithType:self.dismissType];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate{
    return NO;
}

@end
