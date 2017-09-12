//
//  ViewController.m
//  BatteryLife
//
//  Created by vae on 16/11/16.
//  Copyright © 2016年 vae. All rights reserved.
//

#import "BLBatteryLevelController.h"
#import "UIView+Frame.h"
#import "CircleView.h"
#import "DeviceModel.h"
#import "NPCommonConfig.h"
#import "NPGoProButton.h"
#import "UIColor+x.h"
@interface BLBatteryLevelController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) CircleView *circleView;
@property (nonatomic, weak) UILabel *batteryHealthLabel;
@property (nonatomic, weak) UILabel *batteryLeftLabel;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, strong) NSArray *batteryInfoArray;
@property (nonatomic, strong) NSMutableArray *batteryDetailInfoArray;

@property (nonatomic, strong) NSString *batteryReality;
@property (nonatomic, copy) NSString *batteryState;
@property (nonatomic, strong) NSString *currentDeviceBatteryCapacity;
@property (nonatomic, assign) UIDeviceBatteryState state;
@property (nonatomic, assign) NSInteger batterSunHao;

@end

@implementation BLBatteryLevelController

-(NSString *)batteryState{
    if (!_batteryState) {
        _batteryState = [NSString string];
    }
    return _batteryState;
}

-(NSString *)batteryReality{

    if (!_batteryReality) {
        _batteryReality = [NSString string];
    }
    return _batteryReality;
}

//-(NSMutableArray *)batteryDetailInfoArray{
//
//    if (!_batteryDetailInfoArray) {
//       _batteryDetailInfoArray = [NSMutableArray arrayWithCapacity:4];
//    }
//    return _batteryDetailInfoArray;
//}

#pragma mark - Life cycle

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryLevelChanged)
                                                 name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateChange) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryStateDidChangeNotification object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL isLite = [[NPCommonConfig shareInstance] isLiteApp];
    if (isLite) {
        [[NPCommonConfig shareInstance] initAdvertise];
    }
    
    BOOL isShowAD = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (isShowAD) {
        self.interstitialButton = [NPInterstitialButton buttonWithType:NPInterstitialButtonTypeIcon viewController:self];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.interstitialButton];
        NPGoProButton * proBtn = [NPGoProButton goProButton];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:proBtn];
    }
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    
    [self setUpViews];
    
    [self initData];

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(_containerView.frame), self.view.width, self.view.height - _containerView.height);
    [_circleView makeCircle:self.batterSunHao];
    [self batteryStateChange];
}
-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    self.tableView.contentInset = contentInsets;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Load Views
-(void)setUpViews{
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height / 2.0 )];
    containerView.backgroundColor = [UIColor colorWithHexString:@"#545454"];
    [self.view addSubview:containerView];

    
    //设置环形进度条
    CircleView *circleView = [[CircleView alloc] initWithFrame:CGRectMake(containerView.width / 5.0, containerView.height / 6.0 , containerView.width / 5.0 * 3 , containerView.height / 3.0 * 2)];
    circleView.lineWidth = 20;
    circleView.cirleColor = [UIColor colorWithHexString:@"#4aca1d"];
    [circleView makeCircle:100];
    [containerView addSubview:circleView];
    _circleView = circleView;
    
   //健康状况
    CGFloat y = CGRectGetMaxY(circleView.frame);
    UILabel *batteryHealthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, containerView.width, containerView.height - y)];
    NSString * healthString;
    self.batterSunHao = [self batterSunHao];
    
    if (_batterSunHao >= 99) {
        healthString = NSLocalizedString(@"very healthy", @"Very healthy");
    }
    if (_batterSunHao == 98) {
        healthString = NSLocalizedString(@"Health", @"Health");
    }
    if (_batterSunHao == 95) {
        healthString = NSLocalizedString(@"ordinary", @"ordinary");
    }
    batteryHealthLabel.text = healthString;
    batteryHealthLabel.textAlignment = NSTextAlignmentCenter;
    batteryHealthLabel.textColor = [UIColor whiteColor];
    batteryHealthLabel.font = [UIFont systemFontOfSize:27];
    _batteryHealthLabel = batteryHealthLabel;
    [containerView addSubview:batteryHealthLabel];
    
    
