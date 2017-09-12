//
//  LCCameraViewController.m
//  LightCamera
//
//  Created by 何少博 on 16/12/12.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//


#import "LCCameraViewController.h"
#import "GPUImage.h"
#import "LCFilterChooserView.h"
#import "LCFocusMarkView.h"
#import "LCDelayTimePromptView.h"
#import "NPCommonConfig.h"
#import "LCLightModelArray.h"
#import "LCSettingsViewController.h"
#import "MBProgressHUD.h"
#import <Photos/Photos.h>

static void * ExposureModeContext = &ExposureModeContext;
static void * ExposureDurationContext = &ExposureDurationContext;
static void * ISOContext = &ISOContext;

static const float kExposureDurationPower = 5; //曝光时间slider调节参数，越高调节越敏感
static const float kExposureMinimumDuration = 1.0/1000; // 最小曝光时间

typedef struct YRange {
    CGFloat topY;
    CGFloat bottomY;
} YRange;

typedef enum FlashStateModel {
    kFlashStateModelOff = 0,
    kFlashStateModelOn = 1,
    kFlashStateModelAuto = 2,
    kFlashStateModelTorch = 3,
} FlashStateModel;

typedef enum DelayTime {
    kDelayTimeOff = 0,
    kDelayTime3s = 3,
    kDelayTime10s = 10
} DelayTime;

typedef enum LightModel{
    
    kLightModelAuto = 0,
    kLightModelOne = 1,
    kLightModelTwo = 2,
    
} LightModel;

@interface LCCameraViewController ()
///相机
@property (strong, nonatomic) GPUImageStillCamera *stillCamera;

@property (weak, nonatomic) IBOutlet GPUImageView *cameraView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraViewBottom;

@property (strong, nonatomic) GPUImageOutput<GPUImageInput> *exposureFilter;

@property (strong, nonatomic) GPUImageOutput<GPUImageInput> *tempFilter;

@property (strong, nonatomic) GPUImageOutput<GPUImageInput> *autoExposureFilter;

//@property (strong, nonatomic) GPUImageOutput<GPUImageInput> *otherFilter;

@property (strong, nonatomic) GPUImagePicture *memoryPressurePicture1;

@property (strong, nonatomic) GPUImagePicture *memoryPressurePicture2;

@property (strong, nonatomic) GPUImageFilterGroup * filterGroup;

@property (assign, nonatomic) UIInterfaceOrientation orientation;

@property (strong, nonatomic) AVCaptureDevice *device;
//顶部工具栏
@property (weak, nonatomic) IBOutlet UIToolbar *topToolBar;

@property (weak, nonatomic) IBOutlet UIButton *flashBtn;

@property (assign, nonatomic) FlashStateModel flashStateModel;

@property (weak, nonatomic) IBOutlet UIButton *delayTimeBtn;

@property (assign, nonatomic) DelayTime delayTime;

@property (weak, nonatomic) IBOutlet UIButton *cameraTypeBtn;

@property (weak, nonatomic) IBOutlet UIButton *settingsBtn;
//底部工具栏
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolBar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomToolBarBOttom;

@property (weak, nonatomic) IBOutlet UIButton *LightModelBtn;

@property (weak, nonatomic) IBOutlet UIButton *filterBtn;

@property (weak, nonatomic) IBOutlet UIButton *takePhotoBtn;

@property (weak, nonatomic) IBOutlet UIButton *exposureBtn;

@property (weak, nonatomic) IBOutlet UIButton *IDZBtn;
//感光度，快门，缩放
@property (weak, nonatomic) IBOutlet UIView *IDZView;

@property (weak, nonatomic) IBOutlet UILabel *ISOLabel;

@property (weak, nonatomic) IBOutlet UISlider *ISOSlider;

@property (weak, nonatomic) IBOutlet UILabel *ISOValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *shutterLabel;

@property (weak, nonatomic) IBOutlet UISlider *shutterSilder;

@property (weak, nonatomic) IBOutlet UILabel *shutterValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *zoomLabel;

@property (weak, nonatomic) IBOutlet UISlider *zoomSilder;

@property (weak, nonatomic) IBOutlet UILabel *zoomValueLabel;
//曝光
@property (weak, nonatomic) IBOutlet UIView *exposureView;

@property (weak, nonatomic) IBOutlet UILabel *exposureLabel;

@property (weak, nonatomic) IBOutlet UISlider *exposureSlider;

@property (weak, nonatomic) IBOutlet UILabel *exposureValueLabel;
//滤镜选择
@property (weak, nonatomic) IBOutlet LCFilterChooserView *filterChooseView;
//focusView
@property (strong,nonatomic) LCFocusMarkView * focusView;
//延时提示
@property (strong,nonatomic) LCDelayTimePromptView * delayTimeView;

@property (assign,nonatomic) LightModel lightModel;
//
@property (assign,nonatomic) BOOL ISOSliderHasTouched;

@property (assign,nonatomic) BOOL shutterSliderHasTouched;

@property (assign,nonatomic) AVCaptureDevicePosition devicePosition;

@property (assign,nonatomic) NSInteger takePhotosNumber;

@property (weak, nonatomic) IBOutlet UISlider *otherSlider;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *flashBtnItem;

@property (strong,nonatomic) NSTimer * timer;

@property (assign,nonatomic) NSInteger timerIndex;

