//
//  BLUseTimeController.m
//  BatteryLife
//
//  Created by vae on 16/11/16.
//  Copyright © 2016年 vae. All rights reserved.
//

#import "BLUseTimeController.h"
#import "BLUseTableViewCell.h"
#import "UIView+Frame.h"
#import "NPCommonConfig.h"

@interface BLUseTimeController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;


@property (nonatomic, strong) NSMutableArray * modelGroup;

@property (nonatomic, strong) NSMutableArray * group1;
@property (nonatomic, strong) NSMutableArray * group2;
@property (nonatomic, strong) NSMutableArray * group3;
@property (nonatomic, strong) NSMutableArray * group4;
@end

static NSString * reuseIdentifier = @"AvailableViewCell";


@implementation BLUseTimeController

- (NSMutableArray *)modelGroup {
    if (_modelGroup == nil) {
        _modelGroup = [[NSMutableArray alloc] initWithCapacity:30];
        
        NSData * JsonData  = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Available" ofType:@"json"]];
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:JsonData options:NSJSONReadingMutableLeaves error:nil];
        
        for (NSDictionary * item in dic[@"list"]) {
            AvailableModel * model = [[AvailableModel alloc] init];
            [model setValuesForKeysWithDictionary:item];
            [_modelGroup addObject:model];
        }
    }
    return _modelGroup;
}

-(NSMutableArray *)group1{
    if (_group1 == nil) {
        NSMutableArray * array = [NSMutableArray array];
        for (int i = 0; i <= 3 ; i ++) {
            [array addObject:[self.modelGroup objectAtIndex:i]];
        }
        _group1 = array;
    }
    return _group1;
}
-(NSMutableArray *)group2{
    if (_group2 == nil) {
        NSMutableArray * array = [NSMutableArray array];
        for (int i = 4; i <= 6 ; i ++) {
            [array addObject:[self.modelGroup objectAtIndex:i]];
        }
        _group2 = array;
    }
    return _group2;
}
-(NSMutableArray *)group3{
    if (_group3 == nil) {
        NSMutableArray * array = [NSMutableArray array];
        for (int i = 7; i <= 14 ; i ++) {
            [array addObject:[self.modelGroup objectAtIndex:i]];
        }
        _group3 = array;
    }
    return _group3;
}
-(NSMutableArray *)group4{
    if (_group4 == nil) {
        NSMutableArray * array = [NSMutableArray array];
        for (int i = 15; i <= 16 ; i ++) {
            [array addObject:[self.modelGroup objectAtIndex:i]];
        }
        _group4 = array;
    }
    return _group4;
}
#pragma mark - Life Cycle

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear: animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //tableView
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
//    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 150, 0);
    _tableView.delegate = self;
    _tableView.dataSource =self;
    [self.view addSubview:self.tableView];
    
    [self initNavgationBar];
    
    [self setBatteryLevel];
    
    BOOL isShowAD = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (isShowAD) {
        self.interstitialButton = [NPInterstitialButton buttonWithType:NPInterstitialButtonTypeIcon viewController:self];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.interstitialButton];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _tableView.frame = self.view.bounds;
}
-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    _tableView.contentInset = contentInsets;
}

#pragma mark - Setup views
-(void)initNavgationBar{
    self.navigationController.navigationBar.translucent  = NO;
    self.navigationController.navigationBar.backgroundColor = [UIColor greenColor];
//    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blueColor]};

}


#pragma mark - Private Methods
-(void)setBatteryLevel{

    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryLevelChanged)
                                                 name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    
    [self batteryLevelChanged];



}

- (void)batteryLevelChanged
{
    
    CGFloat batteryLevel = [UIDevice currentDevice].batteryLevel;
    
    [self.tableView reloadData];
}

#pragma mark - tableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (section == 0) {
        return self.group1.count;
    }
    else if (section == 1){
        return self.group2.count;
    }
    else if (section == 2){
        return self.group3.count;
    }
    else{
        return self.group4.count;
    }
}


#pragma mark - tableviewDelegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BLUseTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
 
    if (!cell) {
       cell = [[BLUseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.model = self.group1[indexPath.row];
    }
    else if (indexPath.section == 1){
        cell.model = self.group2[indexPath.row];
    }
    else if (indexPath.section == 2){
        cell.model = self.group3[indexPath.row];
    }
    else{
        cell.model = self.group4[indexPath.row];
    }
//    cell.model = self.modelGroup[indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.layoutMargins  = UIEdgeInsetsZero;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    return cell;
    

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
