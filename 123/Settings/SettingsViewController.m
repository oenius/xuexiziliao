//
//  SettingsViewController.m
//  Common
//
//  Created by mayuan on 16/6/30.
//  Copyright © 2016年 camory. All rights reserved.
//

#import "SettingsViewController.h"
#import "SBPaymentManager.h"
#import "Macros.h"

#import "SendEmailManager.h"
#import <MessageUI/MessageUI.h>
#import <sys/utsname.h>
#import "SettingsLocalizeUtil.h"
#import "SBPaymentLocalizeUtil.h"
//#import "CVAdvertiseController.h"
#import "MBProgressHUD.h"

#import "NPCommonConfig.h"
#import "DAAppsViewController.h"
#import "NPInterstitialButton.h"

typedef NS_ENUM(NSInteger, SettingSectionType) {
    SettingSectionTypeProduct,
    SettingSectionTypePurchase,
    SettingSectionTypeGeneral
};

NSString *kViewControllerDataSourceGroupProduct = @"ViewControllerDataSourceGroupProduct";
NSString *kViewControllerDataSourceGroupGeneral = @"ViewControllerDataSourceGroupGeneral";
NSString *AppIniTunesURLFormat = @"itms-apps://itunes.apple.com/app/id%@";


@interface SettingsViewController ()<
UITableViewDelegate,
UITableViewDataSource,
SKStoreProductViewControllerDelegate
>

@property (strong, nonatomic, readwrite) UITableView *tableView;


@property (strong, nonatomic) NSMutableArray<NSString *> *productSectionDataArray;
@property (strong, nonatomic) NSMutableArray<NSString *> *purchaseSectionDataArray;
@property (strong, nonatomic) NSMutableArray<NSString *> *generalSectionDataArray;
// array of 'SettingSectionType'
@property (strong, nonatomic) NSMutableArray *sections;

@end




@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    BOOL shouldShowAd = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (shouldShowAd) {
        self.interstitialButton = [NPInterstitialButton buttonWithType:NPInterstitialButtonTypeIcon viewController:self];
        self.interstitialButton.showAdType = NPInterstitialButtonShowADTypeFullScreen;
        UIBarButtonItem *adIconBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.interstitialButton];
        self.navigationItem.rightBarButtonItem = adIconBarButtonItem;
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [self reloadTableViewData];
    
    self.tableView.backgroundColor = [self tableViewBackgroundColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)reloadTableViewData{
    self.sections = [NSMutableArray array];
    // product
    self.productSectionDataArray = [NSMutableArray array];
    [self setProductSectionItems];
    if (self.productSectionDataArray.count > 0) {
        [self.sections addObject:@(SettingSectionTypeProduct)];
    }
    
    // purchase
    self.purchaseSectionDataArray = [NSMutableArray array];
    [self setPaymentSectionItems];
    if (self.purchaseSectionDataArray.count > 0) {
        [self.sections addObject:@(SettingSectionTypePurchase)];
    }
    // general
    self.generalSectionDataArray = [NSMutableArray array];
    [self setGeneralSectionItems];
    if (self.generalSectionDataArray.count > 0) {
        [self.sections addObject:@(SettingSectionTypeGeneral)];
    }
    
    [self.tableView reloadData];
}

- (void)setProductSectionItems {
    // example
//    [self.productSectionDataArray addObject:@"密码设置"];
}

- (void)setPaymentSectionItems {
//    BOOL shouldShowFullScreanAdCell = [self shouldShowFullScreenAdCell];
//    if (shouldShowFullScreanAdCell) {
//        NSString *adsStr = [SettingsLocalizeUtil localizedStringForKey:@"ads" withDefault:@"Ads"];
//        [self.purchaseSectionDataArray addObject:adsStr];
//    }
    
    BOOL shouldShowInAppPurchase = [self shouldShowInAppPurchase];
    if (shouldShowInAppPurchase) {
        NSString *removeAdsStr = [SettingsLocalizeUtil localizedStringForKey:@"Remove Ads" withDefault:@"Remove Ads"];
        [self.purchaseSectionDataArray addObject:removeAdsStr];
    }
    if ([self isLiteApp]) {
        BOOL needShowRestore = [self needShowRestorePaymentCell];
        if (needShowRestore) {
            NSString *restorePurchaseStr = [SBPaymentLocalizeUtil localizedStringForKey:@"Restore.Purchase" withDefault:@"Restore Purchase"];
            [self.purchaseSectionDataArray addObject:restorePurchaseStr];
        }

        NSString *upgradeToProStr = [SettingsLocalizeUtil localizedStringForKey:@"Upgrade to Pro Version" withDefault:@"Upgrade to Pro Version"];
        NSString *proAppID = [NPCommonConfig shareInstance].proAppId;
        if (proAppID && proAppID.length > 0) {
            [self.purchaseSectionDataArray addObject:upgradeToProStr];
        }
    }
}