@end



@implementation LCCameraViewController
//- (IBAction)otherSlider:(UISlider*)sender {
//    [(GPUImageHighlightShadowFilter * )self.otherFilter setHighlights:sender.value];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    self.cameraViewBottom.constant = contentInsets.bottom;
    self.bottomToolBarBOttom.constant = contentInsets.bottom;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self needsShowAdView]) {
        [[NPCommonConfig shareInstance]initAdvertise];
    }
    
    [self addNotification];
    
    [self initCamera];
    
    [self setalphaExposureView:1 IDZView:0 FilterChooseView:0];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    UIImage * stechImage = [[UIImage imageNamed:@"backGround.png"] resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
//    
////    [self.topToolBar setBackgroundImage:stechImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
////  
//    //    [self.bottomToolBar setBackgroundImage:stechImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
//    self.topToolBar.opaque = NO;
////    self.topToolBar.backgroundColor = [UIColor clearColor];  //设置为背景透明，可以在这里设置背景图片
//    self.topToolBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backGround"]];
//    self.topToolBar.clearsContextBeforeDrawing = YES;
////    [self.topToolBar setBackgroundImage:stechImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefaultPrompt];
////    self.topToolBar.backgroundColor = [UIColor colorWithPatternImage:stechImage];
////    self.bottomToolBar.backgroundColor = [UIColor colorWithPatternImage:stechImage];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self cameraStatusJudge];
    [self initSliderAndLabel];
    [self autoJustExposureCurrentISO:self.device.ISO];
}
-(void)setLightModel:(LightModel)lightModel{
    _lightModel = lightModel;
    
    NSError *error = nil;
    double minDurationSeconds = MAX( CMTimeGetSeconds( self.device.activeFormat.minExposureDuration ), kExposureMinimumDuration );
    double maxDurationSeconds = CMTimeGetSeconds( self.device.activeFormat.maxExposureDuration );
    if ( [self.device lockForConfiguration:&error] ) {
        
        if (lightModel == kLightModelTwo) {
            if ( [self.device isExposureModeSupported:AVCaptureExposureModeCustom] ) {
                self.device.exposureMode = AVCaptureExposureModeCustom;
                BOOL isFront = (self.device.position == AVCaptureDevicePositionFront);//(self.devicePosition ==
                float  shutterDurn = (self.device.position == AVCaptureDevicePositionFront) ? 0.95 : 1.0;
                CGFloat isoValue = self.device.activeFormat.maxISO;
                if (isFront) {
                        isoValue = isoValue / 9 * 8;
                }
                double p = pow( shutterDurn, kExposureDurationPower );
                
                double newDurationSeconds = p * ( maxDurationSeconds - minDurationSeconds ) + minDurationSeconds;
                [self.device setExposureModeCustomWithDuration:CMTimeMakeWithSeconds( newDurationSeconds, 1000*1000*1000 )  ISO:isoValue completionHandler:nil];
//                [self.device unlockForConfiguration];
            }
        }
        else if (lightModel == kLightModelOne){
            if ( [self.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure] ) {
                [self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                
                self.shutterSilder.value = 0.9;
                [self shutterValueChanged:self.shutterSilder];
                
                }
            
                if ([self.device isLowLightBoostSupported]) {
                    self.device.automaticallyEnablesLowLightBoostWhenAvailable = YES;
                }
        }
        else{
            [self initCamera];
            
            [self focusAtPoint:self.cameraView.center];
        }
        [self.device unlockForConfiguration];
    }
    else {
        NSLog( @"Could not lock device for configuration: %@", error );
    }
}

-(void)cameraStatusJudge{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status)
    {
        case AVAuthorizationStatusAuthorized:
            self.view.userInteractionEnabled = YES;
            break;
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
                if (!granted) {
                    [self cameraNotAuthorizaPromt];
                }else{
                    self.view.userInteractionEnabled = YES;
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
#pragma mark - c初始化
-(void)initCamera{
    self.devicePosition = AVCaptureDevicePositionBack;
    if (self.stillCamera != nil) {
        if (self.device.position == AVCaptureDevicePositionFront) {
            self.devicePosition = AVCaptureDevicePositionFront;
        }
        [self.stillCamera stopCameraCapture];
        self.stillCamera = nil;
    }
    self.stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:self.devicePosition];
    self.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    if (self.filterGroup == nil) {
        self.autoExposureFilter = [[GPUImageExposureFilter alloc] init];
        GPUImageExposureFilter* autoFilter = (GPUImageExposureFilter*)self.autoExposureFilter;
        [autoFilter setExposure:0];
        self.exposureFilter = [[GPUImageExposureFilter alloc] init];
        GPUImageExposureFilter* filter = (GPUImageExposureFilter*)self.exposureFilter;
        [filter setExposure:0];
        //锐化
        self.otherSlider.maximumValue = 1;
        self.otherSlider.minimumValue = 0;
        self.otherSlider.value = 0;
//        GPUImageHighlightShadowFilter * otherFilter = [[GPUImageHighlightShadowFilter alloc]init];
//        [otherFilter setBrightness:0];
//        self.otherFilter = otherFilter;
        self.filterGroup = [[GPUImageFilterGroup alloc]init];
        [self.filterGroup addFilter:self.autoExposureFilter];
//        [self.filterGroup addFilter:otherFilter];
        [self.filterGroup addFilter:self.exposureFilter];
//        [self.autoExposureFilter addTarget:self.otherFilter];
        [self.autoExposureFilter addTarget:self.exposureFilter];
        [self.filterGroup setInitialFilters:[NSArray arrayWithObject:self.autoExposureFilter]];;
        [self.filterGroup setTerminalFilter:self.exposureFilter];
    }
    GPUImageExposureFilter* filter = (GPUImageExposureFilter*)self.exposureFilter;
    [filter setExposure:0];
    self.exposureValueLabel.text = @"0";
    self.exposureSlider.value = 0;
    
    [self.stillCamera addTarget:self.filterGroup];
    
    
    self.cameraView.fillMode =  kGPUImageFillModePreserveAspectRatioAndFill;
    [self.filterGroup addTarget:self.cameraView];
    self.device = self.stillCamera.inputCamera;
    [self.device lockForConfiguration:nil];
    if (self.devicePosition == AVCaptureDevicePositionFront) {
        self.flashStateModel = kFlashStateModelOff;
        if ([self.device isFlashModeSupported:AVCaptureFlashModeOff]) {
            [self.flashBtn setImage:[UIImage imageNamed:@"icon_flash_off"] forState:UIControlStateNormal];
            [self.device setFlashMode:AVCaptureFlashModeOff];
        }
    }else{
        
        switch (self.flashStateModel) {
            case kFlashStateModelOff:
                if ([self.device isFlashModeSupported:AVCaptureFlashModeOff]) {
                    [self.device setFlashMode:AVCaptureFlashModeOff];
                }
                break;
            case kFlashStateModelOn:
                if ([self.device isFlashModeSupported:AVCaptureFlashModeOn]) {
                    [self.device setFlashMode:AVCaptureFlashModeOn];
                }
                break;
            case kFlashStateModelAuto:
                if ([self.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
                    [self.device setFlashMode:AVCaptureFlashModeAuto];
                }
                break;
            case kFlashStateModelTorch:
                if ([self.device isTorchModeSupported:AVCaptureTorchModeOn]) {
                    [self.device setTorchMode:AVCaptureTorchModeOn];
                }
                break;
            default:
                break;
                
        }
    }
    NSLog(@"%d:%d",self.device.automaticallyAdjustsVideoHDREnabled,self.device.isVideoHDREnabled);
    
//    self.device.automaticallyAdjustsVideoHDREnabled  =  NO;
//    [self.device setAutomaticallyAdjustsVideoHDREnabled:YES];
//    NSLog(@"%d:%d",self.device.automaticallyAdjustsVideoHDREnabled,self.device.isVideoHDREnabled);
    [self.device unlockForConfiguration];
    self.delayTime = kDelayTimeOff;
    [self.delayTimeBtn setImage:[UIImage imageNamed:@"delaytime0"] forState:UIControlStateNormal];
    [self.stillCamera startCameraCapture];
    [self addObservers];
}

-(void)initSliderAndLabel{
    
    self.exposureSlider.maximumValue = 8;
    self.exposureSlider.minimumValue = -8;
    self.exposureView.backgroundColor = [UIColor clearColor];
    self.exposureSlider.value = 0;
    [(GPUImageExposureFilter*)self.exposureFilter setExposure:0];
    [(GPUImageExposureFilter*)self.autoExposureFilter setExposure:0];
    self.exposureValueLabel.text = [NSString stringWithFormat:@"%.0f",self.exposureSlider.value];
    self.exposureLabel.text = NSLocalizedString(@"NC.Exposure", @"Exposure");
    
    self.ISOSlider.maximumValue = self.device.activeFormat.maxISO;
    self.ISOSlider.minimumValue = self.device.activeFormat.minISO;
    self.ISOSlider.value = self.device.ISO;
    self.ISOValueLabel.text = [NSString stringWithFormat:@"%d",(int)self.ISOSlider.value];
    self.ISOSlider.hidden  = (AVCaptureExposureModeContinuousAutoExposure == self.device.exposureMode);
    self.ISOLabel.hidden = self.ISOSlider.hidden;
    self.ISOValueLabel.hidden = self.ISOSlider.hidden;
    self.ISOLabel.text = NSLocalizedString(@"gallery.ISO:", @"ISO:");
    
    self.shutterSilder.minimumValue = 0;
    self.shutterSilder.maximumValue = 1;
    self.shutterLabel.text = [NSString stringWithFormat:@"%@:",NSLocalizedString(@"NC.Shutter", @"Shutter")];
    self.shutterSilder.hidden = (AVCaptureExposureModeContinuousAutoExposure == self.device.exposureMode);
    self.shutterLabel.hidden = self.shutterSilder.hidden;
    self.shutterValueLabel.hidden = self.shutterSilder.hidden;
    double exposureDurationSeconds = CMTimeGetSeconds( self.device.exposureDuration );
    double minExposureDurationSeconds = MAX( CMTimeGetSeconds( self.device.activeFormat.minExposureDuration ), kExposureMinimumDuration );
    double maxExposureDurationSeconds = CMTimeGetSeconds( self.device.activeFormat.maxExposureDuration );
    double p = ( exposureDurationSeconds - minExposureDurationSeconds ) / ( maxExposureDurationSeconds - minExposureDurationSeconds );
    self.shutterSilder.value = pow( p, 1 / kExposureDurationPower );
    
    double newDurationSeconds = exposureDurationSeconds;
    if ( newDurationSeconds < 1 ) {
        int digits = MAX( 0, 2 + floor( log10( newDurationSeconds ) ) );
        self.shutterValueLabel.text = [NSString stringWithFormat:@"1/%.*f", digits, 1/newDurationSeconds];
    }
    else {
        self.shutterValueLabel.text = [NSString stringWithFormat:@"%.2f", newDurationSeconds];
    }
    
    
    NSLog(@"%g--%g",self.device.activeFormat.videoMaxZoomFactor,self.device.videoZoomFactor);
    self.zoomSilder.maximumValue = 12;
    self.zoomSilder.minimumValue = 1;
    CGFloat deviceValue = self.device.videoZoomFactor;
    if ( deviceValue < 1) {
        self.zoomSilder.value = 1;
    }else{
        self.zoomSilder.value = self.device.videoZoomFactor;
    }
    self.zoomLabel.text = [NSString stringWithFormat:@"%@:",NSLocalizedString(@"NC.Zoom", @"Scaling")];
;
    self.zoomValueLabel.text = [NSString stringWithFormat:@"%.1fx",self.zoomSilder.value];
    
    self.filterChooseView.backback = ^(GPUImageOutput<GPUImageInput> * filter){
        [self chooseFilterCallBack:filter];
    };
}

-(LCFocusMarkView *)focusView{
    if (nil == _focusView) {
        _focusView = [[LCFocusMarkView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        _focusView.hidden = YES;
        [self.cameraView addSubview:_focusView];
    }
    return _focusView;
}


#pragma mark - notictions abserve

-(void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)becomeActiveNotification:(NSNotification *)notif {
    [self cameraStatusJudge];
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (AVAuthorizationStatusAuthorized == status) {
        [self autoJustExposureCurrentISO:self.device.ISO];
    }
}
- (void)orientationChanged:(NSNotification *)notif {
    CGFloat angle;
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortraitUpsideDown:
            angle = M_PI;
            self.orientation = UIInterfaceOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            angle = M_PI_2;
            self.orientation = UIInterfaceOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = - M_PI_2;
            self.orientation = UIInterfaceOrientationLandscapeRight;
            break;
        case UIDeviceOrientationPortrait:
            angle = 0;
            self.orientation = UIInterfaceOrientationPortrait;
            break;
        default:
            return;
    }
    
    CGAffineTransform t = CGAffineTransformMakeRotation(angle);
    
    [UIView animateWithDuration:.3 animations:^{
        self.flashBtn.transform = t;
        self.delayTimeBtn.transform = t;
        self.cameraTypeBtn.transform = t;
        self.settingsBtn.transform = t;
        
        self.LightModelBtn.transform = t;
        self.filterBtn.transform = t;
        self.takePhotoBtn.transform = t;
        self.exposureBtn.transform = t;
        self.IDZBtn.transform = t;
        
    } completion:^(BOOL finished) {
    }];
}
#pragma mark 选择滤镜
-(void)chooseFilterCallBack:(GPUImageOutput<GPUImageInput> *)filter
{
    [(GPUImageExposureFilter * )self.autoExposureFilter setExposure:0];
    
    
    
    [self.stillCamera removeTarget:self.filterGroup];
    self.filterGroup = nil;
    self.filterGroup = [[GPUImageFilterGroup alloc]init];
    self.tempFilter = filter;
    [self.autoExposureFilter removeAllTargets];
    [self.exposureFilter removeAllTargets];
    [self.tempFilter removeAllTargets];
    [self.filterGroup removeAllTargets];
    [self.filterGroup addFilter:self.tempFilter];
    [self.filterGroup addFilter:self.autoExposureFilter];
    [self.filterGroup addFilter:self.exposureFilter];
    [self.tempFilter addTarget:self.autoExposureFilter];
    [self.autoExposureFilter addTarget:self.exposureFilter];
    [self.filterGroup setInitialFilters:[NSArray arrayWithObjects:self.tempFilter, nil]];
    [self.filterGroup setTerminalFilter:self.exposureFilter];
    [self.stillCamera removeAllTargets];
    [self.stillCamera addTarget:self.filterGroup];
    
    [self.filterGroup addTarget:self.cameraView];
    [self autoJustExposureCurrentISO:self.device.ISO];
    
}
#pragma mark 保存图片
-(void)judgePhotoAuthorityTakePhoto{
    
    PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
    switch (photoAuthorStatus) {
        case PHAuthorizationStatusAuthorized:
            [self asyncSaveImageWithPhoto];
            break;
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self asyncSaveImageWithPhoto];
                }else{
                    self.takePhotoBtn.selected = NO;
                }
            }];
        }
            break;
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
            self.takePhotoBtn.selected = NO;
            [self photosNotAuthorizaPromt];
            break;
        default:
            break;
    }
    
}
//异步保存图片
-(void)asyncSaveImageWithPhoto
{
//    NSLog(@"%d:%d",self.device.automaticallyAdjustsVideoHDREnabled,self.device.isVideoHDREnabled);
    __weak typeof(self) weakSelf = self;
    [self.stillCamera capturePhotoAsJPEGProcessedUpToFilter:self.filterGroup withCompletionHandler:^(NSData *processedJPEG, NSError *error) {
        weakSelf.takePhotosNumber ++;
        UIImage * addImage = [UIImage imageWithData:processedJPEG];
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImage:addImage];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
//            NSString * message;
//            if (error) {
//                message = @"保存失败";
//            }else{
//                message = @"保存成功";
//            }
            weakSelf.takePhotoBtn.selected = NO;
            [weakSelf aboutAD];
            
        }];
    }];
    
}
-(void)showMessage:(NSString*)message{

    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.cameraView animated:YES];
        
        hud.mode = MBProgressHUDModeText;
        hud.label.text = message;
        
        hud.offset = CGPointMake(0.f, -100);
        
        [hud hideAnimated:YES afterDelay:0.75f];
        
    });

}

