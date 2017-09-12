//
//  MainViewController.m
//  AngleMeter
//
//  Created by 何少博 on 16/9/18.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "MainViewController.h"
#import "NPCommonConfig.h"
#import "NPInterstitialButton.h"
#import "NSObject+x.h"
#import "CameraView.h"
#import "CrossView.h"
#import "CusSettingsViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreMotion/CoreMotion.h>
@interface MainViewController ()

@property (nonatomic,strong)CMMotionManager * motionManager;

@property (weak, nonatomic) IBOutlet UIButton *CameraBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UILabel *way1Label;
@property (weak, nonatomic) IBOutlet UILabel *way2Label;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomCon;
@property (weak, nonatomic) IBOutlet UIView *imageContentView;
@property (weak, nonatomic) IBOutlet UIView *labelContentVIew;
@property (weak, nonatomic) IBOutlet UIView *cameraContentView;
@property (weak, nonatomic) IBOutlet UIImageView *ruler_V;
@property (weak, nonatomic) IBOutlet UIImageView *ruler_H;

@property (weak, nonatomic) IBOutlet CrossView * crossView;

@property (assign, nonatomic) BOOL isPause;
@property (weak, nonatomic) CameraView * cameraView;
@property (strong,nonatomic)NSOperationQueue * operaQue;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = [self getAppName];;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.alpha = 0.5;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:self action:@selector(settingBtnClick:)];
    self.way1Label.font = [UIFont fontWithName:@"DBLCDTempBlack" size:20];
    self.way2Label.font = [UIFont fontWithName:@"DBLCDTempBlack" size:20];
    [[NPCommonConfig shareInstance] initAdvertise];
    BOOL shouldShowAd = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (shouldShowAd) {
        NPInterstitialButton *interstitialButton = [NPInterstitialButton buttonWithType:NPInterstitialButtonTypeIcon viewController:self];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:interstitialButton];
    }
    _bottomCon.constant = [self adjustBottom];
    self.imageContentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    self.labelContentVIew.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    self.cameraContentView.backgroundColor = [UIColor blackColor];
    self.motionManager = [[CMMotionManager alloc]init];
    self.crossView.alpha = 0;
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.stopBtn setImage:[UIImage imageNamed:@"unchocked"] forState:UIControlStateNormal];
    [self startDeviceMotion];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.cameraView == nil) {
        if ([self canUserCamear]) {
            CameraView * cameraView = [[CameraView alloc]initWithFrame:self.cameraContentView.bounds];
            cameraView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            self.cameraView = cameraView;
            [self.cameraContentView addSubview:cameraView];
        }
        else{
            NSString*appName = [self getAppName];
            NSString *tipsString =[NSString stringWithFormat:NSLocalizedString(@"newAPPname.camera.Allow Camory to access camera", @"Please allow %1@ to access camera in Settings-Privacy-Camera-%2@(Turn on)."),appName,appName];
            [self addAlertViewController_OK_NothingWithMessage:tipsString];
        }
    }
    self.crossView.layer.anchorPoint = CGPointMake(0.5, 1);
    [UIView animateWithDuration:0.25 animations:^{
        self.crossView.alpha = 1;
    }];
}
-(NSOperationQueue *)operaQue{
    if (_operaQue == nil) {
        _operaQue = [[NSOperationQueue alloc]init];
    }
    return _operaQue;
}
-(NSString *)getAppName{
    NSString*appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if ([appName length] == 0 || appName == nil)
    {
        appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey];
    }
    return  appName;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -actions
- (IBAction)caneraBtnClick:(UIButton *)sender {
    [self.cameraView changeCamera];
}
- (IBAction)stopBtnClick:(UIButton *)sender {
    self.isPause = !self.isPause;
    if (self.isPause) {
        [self.stopBtn setImage:[UIImage imageNamed:@"LOCK"] forState:UIControlStateNormal];
        [self stopDeviceMotion];
    }else{
        [self.stopBtn setImage:[UIImage imageNamed:@"unchocked"] forState:UIControlStateNormal];
        [self startDeviceMotion];
    }
    
}
- (IBAction)settingBtnClick:(UIButton *)sender {
    CusSettingsViewController * setting = [[CusSettingsViewController alloc]init];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:setting];
    nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:nav animated:YES completion:nil];
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch * touch = [touches anyObject];
    CGPoint  point = [touch locationInView:self.cameraView];
    [self.cameraView focusAtPoint:point];
}

