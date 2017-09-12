//
//  CIAddBackGroundViewController.m
//  CutoutImage
//
//  Created by 何少博 on 17/2/14.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "CIAddBackGroundViewController.h"

#define MAS_SHORTHAND
#import "Masonry.h"
#import "MBProgressHUD.h"
#import "CIAddBackGroundToolView.h"
#import "CICutoutImageViewModel.h"
#import "UIColor+x.h"
#import "NPCommonConfig.h"
#import <Photos/Photos.h>
//#import "NPInterstitialButton.h"
#define  kToolViewHeight  self.view.bounds.size.height * 0.23

static const CGFloat kStateHeight = 20;

static const CGFloat kButtonHeight = 40;

@interface CIAddBackGroundViewController ()
<CIAddBackGroundToolViewDeleagte>

@property (nonatomic,strong) UIImageView *backGroundImageView;

@property (nonatomic,strong) UIImageView *foreGroundImageView;

@property (nonatomic,strong) CIAddBackGroundToolView *toolView;

@property (nonatomic,strong) UIButton *backButton;

@property (nonatomic,strong) UIButton *saveButton;

@property (nonatomic,strong) UIImage *foreImage;

@property (nonatomic,strong) UIImage *backGroundImage;

@property (nonatomic, strong) UITableView *tableView;

//@property (nonatomic,assign) BOOL showBorder;

@end




@implementation CIAddBackGroundViewController

-(instancetype)initWithImage:(UIImage *)image{
    self = [super init];
    if (self) {
        self.foreImage = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
    
}

#pragma mark - 广告

-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    [self genXinYueShu:contentInsets.bottom];
}

#pragma mark - UI

-(void)genXinYueShu:(CGFloat)bottom{
    [self.toolView updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.bottom).offset(-bottom);
    }];
    CGFloat maxHeight = self.view.bounds.size.height - kStateHeight - kToolViewHeight - kButtonHeight - 20 -bottom;
    CGFloat maxWidth = self.view.bounds.size.width -20;
    CGSize size = [[CICutoutImageViewModel new]getProperImageViewSize:self.backGroundImage.size maxWidth:maxWidth maxHeight:maxHeight];
    CGFloat offset = (64 - kToolViewHeight - bottom )/2;
    [self.backGroundImageView updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(size.height));
        make.width.equalTo(@(size.width));
        make.centerY.equalTo(self.view.centerY).offset(offset);
    }];
}


-(void)setupSubView{
    [self setupFuZhuView];
    [self setupBackButton];
    [self setupSaveButton];
    [self setupToolView];
    [self setupBackGroundImageViewAndForeGroundImageView];
    BOOL showAD = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (showAD) {
        [self setupInsertADButton];
    }
    
}

-(void)setupInsertADButton{
    NPInterstitialButton * insert = [NPInterstitialButton buttonWithType:NPInterstitialButtonTypeIcon viewController:self];
    insert.tintColor = [UIColor whiteColor];
    [self.view addSubview:insert];
    [insert makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.saveButton.left);
        make.width.equalTo(@(kButtonHeight-6));
        make.height.equalTo(@(kButtonHeight-6));
        make.centerY.equalTo(self.saveButton.centerY);
    }];
}

-(void)setupBackButton{
    self.backButton = [[UIButton alloc]init];
    [self.view addSubview:_backButton];
    [_backButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(kStateHeight));
        make.left.equalTo(self.view.left).offset(10);
        make.width.equalTo(@(kButtonHeight));
        make.height.equalTo(@(kButtonHeight));
    }];
//    [_backButton setTitle:@"返回" forState:UIControlStateNormal];
    [_backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backButtonClick)
                forControlEvents:UIControlEventTouchUpInside];
}

-(void)setupSaveButton{
    self.saveButton = [[UIButton alloc]init];
    [self.view addSubview:_saveButton];
    [_saveButton makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(kStateHeight));
        make.right.equalTo(self.view.right).offset(-10);
        make.width.equalTo(@(kButtonHeight));
        make.height.equalTo(@(kButtonHeight));
    }];
//    [_saveButton setTitle:@"保存"  forState:UIControlStateNormal];
    [_saveButton setImage:[UIImage imageNamed:@"save"]forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(saveButtonClick)
                forControlEvents:UIControlEventTouchUpInside];
}
-(void)setupFuZhuView{
    UIView * fuZhuView = [[UIView alloc]init];
    [self.view addSubview:fuZhuView];
    fuZhuView.backgroundColor = [UIColor colorWithHexString:@"1d1d1d"];
    [fuZhuView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.top);
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
        make.height.equalTo(@(64));
    }];
}
-(void)setupToolView{
    self.toolView = [[CIAddBackGroundToolView alloc]init];
    _toolView.delegate = self;
    CGFloat height = self.view.bounds.size.height * 0.23;
    [self.view addSubview:_toolView];
    [_toolView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.bottom);
        make.right.equalTo(self.view.right);
        make.left.equalTo(self.view.left);
        make.height.equalTo(@(height));
    }];
}