//    //可用时长
//    UILabel *batteryLeftLeft = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, circleView.width-20, 20)];
//    batteryLeftLeft.center = circleView.center;
//    batteryLeftLeft.textAlignment = NSTextAlignmentCenter;
//    batteryLeftLeft.textColor = [UIColor greenColor];
//    batteryLeftLeft.font = [UIFont systemFontOfSize:20];
//    batteryLeftLeft.numberOfLines = 1;
//    batteryLeftLeft.minimumScaleFactor = 0.5;
//    batteryLeftLeft.adjustsFontSizeToFitWidth = YES;
//    _batteryLeftLabel = batteryLeftLeft;
//    [containerView addSubview:batteryLeftLeft];
    _containerView = containerView;
    //显示电池基本信息
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(containerView.frame), self.view.width, self.view.height - containerView.height)];
    [self.view addSubview:tableView];
    _tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    
    
}

-(void)initData{
    
    self.batteryInfoArray = @[NSLocalizedString(@"remaining battery", @"Remaining battery capacity"),
                              NSLocalizedString(@"Battery status", @"Battery status")
                              ];
    //具体的电池信息
    if (!_currentDeviceBatteryCapacity) {
        _currentDeviceBatteryCapacity = NSLocalizedString(@"Unknown state", @"Unknown state");
    }
    [self batteryLevelChanged];
    
    self.batteryDetailInfoArray = [@[_batteryReality,
                                     self.batteryState] mutableCopy];
    
    [self batteryStateChange];
    
}


//-(void)initData{
//
//    self.batteryInfoArray = @[@"电池电量",
//                              @"剩余电量",
//                              @"电压",
//                              @"状态"
//                              ];
//    //具体的电池信息
//    NSString *currentDeviceBatteryCapacity = [[DeviceModel sharedModel] battery_capacity];
//    NSString *voltage = [NSString stringWithFormat:@"%.2fV",randomFloatBetween(430, 432)/100];
//    _currentDeviceBatteryCapacity = currentDeviceBatteryCapacity;
//    
//    if (!_currentDeviceBatteryCapacity) {
//        _currentDeviceBatteryCapacity = @"unkonwn";
//    }
//    
//    [self batteryLevelChanged];
//    
//    self.batteryDetailInfoArray = [@[_currentDeviceBatteryCapacity,
//                                    _batteryReality,
//                                    voltage,
//                                    self.batteryState] mutableCopy];
//    
//    [self batteryStateChange];
//
//}


#pragma mark - private method
//电池电量改变
-(void)batteryLevelChanged{
    
    CGFloat batteryLevel = [UIDevice currentDevice].batteryLevel;
    NSString *battry =[NSString stringWithFormat:@"%.f", batteryLevel * 100];
    _batteryReality = [NSString stringWithFormat:@"%@%%",battry];
    if (self.batteryDetailInfoArray) {
        self.batteryDetailInfoArray[0] = self.batteryReality;
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
           self.batteryDetailInfoArray[1] =  NSLocalizedString(@"Not charged", @"Not charged");
            break;
        case UIDeviceBatteryStateFull:
            self.batteryDetailInfoArray[1] = NSLocalizedString(@"finished charging", @"Finished charging");
            break;
        case UIDeviceBatteryStateCharging:
            self.batteryDetailInfoArray[1] = NSLocalizedString(@"charging", @"charging");
            break;
        case UIDeviceBatteryStateUnknown:
            self.batteryDetailInfoArray[1] = NSLocalizedString(@"Unknown state", @"Unknown state");
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}

-(void)removeAdNotification:(NSNotification *)notification{
    [super removeAdNotification:notification];
    self.navigationItem.leftBarButtonItem = nil;
}

#pragma mark - 电池损耗

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

#pragma mark - tableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.batteryInfoArray.count;
}


#pragma mark - tableViewDelegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString *reuseID = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID];
    }

    cell.textLabel.text = self.batteryInfoArray[indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#a8a8a8"];
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.text = self.batteryDetailInfoArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 1) {
        if (_state == UIDeviceBatteryStateUnplugged) {
            
            cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#e32d2d"];
            
        }else if(_state == UIDeviceBatteryStateFull){
            cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#4aca1d"];
        }else if (_state == UIDeviceBatteryStateCharging){
            cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#4aca1d"];
        }
        
    }else{
       cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#545454"];
    }

    return  cell;
}

@end
