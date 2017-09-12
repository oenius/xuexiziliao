//
//  ShenHeViewController.m
//  PrivateAlbumV1.0
//
//  Created by 刘胜 on 2017/8/22.
//  Copyright © 2017年 刘胜. All rights reserved.
//

#import "ShenHeViewController.h"
#import "UIColor+SN.h"
#import "NPCommonConfig+FeiFan.h"
@interface ShenHeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titlebel;


@property (weak, nonatomic) IBOutlet UITextView *aaaaa;
@property (weak, nonatomic) IBOutlet UIButton *yinsi;
@property (weak, nonatomic) IBOutlet UIButton *fuwu;

@end

@implementation ShenHeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.aaaaa setTextColor:[UIColor colorWithHexString:@"0x589BF4"]];
    [self.titlebel setTextColor:[UIColor colorWithHexString:@"0x589BF4"]];
    self.yinsi.backgroundColor = [UIColor colorWithHexString:@"0x589BF4"];
    self.fuwu.backgroundColor = [UIColor colorWithHexString:@"0x589BF4"];
    [self.yinsi setTitle:NSLocalizedString(@"Privacy_Policy.new", @"隐私政策") forState:(UIControlStateNormal)];
    self.yinsi.layer.cornerRadius = 5;
    self.yinsi.layer.masksToBounds = YES;
    [self.fuwu setTitle:NSLocalizedString(@"service.detial", @"服务条款") forState:(UIControlStateNormal)];
    self.fuwu.layer.cornerRadius = 5;
    self.fuwu.layer.masksToBounds = YES;
    self.titlebel.text = @"PREMIUM SUBSCRIPTION";
    self.aaaaa.text = [NPCommonConfig shareInstance].subscriptionDescription;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.aaaaa.font = [UIFont fontWithName:@"Arial" size:20];
    }
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"fanhui"] style:(UIBarButtonItemStylePlain) target:self action:@selector(cancel:)];
}

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(cancelClick)]) {
            [self.delegate cancelClick];
        }
    }];
}
- (IBAction)yinsi:(id)sender {
    NSURL * url = [NSURL URLWithString:[NPCommonConfig shareInstance].privacyPolicyUrl];
    [[UIApplication sharedApplication] openURL:url];
}
- (IBAction)fuwu:(id)sender {
    NSURL * url = [NSURL URLWithString:[NPCommonConfig shareInstance].teamOfUseUrl];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
