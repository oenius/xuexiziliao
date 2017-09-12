//
//  CVBaseViewController.m
//  CloudPlayer
//
//  Created by zhouxingfa on 16/4/19.
//  Copyright © 2016年 __VideoApps___. All rights reserved.
//

#import "BaseViewController.h"
#import "CVAdvertiseController.h"
#import "Macros.h"
#import "iRate.h"
#import "NPCommonConfig.h"
#import "SettingsLocalizeUtil.h"
#import "SBPaymentLocalizeUtil.h"

@interface BaseViewController ()<UIWebViewDelegate>

@property(strong, nonatomic) UIView *bannerView;
@property(strong, nonatomic) UIView *nativeAdView;
@property(strong, nonatomic) UIView *native250HAdView;
@property(strong, nonatomic) UIView *native132HAdView;

@property (assign, nonatomic) BOOL bannerViewNeedHiden;
@property (assign, nonatomic) BOOL nativeViewNeedHiden;
@property (assign, nonatomic) BOOL native132HViewNeedHiden;
@property (assign, nonatomic) BOOL native250HViewNeedHiden;

@property (nonatomic, assign) BOOL isLastViewDidAppearShowAd;

@end

@implementation BaseViewController
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(advertiseInterstitialNotification:) name:keyInterstitialNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAdNotification:) name:kAdvertiseRemoveAdsNotification object:nil];
}

- (void)onNetworkStateChanged:(NSNotification *)notification {
    NSNumber *enableNetwork = notification.object;
    if (enableNetwork.boolValue) {
        [self loadAdsNeeded];
    }
}

- (void)advertiseInterstitialNotification:(NSNotification *)notification{
    // 全屏广告 加载状态变化的通知
}


- (void)removeAdNotification:(NSNotification *)notification{
    [self.bannerView removeFromSuperview];
    self.bannerView = nil;
    [self setAdEdgeInsets:UIEdgeInsetsZero];
    
    // remove nativeAdView;
    [self.nativeAdView removeFromSuperview];
    self.nativeAdView = nil;
    
    [self.native132HAdView removeFromSuperview];
    self.native132HAdView = nil;
    
    [self.native250HAdView removeFromSuperview];
    self.native250HAdView = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    BOOL  shouldIncrease = [self shouldIncreaseViewAppearCountForShowFullscreenAd];
    if (shouldIncrease) {
        [self increaseViewAppearCountForShowFullscreenAd];
    }
    LOG(@"%s, 子类重写了该方法，正确",__func__);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNetworkStateChangedNotification object:nil];
    LOG(@"%s, 子类重写了该方法，正确",__func__);
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    LOG(@"%s, 子类重写了该方法，正确",__func__);
    [self loadAdsNeeded];
    
    BOOL showAd = [self shouldShowFullScreenAd];
    if (showAd) {
        NPViewAppearDisplayFullScreenType fullScreenType = [NPCommonConfig shareInstance].fullScreenType;
        BOOL isSafe = [[NPCommonConfig shareInstance] isSafeForAppleReviewPeriod];
        switch (fullScreenType) {
            case NPViewAppearDisplayFullScreenTypeInterstitialOnly:{
                [[NPCommonConfig shareInstance] showInterstitialAdInViewController:self];
            }
                break;
            case NPViewAppearDisplayFullScreenTypeInterstitialWithNativeAd:{
                [[NPCommonConfig shareInstance] showFullScreenAdWithNativeAdAlertViewForController:self];
            }
                break;
            case NPViewAppearDisplayFullScreenTypeInterstitialWithNativeAdORRemindWatchVideo:{
                if (isSafe) {
                    [[NPCommonConfig shareInstance] showFullScreenAdORRemindRewardVideoAdForController:self];
                }else{
                    [[NPCommonConfig shareInstance] showFullScreenAdWithNativeAdAlertViewForController:self];
                }
            }
                break;
            default:{
                [[NPCommonConfig shareInstance] showFullScreenAdWithNativeAdAlertViewForController:self];
            }
                break;
        }
        [self clearViewAppearCountForShowFullscreenAd];
    }
    
    if (_isLastViewDidAppearShowAd == NO) {
        // 上次未显示广告，计数，可能弹出提示评论框。此处为了防止 和提示购买弹出同时弹出
        [[iRate sharedInstance] logEvent:NO];
    }
    
    if (showAd) {
        self.isLastViewDidAppearShowAd = YES;
    }else{
        self.isLastViewDidAppearShowAd = NO;
    }

    BOOL showAnimation = [NPCommonConfig shareInstance].enableBannerViewAnimation;
    if (showAnimation) {
        [self showAdsBtnAnimation:self.interstitialButton];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkStateChanged:) name:kNetworkStateChangedNotification object:nil];
    
}