-(void)aboutAD{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
//        [self focusAtPoint:self.cameraView.center];
        
        if (self.takePhotosNumber >= 5) {
            self.takePhotosNumber = 0;
            if ([self needsShowAdView]) {
                [[NPCommonConfig shareInstance] showNavitveAdAlertViewWithFullScreenAdForController:self];
            }
        }
    });
}
#pragma mark 聚焦

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.focusView.hidden == NO) {
        return;
    }
    UITouch * touch = [touches anyObject];
    YRange range = [self getTapYRange];
    CGPoint point = [touch locationInView:self.cameraView];
    if (point.y>=range.bottomY || point.y <= range.topY) {
        return;
    }
    [self focusAtPoint:point];
}

-(YRange)getTapYRange{
    
    CGFloat topy = CGRectGetMaxY(self.topToolBar.frame);
    
    UIView * view ;
    if (self.exposureView.alpha != 0) {
        view = self.exposureView;
    }
    else if (self.IDZView.alpha != 0){
        view = self.IDZView;
    }
    else if (self.filterChooseView.alpha != 0){
        view = self.filterChooseView;
    }
    else{
        view = self.bottomToolBar;
    }
    CGFloat bottomy = CGRectGetMinY(view.frame);
    
    YRange range;
    range.topY = topy;
    range.bottomY = bottomy;
    return range;
}


