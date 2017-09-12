//
//  PreviewViewController.m
//  InstaMessage
//
//  Created by 何少博 on 16/8/12.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "PreviewViewController.h"
#import "UIColor+x.h"
#import "NPCommonConfig.h"
#import "SettingsLocalizeUtil.h"
#import "MBProgressHUD.h"
@interface PreviewViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIImageView *lockImageView;


@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewSupviewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewSupviewHight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewSupviewWeigh;

@property (assign,nonatomic)BOOL bannerViewHiddenFlag;


@end

NSString *AppIniTunesURLFormat_Preview = @"itms-apps://itunes.apple.com/app/id%@";

@implementation PreviewViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(onBlackBtnClick)];
    
    self.view.backgroundColor = color_e0dfe0;
    if ([[NPCommonConfig shareInstance] shouldShowAdvertise]) {
        NPInterstitialButton * adBtn = [NPInterstitialButton buttonWithType:NPInterstitialButtonTypeIcon viewController:self];
        adBtn.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:adBtn];
    }
    self.title =  NSLocalizedString(@"message.photo preview", @"Preview");
    [self setupSubViews];

    
}


-(void)setupSubViews{
    self.imageView.image = _image;
    self.topView.backgroundColor = color_2083fc;
    [self.shareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.saveBtn.layer.cornerRadius = 5;
    self.saveBtn.layer.masksToBounds = YES;
    self.saveBtn.backgroundColor = color_2083fc;
    self.shareBtn.layer.cornerRadius = 5;
    self.shareBtn.layer.masksToBounds = YES;
    self.shareBtn.backgroundColor = color_2083fc;
    self.lockImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.saveBtn setTitle:NSLocalizedString(@"common.Save", @"Save") forState:UIControlStateNormal];
    [self.shareBtn setTitle:NSLocalizedString(@"common.Share", @"Share") forState: UIControlStateNormal];
    if ([[NPCommonConfig shareInstance] isLiteApp]) {
        if (self.saveAction == COMMENT) {
            self.shareBtn.enabled = NO;
            [self.shareBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            self.lockImageView.image = [UIImage imageNamed:@"lock"];
        }
        else if (self.saveAction == GOPRO){
            self.shareBtn.enabled = NO;
            [self.shareBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            self.lockImageView.image = [UIImage imageNamed:@"lock"];
        }else{
        }
    }
    
    CGFloat W = [UIScreen mainScreen].bounds.size.width;
    CGFloat H = [UIScreen mainScreen].bounds.size.height;
    W = W-10;
    H = H - 150-64;
    
    CGFloat min = W<H?W:H;
    self.imageViewSupviewHight.constant = min;
    self.imageViewSupviewWeigh.constant = min;
    CGFloat top = (H+10 - min)/2;
    self.imageViewSupviewTop.constant = top;

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.bannerView.hidden = self.bannerViewHiddenFlag;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.bannerViewHiddenFlag = self.bannerView.hidden;
    self.bannerView.hidden = NO;
}
-(void)setImage:(UIImage *)image{
    _image = image;
}
- (void)advertiseInterstitialNotification:(NSNotification *)notification{
    [super advertiseInterstitialNotification:notification];
    NSNumber *enableInterstitial = notification.object;
    if (enableInterstitial.boolValue) {
//        self.fullScreenAdButton.enabled = YES;
    }else{
//        self.fullScreenAdButton.enabled = NO;
    }
}
- (void)removeAdNotification:(NSNotification *)notification{
    [super removeAdNotification:notification];
    self.navigationItem.rightBarButtonItem = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (IBAction)onSaveBtnClick:(UIButton *)sender {
    
    if (self.saveAction == SAVE) {
        UIImageWriteToSavedPhotosAlbum(_image, nil, nil, nil);
        NSString *systemAlbum = NSLocalizedString(@"Album", @"Albums");
        NSString *saveSuccessMessage =[NSString stringWithFormat:NSLocalizedString(@"gallery.save photo to %@ successfully", @"gallery.save photo to %@ successfully"),systemAlbum];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = saveSuccessMessage;
        [hud hideAnimated:YES afterDelay:1.f];
        self.editVC.showAds = YES;
    }
    else if(self.saveAction == COMMENT){
        NSString * title = [SettingsLocalizeUtil localizedStringForKey:@"setting.comment" withDefault:@"Rate Us"];
        NSString * nowUnlock = NSLocalizedString(@"message.unlock immediately", @"Unlock Now");
        NSString * message = [NSString stringWithFormat:@"%@->%@",NSLocalizedString(@"button.title rate", @"Rate it"),nowUnlock];
        UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"common.Cancel", @"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:nowUnlock style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:@[] forKey:kCommentArray];
            [userDefault synchronize];
            self.saveAction = SAVE;
            self.lockImageView.image = nil;
            [[NPCommonConfig shareInstance] openRatingsPageInAppStore];
        }];
        [alerVC addAction:cancel];
        [alerVC addAction:ok];
        [self presentViewController:alerVC animated:YES completion:nil];
    }
    else if (self.saveAction == GOPRO){
        NSString *upgradeToProStr = [SettingsLocalizeUtil localizedStringForKey:@"Upgrade to Pro Version" withDefault:@"Upgrade to Pro Version"];
        NSString * nowUnlock = NSLocalizedString(@"message.unlock immediately", @"Unlock Now");
        NSString * message = [NSString stringWithFormat:@"%@->%@",upgradeToProStr,nowUnlock];
        UIAlertController * alerVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"message.prompt", @"Prompt") message:upgradeToProStr preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"common.Cancel", @"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:nowUnlock style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *proAppID = [NPCommonConfig shareInstance].proAppId;;
            NSString *proAppLink = [NSString stringWithFormat:AppIniTunesURLFormat_Preview, proAppID];
            NSURL * url = [NSURL URLWithString:proAppLink];
            [[UIApplication sharedApplication] openURL:url];
        }];
        
        [alerVC addAction:cancel];
        [alerVC addAction:ok];
        [self presentViewController:alerVC animated:YES completion:nil];
    }
}
- (void)onBlackBtnClick {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onShareBtnClick:(UIButton *)sender {
    
    NSArray *activityItem = [NSArray arrayWithObject:_image];
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:activityItem applicationActivities:nil];
    UIPopoverPresentationController *popover = activity.popoverPresentationController;
    if (popover) {
        popover.sourceView = self.shareBtn;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController:activity animated:YES completion:^{
        self.editVC.showAds = YES;
    }];
    
}



-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    CGFloat W = [UIScreen mainScreen].bounds.size.width;
    CGFloat H = [UIScreen mainScreen].bounds.size.height;
    W = W-10;
    H = H - 150-64;
    
    CGFloat min = W<H?W:H;
    self.imageViewSupviewHight.constant = min;
    self.imageViewSupviewWeigh.constant = min;
    CGFloat top = (H+10 - min)/2;
    
    self.imageViewSupviewTop.constant = top;
}
//修改Plist文件



@end