- (void)loadAdsNeeded {
#ifndef ISPRO
    if ([self needLoadBannerAdView]) {
        [self achieveBannerView];
    }
    if ([self needLoadNativeAdView]) {
        [self achieveNativeAdView];
    }
    if ([self needLoadNative250HAdView]) {
        [self achieveNative250HAdView];
    }
    if ([self needLoadNative132HAdView]) {
        [self achieveNative132HAdView];
    }
#endif
}


- (BOOL)needsShowAdView{
    BOOL shouldShowAD = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    return shouldShowAD;
}


- (void)achieveBannerView{
    if([self needsShowAdView] == false){
        return;
    }
#ifndef ISPRO
    if (self.bannerViewNeedHiden) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[CVAdvertiseController shareInstance] achieveBannerView:^(UIView *bannerView) {
        if(bannerView == nil){
            return ;
        }
        if (weakSelf.bannerView == nil) {
            UIView *bannerSuperView = [[UIView alloc]initWithFrame:bannerView.bounds];
            bannerSuperView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
            [bannerSuperView addSubview:bannerView];
            weakSelf.bannerView = bannerSuperView;
            [weakSelf.view addSubview:weakSelf.bannerView];
            NSLog(@"%s, add new bannerView",__func__);
            
        }else{
            [weakSelf.bannerView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
            [weakSelf.bannerView addSubview:bannerView];
            NSLog(@"%s, reload new bannerView",__func__);
        }
        [weakSelf adjustAdview];
        
        BOOL enableAnimation = [NPCommonConfig shareInstance].enableBannerViewAnimation;
        if (enableAnimation) {
            [weakSelf randomAnimationWithView:self.bannerView];
        }
    }];
#endif
}

#pragma mark - 广告动画

#define Duration         0.25f
#define Delay            0.0f
#define SpringDamping    0.1f
#define SpringVelocity   10.0f


- (void)randomAnimationWithView:(UIView *)view {
#ifndef ISPRO
    NSInteger index = arc4random() % 6;
     LOG(@"%s, index: %ld ",__func__, index);
    switch (index) {
//        case 0:{
//            [self transitionWithType:kCATransitionMoveIn forView:view];
//            break;
//        }
//        case 1:{
//            [self animationWithView:view WithAnimationTransition:UIViewAnimationTransitionFlipFromLeft];
//            break;
//        }
//        case 2:{
//            [self leftRightShakeAnimateForView:view];
//            break;
//        }
//        case 3:{
//            [self topBottomShakeAnimateForView:view];
//            break;
//        }
//        case 4: {
//            [self scaleAnimationForView:view];
//            break;
//        }
//        case 5: {
//            [self rotationShakeAnimationInView:view];
//            break;
//        }
            
        default:{
            [self transitionWithType:kCATransitionMoveIn forView:view];
        }
            break;
    }
#endif
}

// 翻页动画
- (void)animationWithView : (UIView *)view WithAnimationTransition : (UIViewAnimationTransition) transition{
    [UIView animateWithDuration:Duration animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:transition forView:view cache:YES];
    }];
}

// 移动动画
- (void)transitionWithType:(NSString *) type forView:(UIView *)view{
    CATransition *animation = [CATransition animation];
    animation.type = type;
    animation.subtype = kCATransitionFromLeft;
    //@"rippleEffect";
    // animation.subtype = kCATransitionFromRight;
    // kCATransitionFade   kCATransitionPush  kCATransitionReveal   kCATransitionMoveIn
    [animation setDuration:Duration];
    [animation setRepeatCount:1.0];
    //设置运动速度
    animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
    [view.layer addAnimation:animation forKey:@"fadeMoveIn"];
}

//绕X轴翻转
-(void)rotateXAnimateForView:(UIView *)view{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    [animation setFromValue:[NSNumber numberWithFloat:0]];
    [animation setToValue:[NSNumber numberWithFloat:M_PI*2]];
    [animation setDuration:Duration];
    [animation setRepeatCount:1];
    animation.cumulative=YES;
    [view.layer addAnimation:animation forKey:nil];
}

