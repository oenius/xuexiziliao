//
//  IDPhotoEditViewController.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/24.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDPhotoEditViewController.h"
#import <GPUImage.h>
#import "IDMeiFuView.h"
#import "IDContentView.h"
#import "IDDaYanView.h"
#import "IDShouLianView.h"
#import "IDZengQiangView.h"
#import "LFGPUImageBeautyFilter.h"
#import "HSGPUImageBigEyeFilter.h"
#import "HSGPUImageEnhancementFilter.h"
#import <SVProgressHUD.h>
#import "IDCutBGViewController.h"
#import "FaceDetectorManager.h"
#import "IDBigEyeCircleView.h"
#import "IDMagnifier.h"
#import "CIFinagerTrackingView.h"
#import "UIButton+LZCategory.h"
#import "UINavigationController+x.h"
#define MAS_SHORTHAND
#import "Masonry.h"
#import "NPCommonConfig.h"
static CGFloat const kContentViewDefaultHeight = 44;

typedef enum : NSUInteger {
    IDPhotoEditTouchStateNone,
    IDPhotoEditTouchStateBigEye,
    IDPhotoEditTouchStateThinFace,
} IDPhotoEditTouchState;

@interface IDPhotoEditViewController (){
    CGFloat bigEyeValue ;
}

@property (nonatomic,copy) NSString *idType;

@property (nonatomic,assign) IDPhotoBGType bgType;

@property (assign,nonatomic) CGFloat imageRatio;

@property (weak, nonatomic) IBOutlet UIToolbar *toolView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewBottom;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;

@property (weak, nonatomic) IBOutlet IDContentView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *meiYanBtn;

@property (weak, nonatomic) IBOutlet UIButton *zengQiangBtn;

@property (weak, nonatomic) IBOutlet UIButton *daYan;

@property (weak, nonatomic) IBOutlet UIButton *shouLian;

@property (weak, nonatomic) IBOutlet UIImageView *originalImageView;

@property (nonatomic,strong) UIImage * tmpImage;

@property (strong, nonatomic) GPUImageView *gpuImageView;

@property (weak,nonatomic)IDMeiFuView * meiFuView;

@property (weak,nonatomic)IDDaYanView * daYanView;

@property (weak,nonatomic)IDShouLianView * shouLianView;

@property (weak,nonatomic)IDZengQiangView * zengQiangView;

@property (strong,nonatomic) LFGPUImageBeautyFilter * beautifyFilter;

@property (strong,nonatomic) HSGPUImageBigEyeFilter * bigEyeFilter;

@property (strong,nonatomic) HSGPUImageEnhancementFilter * zengQiangFilter;

@property (strong,nonatomic) GPUImagePicture * gpuPicture;

@property (assign,nonatomic) BOOL isFirstOpen;

@property (weak, nonatomic) IBOutlet UIButton *compareBtn;

@property (nonatomic,assign) CGPoint leftEyePoint;

@property (nonatomic,assign) CGPoint rightEyePoint;

@property (nonatomic,assign) IDPhotoEditTouchState currentState;

@property (nonatomic,strong) IDBigEyeCircleView * circleView;

@property (nonatomic,strong) CIFinagerTrackingView * trackingView;

@property (nonatomic,assign) BOOL isHasDetectionFace;

@end


@implementation IDPhotoEditViewController

#pragma mark - ========

-(instancetype)initWithChiCunType:(NSString *)idType BGType:(IDPhotoBGType) bgType editImage:(UIImage *)image{
    self = [super initWithNibName:@"IDPhotoEditViewController" bundle:nil];
    if (self) {
        self.idType = idType;
        self.bgType = bgType;
        self.editImage = image;
        self.imageRatio = image.size.width/image.size.height;
        self.isFirstOpen = YES;
        self.currentState = IDPhotoEditTouchStateNone;
    }
    return self;
    
}

