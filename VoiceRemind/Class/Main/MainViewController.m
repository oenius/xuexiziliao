//
//  MainViewController.m
//  VoiceRemind
//
//  Created by 何少博 on 16/8/24.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "MainViewController.h"
#import "CustomSettingsViewController.h"
#import "RecoderViewController.h"
#import "AllremindViewController.h"
#import "NSObject+x.h"
@interface MainViewController ()

@property (nonatomic,weak)IBOutlet UIButton * allRemind;
@property (weak, nonatomic) IBOutlet UIButton *recording;


@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setNavitiaonBarAnsView];
    [self setSubViews];
   
    LOG(@"Voice_directory->%@",Voice_directory);
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
-(void)setNavitiaonBarAnsView{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"AD" style:UIBarButtonItemStylePlain target:self action:@selector(adsButtonClick)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(jumpSettingController)];
    [self.view setBackgroundColor: [UIColor whiteColor]];
}
-(void)setSubViews{
    
    [_allRemind setTitle:@"所有提醒" forState:UIControlStateNormal];
    [_allRemind setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma  mark - actions

- (IBAction)allRemindButtonClick:(UIButton *)sender {
    AllremindViewController * allremind = [[AllremindViewController alloc]init];
    [self presentViewController:allremind animated:YES completion:nil];
    
}

- (IBAction)recordingButtonClick:(UIButton *)sender {
    RecoderViewController * reVC = [[RecoderViewController alloc]init];
    [self.navigationController pushViewController:reVC animated:YES];
}

-(void)jumpSettingController{
     CustomSettingsViewController* setting = [[CustomSettingsViewController alloc]init];
    [self.navigationController pushViewController:setting animated:YES];
}

-(void)adsButtonClick{
    
}

#pragma mark - 调整广告位置

-(float)adViewBottomOffsetFromSuperViewBottom{
    CGFloat view_h = self.view.bounds.size.height;
//    CGRect navFrame = self.navigationController.navigationBar.frame;
    CGFloat ads_h  = [self isIPad]?90:50;
    return view_h - ads_h;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self setAdViewHiden:YES];
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self adjustAdview];
    [self setAdViewHiden:NO];
    
}
@end