//绕Y轴翻转
-(void)rotateYAnimateForView:(UIView *)view{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    [animation setFromValue:[NSNumber numberWithFloat:0]];
    [animation setToValue:[NSNumber numberWithFloat:M_PI*2]];
    [animation setDuration:Duration];
    [animation setRepeatCount:1];
    animation.cumulative=YES;
    [view.layer addAnimation:animation forKey:nil];
}



//左右抖动
-(void)leftRightShakeAnimateForView:(UIView *)view{
    CGAffineTransform originalTransform = view.transform;
    view.transform = CGAffineTransformMakeTranslation(view.frame.size.height / 4.0f, 0);
    [UIView animateWithDuration:Duration delay:Delay usingSpringWithDamping:SpringDamping initialSpringVelocity:SpringVelocity options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.transform = originalTransform;
    } completion:^(BOOL finished) {
    }];
    
}

//上下抖动
-(void)topBottomShakeAnimateForView:(UIView *)view{
    CGAffineTransform originalTransform = view.transform;
    view.transform = CGAffineTransformMakeTranslation(0, view.frame.size.height / 4.0f);
    [UIView animateWithDuration:Duration delay:Delay usingSpringWithDamping:SpringDamping initialSpringVelocity:SpringVelocity options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.transform = originalTransform;
    } completion:^(BOOL finished) {
    }];
}

// 放大缩小动画
- (void)scaleAnimationForView:(UIView *)view {
    CGAffineTransform originalTransform = view.transform;
    view.transform = CGAffineTransformMakeScale(1.2, 1.2);
    [UIView animateWithDuration:Duration delay:Delay usingSpringWithDamping:SpringDamping initialSpringVelocity:SpringVelocity options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.transform = originalTransform;
    } completion:^(BOOL finished) {
    }];
}


#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)
// 旋转震动动画
- (void)rotationShakeAnimationInView:(UIView *)view {
    CGAffineTransform originalTransform = view.transform;
    view.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(10));
    [UIView animateWithDuration:Duration delay:Delay usingSpringWithDamping:SpringDamping initialSpringVelocity:SpringVelocity options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.transform = originalTransform;
    } completion:^(BOOL finished) {
    }];
}



