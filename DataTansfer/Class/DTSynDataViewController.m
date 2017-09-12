//
//  DTSynDataViewController.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/17.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTSynDataViewController.h"
#import "DTFileChoiceViewController.h"
#import "STTabBarController.h"
#import "DTSearchDeviceViewController.h"
#import "DTScanQRViewContrller.h"
#import "UINavigationController+DT.h"
#import "HSPresentAnimaion.h"
#import "NPGoProButton.h"
#import "NPCommonConfig.h"
#import "DTFileTransferViewController.h"
#import <SVProgressHUD.h>
#import "UIImage+x.h"
#import "DTInvitedInstallViewController.h"
#import "DTContactViewModel.h"
#import "DTPhotoViewModel.h"
#import "DTVideoViewModel.h"
//#import "DTMusicViewModel.h"
@interface DTSynDataViewController ()

@property (nonatomic,strong) UIButton * xinPhoneReceiveBtn;
@property (nonatomic,strong) UIButton * oldPhoneSentBtn;

@property (nonatomic,strong) UIImageView * iconImageView;

@property (nonatomic,assign) BOOL canPresentListVC;

@property (nonatomic,assign) BOOL isAllTaskDidFinish;

@end

@implementation DTSynDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"bg"].CGImage);
    [self setupSubViews];
    if ([[NPCommonConfig shareInstance]isLiteApp]) {
        NPGoProButton * go = [NPGoProButton goProButtonWithImage:[UIImage imageNamed:@"ads"] Frame:CGRectMake(0, 0, 40, 40)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:go];
    }
    [self.navigationController clearUI];
    self.title = [DTConstAndLocal shujuchuanshu];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:[DTConstAndLocal anzhuang] style:(UIBarButtonItemStylePlain) target:self action:@selector(invitedInstall)];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(scanQRSuccess:) name:kSearchTaskListSuccessNotition object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(allTaskDidFinish) name:kAllTaskDidFinishNotition object:nil];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setMinimumSize:CGSizeMake(100, 100)];
    
}

///添加控件
-(void)setupSubViews{
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenHeight/4, screenHeight/4)];
    self.iconImageView.image = [UIImage imageNamed:@"title_icon"];
    [self.view addSubview:self.iconImageView];
    
    self.xinPhoneReceiveBtn = [[UIButton alloc]init];
    [self.xinPhoneReceiveBtn setBackgroundImage:[UIImage imageNamed:@"btn"] forState:(UIControlStateNormal)];
    [self.xinPhoneReceiveBtn addTarget:self action:@selector(xinPhoneReceiveClick:)
                      forControlEvents:(UIControlEventTouchUpInside)];
    [self.xinPhoneReceiveBtn setTitle:[DTConstAndLocal newPhoneRecive] forState:(UIControlStateNormal)];
    [self.xinPhoneReceiveBtn setTitleColor:[UIColor colorWithHexString:@"333333"] forState:(UIControlStateNormal)];
    [self.view addSubview:self.xinPhoneReceiveBtn];
    
    self.oldPhoneSentBtn = [[UIButton alloc]init];
    [self.oldPhoneSentBtn setBackgroundImage:[UIImage imageNamed:@"btn"] forState:(UIControlStateNormal)];
    [self.oldPhoneSentBtn addTarget:self action:@selector(oldPhoneSentClick:)
                      forControlEvents:(UIControlEventTouchUpInside)];
    [self.oldPhoneSentBtn setTitle:[DTConstAndLocal oldPhoneSend] forState:(UIControlStateNormal)];
    [self.oldPhoneSentBtn setTitleColor:[UIColor colorWithHexString:@"333333"] forState:(UIControlStateNormal)];
    [self.view addSubview:self.oldPhoneSentBtn];
    
    [self.xinPhoneReceiveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.view).offset(-70);
        make.height.equalTo(self.view.mas_height).multipliedBy(0.09);
    }];
    
    [self.oldPhoneSentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.xinPhoneReceiveBtn.mas_top).offset(-20);
        make.height.equalTo(self.view.mas_height).multipliedBy(0.09);
        
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    CGFloat height = [UIScreen mainScreen].bounds.size.height/4;
    CGFloat Y = [UIScreen mainScreen].bounds.size.height/5;
    CGFloat X = ([UIScreen mainScreen].bounds.size.width - height)/2 + height/6;
    self.iconImageView.frame = CGRectMake(X, Y, height, height);
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (self.canPresentListVC)
    {
        DTFileTransferViewController * fileT = [[DTFileTransferViewController alloc]init];
        UINavigationController * navi = [[UINavigationController alloc]initWithRootViewController:fileT];
        [self presentViewController:navi animated:YES completion:^{
            self.canPresentListVC = NO;
        }];
    }
    else if(self.isAllTaskDidFinish){
        [DTConstAndLocal showADRandom:1 forController:self];
        self.isAllTaskDidFinish = NO;
    }
}

#pragma mark - actions  

-(void)xinPhoneReceiveClick:(UIButton *)sender{

    [self shenQingQuanXian:NO completed:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            DTScanQRViewContrller * search =[[DTScanQRViewContrller alloc]init];
            UINavigationController * navi = [[UINavigationController alloc]initWithRootViewController:search];
            [navi clearUI];
            navi.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:navi animated:YES completion:nil];
        });
    }];
    
}
-(void)oldPhoneSentClick:(UIButton *)sender{
    
    [self shenQingQuanXian:YES completed:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            DTFileChoiceViewController * fileChoose = [[DTFileChoiceViewController alloc]init];
            [self.navigationController pushViewController:fileChoose animated:YES];
        });
    }];
    
}

-(void)scanQRSuccess:(NSNotification *)noti{
    if (noti.object) {
        self.canPresentListVC = YES;
    }
}



-(void)shenQingQuanXian:(BOOL)music completed:(void(^)())completed{
    
    [[DTContactViewModel new]authorizationStatus:^(DTAuthorizationResult result) {
        if (result == DTAuthorizationResultNO) { return ;}
        [[DTAssetBaseViewModel new]authorizationStatus:^(DTAuthorizationResult result) {
            if (result == DTAuthorizationResultNO) { return ;}
            completed();
//            if (music) {
//                [[DTMusicViewModel new] authorizationStatus:^(DTAuthorizationResult result) {
//                    if (result == DTAuthorizationResultNO) { return ;}
//                    completed();
//                }];
//            }else{
//                completed();
//            }
        }];
    }];
}


-(void)allTaskDidFinish{
    self.isAllTaskDidFinish = YES;
}

-(void)invitedInstall{
    
    NSString * appid ;
    if ([NPCommonConfig shareInstance].isLiteApp) {
        appid = [NPCommonConfig shareInstance].liteAppId;
    }else{
        appid = [NPCommonConfig shareInstance].proAppId;
    }
    
    NSString * itunsLianJie = [NSString stringWithFormat:itunesURLFormat, appid];;
//    UIImage * QR = [UIImage createQRWithString:itunsLianJie QRSize:CGSizeMake(180, 180) QRColor:[UIColor whiteColor] bkColor:[UIColor blackColor]];
    UIImage * QR = [UIImage generateWithDefaultQRCodeData:itunsLianJie imageViewWidth:200];
    if (QR) {
        DTInvitedInstallViewController * inviInstall = [[DTInvitedInstallViewController alloc]initWithQRImage:QR];
        UINavigationController * navi = [[UINavigationController alloc]initWithRootViewController:inviInstall];
        navi.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:navi animated:YES completion:nil];
    }
}


@end