-(CIFinagerTrackingView *)trackingView{
    if (_trackingView == nil) {
        _trackingView = [[CIFinagerTrackingView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        
    }
    return _trackingView;
}

-(IDBigEyeCircleView *)circleView{
    if (nil == _circleView) {
        _circleView = [[IDBigEyeCircleView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    }
    return _circleView;
}

-(GPUImageView *)gpuImageView{
    if (_gpuImageView == nil) {
        _gpuImageView = [[GPUImageView alloc]init];
        [self.view insertSubview:_gpuImageView aboveSubview:_originalImageView];
        [_gpuImageView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_originalImageView.top);
            make.left.equalTo(_originalImageView.left);
            make.right.equalTo(_originalImageView.right);
            make.bottom.equalTo(_originalImageView.bottom);
        }];
    }
    return _gpuImageView;
}

#pragma mark - 视图生命周期

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.originalImageView.image = self.editImage;
    
    [self initUI];
    NSLayoutConstraint * ratioCon = [NSLayoutConstraint constraintWithItem:self.originalImageView attribute:(NSLayoutAttributeWidth) relatedBy:(NSLayoutRelationEqual) toItem:self.originalImageView attribute:(NSLayoutAttributeHeight) multiplier:self.imageRatio constant:0];
    [self.originalImageView addConstraint:ratioCon];
    self.gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatio;
    self.gpuImageView.alpha = 0;
    
}

-(void)initUI{
    [self.meiYanBtn setTitle:[IDConst instance].FaceBeauty forState:(UIControlStateNormal)];
    [self.daYan setTitle:[IDConst instance].BigEye forState:(UIControlStateNormal)];
    [self.zengQiangBtn setTitle:[IDConst instance].Enhance forState:(UIControlStateNormal)];
    self.toolView.clipsToBounds = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:(UIBarButtonItemStylePlain) target:self action:@selector(goBack)];;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"next"] style:(UIBarButtonItemStylePlain) target:self action:@selector(nextStep)];
    UIImage * barImage = [UIImage jk_imageWithColor:[UIColor colorWithHexString:@"#2c2e30"]];
    barImage = [barImage resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:(UIImageResizingModeStretch)];
    [self.navigationController.navigationBar setBackgroundImage:barImage forBarMetrics:(UIBarMetricsDefault)];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#2c2e30"];
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.meiYanBtn LZSetbuttonType:(LZCategoryTypeBottom)];
    [self.daYan LZSetbuttonType:(LZCategoryTypeBottom)];
    [self.zengQiangBtn LZSetbuttonType:(LZCategoryTypeBottom)];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_isFirstOpen) {
        _isFirstOpen = NO;
        [SVProgressHUD showWithStatus: [IDConst instance].Processing];
        WeakSelf
        [self runAsynchronous:^{
            NSArray * features  = [[FaceDetectorManager manager] faceDetectWithImage:self.editImage];
            [weakSelf runAsyncOnMainThread:^{
                [SVProgressHUD dismiss];
                if (features.count == 0 || features == nil ) {
                    [UIAlertController showMessageOKAndCancel:[IDConst instance].NoFace action:^(AlertActionType actionType) {
                        if (actionType == AlertActionTypeOK) {
                            bigEyeValue = kDefaultRadius;
                            weakSelf.isHasDetectionFace = NO;
                            return;
                        }else{
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                            return;
                        }
                    }];
                }else{
                    for (CIFaceFeature * feature in features) {
                        if (feature.hasLeftEyePosition) {
                            _leftEyePoint = feature.leftEyePosition;
                        }
                        if (feature.hasRightEyePosition) {
                            _rightEyePoint = feature.rightEyePosition;
                        }
//                        if (feature.hasMouthPosition) {
//                            _mousePoint = feature.mouthPosition;
//                        }
//                        _faceRect = feature.bounds;
                        break;
                    }
                    [weakSelf adjustFacePoitns];
                    weakSelf.isHasDetectionFace = YES;
                }
                [weakSelf meiYanBtnClick:weakSelf.meiYanBtn];
            }];
        }];
    }
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [UIApplication sharedApplication].statusBarHidden = NO;
}
#pragma mark - touch event

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch * touch = touches.allObjects.firstObject;
    CGPoint touchPoint = [touch locationInView:self.gpuImageView];
    CGRect rect = self.gpuImageView.bounds;
    if (!CGRectContainsPoint(rect, touchPoint)) return;
    if (self.currentState == IDPhotoEditTouchStateBigEye) {
       
        [self.gpuImageView addSubview:self.circleView];
        self.circleView.alpha = 1;
        self.circleView.isShowMask = NO;
        self.circleView.centerPoint = touchPoint;
        CGPoint eyePoint = CGPointMake(touchPoint.x/self.gpuImageView.bounds.size.width,
                                       touchPoint.y/self.gpuImageView.bounds.size.height);
        self.bigEyeFilter.leftEyeCenterPosition = eyePoint;
        self.bigEyeFilter.rightEyeCenterPosition = eyePoint;
        CGFloat radius = bigEyeValue/self.gpuImageView.bounds.size.width;
        self.bigEyeFilter.radius = radius;
        [self.trackingView beganTrackingView:self.view];
        [self.trackingView trackingPoint:[touch locationInView:self.view]];
    }
    
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch * touch = touches.allObjects.firstObject;
    CGPoint touchPoint = [touch locationInView:self.gpuImageView];
    CGRect rect = self.gpuImageView.bounds;
    if (!CGRectContainsPoint(rect, touchPoint)) return;
    if (self.currentState == IDPhotoEditTouchStateBigEye) {
        self.circleView.centerPoint = touchPoint;
        CGPoint eyePoint = CGPointMake(touchPoint.x/self.gpuImageView.bounds.size.width,
                                       touchPoint.y/self.gpuImageView.bounds.size.height);
        self.bigEyeFilter.leftEyeCenterPosition = eyePoint;
        self.bigEyeFilter.rightEyeCenterPosition = eyePoint;
        CGFloat radius = bigEyeValue/self.gpuImageView.bounds.size.width;
        self.bigEyeFilter.radius = radius;
        [self.gpuPicture processImage];
        [self.trackingView trackingPoint:[touch locationInView:self.view]];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    if (self.currentState == IDPhotoEditTouchStateBigEye) {
        [self.gpuPicture processImageUpToFilter:self.bigEyeFilter withCompletionHandler:^(UIImage *processedImage) {
            if (processedImage) {
//                self.editImage = processedImage;
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.originalImageView.image = processedImage;
                    self.gpuPicture = [[GPUImagePicture alloc]initWithImage:processedImage];
                   [self.gpuPicture addTarget:self.bigEyeFilter];
                });
            }
        }];
        [self.circleView removeFromSuperview];
        [self.trackingView endTracking];
    }

}
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.circleView removeFromSuperview];
    
}


