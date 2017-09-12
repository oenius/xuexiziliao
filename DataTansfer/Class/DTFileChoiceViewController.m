//
//  DTFileChoiceViewController.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/18.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTFileChoiceViewController.h"
#import "DTFileChoiceViewModel.h"
#import "DTFileChoiceTableViewCell.h"
#import "DTContactPickerViewController.h"
#import "DTPhotoPickerViewController.h"
#import "DTVideoPickerViewController.h"
//#import "DTMusicPickerViewController.h"
#import "UINavigationController+DT.h"
#import "DTServerManager.h"
#import "DTSearchDeviceViewController.h"
#import "DTSendDataViewController.h"
#import <SVProgressHUD.h>
#import "UIImage+x.h"
#import "UINavigationController+DT.h"
#import "HSPresentAnimaion.h"
@interface DTFileChoiceViewController ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UINavigationBarDelegate>

@property (nonatomic,strong) UITableView * tableView;

@property (nonatomic,strong) DTFileChoiceViewModel * viewModel;

@property (nonatomic,strong) UIButton * beginSentBtn;

@end


static NSString * kDTFileChoiceCellID = @"kDTFileChoiceCellID";

@implementation DTFileChoiceViewController


#pragma mark - 初始化

-(DTFileChoiceViewModel *)viewModel{
    if (_viewModel == nil) {
        _viewModel = [[DTFileChoiceViewModel alloc]init];
    }
    return _viewModel;
}

-(void)setupSubViews{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:(UITableViewStyleGrouped)];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView registerClass:[DTFileChoiceTableViewCell class] forCellReuseIdentifier:kDTFileChoiceCellID];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.beginSentBtn = [[UIButton alloc]init];
    [self.beginSentBtn setTitle:[DTConstAndLocal startSending] forState:(UIControlStateNormal)];
    [self.beginSentBtn setTitleColor:[UIColor colorWithHexString:@"333333"] forState:(UIControlStateNormal)];
    [self.beginSentBtn setBackgroundImage:[UIImage imageNamed:@"btn2"] forState:(UIControlStateNormal)];;
    [self.beginSentBtn addTarget:self action:@selector(beignSentClick) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:self.beginSentBtn];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    CGFloat bottomSpac = 50;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        bottomSpac = 90;
    }
    [self.beginSentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.view).offset(-bottomSpac);
        make.height.equalTo(self.view.mas_height).multipliedBy(0.08);
    }];
}
    

#pragma mark - 视图生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController clearUI];
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"iphonebg"].CGImage);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:(UIBarButtonItemStylePlain) target:self action:@selector(back)];
    [self setupSubViews];
    
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.tableView) {
        [self.tableView reloadData];
    }
    [UIApplication sharedApplication].statusBarHidden = NO;
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}




-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [DTConstAndLocal showADRandom:5 forController:self];

}

#pragma mark - acrions

-(void)beignSentClick{
    if ([self.viewModel checkSelectedCount] == 0) {
        [SVProgressHUD showImage:nil status:[DTConstAndLocal xuanzewenjia]];
        [SVProgressHUD dismissWithDelay:1.5];
        return;
    }else{
        [self.viewModel syncSelectsToDataResponse];
        if ([[DTServerManager shareInstance] isRunning]) {
            [self openQRWithUrl:nil];
        }else{
            [SVProgressHUD show];
            [[DTServerManager shareInstance] openServer:^(NSString *baseUrl) {
                [self openQRWithUrl:baseUrl];
                [SVProgressHUD dismiss];
            }];
        }
    }
    
}

-(void)openQRWithUrl:(NSString *)baseUrl{
    NSString * url = baseUrl;
    if (baseUrl == nil) {
        url = [DTServerManager shareInstance].baseUrl;
    }
    NSString * taskListRequeltStr = [url stringByAppendingString:kRequestTaskListPath];
    LOG(@"baseUrl = %@,taskListRequeltStr = %@",url,taskListRequeltStr);
//    UIImage * QR = [UIImage createQRWithString:taskListRequeltStr QRSize:CGSizeMake(180, 180) QRColor:[UIColor whiteColor] bkColor:[UIColor blackColor]];
    UIImage * QR = [UIImage generateWithDefaultQRCodeData:taskListRequeltStr imageViewWidth:200];
    [SVProgressHUD dismiss];
    if (QR == nil) {  return; }
    DTSendDataViewController * sendData = [[DTSendDataViewController alloc]initWithQRImage:QR];
    UINavigationController * navi = [[UINavigationController alloc]initWithRootViewController:sendData];
    navi.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:navi animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewModel numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.viewModel numberOfRowsInSection:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DTFileChoiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDTFileChoiceCellID ];
    cell.model = [self.viewModel modelAtIndexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DTFileChoiceModel * model = [self.viewModel modelAtIndexPath:indexPath];
    DTDataBaseViewModel * baseViewModel = model.viewModel;
    switch (model.modelType) {
        case DTFileTypeContact:
            [self goToChoiceContact:baseViewModel];
            break;
        case DTFileTypePhtoto:
            [self goToChoicePhoto:baseViewModel];
            break;
        case DTFileTypeVideo:
            [self goToChoiceVideo:baseViewModel];
            break;
        case DTFileTypeMusic:
            [self goToChoiceMusic:baseViewModel];
            break;
        default:
            break;
    }
}
-(void)goToChoiceContact:(DTDataBaseViewModel *)viewModel{
    DTContactPickerViewController * contact = [[DTContactPickerViewController alloc]init];
    contact.viewModel = (DTContactViewModel *)viewModel;
    UINavigationController * contactNavi = [[UINavigationController alloc]initWithRootViewController:contact];
    [contactNavi defaultUI];
    [self presentViewController:contactNavi animated:YES completion:nil];
}
-(void)goToChoicePhoto:(DTDataBaseViewModel *)viewModel{
    DTPhotoPickerViewController * vc = [[DTPhotoPickerViewController alloc]init];
    vc.viewModel = (DTPhotoViewModel *)viewModel;
    UINavigationController * vcNavi = [[UINavigationController alloc]initWithRootViewController:vc];
    [vcNavi defaultUI];
    [self presentViewController:vcNavi animated:YES completion:nil];
}
-(void)goToChoiceVideo:(DTDataBaseViewModel *)viewModel{
    DTVideoPickerViewController * vc = [[DTVideoPickerViewController alloc]init];
    vc.viewModel = (DTVideoViewModel *)viewModel;
    UINavigationController * vcNavi = [[UINavigationController alloc]initWithRootViewController:vc];
    [vcNavi defaultUI];
    [self presentViewController:vcNavi animated:YES completion:nil];
}
-(void)goToChoiceMusic:(DTDataBaseViewModel *)viewModel{
//    DTMusicPickerViewController * vc = [[DTMusicPickerViewController alloc]init];
//    vc.viewModel = (DTMusicViewModel *)viewModel;
//    UINavigationController * vcNavi = [[UINavigationController alloc]initWithRootViewController:vc];
//    [vcNavi defaultUI];
//    [self presentViewController:vcNavi animated:YES completion:nil];
}
-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-contentInsets.bottom);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view setNeedsDisplay];
    }];
}

@end