- (IBAction)adBtnClick:(UIButton *)sender {
    if ([self needsShowAdView]) {
        [[NPCommonConfig shareInstance] showInterstitialAdInViewController:self];
    }
}
#pragma mark - 角度相关
-(double)radusAdjust:(double)oldR{
    double angle = 0;
    if (oldR<=0) {
        angle = (oldR + M_PI) * 180.0/M_PI;
    }else{
        angle = (oldR - M_PI) * 180.0/M_PI;
    }
    return angle;
}
- (void)startDeviceMotion {
    //设置采样间隔
    _motionManager.deviceMotionUpdateInterval = 0.05;
    __weak typeof(self) weakSelf = self;
    [_motionManager startDeviceMotionUpdatesToQueue:self.operaQue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {

        double way1 = acos(-motion.gravity.z) * 180.0/M_PI;
        double way2 = [weakSelf radusAdjust:atan2(motion.gravity.x, motion.gravity.y)];
        NSString * way1Text = [NSString stringWithFormat:@"%0.1f°",way1];
        NSString * way2Text = [NSString stringWithFormat:@"%0.1f°",way2];
        double rotation = atan2(motion.gravity.x, motion.gravity.y) - M_PI;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//            if (weakSelf.isPause == YES) return ;
            weakSelf.way1Label.text = way1Text;
            weakSelf.way2Label.text = way2Text;
            weakSelf.crossView.transform = CGAffineTransformMakeRotation(rotation);
        }];
    }];
    //开始采样
//    [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical toQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
//        double way1 = acos(-motion.gravity.z)* 180.0/M_PI;
//        double way2 = [self radusAdjust:atan2(motion.gravity.x, motion.gravity.y)];
//        self.way1Label.text = [NSString stringWithFormat:@"%0.2f",way1];
//        self.way2Label.text = [NSString stringWithFormat:@"%0.2f",way2];
//    }];
}


- (void)stopDeviceMotion {
    [_motionManager stopDeviceMotionUpdates];
}


#pragma mark - 检查相机权限
- (BOOL)canUserCamear{
    __block BOOL canUserCamera = YES;
    if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
        if ([[AVCaptureDevice class] respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
            AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (authorizationStatus == AVAuthorizationStatusRestricted
                || authorizationStatus == AVAuthorizationStatusDenied) {
                canUserCamera = NO;
            }
        }
    }
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted == YES) {
            canUserCamera = YES;
        }else{
            canUserCamera = NO;
        }
    }];
    return canUserCamera;
}
-(void)addAlertViewController_OK_NothingWithMessage:(NSString *)messsage;{
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:messsage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:ok];
    [self presentViewController:alertVC animated:YES completion:nil];
}
#pragma mark - help
-(CGFloat)adjustBottom{
    CGFloat bottomOffset = 50 + 20;
    if ([self needsShowAdView]) {
        if ([self isIPad]) {
            bottomOffset = 90 + 20;
        }else{
            bottomOffset = 50 + 20;
        }
    }
    return bottomOffset;
}
#pragma mark camera utility
    - (BOOL) isCameraAvailable{
        return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    }
    
    - (BOOL) isRearCameraAvailable{
        return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    }
    
    - (BOOL) isFrontCameraAvailable {
        return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
    }
    - (BOOL) doesCameraSupportTakingPhotos {
        return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
    }
    
    - (BOOL) isPhotoLibraryAvailable{
        return [UIImagePickerController isSourceTypeAvailable:
                UIImagePickerControllerSourceTypePhotoLibrary];
    }
    - (BOOL) canUserPickVideosFromPhotoLibrary{
        return [self
                cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    - (BOOL) canUserPickPhotosFromPhotoLibrary{
        return [self
                cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    - (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
        __block BOOL result = NO;
        if ([paramMediaType length] == 0) {
            return NO;
        }
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
        [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *mediaType = (NSString *)obj;
            if ([mediaType isEqualToString:paramMediaType]){
                result = YES;
                *stop= YES;
            }
        }];
        return result;
    }

@end
