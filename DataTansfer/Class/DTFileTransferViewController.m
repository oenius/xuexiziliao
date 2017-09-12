//
//  DTFileTransferViewController.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/26.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTFileTransferViewController.h"
#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import "DTServerManager.h"
#import "DTFileTransferViewModel.h"
#import "DTDwonTask.h"
#import "DTFileTransferTableViewCell.h"
#import "DTTaskManager.h"
#import "DTPromptHUD.h"
@interface DTFileTransferViewController ()<
UITableViewDelegate,
UITableViewDataSource,
DTTaskManagerDelegate>

@property (nonatomic,strong) UITableView * tableView;

@property (nonatomic,strong) NSArray * dataSource;

@property (nonatomic,strong) NSString * baseUrl;

@property (nonatomic,strong) DTFileTransferViewModel * viewModel;

@property (nonatomic,strong) DTTaskManager * taskManager;

@property (nonatomic,assign) BOOL tableViewScrolling;

@property (nonatomic,strong) UIView * topContentView;

@property (nonatomic,strong) UILabel * promptLabel1;

@property (nonatomic,strong) UILabel * promptLabel2;

@property (nonatomic,strong) UILabel * promptLabel3;

@property (nonatomic,strong) UILabel * promptLabel4;

@property (nonatomic,strong) UILabel * promptLabel5;

@property (nonatomic,assign) NSUInteger successCount;

@property (nonatomic,strong) NSString * currentSSID;

@end

static NSString * kFileTransferCellID = @"kFileTransferCellID";

@implementation DTFileTransferViewController


-(DTTaskManager *)taskManager{
    if (!_taskManager) {
        _taskManager = [DTTaskManager shareManagaer];
        _taskManager.delegate = self;
    }
    return _taskManager;
}

-(DTFileTransferViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[DTFileTransferViewModel alloc]init];
    }
    return _viewModel;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"tongxunlubg"].CGImage);
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"08c364"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:(UIBarButtonItemStylePlain) target:self action:@selector(back)];
    [self setupSubViews];
  
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}



-(void)setupSubViews{
    self.topContentView = [[UIView alloc]init];
    self.topContentView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.topContentView];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:(UITableViewStyleGrouped)];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView registerClass:[DTFileTransferTableViewCell class] forCellReuseIdentifier:kFileTransferCellID];
    
    [self.topContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(self.view.mas_height).multipliedBy(0.3);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topContentView.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    
    self.promptLabel1 = [self creatLabel];
    [self.topContentView addSubview:self.promptLabel1];
    self.promptLabel1.text = [DTConstAndLocal qiantai];
    
    self.promptLabel2 = [self creatLabel];
    [self.topContentView addSubview:self.promptLabel2];
    self.promptLabel2.text = [DTConstAndLocal fasongwifi];
    
    self.currentSSID = [DTConstAndLocal fetchSSID];
    self.promptLabel3 = [self creatLabel];
    [self.topContentView addSubview:self.promptLabel3];
    self.promptLabel3.text = self.currentSSID;
    self.promptLabel3.textColor = [UIColor colorWithHexString:@"08c364"];
    
    self.promptLabel4 = [self creatLabel];
    [self.topContentView addSubview:self.promptLabel4];
    self.promptLabel4.text = @"";
    
    self.promptLabel5 = [self creatLabel];
    [self.topContentView addSubview:self.promptLabel5];
    self.promptLabel5.text = @"";
    
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
        make.bottom.equalTo(self.promptLabel5.mas_top);
        make.height.equalTo(self.promptLabel3.mas_height);
    }];
    
    [self.promptLabel5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.self.promptLabel4.mas_bottom);
        make.left.equalTo(self.topContentView.mas_left).offset(20);
        make.right.equalTo(self.topContentView.mas_right).offset(-20);
        make.bottom.equalTo(self.topContentView.mas_bottom);
        make.height.equalTo(self.promptLabel4.mas_height);
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
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [SVProgressHUD dismiss];
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
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [DTConstAndLocal closeNetWorikingCheck];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.baseUrl == nil && [DTServerManager shareInstance].serachSuccess == YES) {
        self.baseUrl = [DTServerManager shareInstance].baseUrl;
        [self requestDeviceName];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)back{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:[DTConstAndLocal tishi] message:[DTConstAndLocal Areyousure]preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:[DTConstAndLocal ok] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [[DTServerManager shareInstance]closeServer];
        [self.taskManager cancelDownLoad];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:[DTConstAndLocal cancel] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - 接收任务通知

-(void)requestDeviceName{
    NSString * requestDeviceNameUrl = [NSString stringWithFormat:@"%@%@",self.baseUrl,kRequestDeviceNamePath];
    requestDeviceNameUrl = [requestDeviceNameUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [SVProgressHUD show];
    AFHTTPSessionManager * manger = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSString * deviceName = [DTConstAndLocal getDeviceName];
    deviceName = [deviceName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [manger GET:requestDeviceNameUrl parameters:@{@"IDFR":deviceName} progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary * responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * serverName = responseObject[kServeriPhoneNameKey];
            self.promptLabel4.text = [NSString stringWithFormat:@"%@%@",[DTConstAndLocal device],serverName];
            
            [SVProgressHUD dismiss];
        });
        [self requestTaskList];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.promptLabel4.text = [DTConstAndLocal connectionfailure];
            [SVProgressHUD showErrorWithStatus:[DTConstAndLocal connectionfailure]];
            [SVProgressHUD dismissWithDelay:1.5];
        });
    }];
}