-(void)showAdsBtnAnimation:(UIButton *)button{
    if (button) {
        CGAffineTransform originalTransform = button.transform;
        button.transform=CGAffineTransformMakeScale(2.0f, 2.0f);
        [UIView animateWithDuration:Duration delay:Delay usingSpringWithDamping:SpringDamping initialSpringVelocity:SpringVelocity options:UIViewAnimationOptionCurveEaseInOut animations:^{
            button.transform = originalTransform ;
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - 原生广告

- (void)achieveNativeAdView{
    if([self needsShowAdView] == false){
        return;
    }
    if (self.nativeViewNeedHiden) {
        return;
    }
#ifndef ISPRO
    __weak typeof(self) weakSelf = self;
    [[CVAdvertiseController shareInstance] achieveNativeExpressView:^(UIView *nativeView) {
        if(nativeView == nil){
            return ;
        }
        if(weakSelf.nativeAdView != nil){
            [weakSelf.nativeAdView removeFromSuperview];
            weakSelf.nativeAdView = nil;
            NSLog(@"%s, remove old nativeAdView",__func__);
        }
        nativeView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        weakSelf.nativeAdView = nativeView;
        [weakSelf showNativeAdView:nativeView];
        NSLog(@"%s, add new nativeAdView",__func__);
        BOOL enableAnimation = [NPCommonConfig shareInstance].enableBannerViewAnimation;
        if (enableAnimation) {
            [weakSelf randomAnimationWithView:nativeView];
        }
    }];
#endif
}

- (void)achieveNative250HAdView{
    if([self needsShowAdView] == false){
        return;
    }
    if (self.native250HViewNeedHiden) {
        return;
    }
#ifndef ISPRO
    __weak typeof(self) weakSelf = self;
    [[CVAdvertiseController shareInstance] achieveNativeExpress250HView:^(UIView *native250HView) {
        if(native250HView == nil){
            return ;
        }
        if(weakSelf.native250HAdView != nil){
            [weakSelf.native250HAdView removeFromSuperview];
            weakSelf.native250HAdView = nil;
            NSLog(@"%s, remove old native250HAdView",__func__);
        }
        native250HView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        weakSelf.native250HAdView = native250HView;
        [weakSelf showNative250HAdView:native250HView];
        NSLog(@"%s, add new native250HAdView",__func__);
//        BOOL enableAnimation = [NPCommonConfig shareInstance].enableBannerViewAnimation;
//        if (enableAnimation) {
//            [weakSelf animationWithView:native250HView WithAnimationTransition:UIViewAnimationTransitionFlipFromRight];
//        }
    }];
#endif
}

- (void)achieveNative132HAdView{
    if([self needsShowAdView] == false){
        return;
    }
    if (self.native132HViewNeedHiden) {
        return;
    }
#ifndef ISPRO
    __weak typeof(self) weakSelf = self;
    [[CVAdvertiseController shareInstance] achieveNativeExpress132HView:^(UIView *native132HView){
        if(native132HView == nil){
            return ;
        }
        if(weakSelf.native132HAdView != nil){
            [weakSelf.native132HAdView removeFromSuperview];
            weakSelf.native132HAdView = nil;
            NSLog(@"%s, remove old native132HAdView",__func__);
        }
        native132HView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        weakSelf.native132HAdView = native132HView;
        [weakSelf showNative132HAdView:native132HView];
        NSLog(@"%s, add new native132HAdView",__func__);
        
        BOOL enableAnimation = [NPCommonConfig shareInstance].enableBannerViewAnimation;
        if (enableAnimation) {
            [weakSelf animationWithView:native132HView WithAnimationTransition:UIViewAnimationTransitionFlipFromRight];
        }
    }];
#endif
}


- (void)adjustAdview{
    if (self.bannerView == nil || self.bannerView.superview == nil || self.bannerView.bounds.size.height == 0) {
        [self setAdEdgeInsets:UIEdgeInsetsZero];
        return;
    }

    UIEdgeInsets contentInset = UIEdgeInsetsMake(0, 0, self.bannerView.bounds.size.height, 0);
    [self setAdEdgeInsets:contentInset];
    
    float offsetOfBottom = [self adViewBottomOffsetFromSuperViewBottom];
    CGPoint center = CGPointMake(self.view.frame.size.width/2,
                                 self.view.frame.size.height - self.bannerView.frame.size.height/2 - offsetOfBottom);
    self.bannerView.center = center;
}

- (void)showNativeAdView:(UIView *)nativeAdView{
    CGSize nativeAdViewSize = nativeAdView.frame.size;
    nativeAdView.frame = CGRectMake(0, 0, nativeAdViewSize.width, nativeAdViewSize.height);
}

- (void)showNative250HAdView:(UIView *)nativeAdView {
    CGSize nativeAdViewSize = nativeAdView.frame.size;
    nativeAdView.frame = CGRectMake(0, 0, nativeAdViewSize.width, nativeAdViewSize.height);
}

- (void)showNative132HAdView:(UIView *)nativeAdView{
    CGSize nativeAdViewSize = nativeAdView.frame.size;
    nativeAdView.frame = CGRectMake(0, 0, nativeAdViewSize.width, nativeAdViewSize.height);
}


- (BOOL)needLoadBannerAdView {
    return YES;
}

- (BOOL)needLoadNativeAdView{
    return NO;
}

- (BOOL)needLoadNative250HAdView{
    return NO;
}

- (BOOL)needLoadNative132HAdView{
    return NO;
}

- (NSString *)screemName{
    return @"";
}

- (void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    
}

- (void)setAdViewHiden:(BOOL)hiden{
    self.bannerViewNeedHiden = hiden;
    self.bannerView.hidden = hiden;
}

- (void)setNativeAdViewHiden:(BOOL)hiden{
    self.nativeViewNeedHiden = hiden;
    self.nativeAdView.hidden = hiden;
}

- (void)setNative250HAdViewHiden:(BOOL)hiden{
    self.native250HViewNeedHiden = hiden;
    self.native250HAdView.hidden = hiden;
}


- (void)setNative132HAdViewHiden:(BOOL)hiden{
    self.native132HViewNeedHiden = hiden;
    self.native132HAdView.hidden = hiden;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(float)adViewBottomOffsetFromSuperViewBottom{
    return 0;
}

- (CGSize)sizeOfAdsView{
    return self.bannerView.frame.size;
}

#pragma mark  - Auto show FullScreenAd
- (BOOL) shouldShowFullScreenAd {
    BOOL shouldShowAD = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (NO == shouldShowAD) {
        return NO;
    }
    // time
    NSInteger viewAppearUntilShowFullAd = [NPCommonConfig shareInstance].viewAppearUntilShowInterstitialAd;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger currentCount = [userDefault integerForKey:Key_User_ViewAppear_Before_FullscreenAd];
    if (currentCount >= viewAppearUntilShowFullAd) {
        return YES;
    }else{
        return NO;
    }
    return YES;
}

- (BOOL)shouldIncreaseViewAppearCountForShowFullscreenAd{
    return YES;
}

- (void)increaseViewAppearCountForShowFullscreenAd {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger currentCount = [userDefault integerForKey:Key_User_ViewAppear_Before_FullscreenAd];
    currentCount ++;
    [userDefault setInteger:currentCount forKey:Key_User_ViewAppear_Before_FullscreenAd];
     LOG(@"%s, currentCount: %ld",__func__, currentCount);
}


- (void)clearViewAppearCountForShowFullscreenAd {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setInteger:0 forKey:Key_User_ViewAppear_Before_FullscreenAd];
    [userDefault synchronize];
}

#pragma mark - Prompt ProVersion and InAppPayment

//- (BOOL)shouldPromptPayment{
//    BOOL shouldShowAD = [[NPCommonConfig shareInstance] shouldShowAdvertise];
//    if (NO == shouldShowAD) {
//        return NO;
//    }
//    // time
//    NSInteger viewAppearUntilPromptPayment = [NPCommonConfig shareInstance].viewAppearUntilPromptPayment;
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    NSInteger currentCount = [userDefault integerForKey:Key_User_ViewAppear_BeforePrompt_Count];
//    if (currentCount >= viewAppearUntilPromptPayment) {
//        return YES;
//    }else{
//        return NO;
//    }
//    return YES;
//}

//- (void)increaseViewAppearCountForPromptPayment{
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    NSInteger currentCount = [userDefault integerForKey:Key_User_ViewAppear_BeforePrompt_Count];
//    currentCount ++;
//    [userDefault setInteger:currentCount forKey:Key_User_ViewAppear_BeforePrompt_Count];
//}
//
//- (void)clearViewAppearCountForPromptPayment {
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    [userDefault setInteger:0 forKey:Key_User_ViewAppear_BeforePrompt_Count];
//    [userDefault synchronize];
//}

- (void)promptProVersionAndRemoveAdPayment{
     LOG(@"%s",__func__);
    NSString *paymentPromptMessage = [SBPaymentLocalizeUtil localizedStringForKey:@"No ads for perfect experience" withDefault:@"No ads for perfect experience"];
     //[SettingsLocalizeUtil localizedStringForKey:@"Payment prompt message" withDefault:@"If you enjoy using %@, get an Ad-free Version for a Better Experience."];
    NSString *applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if ([applicationName length] == 0){
        applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey];
    }
    paymentPromptMessage = [paymentPromptMessage stringByReplacingOccurrencesOfString:@"%@" withString:applicationName];
    
    UIViewController *topController = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (topController.presentedViewController){
        topController = topController.presentedViewController;
    }
    if ([UIAlertController class] && topController){
        NSString *remindStr = [SBPaymentLocalizeUtil localizedStringForKey:@"Buy" withDefault:@"Purchase"];
//        NSString *remindStr = [SBPaymentLocalizeUtil localizedStringForKey:@"Remind info" withDefault:@"Remind info"];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:remindStr message:paymentPromptMessage preferredStyle:UIAlertControllerStyleAlert];
        
        //upgrade action
        NSString *upgradeToProStr = [SettingsLocalizeUtil localizedStringForKey:@"Upgrade to Pro Version" withDefault:@"Upgrade to Pro Version"];
        [alert addAction:[UIAlertAction actionWithTitle:upgradeToProStr style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
            [self displayProVersionInfo];
        }]];
        
        //upgrade action
        NSString *removeAdsStr = [SettingsLocalizeUtil localizedStringForKey:@"Remove Ads" withDefault:@"Remove Ads"];
        [alert addAction:[UIAlertAction actionWithTitle:removeAdsStr style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
            [self removeAdPayment];
        }]];
        
        NSString *cancelStr = [SBPaymentLocalizeUtil localizedStringForKey:@"cancel" withDefault:@"Cancel"];
        //rate action
        [alert addAction:[UIAlertAction actionWithTitle:cancelStr style:UIAlertActionStyleCancel handler:^(__unused UIAlertAction *action) {
        }]];
        
        //get current view controller and present alert
        [topController presentViewController:alert animated:YES completion:NULL];
        // clean count
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setInteger:0 forKey:Key_User_ViewAppear_BeforePrompt_Count];
        [userDefault synchronize];
    }
}

