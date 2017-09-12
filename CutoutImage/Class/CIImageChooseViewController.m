//
//  CIImageChooseViewController.m
//  CutoutImage
//
//  Created by 何少博 on 17/2/5.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//


#import "CIImageChooseViewController.h"
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>
#define MAS_SHORTHAND
#import "Masonry.h"
#import "CISettingsViewController.h"
#import "PhotoTweaksViewController.h"
#import "CICutoutImageViewController.h"
#import "UIColor+x.h"
#import "CustomAnimatedDelegate.h"
#import "NPCommonConfig.h"
#import "NPGoProButton.h"
#import "CIGuideViewController.h"
#import "CIUserDefaultManager.h"
typedef enum : NSUInteger {
    CIImagePickerTypeAlbum,
    CIImagePickerTypeCamera,
} CIImagePickerType;

@interface CIImageChooseViewController ()
<UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
PhotoTweaksViewControllerDelegate>


@property (nonatomic,strong) UIImagePickerController * imagePicker;
@property (nonatomic,strong) NPGoProButton *goPro;

@property (nonatomic,strong) UIButton * helpBtn;

@end

@implementation CIImageChooseViewController

#pragma mark - 视图相关
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addButton];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([CIUserDefaultManager getShouldShowAD]) {
        BOOL showAd = [[NPCommonConfig shareInstance]shouldShowAdvertise];
        if (showAd == YES) {
            [CIUserDefaultManager setShouldShowAD:NO];
            [[NPCommonConfig shareInstance] showInterstitialAdInViewController:self];
        }
    }
    if ([CIUserDefaultManager getFirstLaunchMark]) {
        [self helpBtnClick:nil];
        [CIUserDefaultManager setFirstLaunchMark:NO];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

#pragma mark - 初始化子视图

-(void)addButton{
    
    UIImageView * imageView = [[UIImageView alloc]init];
    imageView.image = [UIImage imageNamed:@"bg.png"];
    [self.view insertSubview:imageView atIndex:0];
    [imageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.top);
        make.bottom.equalTo(self.view.bottom);
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
    }];
    
    if ([[NPCommonConfig shareInstance] shouldShowAdvertise]) {
        _goPro = [NPGoProButton goProButtonWithImage:[UIImage imageNamed:@"title_gopro_icon"] Frame:CGRectZero];
        _goPro.tintColor = [UIColor whiteColor];
        [self.view addSubview:_goPro];
        [_goPro makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@60);
            make.height.equalTo(@40);
            make.top.equalTo(self.view.top).offset(20);
            make.left.equalTo(self.view.left).offset(20);
        }];
    }
    
   
    
    UIButton * settingBtn = [[UIButton alloc]init];
    [settingBtn setImage:[UIImage imageNamed:@"setting"]forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(settingsBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingBtn];
    [settingBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@40);
        make.top.equalTo(self.view.top).offset(20);
        make.right.equalTo(self.view.right).offset(-20);
    }];

    _helpBtn = [[UIButton alloc]init];
    [_helpBtn setImage:[UIImage imageNamed:@"help"]forState:UIControlStateNormal];
    [_helpBtn addTarget:self action:@selector(helpBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_helpBtn];
    [_helpBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@40);
        make.height.equalTo(@40);
        make.bottom.equalTo(self.view.bottom).offset(-20);
        make.right.equalTo(self.view.right).offset(-20);
    }];
    
    UIButton * albumBtn = [[UIButton alloc]init];
    [albumBtn setImage:[UIImage imageNamed:@"PHOTO"]forState:UIControlStateNormal];
    [albumBtn addTarget:self action:@selector(albumBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:albumBtn];
    
    CGFloat btnWidth = self.view.bounds.size.width / 3;
    
    btnWidth = btnWidth > 250 ? 250 : btnWidth;
    
    [albumBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(btnWidth));
        make.height.equalTo(@(btnWidth));
        make.centerX.equalTo(self.view.centerX);
        make.centerY.equalTo(self.view.centerY).multipliedBy(0.6);
    }];
    
    UIButton * cameraBtn = [[UIButton alloc]init];
    [cameraBtn setImage:[UIImage imageNamed:@"CAMERA"]forState:UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(cameraBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraBtn];
    [cameraBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(btnWidth));
        make.height.equalTo(@(btnWidth));
        make.centerX.equalTo(self.view.centerX);
        make.centerY.equalTo(self.view.centerY).multipliedBy(1.2);
    }];
    
}

#pragma mark - 广告刷新
-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    [_helpBtn updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.bottom).offset(-(20+contentInsets.bottom));
    }];
}

#pragma mark - actions

-(void)helpBtnClick:(UIButton *)sender{
    CIGuideViewController * guide = [[CIGuideViewController alloc]init];
    UINavigationController * naiv = [[UINavigationController alloc]initWithRootViewController:guide];
    naiv.navigationBar.barTintColor = [UIColor colorWithHexString:@"1d1d1d"];
    naiv.navigationBar.tintColor = [UIColor whiteColor];
    [self presentViewController:naiv animated:YES completion:nil];
}

