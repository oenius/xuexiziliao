//
//  BLDetailController.m
//  BatteryLife
//
//  Created by vae on 16/11/17.
//  Copyright © 2016年 vae. All rights reserved.
//

#import "BLDetailController.h"
#import "BLGeneralModel.h"
#import "BLNetWorkModel.h"
#import "BLMemoryModel.h"
#import "BLDiskModel.h"
#import "DeviceModel.h"
#import "NPCommonConfig.h"
@interface BLDetailController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *systemInfoTitleArray;
@property (nonatomic, strong) NSMutableArray *systemInfoDetailsArray;


@property (nonatomic, strong) NSString *batteryReality;
@property (nonatomic, copy) NSString *batteryState;
@property (nonatomic, strong) NSString *currentDeviceBatteryCapacity;
@property (nonatomic, assign) UIDeviceBatteryState state;
@end

@implementation BLDetailController


#pragma mark - life cycle



- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self initData];
    
    [self setUpViews];
    
    BOOL isShowAD = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (isShowAD) {
        self.interstitialButton = [NPInterstitialButton buttonWithType:NPInterstitialButtonTypeIcon viewController:self];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.interstitialButton];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setUpViews{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.tableView.frame = self.view.bounds;
}

-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    self.tableView.contentInset = contentInsets;
}

#pragma mark - initData
-(void)initData{

    if ([self.infoType isEqualToString:@"General"]) {
        BLGeneralModel *model = [[BLGeneralModel alloc] init];
        self.systemInfoTitleArray = [NSMutableArray arrayWithArray:model.systemInfoTitle];
        self.systemInfoDetailsArray = [NSMutableArray arrayWithArray:model.systemInfoDetails];
    }else if ([self.infoType isEqualToString:@"Network"]){
        BLNetWorkModel *model = [[BLNetWorkModel alloc] init];
        self.systemInfoTitleArray = [NSMutableArray arrayWithArray:model.netWorkTitleArray];
        self.systemInfoDetailsArray = [NSMutableArray arrayWithArray:model.netWorkDetailsArray];
    }else if([self.infoType isEqualToString:@"Memory"]){
        BLMemoryModel *model = [[BLMemoryModel alloc] init];
        self.systemInfoTitleArray = [NSMutableArray arrayWithArray:model.memoryTitleArray];
        self.systemInfoDetailsArray = [NSMutableArray arrayWithArray:model.memoryDetailsArray];
    }else if ([self.infoType isEqualToString:@"Disk"]){
        BLDiskModel *model = [[BLDiskModel alloc] init];
        self.systemInfoTitleArray = [NSMutableArray arrayWithArray:model.diskTitleArray];
        self.systemInfoDetailsArray = [NSMutableArray arrayWithArray:model.diskDetailsArray];;
    }else if([self.infoType isEqualToString:@"Batter"]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryLevelChanged)
                                                     name:UIDeviceBatteryLevelDidChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateChange) name:UIDeviceBatteryStateDidChangeNotification object:nil];
        [self initBatterData];
    }
}
-(void)initBatterData{
    
    NSString * diangliang = NSLocalizedString(@"battery power", @"Battery Power");
    NSString * rongliang = NSLocalizedString(@"Remain Capacity", @"Remain Capacity");
    NSString * diangya = NSLocalizedString(@"Voltage", @"Voltage");
    NSString * zhuangtai = NSLocalizedString(@"Battery status", @"Battery status");
    self.systemInfoTitleArray = [NSMutableArray arrayWithObjects:diangliang,rongliang,diangya, zhuangtai,nil];
    CGFloat batteryLevel = [UIDevice currentDevice].batteryLevel;
    self.systemInfoTitleArray[0] = [NSString stringWithFormat:@"%@(%.0f)%%",diangliang,batteryLevel*100];
    //具体的电池信息
    UIDevice *device = [UIDevice currentDevice];
    //展示一下UIDevice里的一些常用属性
    NSLog(@"当前设备名:%@",device.name);
    NSLog(@"当前设备类型:%@",device.model);
    NSLog(@"当前设备本地化版本:%@",device.localizedModel);
    NSLog(@"当前设备系统:%@",device.systemName);
    NSLog(@"当前设备系统版本:%@",device.systemVersion);
    NSString *currentDeviceBatteryCapacity = [[DeviceModel sharedModel] battery_capacity];
    
    DeviceModel * model = [DeviceModel sharedModel];
    NSLog(@"当前设备名:%@",model.device_name);
    NSLog(@"当前设备类型:%@",model.battery_capacity);
    
    NSString *voltage = [NSString stringWithFormat:@"%.2fV",randomFloatBetween(428, 432)/100];
    _currentDeviceBatteryCapacity = currentDeviceBatteryCapacity;
    CGFloat persent = ((CGFloat)[self batterSunHao]);
    self.systemInfoTitleArray[1] = [NSString stringWithFormat:@"%@(%.0f)%%",rongliang,persent];
    if (!_currentDeviceBatteryCapacity) {
        _currentDeviceBatteryCapacity = NSLocalizedString(@"Unknown state", @"Unknown state");
    }else{
        NSString *realityBattery = [_currentDeviceBatteryCapacity stringByReplacingOccurrencesOfString:@"mAh" withString:@""];
        _currentDeviceBatteryCapacity = [NSString stringWithFormat:@"%.0fmAh",realityBattery.floatValue * (persent/100)];
        
    }
    NSString * batterCapacity = [NSString stringWithFormat:@"%@/%@",_currentDeviceBatteryCapacity,currentDeviceBatteryCapacity];
    [self batteryLevelChanged];
    
    self.systemInfoDetailsArray = [NSMutableArray arrayWithObjects:_batteryReality,
                                                                   batterCapacity,
                                                                   voltage,
                                                                   self.batteryState,nil];
    
    [self batteryStateChange];
    
}
//电池电量改变
-(void)batteryLevelChanged{
    
    CGFloat batteryLevel = [UIDevice currentDevice].batteryLevel;

    NSString *realityBattery = [_currentDeviceBatteryCapacity stringByReplacingOccurrencesOfString:@"mAh" withString:@""];
    _batteryReality = [NSString stringWithFormat:@"%ldmAh/%ldmAh",(long)(batteryLevel * realityBattery.integerValue),(long)realityBattery.integerValue];
    if (self.systemInfoDetailsArray) {
        self.systemInfoDetailsArray[0] = self.batteryReality;
        NSString * diangliang = NSLocalizedString(@"battery power", @"Battery Power");
        self.systemInfoTitleArray[0] = [NSString stringWithFormat:@"%@(%.0f)%%",diangliang,batteryLevel*100];
    }
    

    
    [self.tableView reloadData];
}


