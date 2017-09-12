//
//  DTAssetBasePickerViewController.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/22.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTAssetBasePickerViewController.h"
#import <MWPhotoBrowser.h>
#import <MWPhotoBrowserPrivate.h>

#import <MBProgressHUD.h>

#import "DTAssetPickerDataSource.h"

#import "DTVideoViewModel.h"
#import "DTPhotoViewModel.h"
#import "UINavigationController+DT.h"
@interface DTAssetBasePickerViewController ()
@property (nonatomic,strong) MBProgressHUD * hud;
@property (nonatomic,strong) DTAssetPickerDataSource * dataSource;
@property (nonatomic,strong) MWPhotoBrowser * browser;
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,assign) BOOL isSelectAll;
@end

@implementation DTAssetBasePickerViewController


-(void)setBaseViewModel:(DTAssetBaseViewModel *)baseViewModel{
    _baseViewModel = baseViewModel;
    self.dataSource = [[DTAssetPickerDataSource alloc]initWithDataSource:_baseViewModel.dataArray];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"08c364"];
    self.view.layer.contents  = (__bridge id _Nullable)([UIImage imageNamed:@"tongxunlubg"].CGImage);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:[DTConstAndLocal quanxuan] style:UIBarButtonItemStylePlain target:self action:@selector(selectorAllItemClick)];
    UIBarButtonItem *doneBarItem = [[UIBarButtonItem alloc]initWithTitle:[DTConstAndLocal done] style:(UIBarButtonItemStylePlain) target:self action:@selector(doneItemClick)];
    self.navigationItem.leftBarButtonItem = doneBarItem;
    self.contentView = [[UIView alloc] init];
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    [self.baseViewModel getSelectIndexNumbersFromModels:self.dataSource.selecteds];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.browser) {
        [self jiaZaiBorwser:YES];
    }
}

-(void)jiaZaiBorwser:(BOOL)animation{
    self.browser = [[MWPhotoBrowser alloc] initWithDelegate:self.dataSource];
    _browser.displayActionButton = YES;
    _browser.displayNavArrows = YES;
    _browser.displaySelectionButtons = YES;
    _browser.alwaysShowControls = NO;
    _browser.zoomPhotosToFill = YES;
    _browser.enableGrid = YES;
    _browser.startOnGrid = YES;
    _browser.enableSwipeToDismiss = YES;
    _browser.autoPlayOnAppear = NO;
    _browser.view.frame = self.contentView.bounds;
    _browser.view.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_browser.view];
    _browser.view.alpha = 0;
    [self showActivityAnimation:NO];
    NSTimeInterval durarion = animation ? 0.5 : 0.0;
    [UIView animateWithDuration:durarion animations:^{
        _browser.view.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    
}
-(void)showActivityAnimation:(BOOL)show{
    if (show) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.view.userInteractionEnabled = NO;
    }else{
        [self.hud hide:YES];
        self.view.userInteractionEnabled = YES;
    }
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    _browser.view.frame = self.contentView.bounds;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!self.browser) {
        [self showActivityAnimation:YES];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)doneItemClick{
    
    [self.baseViewModel setSelectedArrayWithIndexNumbers:self.dataSource.selecteds];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)selectorAllItemClick{
    UIBarButtonItem * sender = self.navigationItem.rightBarButtonItem;
    BOOL isSelectAll = NO;
    if ([sender.title isEqualToString:[DTConstAndLocal quanxuan]]) {
        [sender setTitle:[DTConstAndLocal cancel]];
        isSelectAll = YES;
    }else{
        [sender setTitle:[DTConstAndLocal quanxuan]];
    }
    if (isSelectAll) {
        [self.dataSource selectedAllPhotos];
        [self.browser hideGrid];
        [self.browser showGrid:YES];
    }else{
        [self.dataSource removeSelectedAllPhotos];
        [self.browser hideGrid];
        [self.browser showGrid:YES];
    }
}
-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-contentInsets.bottom);
    }];
}

-(BOOL)needLoadBannerAdView{
    return NO;
}

@end