-(void)settingsBtnClick:(UIButton *)sender{
    CISettingsViewController * settings = [[CISettingsViewController alloc]init];
    UINavigationController * naiv = [[UINavigationController alloc]initWithRootViewController:settings];
    naiv.navigationBar.barTintColor = [UIColor colorWithHexString:@"1d1d1d"];
    naiv.navigationBar.tintColor = [UIColor whiteColor];
    [self presentViewController:naiv animated:YES completion:nil];
}

-(void)albumBtnClick:(UIButton *)sender{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (PHAuthorizationStatusAuthorized == status) {
                    dispatch_async(dispatch_get_main_queue(), ^{                        
                        [self pickerImageFromType:CIImagePickerTypeAlbum];
                    });
                }
            }];
        }
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
            [self authorizationStatusDeniedAlertViewType:CIImagePickerTypeAlbum];
            break;
        case PHAuthorizationStatusAuthorized:
            [self pickerImageFromType:CIImagePickerTypeAlbum];
            break;
            
        default:
            break;
    }
}

-(void)cameraBtnClick:(UIButton *)sender{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {//相机权限
                if (granted) {
                    [self pickerImageFromType:CIImagePickerTypeCamera];
                }
            }];
        }
            break;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            [self authorizationStatusDeniedAlertViewType:CIImagePickerTypeCamera];
            break;
        case AVAuthorizationStatusAuthorized:
            [self pickerImageFromType:CIImagePickerTypeCamera];
            break;
        default:
            break;
    }
}

#pragma imagePicker


-(void)authorizationStatusDeniedAlertViewType:(CIImagePickerType)type{
    
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

-(BOOL)pickerImageFromType:(CIImagePickerType)type{
    
    UIImagePickerControllerSourceType sourceType = type == CIImagePickerTypeAlbum ?UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeCamera;
    BOOL success = [UIImagePickerController isSourceTypeAvailable:sourceType];
    if (success == NO ) {
         return NO;
    }
    
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.navigationBar.barTintColor = [UIColor colorWithHexString:@"1d1d1d"];
    self.imagePicker.navigationBar.tintColor = [UIColor whiteColor];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = sourceType;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    self.imagePicker.allowsEditing = NO;
    NSDictionary * attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.imagePicker.navigationBar.titleTextAttributes = attributes;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    return YES;
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *resultImage;
    
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            resultImage = editedImage;
        } else {
            resultImage = originalImage;
        }
    }
    
    if (self.imagePicker) {
        [self.imagePicker dismissViewControllerAnimated:NO completion:nil];
        self.imagePicker = nil;
    }
    PhotoTweaksViewController *photoTweaksViewController = [[PhotoTweaksViewController alloc] initWithImage:resultImage];
    photoTweaksViewController.delegate = self;
    photoTweaksViewController.autoSaveToLibray = YES;
    photoTweaksViewController.maxRotationAngle = M_PI;
    
    UINavigationController * navi = [[UINavigationController alloc]initWithRootViewController:photoTweaksViewController];
    navi.navigationBar.barTintColor = [UIColor colorWithHexString:@"1d1d1d"];
    navi.navigationBar.tintColor = [UIColor whiteColor];
    navi.modalPresentationStyle = UIModalPresentationCustom;
    navi.transitioningDelegate = [CustomAnimatedDelegate sharedInstance];
    
    [self presentViewController:navi animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    self.imagePicker = nil;
}


- (void)photoTweaksController:(PhotoTweaksViewController *)controller didFinishWithCroppedImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    UIImage * properImage = [self getProperResizedImage:croppedImage];
    CICutoutImageViewController * cutoutImageVC = [[CICutoutImageViewController alloc]initWithImage:properImage];
    
    [self presentViewController:cutoutImageVC animated:YES completion:nil];
    
}

- (void)photoTweaksControllerDidCancel:(PhotoTweaksViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 压缩图片


///图片最大宽度为1024
-(UIImage *)getProperResizedImage:(UIImage*)original{
    float ratio = original.size.width/original.size.height;
    
    if(original.size.width > original.size.height){
        if(original.size.width > 1024){
            return [self resizeWithRotation:original size:CGSizeMake(1024, 1024/ratio)];
        }
    }else{
        if(original.size.height > 1024){
            return [self resizeWithRotation:original size:CGSizeMake(1024*ratio, 1024)];
        }
    }
    return original;
}

static inline double radians2 (double degrees) {return degrees * M_PI/180;}

-(UIImage*)resizeWithRotation:(UIImage *) sourceImage size:(CGSize) targetSize
{
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }
    
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, radians2(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, radians2(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, radians2(-180.));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage;
}

#pragma mark - 去广告通知
-(void)removeAdNotification:(NSNotification *)notification{
    [super removeAdNotification:notification];
    self.goPro.hidden = YES;
    self.goPro = nil;
}

@end