- (void)displayProVersionInfo {
    NSString *proAppId = [NPCommonConfig shareInstance].proAppId;
    if (proAppId == nil) {
        return;
    }
    NSString *appUrlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%ld?mt=8", (long)proAppId.integerValue];
    NSURL *appURL = [[NSURL alloc] initWithString:appUrlString];
    [[UIApplication sharedApplication] openURL:appURL];
}

- (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

- (void)removeAdPayment {
    [[NPCommonConfig shareInstance] paymentForRemoveAd];
}

#pragma mark - CASINO

// default Frame : 468/60
- (void)CASINO_ShowPlanet7_InView:(UIView *)view frame:(CGRect)frame isCenter:(BOOL)isCenter{
    UIWebView *webV = [[UIWebView alloc] initWithFrame:frame];
    webV.backgroundColor = [UIColor clearColor];
    webV.opaque = NO;
    webV.delegate = self;
    webV.dataDetectorTypes = UIDataDetectorTypeAll;
    [webV loadHTMLString:@"<a href='http://www.planet7links.com/click/2/9895/16270/1' referrerpolicy='unsafe-url'><img src='http://www.planet7links.com/view/2/9895/16270/' title='Planet7 | 400% Bonus | Generic with a signup form (Best Converting) ' alt='Planet7 | 400% Bonus | Generic with a signup form (Best Converting) ' referrerpolicy='unsafe-url'/></a>" baseURL:nil];
    [view addSubview:webV];
    
    if (isCenter) {
        webV.frame = CGRectMake((view.frame.size.width - frame.size.width)/2, frame.origin.y, frame.size.width, frame.size.height);
    }
}

// default Frame : 468/60
- (void)CASINO_ShowRoyalAce_InView:(UIView *)view frame:(CGRect)frame isCenter:(BOOL)isCenter{
    if (![[NPCommonConfig shareInstance] shouldShowAdvertise]) {
        return;
    }
    UIWebView *webV = [[UIWebView alloc] initWithFrame:frame];
    webV.backgroundColor = [UIColor clearColor];
    webV.opaque = NO;
    webV.delegate = self;
    webV.dataDetectorTypes = UIDataDetectorTypeAll;
    [webV loadHTMLString:@"<a href='http://www.royalacelinks.com/click/3/9780/16270/1' referrerpolicy='unsafe-url'><img src='http://www.royalacelinks.com/view/3/9780/16270/' title='Royal Ace│ High Rollers│ 200% Bonus' alt='Royal Ace│ High Rollers│ 200% Bonus' referrerpolicy='unsafe-url'/></a>" baseURL:nil];
    [view addSubview:webV];
    
    if (isCenter) {
        webV.frame = CGRectMake((view.frame.size.width - frame.size.width)/2, 0, frame.size.width, frame.size.height);
    }
}

- (void)CASINO_Planet7{
    if (![[NPCommonConfig shareInstance] shouldShowAdvertise]) {
        return;
    }
    NSURL *url = [NSURL URLWithString:@"http://www.planet7links.com/click/2/9895/16270/1"];
    if([[UIApplication sharedApplication]canOpenURL:url])
    {
        [[UIApplication sharedApplication]openURL:url];
    }
}

- (void)CASINO_RoyalAce{
    NSURL *url = [NSURL URLWithString:@"http://www.royalacelinks.com/click/3/9780/16270/1"];
    if([[UIApplication sharedApplication]canOpenURL:url])
    {
        [[UIApplication sharedApplication]openURL:url];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (![[NPCommonConfig shareInstance] shouldShowAdvertise]) {
        return NO;
    }
    //判断是否是单击
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        NSURL *url = [request URL];
        if([[UIApplication sharedApplication]canOpenURL:url])
        {
            [[UIApplication sharedApplication]openURL:url];
        }
        return NO;
    }
    return YES;
}

@end
