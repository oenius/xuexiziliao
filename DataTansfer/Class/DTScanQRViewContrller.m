//
//  DTScanQRViewContrller.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/26.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTScanQRViewContrller.h"
#import <AVFoundation/AVFoundation.h>
#import "DTScanQRView.h"
#import "DTServerManager.h"
#import <SVProgressHUD.h>
@interface DTScanQRViewContrller () <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
/// 图层类
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) DTScanQRView *scanningView;


@end

@implementation DTScanQRViewContrller

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.scanningView startScanAnimation];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scanningView stopScanAnimation];
    
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.previewLayer.frame = self.view.bounds;
}

- (void)dealloc {

    [self removeScanningView];
    LOG(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:(UIBarButtonItemStylePlain) target:self action:@selector(back)];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self checkauthorizationStatus];
}

-(void)setupScanView{
    _scanningView = [[DTScanQRView alloc ]initWithFrame:CGRectZero];
    [self.view addSubview:self.scanningView];
    [self.scanningView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
    [self setupSGQRCodeScanning];
}

- (void)removeScanningView {
    [self.scanningView stopScanAnimation];
    [self.scanningView removeFromSuperview];
    self.scanningView = nil;
}


- (void)setupSGQRCodeScanning {
    // 1、获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2、创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    // 3、创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    // 4、设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 设置扫描范围(每一个取值0～1，以屏幕右上角为坐标原点)
    // 注：微信二维码的扫描范围是整个屏幕，这里并没有做处理（可不用设置）
    output.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
    
    // 5、初始化链接对象（会话对象）
    self.session = [[AVCaptureSession alloc] init];
    // 高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    // 5.1 添加会话输入
    [_session addInput:input];
    
    // 5.2 添加会话输出
    [_session addOutput:output];
    
    // 6、设置输出数据类型，需要将元数据输出添加到会话后，才能指定元数据类型，否则会报错
    // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    // 7、实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.view.layer.bounds;
    
    // 8、将图层插入当前视图
    [self.view.layer insertSublayer:_previewLayer atIndex:0];
    
    // 9、启动会话
    [_session startRunning];
}

-(void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - - - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        if ([obj.stringValue containsString:kRequestTaskListPath]) {
            [self playSoundEffect:@"sound.caf"];
            [self.session stopRunning];
            [self.scanningView stopScanAnimation];
            [DTServerManager shareInstance].baseUrl = [obj.stringValue  stringByReplacingOccurrencesOfString:kRequestTaskListPath withString:@""];
            [DTServerManager shareInstance].serachSuccess = YES;
            [[NSNotificationCenter defaultCenter ] postNotificationName:kSearchTaskListSuccessNotition object:obj];
            
            [SVProgressHUD showSuccessWithStatus:[DTConstAndLocal GeneratingTasks]];
            [SVProgressHUD dismissWithDelay:1.5];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self.previewLayer removeFromSuperlayer];
                [self back];
            });
        }
        else if ([obj.stringValue containsString:@"http://itunes.apple.com/app/id"])
        {
            NSString * link = [obj.stringValue stringByReplacingOccurrencesOfString:@"http" withString:@"itms-apps"];
            NSURL * url = [NSURL URLWithString:link];
            if ([[UIApplication sharedApplication]canOpenURL:url]) {
                [[UIApplication sharedApplication]openURL:url];
            }
            
        }
    }
    
}
-(void)checkauthorizationStatus{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {//相机权限
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                       [self setupScanView];
                    });
                    
                }
            }];
        }
            break;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            [self authorizationStatusDeniedAlertView];
            break;
        case AVAuthorizationStatusAuthorized:{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setupScanView];
            });
        }
            break;
        default:
            break;
    }
}

-(void)authorizationStatusDeniedAlertView{
    UIAlertController * alertCon = [UIAlertController alertControllerWithTitle:[DTConstAndLocal tishi] message:[DTConstAndLocal noquanxiangoset] preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:[DTConstAndLocal cancel] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * done = [UIAlertAction actionWithTitle:[DTConstAndLocal settings] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        NSURL * settingUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication]canOpenURL:settingUrl]) {
            [[UIApplication sharedApplication]openURL:settingUrl];
        }
    }];
    
    [alertCon addAction:cancel];
    [alertCon addAction:done];

    [self presentViewController:alertCon animated:YES completion:nil];
}

/** 播放音效文件 */
- (void)playSoundEffect:(NSString *)name {
    // 获取音效
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
    
    // 1、获得系统声音ID
    SystemSoundID soundID = 0;
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    
    // 2、播放音频
    AudioServicesPlaySystemSound(soundID); // 播放音效
}
/** 播放完成回调函数 */
void soundCompleteCallback(SystemSoundID soundID, void *clientData){
    
}



@end
