//
//  LCMainViewController.m
//  LightCamera
//
//  Created by 何少博 on 16/12/9.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "LCMainViewController.h"
#import <AVFoundation/AVFoundation.h>
#define MAS_SHORTHAND
#import "Masonry.h"
#import "LCCameraViewController.h"


typedef NS_ENUM( NSInteger, LCCameraAuthorizedResult ) {
    LCCameraAuthorizedResultSuccess,
    LCCameraAuthorizedResultCameraNotAuthorized
};

@interface LCMainViewController ()

@property (nonatomic, strong) UIButton * startBtn;

@end

@implementation LCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkGrayColor];
    [self init_UI];
}

-(void)init_UI{
    self.startBtn = [[UIButton alloc] init];
    _startBtn.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:_startBtn];
    [_startBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.width).multipliedBy(0.25);
        make.height.equalTo(self.view.width).multipliedBy(0.25);
        make.centerX.equalTo(self.view.centerX);
        make.centerY.equalTo(self.view.centerY);
    }];
    [_startBtn setTitle:@"Camera" forState:UIControlStateNormal];
    [_startBtn addTarget:self action:@selector(startBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)startBtnClick{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status)
    {
        case AVAuthorizationStatusAuthorized:
        {
            [self jumpToCmaeraViewController];
            break;
        }
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
                if (!granted) {
                    [self cameraNotAuthorizaPromt];
                }else{
                    [self jumpToCmaeraViewController];
                }
            }];
            break;
        }
        default:
        {
            [self cameraNotAuthorizaPromt];
            break;
        }
    }
}

-(void)jumpToCmaeraViewController{
    LCCameraViewController * camera = [[LCCameraViewController alloc] init];
    [self presentViewController:camera animated:YES completion:nil];
}

-(void)cameraNotAuthorizaPromt{
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请设置权限" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:ok];
    [self presentViewController:alertVC animated:YES completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