-(void)requestTaskList{
    NSString * taskListUrl = [self.baseUrl stringByAppendingString:kRequestTaskListPath];
    taskListUrl = [taskListUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [SVProgressHUD show];
    AFHTTPSessionManager * manger = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSString * deviceName = [DTConstAndLocal getDeviceName];
    deviceName = [deviceName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [manger GET:taskListUrl parameters:@{@"IDFR":deviceName} progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        LOG(@"%@",responseObject);
       
        [self.viewModel generateTaskWithTaskList:responseObject andBaseUrl:self.baseUrl];
        [self.taskManager addTasks:[self.viewModel getAllTasks]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
        self.promptLabel5.text = [NSString stringWithFormat:@"%@:0/%zd",[DTConstAndLocal yiwancheng],[responseObject count]];
          [self.tableView reloadData];
          [self.taskManager startDownLoad];
             [SVProgressHUD dismiss];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        LOG(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
             [SVProgressHUD dismiss];
        });
    }];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.tableViewScrolling = YES;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    self.tableViewScrolling = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewModel numberOfSectionsInTableView];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfRowsInSection:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DTFileTransferTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFileTransferCellID];
    if (!cell) {
        cell = [[DTFileTransferTableViewCell alloc]initWithStyle:(UITableViewCellStyleValue2) reuseIdentifier:kFileTransferCellID];
    }
    DTDwonTask * task = [self.viewModel modelWithIndexPath:indexPath];
    cell.model = task;
    WEAKSELF_DT
    cell.retryBlock = ^(DTDwonTask * model){
        [weakSelf.taskManager retryTask:model];
    };
    return cell;
}
-(void)reloadDataWithTask:(DTDwonTask *)task{
//    if (self.tableViewScrolling) {
//        return;
//    }
    NSIndexPath * indexPath = [self.viewModel indexPathWithModel:task];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
        [self.tableView endUpdates];
    });
}
#pragma mark - DTTaskManagerDelegate
-(void)allTaskDidDownload:(DTTaskManager *)manager{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
-(void)currentTaskBeginDwonload:(DTDwonTask *)task{
    
}

-(void)currentTask:(DTDwonTask *)task progress:(CGFloat)progress{
   
    [self reloadDataWithTask:task];
    
}

-(void)currentTask:(DTDwonTask *)task didError:(NSError *)error{
  
    NSString * errorStr = error.localizedDescription;
    if (task.status == DTDwonTaskStatusTimeOut) {
        errorStr = [NSString stringWithFormat:@"%@ %@",errorStr,[DTConstAndLocal chectnetwork]];
    }
    else if (task.status == DTDwonTaskStatusNotContectServer){
        errorStr = [NSString stringWithFormat:@"%@ %@",errorStr,[DTConstAndLocal chectnetwork]];
    }
    [DTPromptHUD showWithString:errorStr];
}

-(void)currentTask:(DTDwonTask *)task statusChanged:(DTDwonTaskStatus) status{
    [self reloadDataWithTask:task];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == DTDwonTaskStatusSaveSuccesse) {
            @synchronized (self) {
                self.successCount ++;
                NSUInteger totleCount = [self.viewModel numberOfRowsInSection:0];
                self.promptLabel5.text = [NSString stringWithFormat:@"%@:%zd/%zd",[DTConstAndLocal yiwancheng],self.successCount,totleCount];
                if (self.successCount == totleCount) {
                    [DTPromptHUD showWithString:[DTConstAndLocal done]];
                }
            }
        }
    });
    
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
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
