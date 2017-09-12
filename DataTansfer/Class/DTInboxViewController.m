//
//  DTInboxViewController.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/17.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTInboxViewController.h"
//#import "DTMusicViewController.h"
#import <MWPhotoBrowser.h>
#import <SVProgressHUD.h>
#import "DTAssetPickerDataSource.h"
#import "DTAssetBaseViewModel.h"
#import "UINavigationController+DT.h"

@interface DTInboxViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView * tableView;

@property (nonatomic,strong) DTAssetPickerDataSource * browserDataSource;

@property (nonatomic,strong) NSArray * dataSource;

@property (nonatomic,strong) DTAssetBaseViewModel * baseViewModel;

@end

@implementation DTInboxViewController


#pragma mark - life Clirle

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupSubViews];
    [self setupDataSource];
    [self.navigationController clearUI];
    self.title = [DTConstAndLocal inbox];
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"bg"].CGImage);
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
}

-(void)setupSubViews{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:(UITableViewStylePlain)];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom);
        make.right.equalTo(self.view.mas_right);
    }];
}

-(void)setupDataSource{
    self.dataSource = @[
                        [DTConstAndLocal tupian],
                        [DTConstAndLocal shipin],
//                        [DTConstAndLocal yinyue],
                        ];
}


#pragma mark - Table view data source



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InboxViewCellID" ];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleValue1) reuseIdentifier:@"InboxViewCellID"];
    }
    
    [self congigCell:cell atIndexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row <= 1){
        [SVProgressHUD show];
        self.baseViewModel = [[DTAssetBaseViewModel alloc]init];
        if (indexPath.row == 0) {
            [self.baseViewModel loadDatasInbox:PHAssetMediaTypeImage];
        }else{  
            [self.baseViewModel loadDatasInbox:PHAssetMediaTypeVideo];
        }
        self.browserDataSource = [[DTAssetPickerDataSource alloc]initWithDataSource:_baseViewModel.dataArray];
        
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self.browserDataSource];
        browser.displayActionButton = YES;
        browser.displayNavArrows = YES;
        browser.displaySelectionButtons = NO;
        browser.alwaysShowControls = NO;
        browser.zoomPhotosToFill = YES;
        browser.enableGrid = YES;
        browser.startOnGrid = YES;
        [browser setCurrentPhotoIndex:0];
        [SVProgressHUD dismiss];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:nc animated:YES completion:nil];
        browser.title = self.dataSource[indexPath.row];
        [DTConstAndLocal showADRandom:5 forController:browser];
    }
    
//    if (indexPath.row == 2) {
//        DTMusicViewController * musicvc =[[DTMusicViewController alloc]init];
//        musicvc.title = self.dataSource[indexPath.row];
//        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:musicvc];
//        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//        [self presentViewController:nc animated:YES completion:nil];
//    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}
-(void)congigCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    cell.textLabel.text = self.dataSource[indexPath.row];
    if ([cell.textLabel.text isEqualToString:[DTConstAndLocal tupian]]) {
        cell.imageView.image = [UIImage imageNamed:@"xiangce"];
    }
    else if ([cell.textLabel.text isEqualToString:[DTConstAndLocal shipin]]) {
        cell.imageView.image = [UIImage imageNamed:@"shiping"];
    }
    else if ([cell.textLabel.text isEqualToString:[DTConstAndLocal yinyue]]) {
        cell.imageView.image = [UIImage imageNamed:@"yinyue"];
    }
    UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    cell.selectedBackgroundView = backView;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
-(BOOL)needLoadNative250HAdView{
    return YES;
}
- (void)showNative250HAdView:(UIView *)nativeAdView {
    [super showNative250HAdView:nativeAdView];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat tableViewContentHeight = self.tableView.contentSize.height;
    CGSize nativeViewSize = nativeAdView.frame.size;
    CGRect destFrame = CGRectMake((screenWidth - nativeViewSize.width) / 2.0, tableViewContentHeight, nativeViewSize.width, nativeViewSize.height);
    nativeAdView.frame = destFrame;
    [self.tableView addSubview:nativeAdView];
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.bottom = nativeAdView.frame.size.height;
    self.tableView.contentInset = inset;
}

@end