#pragma mark - actions

-(void)goBack{
    [self.navigationController usingTheGradient];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)nextStep{
//    CGSize properSize = [self getImageSizeWithType:self.idType];
    UIImage * newImage = self.originalImageView.image;
//    newImage = [newImage jk_resizedImage:properSize interpolationQuality:(kCGInterpolationHigh)];
    IDCutBGViewController * cutbg = [[IDCutBGViewController alloc]initWithImage:newImage idType:self.idType BGType:self.bgType];
    [self.navigationController pushViewController:cutbg animated:YES];
   
}



- (IBAction)meiYanBtnClick:(UIButton *)sender {
    self.title = [IDConst instance].FaceBeauty;
    [self showMeiFuView];
    [self hiddenToolView];
    
    [self.view insertSubview:self.gpuImageView aboveSubview:self.originalImageView];
    self.gpuPicture = [[GPUImagePicture alloc] initWithImage:self.self.originalImageView.image];
    self.beautifyFilter = [[LFGPUImageBeautyFilter alloc] init];
    [self.beautifyFilter forceProcessingAtSize:self.gpuImageView.sizeInPixels];
    [self.gpuPicture addTarget:self.beautifyFilter];
    [self.beautifyFilter addTarget:self.gpuImageView];
    self.beautifyFilter.beautyLevel = 0.5;
    self.beautifyFilter.brightLevel = 0.5;
    [self.gpuPicture processImage];
}