//电池充电状态改变
-(void)batteryStateChange{
    
    UIDevice *device = [UIDevice currentDevice];
    UIDeviceBatteryState state = [UIDevice currentDevice].batteryState;
    _state = state;
    
    switch (device.batteryState) {
        case UIDeviceBatteryStateUnplugged:
            self.systemInfoDetailsArray[3] = NSLocalizedString(@"Not charged", @"Not charged");
            break;
        case UIDeviceBatteryStateFull:
            self.systemInfoDetailsArray[3] = NSLocalizedString(@"finished charging", @"Finished charging");
            break;
        case UIDeviceBatteryStateCharging:
            self.systemInfoDetailsArray[3] = NSLocalizedString(@"charging", @"charging");
            break;
        case UIDeviceBatteryStateUnknown:
            self.systemInfoDetailsArray[3] = NSLocalizedString(@"Unknown state", @"Unknown state");
            break;
        default:
            break;
    }
    [self.tableView reloadData];
    
    
}
-(NSInteger)batterSunHao{
    NSString * deviceModel = [DeviceModel platform];
    BOOL isiPhone6 = [deviceModel containsString:@"iPhone 6"];
    BOOL isiPhone6s_SE = ([deviceModel containsString:@"iPhone 6s"]||[deviceModel containsString:@"iPhone SE"]);
    BOOL isiPhone7 = [deviceModel containsString:@"iPhone 7"];
    BOOL isiPadAir = [deviceModel containsString:@"iPad Air"];
    BOOL isiPadPro = [deviceModel containsString:@"iPad Pro"];
    
    if (isiPhone7) {
        return  100;
    }
    if (isiPadPro || isiPhone6s_SE) {
        return 99;
    }
    if (isiPadAir || isiPhone6) {
        return 98;
    }
    return 95;
}

float randomFloatBetween(float smallNumber,float bigNumber){
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}
#pragma mark - tableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.systemInfoTitleArray.count;
}


#pragma mark - tableViewDelegate 
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *reuseID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID];
    }
    
    cell.textLabel.text = self.systemInfoTitleArray[indexPath.row];
    cell.detailTextLabel.text = self.systemInfoDetailsArray[indexPath.row];
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
//
//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//
//
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
