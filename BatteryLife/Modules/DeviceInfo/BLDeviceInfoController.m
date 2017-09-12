//
//  BLDeviceInfoController.m
//  BatteryLife
//
//  Created by vae on 16/11/16.
//  Copyright © 2016年 vae. All rights reserved.
//

#import "BLDeviceInfoController.h"
#import "BLDetailController.h"
#import "UIColor+x.h"
#import "NPGoProButton.h"
#import "NPCommonConfig.h"
@interface BLDeviceInfoController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *systemInfoArray;

    
@end

@implementation BLDeviceInfoController

#pragma mark - lazy load
-(NSMutableArray *)systemInfoArray{
    
    if (!_systemInfoArray) {

        _systemInfoArray = [NSMutableArray arrayWithArray:[self baseInfoArray]];
    }
    return _systemInfoArray;
}

- (BOOL)shouldShowNativeAdView {
    BOOL showAdView = [self needsShowAdView];
    if (showAdView) {
        UIView *nativeAdView = [self nativeAdView];
        if (nativeAdView) {
            return YES;
        }
    }
    return NO;
}

-(NSArray *)baseInfoArray{
   return  @[
      NSLocalizedString(@"battery", @"Battery"),
      NSLocalizedString(@"General", @"General"),
      NSLocalizedString(@"SECTION_HEADER_NETWORK", @"Network"),
      @"RAM",
      NSLocalizedString(@"Disk", @"Disk")
      ];
}

-(void)resetSysInfoArray{
    _systemInfoArray = [NSMutableArray arrayWithArray:[self baseInfoArray]];
    if ([self shouldShowNativeAdView]) {
        [_systemInfoArray addObject:@""];
    }
}

-(void)tableviewrelaodData{
    [self resetSysInfoArray];
    [self.tableView reloadData];
}

#pragma mark - Life Cycle



-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self tableviewrelaodData];
}

-(void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setUpView];
    
    BOOL isShowGoPro = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (isShowGoPro) {
        NPGoProButton * goPro = [NPGoProButton goProButton];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:goPro];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setUpViews

-(void)setUpView{
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}


#pragma mark - tableviewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return  self.systemInfoArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString *reuseID = @"SYSCELL";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID];
    }
    
    cell.textLabel.text = self.systemInfoArray[indexPath.row];
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    UIImage * image ;
    if (indexPath.row == 0) {
        image = [UIImage imageNamed:@"battery2"];
    }else if (indexPath.row == 1) {
        image = [UIImage imageNamed:@"general"];
    }else if(indexPath.row == 2){
        image = [UIImage imageNamed:@"internet"];
    }else if (indexPath.row == 3){
        image = [UIImage imageNamed:@"memori"];
    }else if (indexPath.row == 4){
        image = [UIImage imageNamed:@"storage"];
    }
    
    UIView *nativeAdView = [self nativeAdView];
    if (indexPath.row == 5){
        nativeAdView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [cell addSubview:nativeAdView];
    }else{
        cell.imageView.image = image;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return  cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 5) {
        return 80;
    }else{
        return 45.0;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BLDetailController *detailVC = [[BLDetailController alloc] init];
    if (indexPath.row == 0) {
        detailVC.infoType = @"Batter";
    }else if (indexPath.row == 1) {
        detailVC.infoType = @"General";
    }else if(indexPath.row == 2){
        detailVC.infoType = @"Network";
    }else if (indexPath.row == 3){
        detailVC.infoType = @"Memory";
    }else if (indexPath.row == 4){
        detailVC.infoType = @"Disk";
    }
    //TODO:修改itemTitle
    [self.navigationController pushViewController:detailVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
    //// 重写父类方法, 自定义不需要加载显示Banner广告
- (BOOL)needLoadBannerAdView {
    return NO;
}
    
    // 重写父类方法, 自定义需要加载显示原生250H广告
- (BOOL)needLoadNative250HAdView{
    return NO;
}
-(BOOL)needLoadNativeAdView{
    return YES;
}
- (BOOL)needShowRestorePaymentCell {
    return NO;
}


- (void)showNativeAdView:(UIView *)nativeAdView {
    [super showNativeAdView:nativeAdView];
    
    
    [self tableviewrelaodData];
}

- (void)removeAdNotification:(NSNotification *)notification {
    [super removeAdNotification:notification];
    self.navigationItem.rightBarButtonItem = nil;
    [self tableviewrelaodData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