- (IBAction)daYanBtnClick:(UIButton *)sender {
    

    self.title = [IDConst instance].BigEye;
    [self showDaYanView];
    [self hiddenToolView];
    
    [self.view insertSubview:self.gpuImageView aboveSubview:self.originalImageView];
    self.gpuPicture = [[GPUImagePicture alloc] initWithImage:self.originalImageView.image];
    self.bigEyeFilter = [[HSGPUImageBigEyeFilter alloc] init];
    [self.bigEyeFilter forceProcessingAtSize:self.gpuImageView.sizeInPixels];
    [self.gpuPicture addTarget:self.bigEyeFilter];
    [self.bigEyeFilter addTarget:self.gpuImageView];
    if (_isHasDetectionFace == YES) {
        _bigEyeFilter.rightEyeCenterPosition = _rightEyePoint;
        _bigEyeFilter.leftEyeCenterPosition = _leftEyePoint;
        CGFloat radius = (_rightEyePoint.x - _leftEyePoint.x)/2.5;
        _bigEyeFilter.radius  = radius;
    }else{
        _bigEyeFilter.rightEyeCenterPosition = CGPointZero;
        _bigEyeFilter.leftEyeCenterPosition = CGPointZero;
    }
    
    [self.gpuPicture processImage];
}


- (IBAction)shouLianBtnClick:(UIButton *)sender {
    [self showShouLianView];
    [self hiddenToolView];
    
}


- (IBAction)zengQiangBtnClick:(UIButton *)sender {
    self.title = [IDConst instance].Enhance;
    [self showZengQiangView];
    [self hiddenToolView];
    
    [self.view insertSubview:self.gpuImageView aboveSubview:self.originalImageView];
    self.gpuPicture = [[GPUImagePicture alloc] initWithImage:self.self.originalImageView.image];
    self.zengQiangFilter = [[HSGPUImageEnhancementFilter alloc] init];

    [self.zengQiangFilter forceProcessingAtSize:self.gpuImageView.sizeInPixels];
    [self.gpuPicture addTarget:self.zengQiangFilter];
    [self.zengQiangFilter addTarget:self.gpuImageView];
    [self.gpuPicture processImage];
}

- (IBAction)CompareBtnTouchDown:(UIButton *)sender {
    self.tmpImage = self.originalImageView.image;
    self.originalImageView.image = self.editImage;
    self.gpuImageView.hidden = YES;
}
- (IBAction)compareBtnTouchCancel:(id)sender {
    self.gpuImageView.hidden = NO;
    self.originalImageView.image = self.tmpImage;
}

#pragma mark - 人脸坐标点计算

-(void)adjustFacePoitns{
    CGSize imageSize = self.editImage.size;
    _leftEyePoint = [self conversionCoordinates:_leftEyePoint imageSize:imageSize];
    _rightEyePoint = [self conversionCoordinates:_rightEyePoint imageSize:imageSize];
}