-(void)setupBackGroundImageViewAndForeGroundImageView{
    if (self.backGroundImage == nil) {
        NSString * path = [[NSBundle mainBundle]pathForResource:@"background.jpg" ofType:nil];
        self.backGroundImage = [UIImage imageWithContentsOfFile:path];
    }
    CGSize size = [self getProperSizeWithImage:self.backGroundImage];
    CGFloat offset = -ABS(kToolViewHeight-kStateHeight-kButtonHeight)/2;
    self.backGroundImageView = [[UIImageView alloc]init];
    self.backGroundImageView.image = _backGroundImage;
    self.backGroundImageView.userInteractionEnabled = YES;
    self.backGroundImageView.clipsToBounds = YES;
    [self.view addSubview:_backGroundImageView];
    [_backGroundImageView setContentMode:UIViewContentModeScaleAspectFit];
    [_backGroundImageView makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(size.height));
        make.width.equalTo(@(size.width));
        make.centerX.equalTo(self.view.centerX);
        make.centerY.equalTo(self.view.centerY).offset(offset);
    }];
    
    self.foreGroundImageView = [[UIImageView alloc]init];
   
    self.foreGroundImageView.image = self.foreImage;
    [self.backGroundImageView addSubview:_foreGroundImageView];
    self.foreGroundImageView.userInteractionEnabled = YES;
    CGFloat scale = self.foreImage.size.width/self.foreImage.size.height;
    CGFloat height,width;
    if (scale > 1) {
        width = 280;
        height = 280/scale;
    }else{
        height = 280;
        width = 280*scale;
    }
    [_foreGroundImageView setContentMode:UIViewContentModeScaleAspectFit];
    [_foreGroundImageView makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(height));
        make.width.equalTo(@(width));
        make.centerX.equalTo(self.backGroundImageView.centerX);
        make.centerY.equalTo(self.backGroundImageView.centerY);
    }];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(Scaler:)];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(Move:)];
    
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(rotate:)];
    
    [self.foreGroundImageView addGestureRecognizer:pinch];
    [self.foreGroundImageView addGestureRecognizer:pan];
    [self.foreGroundImageView addGestureRecognizer:rotation];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}
#pragma mark - button actions
-(void)backButtonClick{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"canTouch" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)saveButtonClick{
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (PHAuthorizationStatusAuthorized == status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self saveChoose];
                    });
                }
            }];
        }
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
            [self authorizationStatusDeniedAlertView];
            break;
        case PHAuthorizationStatusAuthorized:
            [self saveChoose];
            break;
            
        default:
            break;
    }
}

#pragma mark - 保存方法
-(void)authorizationStatusDeniedAlertView{
    
    UIAlertController * alertCon = [UIAlertController alertControllerWithTitle:CI_Prompt message:CI_Permissions preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:CI_Cancel style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction * done = [UIAlertAction actionWithTitle:CI_Settings style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        NSURL * settingUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication]canOpenURL:settingUrl]) {
            [[UIApplication sharedApplication]openURL:settingUrl];
        }
    }];
    
    [alertCon addAction:cancel];
    [alertCon addAction:done];
    
    [self presentViewController:alertCon animated:YES completion:nil];
}
-(void)saveChoose{
    __weak typeof(self) weakSelf = self;
    UIAlertController * alertC = [UIAlertController alertControllerWithTitle:nil message:nil
                                                              preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:CI_Cancel style:(UIAlertActionStyleCancel)
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        
                                                    }];
    UIAlertAction * saveForeimage = [UIAlertAction actionWithTitle:CI_ForegroundImage style:(UIAlertActionStyleDefault)
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               [weakSelf saveForeImage];
                                                           }];
    UIAlertAction * saveHeChengimage = [UIAlertAction actionWithTitle:CI_CompositeImage style:(UIAlertActionStyleDefault)
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  [weakSelf saveHeChengImage];
                                                              }];
    UIAlertAction * shareimage = [UIAlertAction actionWithTitle:CI_Share style:(UIAlertActionStyleDefault)
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [weakSelf shareImage];
                                                        }];
    
    [alertC addAction:cancel];
    [alertC addAction:saveForeimage];
    [alertC addAction:saveHeChengimage];
    [alertC addAction:shareimage];
    UIPopoverPresentationController *popoverVC = alertC.popoverPresentationController;
    if (popoverVC) {
        popoverVC.sourceView = self.saveButton;
        popoverVC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController:alertC animated:YES completion:nil];
}

