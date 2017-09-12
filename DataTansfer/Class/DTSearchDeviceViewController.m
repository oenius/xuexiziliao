//
//  DTSearchDeviceViewController.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/24.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTSearchDeviceViewController.h"
#import "DTRadarScanView.h"
#import "DTServerManager.h"
#import <AFNetworking.h>
@interface DTSearchDeviceViewController ()<NSURLConnectionDataDelegate>

@property (strong,nonatomic)DTRadarScanView * scanView;


@property (nonatomic,strong) NSURLConnection * cone  ;
@end

@implementation DTSearchDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor dt_tintColor];
//    self.scanView = [[DTRadarScanView alloc]init];
//    [self.view addSubview:self.scanView];
//    [self.scanView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view.mas_top);
//        make.left.equalTo(self.view.mas_left);
//        make.right.equalTo(self.view.mas_right);
//        make.height.equalTo(self.view.mas_width);
//    }];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self searchSetver];
}


-(void)searchSetver{
    [[DTServerManager shareInstance]searchServer:^(BOOL success, NSString *baseUrl) {
        LOG(@"baseUrl = %@",baseUrl);
        NSString * urlStr = [baseUrl stringByAppendingFormat:@"%@%@",kRequestContactsPath,@"2698422E-A0B7-4760-9B1F-972E01BD42CC"];

        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:urlStr parameters:@"" progress:^(NSProgress * _Nonnull downloadProgress) {
            LOG(@"%@",downloadProgress);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            LOG(@"%@",task);
            LOG(@"%@",responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            LOG(@"%@",error);
        }];
        
    }];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSLog(@"%@",data);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