-(CGPoint)conversionCoordinates:(CGPoint)point imageSize:(CGSize) size{
    
    CGPoint newPoint = point;
    newPoint.y = size.height - newPoint.y;
    
//    CGSize imageViewSize = self.originalImageView.bounds.size;
//    CGFloat widthScale = imageViewSize.width/size.width;
//    CGFloat heightScale = imageViewSize.height/size.height;
//    CGPoint kk = newPoint;
//    kk.x = kk.x * widthScale;
//    kk.y = kk.y * heightScale;
//    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
//    view.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
//    [self.originalImageView addSubview:view];
//    view.center = kk;
    
    newPoint.x = newPoint.x/size.width;
    newPoint.y = newPoint.y/size.height;
    
    return newPoint;
}
#pragma mark - 显示和隐藏视图
-(void)makeConteViewHeight:(CGFloat) height withView:(UIView *)view{
    view.alpha = 0;
    self.contentView.subView = view;
    [self.contentView addSubview:view];
    self.contentViewHeight.constant = height;
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            view.alpha = 1;
        }];
    }];
}
///===========================================================
-(void)hiddenToolView{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.toolView.alpha = 0;
    }];
}

-(void)showToolView{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.title = nil;
    [UIView animateWithDuration:0.25 animations:^{
        self.toolView.alpha = 1;
    }];
    [IDConst showADRandom:5 forController:self];
}
///===========================================================

-(void)showMeiFuView{
    
    if (self.meiFuView) {return;}
    
    WeakSelf
    IDMeiFuView * meiFuView = [[IDMeiFuView alloc]initWithAction:^(const MeiFuActionType type, CGFloat value) {
        if (type == MeiFuActionTypeDone) {
            if (weakSelf.beautifyFilter == nil) return ;
            if (weakSelf.gpuPicture == nil) return;
            [weakSelf.gpuPicture processImageUpToFilter:weakSelf.beautifyFilter withCompletionHandler:^(UIImage *processedImage) {
                if (processedImage) {
                    weakSelf.editImage = processedImage;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.originalImageView.image = processedImage;
                        [weakSelf hiddenMeiFuView];
                        [weakSelf showToolView];
                        
                    });
                }
            }];
        }
        else if (type == MeiFuActionTypeCancel){
            [weakSelf.beautifyFilter removeAllTargets];
            [weakSelf.gpuPicture removeAllTargets];
            [weakSelf.gpuImageView removeFromSuperview];
            weakSelf.beautifyFilter = nil;
            weakSelf.gpuPicture  = nil;
            weakSelf.gpuImageView = nil;
            [weakSelf hiddenMeiFuView];
            [weakSelf showToolView];
        }
        else if (type == MeiFuActionTypeValueChanged){
            NSLog(@"%lf",value);
            weakSelf.gpuImageView.alpha = 1;
            weakSelf.beautifyFilter.beautyLevel = value;
            [weakSelf.gpuPicture processImage];
        }
        
    }];
    
    self.meiFuView = meiFuView;
    [meiFuView setDefaultValue:0.4];
    [self makeConteViewHeight:kMeiFuViewHeight withView:meiFuView];
}
-(void)hiddenMeiFuView{
    self.contentViewHeight.constant = kContentViewDefaultHeight;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.meiFuView.alpha = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.meiFuView) {
            [self.meiFuView removeFromSuperview];
            self.meiFuView = nil;
        }
    }];
}

///===========================================================

