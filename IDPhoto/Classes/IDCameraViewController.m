//
//  IDCameraViewController.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/24.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDCameraViewController.h"
#import <GPUImage.h>


@interface IDCameraViewController ()<CAAnimationDelegate>


@property (weak, nonatomic) IBOutlet GPUImageView *cameraView;

@property (weak, nonatomic) IBOutlet UIButton *flashBtn;

@property (weak, nonatomic) IBOutlet UIButton *cameraTypeBtn;

@property (weak, nonatomic) IBOutlet UIButton *takePhotoBtn;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property (weak, nonatomic) IBOutlet UIButton *resetBtn;

@property (weak, nonatomic) IBOutlet UIButton *doneBtn;

@property (nonatomic,strong) GPUImageFilter * normalFilter;

@property (nonatomic, strong) CALayer *focusLayer;

@property (strong, nonatomic) GPUImageStillCamera *stillCamera;


@end

@implementation IDCameraViewController


#pragma mark - ---------

- (CALayer *)focusLayer {
    if (!_focusLayer) {
        UIImage *focusImage = [UIImage imageNamed:@"touch_focus_x"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, focusImage.size.width, focusImage.size.height)];
        imageView.image = focusImage;
        _focusLayer = imageView.layer;
        _focusLayer.hidden = YES;
    }
    return _focusLayer;
}

-(GPUImageStillCamera *)stillCamera{
    if (_stillCamera == nil) {
        _stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionBack];
        _stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _stillCamera.horizontallyMirrorFrontFacingCamera = YES;
    }
    return _stillCamera;
}
#pragma mark - 视图生命周期
- (void)viewDidLoad {
    [super viewDidLoad];

    self.cameraView.fillMode =  kGPUImageFillModePreserveAspectRatioAndFill;
    self.normalFilter = [[GPUImageFilter alloc]init];
    [self runAsynchronous:^{
        [self.stillCamera addTarget:self.normalFilter];
        [self.normalFilter addTarget:self.cameraView];
        [self.stillCamera startCameraCapture];
    }];
    
    self.imageView.hidden = YES;
    [self.cameraView.layer addSublayer:self.focusLayer];
    [self.cameraView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusTap:)]];
    self.resetBtn.hidden = YES;
    self.doneBtn.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}


#pragma mark - actions
- (IBAction)trunCamera:(UIButton *)sender {
    [self.stillCamera pauseCameraCapture];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.stillCamera rotateCamera];
        [self.stillCamera resumeCameraCapture];
    });
    [self performSelector:@selector(animationCamera) withObject:self afterDelay:0.2f];
}

- (IBAction)fanHuiBtnClick:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(cameraDidCancel:)]) {
        [self.delegate cameraDidCancel:self];
    }
}
- (IBAction)flashBtnClick:(UIButton *)sender {
    if (self.flashBtn.selected) {
        
        if ([self.stillCamera.inputCamera lockForConfiguration:nil]) {
            if ([self.stillCamera.inputCamera isFlashModeSupported:AVCaptureFlashModeAuto]) {
                [self.stillCamera.inputCamera setFlashMode:AVCaptureFlashModeAuto];
                self.flashBtn.selected = NO;
            }
            [self.stillCamera.inputCamera unlockForConfiguration];
        }
    }else {
        
        if ([self.stillCamera.inputCamera lockForConfiguration:nil]) {
            if ([self.stillCamera.inputCamera isFlashModeSupported:AVCaptureFlashModeAuto]) {
                [self.stillCamera.inputCamera setFlashMode:AVCaptureFlashModeAuto];
                self.flashBtn.selected = YES;
            }
            [self.stillCamera.inputCamera unlockForConfiguration];
        }
    }
    
}
- (IBAction)takePhotoBtnClick:(UIButton *)sender {
    WeakSelf
    [self.stillCamera capturePhotoAsImageProcessedUpToFilter:self.normalFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.imageView setImage:processedImage];
            weakSelf.imageView.hidden = NO;
            weakSelf.takePhotoBtn.enabled = NO;
            weakSelf.resetBtn.hidden = NO;
            weakSelf.doneBtn.hidden = NO;
        });
    }];
}
- (IBAction)resetBtnClick:(UIButton *)sender {
    self.imageView.hidden = YES;
    self.takePhotoBtn.enabled = YES;
    self.resetBtn.hidden = YES;
    self.doneBtn.hidden = YES;
}
- (IBAction)doneBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(cameraTakePhoto:didFinish:)]) {
        CGImageRef newCgIm = CGImageCreateCopy(self.imageView.image.CGImage);
        UIImage *newImage = [UIImage imageWithCGImage:newCgIm scale:self.imageView.image.scale orientation:self.imageView.image.imageOrientation];
        CGImageRelease(newCgIm);
        [self.delegate cameraTakePhoto:self didFinish:newImage];
    }
}

- (void)focusTap:(UITapGestureRecognizer *)tap {
    self.cameraView.userInteractionEnabled = NO;
    CGPoint touchPoint = [tap locationInView:tap.view];
    [self layerAnimationWithPoint:touchPoint];
    touchPoint = CGPointMake(touchPoint.x / tap.view.bounds.size.width, touchPoint.y / tap.view.bounds.size.height);
  
    if ([self.stillCamera.inputCamera isFocusPointOfInterestSupported] && [self.stillCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([self.stillCamera.inputCamera lockForConfiguration:&error]) {
            [self.stillCamera.inputCamera setFocusPointOfInterest:touchPoint];
            [self.stillCamera.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
            
            if([self.stillCamera.inputCamera isExposurePointOfInterestSupported] && [self.stillCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            {
                [self.stillCamera.inputCamera setExposurePointOfInterest:touchPoint];
                [self.stillCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            [self.stillCamera.inputCamera unlockForConfiguration];
            
        } else {
            NSLog(@"ERROR = %@", error);
        }
    }
}

#pragma mark - 动画

- (void)animationCamera {
    
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = .5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = @"oglFlip";
    animation.subtype = kCATransitionFromRight;
    [self.cameraView.layer addAnimation:animation forKey:nil];
    [self resetBtnClick:self.resetBtn];
    
}

- (void)layerAnimationWithPoint:(CGPoint)point {
    if (_focusLayer) {
        CALayer *focusLayer = _focusLayer;
        focusLayer.hidden = NO;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [focusLayer setPosition:point];
        focusLayer.transform = CATransform3DMakeScale(2.0f,2.0f,1.0f);
        [CATransaction commit];
        
        CABasicAnimation *animation = [ CABasicAnimation animationWithKeyPath: @"transform" ];
        animation.toValue = [ NSValue valueWithCATransform3D: CATransform3DMakeScale(1.0f,1.0f,1.0f)];
        animation.delegate = self;
        animation.duration = 0.3f;
        animation.repeatCount = 1;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [focusLayer addAnimation: animation forKey:@"animation"];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self performSelector:@selector(focusLayerNormal) withObject:self afterDelay:1.0f];
}
- (void)focusLayerNormal {
    self.cameraView.userInteractionEnabled = YES;
    _focusLayer.hidden = YES;
}
@end