- (void)focusAtPoint:(CGPoint)point{
    NSLog(@"%ld",(long)self.device.exposureMode);
    CGSize size = self.cameraView.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if (self.lightModel != kLightModelTwo) {
            if ([self.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure ]) {
                [self.device setExposurePointOfInterest:focusPoint];
                [self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
        }
        [self.device unlockForConfiguration];
        self.focusView.center = point;
        self.focusView.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.focusView.hidden = YES;
            }];
        }];
    }else{
        NSLog( @"Could not lock device for configuration: %@", error );
    }
    NSLog(@"%ld",(long)self.device.exposureMode);
}

#pragma mark - actions - buttonClick

- (IBAction)flashBtnClick:(UIButton *)sender {
    
    BOOL isFrontCamera = NO;
    if (self.device.position == AVCaptureDevicePositionFront) {
        isFrontCamera = YES;
    }
    NSLog(@"%d",isFrontCamera);
    if (isFrontCamera) {
        [self frontCameraFlashModelChange];
    }else{
        [self backCameraFlashModelChange];
    }
}

-(void)frontCameraFlashModelChange{
    NSError *error = nil;
    if ( [self.device lockForConfiguration:&error] ) {
        switch (self.flashStateModel) {
            case kFlashStateModelAuto:
                self.flashStateModel = kFlashStateModelOn;
                if ([self.device isFlashModeSupported:AVCaptureFlashModeOn]) {
                    [self.device setFlashMode:AVCaptureFlashModeOn];
                    [self.flashBtn setImage:[UIImage imageNamed:@"icon_flash"] forState:UIControlStateNormal];
                }
                break;
            case kFlashStateModelOn:
                self.flashStateModel = kFlashStateModelOff;
                if ([self.device isFlashModeSupported:AVCaptureFlashModeOff]) {
                    [self.device setFlashMode:AVCaptureFlashModeOff];
                    [self.flashBtn setImage:[UIImage imageNamed:@"icon_flash_off"] forState:UIControlStateNormal];
                }
                break;
            case kFlashStateModelOff:
                self.flashStateModel = kFlashStateModelAuto;
                if ([self.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
                    [self.device setFlashMode:AVCaptureFlashModeAuto];
                    [self.flashBtn setImage:[UIImage imageNamed:@"icon_flash_aut"] forState:UIControlStateNormal];
                }
                break;
            default:
                break;
        }
        [self.device unlockForConfiguration];
    }
    else {
        NSLog( @"Could not lock device for configuration: %@", error );
    }
}
-(void)backCameraFlashModelChange{
    NSError *error = nil;
    if ( [self.device lockForConfiguration:&error] ) {
        if ([self.device isTorchModeSupported:AVCaptureTorchModeOff]) {
            [self.device setTorchMode:AVCaptureTorchModeOff];
        }
        switch (self.flashStateModel) {
            case kFlashStateModelAuto:
                self.flashStateModel = kFlashStateModelTorch;
                if ([self.device isTorchModeSupported:AVCaptureTorchModeOn]) {
                    [self.device setTorchMode:AVCaptureTorchModeOn];
                    [self.flashBtn setImage:[UIImage imageNamed:@"icon_flash_torch"] forState:UIControlStateNormal];
                }
                break;
            case kFlashStateModelTorch:
                self.flashStateModel = kFlashStateModelOn;
                if ([self.device isFlashModeSupported:AVCaptureFlashModeOn]) {
                    [self.device setFlashMode:AVCaptureFlashModeOn];
                    [self.flashBtn setImage:[UIImage imageNamed:@"icon_flash"] forState:UIControlStateNormal];
                }
                break;
            case kFlashStateModelOn:
                self.flashStateModel = kFlashStateModelOff;
                if ([self.device isFlashModeSupported:AVCaptureFlashModeOff]) {
                    [self.device setFlashMode:AVCaptureFlashModeOff];
                    [self.flashBtn setImage:[UIImage imageNamed:@"icon_flash_off"] forState:UIControlStateNormal];
                }
                break;
            case kFlashStateModelOff:
                self.flashStateModel = kFlashStateModelAuto;
                if ([self.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
                    [self.device setFlashMode:AVCaptureFlashModeAuto];
                    [self.flashBtn setImage:[UIImage imageNamed:@"icon_flash_aut"] forState:UIControlStateNormal];
                }
                break;
            default:
                break;
        }
        [self.device unlockForConfiguration];
    }
    else {
        NSLog( @"Could not lock device for configuration: %@", error );
    }
}

- (IBAction)delayTimeClick:(UIButton *)sender {
    if (self.timerIndex != 0) {
        return;
    }
    switch (self.delayTime) {
        case kDelayTimeOff:
            self.delayTime = kDelayTime3s;
            [sender setImage:[UIImage imageNamed:@"delaytime3"] forState:UIControlStateNormal];
            break;
        case kDelayTime3s:
            self.delayTime = kDelayTime10s;
            [sender setImage:[UIImage imageNamed:@"delaytime10"] forState:UIControlStateNormal];
            break;
        case kDelayTime10s:
            self.delayTime = kDelayTimeOff;
            [sender setImage:[UIImage imageNamed:@"delaytime0"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    NSLog(@"%f",(CGFloat)self.delayTime);
    if (self.delayTimeView != nil) {
        [self.delayTimeView removeFromSuperview];
    }
    if (self.delayTime != 0) {
        self.delayTimeView = [[LCDelayTimePromptView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        self.delayTimeView.center = self.cameraView.center;
        self.delayTimeView.delayTime = (CGFloat)self.delayTime;
        [self.cameraView addSubview:self.delayTimeView];
    }}

- (IBAction)camreaTypeClick:(UIButton *)sender {
    [self.stillCamera rotateCamera];
    self.device = self.stillCamera.inputCamera;
    self.flashStateModel = kFlashStateModelOff;
    [self.flashBtn setImage:[UIImage imageNamed:@"icon_flash_off"] forState:UIControlStateNormal];
    self.delayTime = kDelayTimeOff;
    [self.delayTimeBtn setImage:[UIImage imageNamed:@"delaytime0"] forState:UIControlStateNormal];
    [self.device lockForConfiguration:nil];
    if ([self.device isFlashModeSupported:AVCaptureFlashModeOff]) {
        [self.device setFlashMode:AVCaptureFlashModeOff];
    }
    [self.device unlockForConfiguration];
    self.lightModel = _lightModel;
    [self initSliderAndLabel];
}

- (IBAction)seetingsBtnClick:(UIButton *)sender {
    LCSettingsViewController * settings = [[LCSettingsViewController alloc]init];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:settings];
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)lightModelBtnClick:(UIButton *)sender {
    
    switch (self.lightModel) {
        case kLightModelAuto:
            [self.LightModelBtn setImage:[UIImage imageNamed:@"M1" ] forState:UIControlStateNormal];
            [self showMessage:@"M1"];
            self.lightModel = kLightModelOne;
            break;
        case kLightModelOne:
            
            [self.LightModelBtn setImage:[UIImage imageNamed: @"M2" ] forState:UIControlStateNormal];
            [self showMessage:@"M2"];
            self.lightModel = kLightModelTwo;
            break;
        case kLightModelTwo:
            [self.LightModelBtn setImage:[UIImage imageNamed:@"Auto" ]  forState:UIControlStateNormal];
            
            self.lightModel = kLightModelAuto;
            [self showMessage:@"Auto"];
            break;
            
        default:
            break;
    }
    
}

- (IBAction)takePhotoBtnClick:(UIButton *)sender {
    if (self.takePhotoBtn.selected == YES) {
        return;
    }
    self.takePhotoBtn.selected = YES;
    if (self.delayTime == 0) {
        [self judgePhotoAuthorityTakePhoto];
    }else{
        self.timerIndex = self.delayTime;
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerSelector) userInfo:nil repeats:YES];
    }
}

-(void)timerSelector{
    self.timerIndex -= 1;
    self.delayTimeView.delayTime = self.timerIndex;
    self.delayTime = kDelayTimeOff;
    [self.delayTimeBtn setImage:[UIImage imageNamed:@"delaytime0"] forState:UIControlStateNormal];
    if (self.timerIndex == 0 ) {
        [self.delayTimeView removeFromSuperview];
        [self judgePhotoAuthorityTakePhoto];
        [self.timer invalidate];
    }
}


- (IBAction)filterBtnClick:(UIButton *)sender {
    if (sender.isSelected == NO) {
        [self setalphaExposureView:0 IDZView:0 FilterChooseView:1];
        sender.selected = YES;
    }else{
        [self setalphaExposureView:1 IDZView:0 FilterChooseView:0];
        sender.selected = NO;
    }
}

- (IBAction)exposureBtnClick:(UIButton *)sender {
    
    [self setalphaExposureView:1 IDZView:0 FilterChooseView:0 ];
}

- (IBAction)IDZBtnClick:(UIButton *)sender {
    
    if (sender.isSelected == NO) {
        [self setalphaExposureView:0 IDZView:1 FilterChooseView:0];
        sender.selected = YES;
    }else{
        [self setalphaExposureView:1 IDZView:0 FilterChooseView:0];
        sender.selected = NO;
    }
}

-(void)setalphaExposureView:(CGFloat) exposure IDZView:(CGFloat)IDZ FilterChooseView:(CGFloat)filterView{
    [UIView animateWithDuration:0.3 animations:^{
        self.exposureView.alpha = exposure;
        self.IDZView.alpha = IDZ;
        self.filterChooseView.alpha = filterView;
    }];
}
- (IBAction)ISOSliderTouchBegin:(UISlider *)sender {
    self.ISOSliderHasTouched = YES;
}

- (IBAction)ISOSliderTouchEnd:(UISlider *)sender {
    self.ISOSliderHasTouched = NO;
}

- (IBAction)shutterSliderTouchBegin:(UISlider *)sender {
    self.shutterSliderHasTouched = YES;
}

- (IBAction)shutterSliderTouchEnd:(UISlider *)sender {
    self.shutterSliderHasTouched = NO;
}


#pragma mark - actions - sliderValueChanged

- (IBAction)ISOValueChanged:(UISlider *)sender {
    NSError *error = nil;
    if ( [self.device lockForConfiguration:&error] ) {
        if ([self.device isExposureModeSupported:AVCaptureExposureModeCustom]) {
            [self.device setExposureModeCustomWithDuration:AVCaptureExposureDurationCurrent ISO:sender.value completionHandler:nil];
        }
        [self.device unlockForConfiguration];
        self.ISOValueLabel.text = [NSString stringWithFormat:@"%d",(int)sender.value];
    }
    else {
        NSLog( @"Could not lock device for configuration: %@", error );
    }
}

- (IBAction)shutterValueChanged:(UISlider *)sender {
    UISlider *control = sender;
    NSError *error = nil;
    
    NSLog(@"%g",sender.value);
    
    double p = pow( control.value, kExposureDurationPower );
    double minDurationSeconds = MAX( CMTimeGetSeconds( self.device.activeFormat.minExposureDuration ), kExposureMinimumDuration );
    double maxDurationSeconds = CMTimeGetSeconds( self.device.activeFormat.maxExposureDuration );
    double newDurationSeconds = p * ( maxDurationSeconds - minDurationSeconds ) + minDurationSeconds;
    NSLog(@"%g",newDurationSeconds);
    if ( [self.device lockForConfiguration:&error] ) {
        if ([self.device isExposureModeSupported:AVCaptureExposureModeCustom]) {
            [self.device setExposureModeCustomWithDuration:CMTimeMakeWithSeconds( newDurationSeconds, 1000*1000*1000 )  ISO:AVCaptureISOCurrent completionHandler:nil];
        }
        [self.device unlockForConfiguration];
    }
    else {
        NSLog( @"Could not lock device for configuration: %@", error );
    }
    dispatch_async( dispatch_get_main_queue(), ^{
        if ( newDurationSeconds < 1 ) {
            int digits = MAX( 0, 2 + floor( log10( newDurationSeconds ) ) );
            self.shutterValueLabel.text = [NSString stringWithFormat:@"1/%.*f", digits, 1/newDurationSeconds];
        }
        else {
            self.shutterValueLabel.text = [NSString stringWithFormat:@"%.2f", newDurationSeconds];
        }
    } );
    
}

- (IBAction)zoomValueChanged:(UISlider *)sender {
    NSError *error = nil;
    if ( [self.device lockForConfiguration:&error] ) {
        
        [self.device setVideoZoomFactor:sender.value];
        [self.device unlockForConfiguration];
    }
    else {
        NSLog( @"Could not lock device for configuration: %@", error );
    }
    self.zoomValueLabel.text = [NSString stringWithFormat:@"%.1fx",self.zoomSilder.value];
}
- (void)zoom:(UIPinchGestureRecognizer *)sender{
    
    
}

- (IBAction)exposureValudChanged:(UISlider *)sender {
    GPUImageExposureFilter* filter = (GPUImageExposureFilter*)self.exposureFilter;
    float exposureValue = 0;
    float tempValue = 0;
    
    if (ABS(sender.value) < 1) {
        exposureValue = 0;
        tempValue = 0;
    }
    else if (sender.value >= 1){
        exposureValue = sender.value * 6.0/7.0 - 6.0/7.0;
        tempValue = sender.value * 8.0/7.0 - 8.0/7.0;
    }
    else if(sender.value <= -1){
        exposureValue = sender.value * 6.0/7.0 + 6.0/7.0;
        tempValue = sender.value * 8.0/7.0 + 8.0/7.0;
    }
    [filter setExposure:exposureValue];
    self.exposureValueLabel.text = [NSString stringWithFormat:@"%.0f",tempValue];
}
- (void)addObservers
{
    [self addObserver:self forKeyPath:@"device.ISO" options:NSKeyValueObservingOptionNew context:ISOContext];
    [self addObserver:self forKeyPath:@"device.exposureDuration" options:NSKeyValueObservingOptionNew context:ExposureDurationContext];
    [self addObserver:self forKeyPath:@"device.exposureMode" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:ExposureModeContext];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeObserver:self forKeyPath:@"device.exposureDuration" context:ExposureDurationContext];
    [self removeObserver:self forKeyPath:@"device.ISO" context:ISOContext];
    [self removeObserver:self forKeyPath:@"device.exposureMode" context:ExposureModeContext];
}
#pragma mark - 自动曝光
-(void)autoJustExposureCurrentISO:(CGFloat)currentISO{
    
    CGFloat E = (self.device.position == AVCaptureDevicePositionFront) ? 1.225:1.825 ;//自动曝光最大值
    CGFloat M = self.device.activeFormat.maxISO;//ISO 最大值
    BOOL isFront = (self.device.position == AVCaptureDevicePositionFront);
    if (self.lightModel != kLightModelAuto && isFront != YES) {
        E += 1;
    }
    GPUImageExposureFilter * filter = (GPUImageExposureFilter*)self.autoExposureFilter;
    CGFloat value = (E / M) * currentISO ;
    NSLog(@"Value:%f",value);
    [filter setExposure:value];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    id newValue = change[NSKeyValueChangeNewKey];
    
    if ( context == ISOContext ) {
        if (self.ISOSliderHasTouched == YES) {
            return;
        }
        
        if ( newValue && newValue != [NSNull null] ) {
            float newISO = [newValue floatValue];
            NSLog(@"ISOSliderchanged:%f",newISO);
            [self autoJustExposureCurrentISO:newISO];
            dispatch_async( dispatch_get_main_queue(), ^{
                self.ISOSlider.value = newISO;
                self.ISOValueLabel.text = [NSString stringWithFormat:@"%i", (int)newISO];
            } );
        }
    }
    else if ( context == ExposureDurationContext ) {
        if (self.shutterSliderHasTouched == YES) {
            return;
        }
        if ( newValue && newValue != [NSNull null] ) {
            double newDurationSeconds = CMTimeGetSeconds( [newValue CMTimeValue] );
            double minDurationSeconds = MAX( CMTimeGetSeconds( self.device.activeFormat.minExposureDuration ), kExposureMinimumDuration );
            double maxDurationSeconds = CMTimeGetSeconds( self.device.activeFormat.maxExposureDuration );
            
            double p = ( newDurationSeconds - minDurationSeconds ) / ( maxDurationSeconds - minDurationSeconds );
            NSLog(@"shutterSilderchanged%f",pow( p, 1 / kExposureDurationPower ));
            dispatch_async( dispatch_get_main_queue(), ^{
                
                self.shutterSilder.value = pow( p, 1 / kExposureDurationPower );
                if ( newDurationSeconds < 1 ) {
                    int digits = MAX( 0, 2 + floor( log10( newDurationSeconds ) ) );
                    self.shutterValueLabel.text = [NSString stringWithFormat:@"1/%.*f", digits, 1/newDurationSeconds];
                }
                else {
                    self.shutterValueLabel.text = [NSString stringWithFormat:@"%.2f", newDurationSeconds];
                }
            } );
        }
    }
    else if ( context == ExposureModeContext ) {
        if ( newValue && newValue != [NSNull null] ) {
            AVCaptureExposureMode newMode = [newValue intValue];
            NSLog(@"ExposureModeContext:%ld",(long)newMode);
            if (self.lightModel == kLightModelOne && newMode != AVCaptureExposureModeContinuousAutoExposure ) {
                [self.device lockForConfiguration:nil];
                self.device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
                [self.device unlockForConfiguration];
            }
            self.ISOSlider.hidden = (newMode == AVCaptureExposureModeContinuousAutoExposure);
            self.shutterSilder.hidden = (newMode == AVCaptureExposureModeContinuousAutoExposure);
            self.ISOLabel.hidden = self.ISOSlider.hidden;
            self.ISOValueLabel.hidden = self.ISOSlider.hidden;
            self.shutterLabel.hidden = self.shutterSilder.hidden;
            self.shutterValueLabel.hidden = self.shutterSilder.hidden;
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark - 辅助

-(void)photosNotAuthorizaPromt{
    NSString * message = NSLocalizedString(@"You disabled access, please go to Settings-> Privacy->Photos to set up access", @"You disabled access, please go to Settings-> Privacy->Photos to set up access");
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:ok];
    [self presentViewController:alertVC animated:YES completion:nil];
}

-(void)cameraNotAuthorizaPromt{
    self.view.userInteractionEnabled = NO;
    NSString * tempMessage = NSLocalizedString(@"newAPPname.camera.Allow Camory to access camera", @"Please allow %1@ to access camera in Settings-Privacy-Camera-%2@(Turn on).");
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if ([appName length] == 0 || appName == nil)
    {
        appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey];
    }
    NSString * message = [NSString stringWithFormat:tempMessage,appName,appName];
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:ok];
    [self presentViewController:alertVC animated:YES completion:nil];
}

-(BOOL)isPad{
    BOOL isPad = NO;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        isPad = YES;
    }
    return isPad;
}

#pragma mark - dealloc

-(void)dealloc{
    [self removeObservers];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