-(void)showDaYanView{
    if (self.daYanView) { return; }
    WeakSelf
    IDDaYanView * daYanView = [[IDDaYanView alloc]initWithAction:^(const DaYanViewActionType actionType, CGFloat value) {
        if (weakSelf.bigEyeFilter == nil) return ;
        if (weakSelf.gpuPicture == nil) return;
        weakSelf.gpuImageView.alpha = 1;
        switch (actionType) {
            case DaYanViewActionTypeTouchCancel:
                if (_currentState == IDPhotoEditTouchStateBigEye) {
                    [UIView animateWithDuration:0.5 animations:^{
                        weakSelf.circleView.alpha = 0;
                    } completion:^(BOOL finished) {
                       [weakSelf.circleView removeFromSuperview];
                    }];
                    
                }
                break;
            case DaYanViewActionTypeTouchDown:
                if (_currentState == IDPhotoEditTouchStateBigEye) {
                    
                    [weakSelf.gpuImageView addSubview:weakSelf.circleView];
                    weakSelf.circleView.center = CGPointMake(weakSelf.gpuImageView.bounds.size.width/2,
                                                             weakSelf.gpuImageView.bounds.size.height/2);
                    weakSelf.circleView.isShowMask = YES;
                    weakSelf.circleView.radius  = value;
                    weakSelf.circleView.alpha = 0;
                    [UIView animateWithDuration:0.3 animations:^{
                        weakSelf.circleView.alpha = 1;
                    } completion:^(BOOL finished) {
                    }];
                }
                break;
            case DaYanViewActionTypeShouDongValueChanged:
                
                
                weakSelf.currentState = IDPhotoEditTouchStateBigEye;
                weakSelf.bigEyeFilter.scaleRatio = 0.2;
                weakSelf.circleView.radius  = value;
                bigEyeValue = value;
                break;
            case DaYanViewActionTypeZiDongValueChanged:
                weakSelf.currentState = IDPhotoEditTouchStateNone;
                if (_isHasDetectionFace == YES) {
                    _bigEyeFilter.rightEyeCenterPosition = _rightEyePoint;
                    _bigEyeFilter.leftEyeCenterPosition = _leftEyePoint;
                    CGFloat radius = (_rightEyePoint.x - _leftEyePoint.x)/2.5;
                    _bigEyeFilter.radius  = radius;
                }
                weakSelf.bigEyeFilter.scaleRatio = value;
                [weakSelf.gpuPicture processImage];
                break;
            case DaYanViewActionTypeDone:{
//                weakSelf.bigEyeFilter.leftEyeCenterPosition = CGPointMake(-10,-10);
//                weakSelf.bigEyeFilter.rightEyeCenterPosition = CGPointMake(-10,-10);
                if (weakSelf.currentState == IDPhotoEditTouchStateBigEye) {
                     weakSelf.bigEyeFilter.scaleRatio = 0;
                }
               
                [weakSelf.gpuPicture processImageUpToFilter:weakSelf.bigEyeFilter withCompletionHandler:^(UIImage *processedImage) {
                    if (processedImage) {
                        weakSelf.currentState = IDPhotoEditTouchStateNone;
                        weakSelf.editImage = processedImage;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.originalImageView.image = processedImage;
                            [weakSelf hiddenDaYanView];
                            [weakSelf showToolView];
                           
                        });
                    }
                }];
            }
                break;
            case DaYanViewActionTypeCancel:
                [weakSelf.bigEyeFilter removeAllTargets];
                [weakSelf.gpuPicture removeAllTargets];
                [weakSelf.gpuImageView removeFromSuperview];
                weakSelf.bigEyeFilter = nil;
                weakSelf.gpuPicture  = nil;
                weakSelf.gpuImageView = nil;
                [weakSelf hiddenDaYanView];
                [weakSelf showToolView];
                weakSelf.originalImageView.image = weakSelf.editImage;
                weakSelf.gpuImageView.alpha = 0;
                
                break;
            default:
                break;
        }
    }];
    self.daYanView = daYanView;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.daYanView.isCanZiDong = _isHasDetectionFace;
    });
    self.currentState = _isHasDetectionFace?IDPhotoEditTouchStateNone:IDPhotoEditTouchStateBigEye;
    [self makeConteViewHeight:kDaYanViewHeight withView:daYanView];
}

-(void)hiddenDaYanView{
    self.contentViewHeight.constant = kContentViewDefaultHeight;
    self.currentState = IDPhotoEditTouchStateNone;
    [UIView animateWithDuration:0.25 animations:^{
        self.daYanView.alpha = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.daYanView) {
            [self.daYanView removeFromSuperview];
            self.daYanView = nil;
        }
    }];
}