- (void)setGeneralSectionItems {
    NSString *rateStr = [SettingsLocalizeUtil localizedStringForKey:@"setting.comment" withDefault:@"Rate Us"];
    NSString *suggectionStr = [SettingsLocalizeUtil localizedStringForKey:@"Suggections" withDefault:@"Suggections"];
    
    NSString *watchVideoStr = [SettingsLocalizeUtil localizedStringForKey:@"Watch the video for a better experience" withDefault:@"Watch the video for a better experience"];
    
    [self.generalSectionDataArray addObject:rateStr];
    [self.generalSectionDataArray addObject:suggectionStr];
    if ([self shouldRecommendMoreApp]) {
        NSString *moreAppsStr = [SettingsLocalizeUtil localizedStringForKey:@"More Apps" withDefault:@"More Apps"];
        [self.generalSectionDataArray addObject:moreAppsStr];
    }
    if ([self shouldShowRewardVideoCell]) {
        [self.generalSectionDataArray addObject:watchVideoStr];
    }
}


- (BOOL)isLiteApp {
    return [[NPCommonConfig shareInstance] isLiteApp];
}

- (BOOL)shouldShowInAppPurchase {
    BOOL shouldShowAd = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (shouldShowAd) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldShowFullScreenAdCell {
    BOOL shouldShowAd = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (shouldShowAd) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldShowRewardVideoCell {
    return NO;
    
//    BOOL shouldShowAd = [[NPCommonConfig shareInstance] shouldShowAdvertise];
//    NSString *rewardVideoAdID = [NPCommonConfig shareInstance].admobRewardVideoAdID;
//    if (rewardVideoAdID != nil && shouldShowAd) {
//        return YES;
//    }
//    return NO;
}

- (BOOL)shouldRecommendMoreApp {
    BOOL shouldShowMoreApps = [NPCommonConfig shareInstance].shouldShowMoreAppsInSettings;
    if (NO == shouldShowMoreApps) {
        return NO;
    }
#ifdef DEBUG
    return YES;
#else 
    BOOL isAppOnline = [NPCommonConfig shareInstance].isCurrentVersionOnline;
    if (NO == isAppOnline) {
        return NO;
    }
#endif
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// 重写父类方法，横幅广告显示，影响到tableView content 的显示
- (void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    self.tableView.contentInset = contentInsets;
}


//// 重写父类方法, 自定义不需要加载显示Banner广告
- (BOOL)needLoadBannerAdView {
    return YES;
}

// 重写父类方法, 自定义需要加载显示原生250H广告
- (BOOL)needLoadNative250HAdView{
    return NO;
}

- (BOOL)needShowRestorePaymentCell {
    return YES;
}

- (BOOL)needLoadNativeAdView{
    return NO;
}

- (void)showNative250HAdView:(UIView *)nativeAdView {
    [super showNative250HAdView:nativeAdView];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat tableViewContentHeight = self.tableView.contentSize.height;
    CGSize nativeViewSize = nativeAdView.frame.size;
    CGRect destFrame = CGRectMake((screenWidth - nativeViewSize.width) / 2.0, tableViewContentHeight, nativeViewSize.width, nativeViewSize.height);
    nativeAdView.frame = destFrame;
    [self.tableView addSubview:nativeAdView];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, nativeViewSize.height + 50, 0);
}

- (void)removeAdNotification:(NSNotification *)notification {
    [super removeAdNotification:notification];
    [self reloadTableViewData];
}

#pragma mark  - TableViewTheme
// default whiteColor
- (UIColor *)tableViewBackgroundColor{
    return [UIColor whiteColor];
}
// default whiteColor
- (UIColor *)tableViewCellBackgroundColor{
    return [UIColor whiteColor];
}
// default blackColor
- (UIColor *)tableViewCellTextColor{
    return [UIColor blackColor];
}

- (UIColor *)tableViewHeadViewBackgroundColor {
    return [UIColor colorWithRed:(231.0/255.0) green:(231.0/255.0)  blue:(231.0/255.0)  alpha:1.0];
}

- (UIColor *)tableViewHeadViewTextColor {
    return [UIColor blackColor];
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSNumber *sectionTypeNum = [self.sections objectAtIndex:section];
    SettingSectionType sectionType = sectionTypeNum.integerValue;
    NSInteger rowCount = 0;
    switch (sectionType) {
        case SettingSectionTypePurchase:{
            rowCount = self.purchaseSectionDataArray.count;
        }
            break;
        case SettingSectionTypeGeneral:{
            rowCount = self.generalSectionDataArray.count;
        }
            break;
        case SettingSectionTypeProduct: {
            rowCount = self.productSectionDataArray.count;
        }
        default:
            break;
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
    }
    NSString *title = [self titleForIndexPath:indexPath];
    UIView *nativeAdView = [self nativeAdView];
    if ([title isEqualToString:@"native"]) {
        nativeAdView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [cell addSubview:nativeAdView];
        cell.backgroundColor = [self tableViewCellBackgroundColor];
        cell.textLabel.text = nil;
    }else{
        cell.textLabel.text = title;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [self tableViewCellTextColor];
        cell.backgroundColor = [self tableViewCellBackgroundColor];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect headViewFrame = CGRectMake(0, 0, self.view.frame.size.width, 30);
    UIView *headView = [[UIView alloc] initWithFrame:headViewFrame];
    headView.backgroundColor= [self tableViewHeadViewBackgroundColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, self.view.frame.size.width, 30)];
    titleLabel.textColor= [self tableViewHeadViewTextColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [headView addSubview:titleLabel];
    
    NSNumber *sectionTypeNum = [self.sections objectAtIndex:section];
    SettingSectionType sectionType = sectionTypeNum.integerValue;
    NSString *headTitle = nil;
    switch (sectionType) {
        case SettingSectionTypeProduct:{
            headTitle = [SettingsLocalizeUtil localizedStringForKey:@"user.Settings" withDefault:@"Settings"];
        }
            break;
        case SettingSectionTypeGeneral:{
            headTitle = [SettingsLocalizeUtil localizedStringForKey:@"General" withDefault:@"General"];
        }
            break;
        case SettingSectionTypePurchase:{
            headTitle = [SBPaymentLocalizeUtil localizedStringForKey:@"Buy" withDefault:@"Purchase"];
        }
            break;
        default:
            break;
    }
    titleLabel.text = headTitle;
    return headView;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NSNumber *sectionTypeNum = [self.sections objectAtIndex:section];
//    SettingSectionType sectionType = sectionTypeNum.integerValue;
//    NSString *headTitle = nil;
//    switch (sectionType) {
//        case SettingSectionTypeProduct:{
//            headTitle = [SettingsLocalizeUtil localizedStringForKey:@"user.Settings" withDefault:@"Settings"];
//        }
//            break;
//        case SettingSectionTypeGeneral:{
//            headTitle = [SettingsLocalizeUtil localizedStringForKey:@"General" withDefault:@"General"];
//        }
//            break;
//        case SettingSectionTypePurchase:{
//            headTitle = [SBPaymentLocalizeUtil localizedStringForKey:@"Buy" withDefault:@"Purchase"];
//        }
//            break;
//        default:
//            break;
//    }
//    return headTitle;
//}


- (NSString *)titleForIndexPath:(NSIndexPath *)indexPath {
    NSString *title = nil;
    NSInteger section = indexPath.section;
    NSNumber *sectionTypeNum = [self.sections objectAtIndex:section];
    SettingSectionType sectionType = sectionTypeNum.integerValue;
    switch (sectionType) {
        case SettingSectionTypePurchase:{
            title = self.purchaseSectionDataArray[indexPath.row];
        }
            break;
        case SettingSectionTypeGeneral:{
            title = self.generalSectionDataArray[indexPath.row];
        }
            break;
        case SettingSectionTypeProduct: {
            title = self.productSectionDataArray[indexPath.row];
        }
            break;
        default:
            break;
    }
    return title;
}


#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self titleForIndexPath:indexPath];
    if ([title isEqualToString:@"native"]) {
        return  80;
    }else{
        return 45.0;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self titleForIndexPath:indexPath];
    
    NSString *removeAdsStr = [SettingsLocalizeUtil localizedStringForKey:@"Remove Ads" withDefault:@"Remove Ads"];
    NSString *upgradeToProStr = [SettingsLocalizeUtil localizedStringForKey:@"Upgrade to Pro Version" withDefault:@"Upgrade to Pro Version"];
    NSString *rateStr = [SettingsLocalizeUtil localizedStringForKey:@"setting.comment" withDefault:@"Rate Us"];
    NSString *suggectionStr = [SettingsLocalizeUtil localizedStringForKey:@"Suggections" withDefault:@"Suggections"];
    NSString *moreAppsStr = [SettingsLocalizeUtil localizedStringForKey:@"More Apps" withDefault:@"More Apps"];
    NSString *restorePurchaseStr = [SBPaymentLocalizeUtil localizedStringForKey:@"Restore.Purchase" withDefault:@"Restore Purchase"];
    NSString *adsStr = [SettingsLocalizeUtil localizedStringForKey:@"ads" withDefault:@"Ads"];
    NSString *watchVideoStr = [SettingsLocalizeUtil localizedStringForKey:@"Watch the video for a better experience" withDefault:@"Watch the video for a better experience"];

    NSString *tellFriendStr = @"Tell a friend";

    if ([title isEqualToString:removeAdsStr]) {
        NSString *removeAdProductId = [NPCommonConfig shareInstance].removeAdPurchaseProductId;
        LOG(@"移除广告内购ID = %@",removeAdProductId);
        [[NPCommonConfig shareInstance] paymentForRemoveAd];
    }else if([title isEqualToString:restorePurchaseStr]) {
        [[NPCommonConfig shareInstance] restorePaymentForRemoveAd];
    }else if([title isEqualToString:upgradeToProStr]){
        NSString *proAppID = [NPCommonConfig shareInstance].proAppId;
        NSString *proAppLink = [NSString stringWithFormat:AppIniTunesURLFormat, proAppID];
        NSURL * url = [NSURL URLWithString:proAppLink];
        [[UIApplication sharedApplication] openURL:url];
        
    }else if([title isEqualToString:rateStr]){
        [[NPCommonConfig shareInstance] openRatingsPageInAppStore];
    }else if([title isEqualToString:suggectionStr]){
        NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
        NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
        
        NSString * sug =@"Suggections";
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        if ([appName length] == 0 || appName == nil)
        {
            appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey];
        }
        BOOL islite = [NPCommonConfig shareInstance].isLiteApp;
        if (!islite && ![appName containsString:@"Pro"]) {
            appName = [appName stringByAppendingString:@" Pro"];
        }
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString * deviceModeName = [self deviceModelName];
        NSString * systemVersion = [UIDevice currentDevice].systemVersion;
        NSString * subject = [NSString stringWithFormat:@"%@-%@(V%@),%@,%@,%@",sug,appName,version,countryCode,deviceModeName,systemVersion];
        [[SendEmailManager sharedInstance] sendFadebackEmail:subject];
    }else if([title isEqualToString:moreAppsStr]) {
        // artistId: 1124342842
        NSInteger artistId = 1124342842;
        NSString *artistIdStr = [NPCommonConfig shareInstance].artistId;
        if (artistIdStr != nil && artistIdStr.length > 0) {
            artistId = artistIdStr.integerValue;
        }
        DAAppsViewController *appsViewController = [[DAAppsViewController alloc] init];
        appsViewController.pageTitle = moreAppsStr;
        NSString *currentAppId =  [[NPCommonConfig shareInstance] currentAppID];
        [appsViewController loadAppsWithArtistId:artistId exceptAppIds:@[currentAppId] completionBlock:nil];
        [self.navigationController pushViewController:appsViewController animated:YES];
    }else if([title isEqualToString:tellFriendStr]) {
        NSString *appStoreTrackName = [[NPCommonConfig shareInstance] appStoreTrackName];
        if (appStoreTrackName != nil && appStoreTrackName.length > 0) {
            NSString *currentAppId =  [[NPCommonConfig shareInstance] currentAppID];
            NSString *appstoreUrl = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", currentAppId];
            NSString *content = [NSString stringWithFormat:@"%@  %@", appStoreTrackName, appstoreUrl];
            [[SendEmailManager sharedInstance] sendEmailWithSubject:appStoreTrackName bodyContent:content];
        }
    }else if([title isEqualToString:adsStr]) {
        [[NPCommonConfig shareInstance] showInterstitialAdInViewController:self];
    }else if([title isEqualToString:watchVideoStr]) {
        [[NPCommonConfig shareInstance] watchRewardVideoWithReward:nil];
    }
}

- (void)showTipViewWithMessage:(NSString *)message {
    UIView *view = [UIApplication sharedApplication].delegate.window;
//    UIViewController *topController = [UIApplication sharedApplication].delegate.window.rootViewController;
//    while (topController.presentedViewController)
//    {
//        topController = topController.presentedViewController;
//    }
//    UIView *view = topController.view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.detailsLabel.text = message;
    hud.mode = MBProgressHUDModeText;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2];
    //    [hud hide:YES afterDelay:1];
}


NSString *deviceModel() {
    //here use sys/utsname.h
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    //get the device model
    
    NSString *model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return model;
}


-(NSString * )deviceModelName{
    NSString * deviceModeName = nil;
    UIUserInterfaceIdiom   interfaceIdiom = [[UIDevice currentDevice] userInterfaceIdiom];
    switch (interfaceIdiom) {
        case UIUserInterfaceIdiomPhone:
            deviceModeName = @"iPhone/iPod";
            break;
        case UIUserInterfaceIdiomPad:
            deviceModeName = @"iPad";
            break;
        case UIUserInterfaceIdiomTV:
            deviceModeName = @"Apple TV";
            break;
        case UIUserInterfaceIdiomCarPlay:
            deviceModeName = @"CarPlay";
            break;
        default:
            deviceModeName = @"";
            break;
    }
    return deviceModeName;
}


#pragma mark - Product view controller delegate methods

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
