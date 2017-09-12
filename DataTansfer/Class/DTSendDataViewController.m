//
//  DTSendDataViewController.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/26.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTSendDataViewController.h"
#import "UINavigationController+DT.h"
#import "DTPromptHUD.h"
#import "NPCommonConfig.h"
#import "UIImage+x.h"
#import "DTInvitedInstallViewController.h"
#import "DTServerManager.h"
@interface DTSendDataViewController ()

@property (nonatomic,strong) UIView * topContentView;

@property (nonatomic,strong) UIImageView * imageView;

@property (nonatomic,strong) UILabel * promptLabel1;

@property (nonatomic,strong) UILabel * promptLabel2;

@property (nonatomic,strong) UILabel * promptLabel3;

@property (nonatomic,strong) UILabel * promptLabel4;

@property (nonatomic,assign) CGFloat currentBringess;

@property (nonatomic,strong) NSString * currentSSID;

@property (nonatomic,strong) UIView * bottomContentView;

@property (nonatomic,strong) UILabel * promptLabel5;



@end

@implementation DTSendDataViewController

-(instancetype)initWithQRImage:(UIImage *)image{
    self = [super init];
    if (self) {
        self.QRImage = image;
    }
    return self;
}



#pragma mark - life Clirle

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"旧机发送";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupSubViews];
    NSDictionary * normal = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationController.navigationBar.titleTextAttributes  = normal;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"08c364"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:(UIBarButtonItemStylePlain) target:self action:@selector(back)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"邀请安装" style:(UIBarButtonItemStylePlain) target:self action:@selector(invitedInstall)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reciveClientiPhoneName:) name:kClientiPhoneNameNotition object:nil];
    self.view.layer.contents  = (__bridge id _Nullable)([UIImage imageNamed:@"tongxunlubg"].CGImage);
}

-(void)setupSubViews{
    self.topContentView = [[UIView alloc]init];
    self.topContentView.backgroundColor = [UIColor colorWithHexString:@"313131"];
    [self.view addSubview:self.topContentView];
    
    self.bottomContentView = [[UIView alloc]init];
    self.bottomContentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.bottomContentView];
    
    self.imageView = [[UIImageView alloc]initWithImage:self.QRImage];
    self.imageView.contentMode = UIViewContentModeCenter;
    self.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.imageView.layer.borderWidth = 1;
    [self.bottomContentView addSubview:self.imageView];
    
    [self.topContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(self.view.mas_height).multipliedBy(0.25);
    }];
    
    [self.bottomContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topContentView.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    CGSize imageSize = self.QRImage.size;
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bottomContentView.mas_centerY);
        make.centerX.equalTo(self.bottomContentView.mas_centerX);
        make.height.equalTo(@(imageSize.height));
        make.width.equalTo(@(imageSize.width));
    }];
    
    
    self.promptLabel1 = [self creatLabel];
    [self.topContentView addSubview:self.promptLabel1];
    self.promptLabel1.text = [DTConstAndLocal qiantai];
    
    self.promptLabel2 = [self creatLabel];
    [self.topContentView addSubview:self.promptLabel2];
    self.promptLabel2.text = [DTConstAndLocal jieshouwifi];
    
    self.currentSSID = [DTConstAndLocal fetchSSID];
    self.promptLabel3 = [self creatLabel];
    [self.topContentView addSubview:self.promptLabel3];
    self.promptLabel3.text = self.currentSSID;
    self.promptLabel3.textColor = [UIColor colorWithHexString:@"08c364"];
    
    self.promptLabel4 = [self creatLabel];
    [self.topContentView addSubview:self.promptLabel4];
    self.promptLabel4.text = @"";
    
    self.promptLabel5 = [self creatLabel];
    [self.bottomContentView addSubview:self.promptLabel5];
    self.promptLabel5.textColor = [UIColor colorWithHexString:@"000000"];
    self.promptLabel5.text = [DTConstAndLocal jieshousaomiao];
    
    [self.promptLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topContentView.mas_top);
        make.left.equalTo(self.topContentView.mas_left).offset(20);
        make.right.equalTo(self.topContentView.mas_right).offset(-20);
        make.bottom.equalTo(self.promptLabel2.mas_top);
        
    }];
    
    [self.promptLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.promptLabel1.mas_bottom);
        make.left.equalTo(self.topContentView.mas_left).offset(20);
        make.right.equalTo(self.topContentView.mas_right).offset(-20);
        make.bottom.equalTo(self.promptLabel3.mas_top);
        make.height.equalTo(self.promptLabel1.mas_height);
    }];
    
    [self.promptLabel3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.promptLabel2.mas_bottom);
        make.left.equalTo(self.topContentView.mas_left).offset(20);
        make.right.equalTo(self.topContentView.mas_right).offset(-20);
        make.bottom.equalTo(self.promptLabel4.mas_top);
        make.height.equalTo(self.promptLabel2.mas_height);
    }];
    
    [self.promptLabel4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.promptLabel3.mas_bottom);
        make.left.equalTo(self.topContentView.mas_left).offset(20);
        make.right.equalTo(self.topContentView.mas_right).offset(-20);
        make.bottom.equalTo(self.topContentView.mas_bottom);
        make.height.equalTo(self.promptLabel3.mas_height);
    }];
    
    [self.promptLabel5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomContentView.mas_top);
        make.left.equalTo(self.bottomContentView.mas_left).offset(30);
        make.right.equalTo(self.bottomContentView.mas_right).offset(-30);
        make.bottom.equalTo(self.imageView.mas_top);
    }];
}

-(UILabel *)creatLabel{
    UILabel * label = [[UILabel alloc]init];
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 6;
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    return label;
}


-(void)reciveClientiPhoneName:(NSNotification *)noti{
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        self.promptLabel4.text = [NSString stringWithFormat:@"%@%@",[DTConstAndLocal device],noti.object];
    }];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.currentBringess = [UIScreen mainScreen].brightness;
    [UIView animateWithDuration:0.5 animations:^{
        [UIScreen mainScreen].brightness = 0.8;
    }];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [DTConstAndLocal openNetWorkingCheck:^(NSString *currentSSID) {
        self.promptLabel3.text = currentSSID;
        if (currentSSID == nil) {
            self.currentSSID = currentSSID;
            NSString * wifinotcontect = [DTConstAndLocal wifiDisablew];
            NSString * str = [wifinotcontect stringByAppendingFormat:@"!%@",[DTConstAndLocal chectnetwork]];
            [DTPromptHUD showWithString:str];
        }
        else if ([self.currentSSID isEqualToString:currentSSID]) {
            return;
        }else{
            self.currentSSID = currentSSID;
            NSString * bianhua = [DTConstAndLocal wangluobianhua];
            NSString * str = [bianhua stringByAppendingFormat:@"!%@",[DTConstAndLocal chectnetwork]];
            [DTPromptHUD showWithString:str];
        }
    }];
    [DTConstAndLocal showADRandom:2 forController:self];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIView animateWithDuration:0.5 animations:^{
        [UIScreen mainScreen].brightness = self.currentBringess;
    }];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [DTConstAndLocal closeNetWorikingCheck];
    
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
}


-(void)back{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:[DTConstAndLocal tishi] message:[DTConstAndLocal Areyousure] preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction * ok = [UIAlertAction actionWithTitle:[DTConstAndLocal ok] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [[DTServerManager shareInstance]closeServer];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:[DTConstAndLocal cancel] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)invitedInstall{
    
    NSString * appid;
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


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    [self.bottomContentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@(-contentInsets.bottom));
    }];
}


@end