-(void)saveForeImage{
    NSData * imageData = UIImagePNGRepresentation(self.foreImage);
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:imageData], nil, nil, nil);
    NSString *saveSuccessMessage = CI_Album;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = saveSuccessMessage;
    [hud hideAnimated:YES afterDelay:1.f];
    [self performSelector:@selector(xianShiGuangGao) withObject:nil afterDelay:1.2];
}
-(void)xianShiGuangGao{
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL showAD = [[NPCommonConfig shareInstance] shouldShowAdvertise];
        if (showAD) {
            [[NPCommonConfig shareInstance] showInterstitialAdInViewController:self];
        }
    });
}
-(void)saveHeChengImage{
    UIImage * image = [self heChengImage];
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    NSString *saveSuccessMessage =  CI_Album;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = saveSuccessMessage;
    [hud hideAnimated:YES afterDelay:1.f];
    [self performSelector:@selector(xianShiGuangGao) withObject:nil afterDelay:1.2];
}
-(UIImage *)heChengImage{
    UIGraphicsBeginImageContextWithOptions(self.backGroundImageView.bounds.size,NO,0.0);
    [self.backGroundImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
//    [self writeImage:image saveToAlbum:YES];
    return  image;
}
//-(void)writeImage:(UIImage *)image saveToAlbum:(BOOL)saveToAlbum{
//    NSString * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
//    NSData * imagedata = UIImagePNGRepresentation(image);
//    NSString * name = [[NSUUID UUID]UUIDString];
//    path = [path stringByAppendingPathComponent:[name stringByAppendingString:@".png"]];
//    [imagedata writeToFile:path atomically:YES];
//    if (saveToAlbum) {
//        UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:imagedata], nil, nil, nil);
//    }
//    LOG(@"path:%@",path);
//    
//}
//(^UIActivityViewControllerCompletionHandler)(UIActivityType __nullable activityType, BOOL completed)
-(void)shareImage{
    UIImage * image = [self heChengImage];
    NSArray *activityItem = [NSArray arrayWithObject:image];
    UIActivityViewController *activity = [[UIActivityViewController alloc]
                                          initWithActivityItems:activityItem
                                          applicationActivities:nil];
    UIPopoverPresentationController *popoverVC = activity.popoverPresentationController;
    __weak typeof(self) weakSelf = self;
    activity.completionWithItemsHandler = ^(UIActivityType  activityType, BOOL completed, NSArray *  returnedItems, NSError *  activityError){
        if (completed) {
//            [self performSelector:@selector(xianShiGuangGao) withObject:nil afterDelay:1.2];
            [weakSelf xianShiGuangGao];
        }
    };
    
    if (popoverVC) {
        popoverVC.sourceView = self.saveButton;
        popoverVC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController:activity animated:YES completion:nil];

}
#pragma mark - CIAddBackGroundToolViewDelegate
-(void)imageDidChoosed:(UIImage *)image{
    self.backGroundImage = image;
    self.backGroundImageView.image = image;
    ///更新约束
    CGSize size = [self getProperSizeWithImage:self.backGroundImage];
    CGFloat offset = -ABS(kToolViewHeight-kStateHeight-kButtonHeight)/2;
    [_backGroundImageView updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(size.height));
        make.width.equalTo(@(size.width));
        make.centerX.equalTo(self.view.centerX);
        make.centerY.equalTo(self.view.centerY).offset(offset);
    }];
}

-(void)alphaValueChanged:(CGFloat)value{
    self.foreGroundImageView.alpha = value;
}


#pragma mark - 手势


- (void)Scaler:(UIPinchGestureRecognizer *)pinch{
    LOG(@"%s",__func__);
    UIView *view = pinch.view;
    view.transform = CGAffineTransformScale(view.transform, pinch.scale, pinch.scale);
    pinch.scale = 1;
    
}
- (void)rotate:(UIRotationGestureRecognizer *)rotate{
    LOG(@"%s",__func__);
    UIView *view = rotate.view;
    if (rotate.state == UIGestureRecognizerStateBegan ||
        rotate.state == UIGestureRecognizerStateChanged)
    {
        view.transform = CGAffineTransformRotate(view.transform, rotate.rotation);
        [rotate setRotation:0];
    }
    
}
- (void)Move:(UIPanGestureRecognizer *)pan{
    LOG(@"%s",__func__);
    UIView *view = pan.view;
    if (pan.state == UIGestureRecognizerStateBegan ||
        pan.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [pan translationInView:view.superview];
        CGRect rect = view.superview.bounds;
        CGPoint point = [pan locationInView:view.superview];
        if (!CGRectContainsPoint(rect,point)) return;
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [pan setTranslation:CGPointZero inView:view.superview];
    }
}

#pragma  mark - --------
-(CGSize)getProperSizeWithImage:(UIImage *)image{
    CGFloat maxHeight = self.view.bounds.size.height - kStateHeight - kToolViewHeight - kButtonHeight - 20;
    CGFloat maxWidth = self.view.bounds.size.width -20;
    CGSize size = [[CICutoutImageViewModel new]getProperImageViewSize:image.size maxWidth:maxWidth maxHeight:maxHeight];
    return size;
}




@end