///===========================================================
-(void)showShouLianView{
    if (self.shouLianView) { return; }
    WeakSelf
    IDShouLianView * shouLianView = [[IDShouLianView alloc]initWithAction:^(const ShouLianViewActionType actionType, CGFloat value) {
        
        switch (actionType) {
            case ShouLianViewActionTypeShouDongValueChanged:
                
                break;
            case ShouLianViewActionTypeZiDongValueChanged:
                
                break;
            case ShouLianViewActionTypeDone:
                
                break;
            case ShouLianViewActionTypeCancel:
                
                
                [weakSelf hiddenShouLianView];
                [weakSelf showToolView];
                break;
            default:
                break;
        }
    }];
    self.shouLianView = shouLianView;
    [self makeConteViewHeight:kShouLianViewHeight withView:shouLianView];
}

-(void)hiddenShouLianView{
    self.contentViewHeight.constant = kContentViewDefaultHeight;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.shouLianView.alpha = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.shouLianView) {
            [self.shouLianView removeFromSuperview];
            self.shouLianView = nil;
        }
    }];
}
///===========================================================
-(void)showZengQiangView{
    if (self.zengQiangView) { return; }
    WeakSelf
    IDZengQiangView * zengQiangView = [[IDZengQiangView alloc]initWithAction:^(const ZengQiangActionType actionType, CGFloat value) {
        if (weakSelf.zengQiangFilter == nil)return ;
        if (weakSelf.gpuPicture == nil)  return;
        weakSelf.gpuImageView.alpha = 1;
        switch (actionType) {
            case ZengQiangActionTypeLiangDu:
                weakSelf.zengQiangFilter.brightness = value;
                [weakSelf.gpuPicture processImage];
                NSLog(@"亮度 %g",value);
                break;
            case ZengQiangActionTypeDuiBiDu:
                weakSelf.zengQiangFilter.contrast = value;
                [weakSelf.gpuPicture processImage];
                NSLog(@"对比度 %g",value);
                break;
            case ZengQiangActionTypeBaoHeDu:
                weakSelf.zengQiangFilter.saturation = value;
                [weakSelf.gpuPicture processImage];
                NSLog(@"饱和度 %g",value);
                break;
            case ZengQiangActionTypeBaoGuangDu:
                weakSelf.zengQiangFilter.exposure = value;
                [weakSelf.gpuPicture processImage];
                NSLog(@"曝光度 %g",value);
                break;
            case ZengQiangActionTypeDone:{
                
                [weakSelf.gpuPicture processImageUpToFilter:weakSelf.zengQiangFilter withCompletionHandler:^(UIImage *processedImage) {
                    if (processedImage) {
                        weakSelf.editImage = processedImage;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.originalImageView.image = processedImage;
                            [weakSelf hiddenZengQiangView];
                            [weakSelf showToolView];
                           
                        });
                    }
                }];
            }
                break;
            case ZengQiangActionTypeCancel:
                [weakSelf.zengQiangFilter removeAllTargets];
                [weakSelf.gpuPicture removeAllTargets];
                [weakSelf.gpuImageView removeFromSuperview];
                weakSelf.zengQiangFilter = nil;
                weakSelf.gpuPicture  = nil;
                weakSelf.gpuImageView = nil;
                [weakSelf hiddenZengQiangView];
                [weakSelf showToolView];
                weakSelf.gpuImageView.alpha = 0;
                break;
            default:
                break;
        }
    }];
    self.zengQiangView = zengQiangView;
    [self makeConteViewHeight:kZengQiangViewHeight withView:zengQiangView];
}

-(void)hiddenZengQiangView{
    self.contentViewHeight.constant = kContentViewDefaultHeight;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.zengQiangView.alpha = 0;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.zengQiangView) {
            [self.zengQiangView removeFromSuperview];
            self.zengQiangView = nil;
        }
    }];
}

#pragma mark - 广告相关
-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    self.contentViewBottom.constant = contentInsets.bottom;
    [self.view setViewLayoutAnimation];
}


@end
