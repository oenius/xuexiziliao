//
//  EditViewController+Photo.m
//  InstaMessage
//
//  Created by 何少博 on 16/8/1.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "EditViewController+Photo.h"
#import "UIColor+x.h"
#import "UIImage+ImageEffects.h"
#import "MBProgressHUD.h"
#import <Photos/Photos.h>
#import "NPCommonConfig.h"
@implementation EditViewController (Photo)
-(void)initPhotoContentView{
    self.photoContentView = [PotoContentView viewWithNib:@"PotoContentView" owner:nil];
    self.photoContentView.frame = self.editOptionsBackGroundView.bounds;
    self.photoContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.photoContentView.delegate = self;
    [self.editOptionsBackGroundView addSubview:self.photoContentView];
}

#pragma mark - PotoContentViewDelegate

-(void)potoContentView:(PotoContentView *)potoContentView duiBiDuValue:(CGFloat)value{
    if (!self.blackgroundImageView.image) return;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.editPreviewBackGroundView animated:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CIContext * context = [CIContext contextWithOptions:nil];
        CIImage * image = [CIImage imageWithCGImage:self.blackGroundImageViewTempImage.CGImage];//我们要编辑的图像
        CIFilter * colorControlsFilter = [CIFilter filterWithName:@"CIColorControls"];//色彩滤镜
        [colorControlsFilter setValue:image forKey:@"inputImage"];
        [colorControlsFilter setValue:[NSNumber numberWithFloat:value] forKey:@"inputContrast"];
        UIImage * newImage =  [self setImage:colorControlsFilter context:context];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.blackgroundImageView.image = newImage;
            [hud hideAnimated:YES];
        });
    });
}
-(void)potoContentView:(PotoContentView *)potoContentView baoHeDuValue:(CGFloat)value{
    if (!self.blackgroundImageView.image) return;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.editPreviewBackGroundView animated:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CIContext * context = [CIContext contextWithOptions:nil];
        CIImage * image = [CIImage imageWithCGImage:self.blackGroundImageViewTempImage.CGImage];//我们要编辑的图像
        CIFilter * colorControlsFilter = [CIFilter filterWithName:@"CIColorControls"];//色彩滤镜
        [colorControlsFilter setValue:image forKey:@"inputImage"];
        [colorControlsFilter setValue:[NSNumber numberWithFloat:value] forKey:@"inputSaturation"];
        
        UIImage * newImage =  [self setImage:colorControlsFilter context:context];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.blackgroundImageView.image = newImage;
            [hud hideAnimated:YES];
        });
    });
}
-(void)potoContentView:(PotoContentView *)potoContentView liangDuValue:(CGFloat)value{
    if (!self.blackgroundImageView.image) return;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.editPreviewBackGroundView animated:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CIContext * context = [CIContext contextWithOptions:nil];
        CIImage * image = [CIImage imageWithCGImage:self.blackGroundImageViewTempImage.CGImage];//我们要编辑的图像
        CIFilter * colorControlsFilter = [CIFilter filterWithName:@"CIColorControls"];//色彩滤镜
        [colorControlsFilter setValue:image forKey:@"inputImage"];
        [colorControlsFilter setValue:[NSNumber numberWithFloat:value] forKey:@"inputBrightness"];
        
        UIImage * newImage =  [self setImage:colorControlsFilter context:context];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.blackgroundImageView.image = newImage;
            [hud hideAnimated:YES];
        });
    });
}
-(void)potoContentView:(PotoContentView *)potoContentView maoBoLiValue:(CGFloat)value{
    if (!self.blackgroundImageView.image) return;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.editPreviewBackGroundView animated:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage * newImage = [self.blackGroundImageViewTempImage applyDarkEffectBlurWithRadius:value*30];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.blackgroundImageView.image = newImage;
            [hud hideAnimated:YES];
        });
    });
}
-(void)potoContentView:(PotoContentView *)potoContentView actionWithTag:(PhotoActionTag)tag{
    
    switch (tag) {
            
        case PhotoAction_Camera:
        {
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            switch (status) {
                case AVAuthorizationStatusNotDetermined:
                {
                    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {//相机权限
                        if (granted) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self presentImagePickerController:UIImagePickerControllerSourceTypeCamera];
                            });
                        }
                    }];
                }
                    break;
                case AVAuthorizationStatusRestricted:
                case AVAuthorizationStatusDenied:
                    [self authorizationStatusDeniedAlertViewType:UIImagePickerControllerSourceTypeCamera];
                    break;
                case AVAuthorizationStatusAuthorized:
                    [self presentImagePickerController:UIImagePickerControllerSourceTypeCamera];
                    break;
                default:
                    break;
            }

            self.bannerView.hidden = NO;
        }
            break;
        case PhotoAction_Album:
        {

            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            switch (status) {
                case PHAuthorizationStatusNotDetermined:
                {
                    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                        if (PHAuthorizationStatusAuthorized == status) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self presentImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary];
                            });
                        }
                    }];
                }
                    break;
                case PHAuthorizationStatusRestricted:
                case PHAuthorizationStatusDenied:
                    [self authorizationStatusDeniedAlertViewType:UIImagePickerControllerSourceTypePhotoLibrary];
                    break;
                case PHAuthorizationStatusAuthorized:
                    [self presentImagePickerController:UIImagePickerControllerSourceTypePhotoLibrary];
                    break;
                    
                default:
                    break;
            }
            self.bannerView.hidden = NO;
        }
            break;
        case PhotoAction_UpDown:
            self.bannerView.hidden = NO;
            self.blackGroundImageViewSupView.transform = CGAffineTransformScale(self.blackGroundImageViewSupView.transform, 1.0, -1.0);
            self.beiFanZhuan = !self.beiFanZhuan;
            break;
        case PhotoAction_LeftRight:
            self.bannerView.hidden = NO;
            self.blackGroundImageViewSupView.transform = CGAffineTransformScale(self.blackGroundImageViewSupView.transform, -1.0, 1.0);
            self.beiFanZhuan = !self.beiFanZhuan;
            break;
        case PhotoAction_Ads:
            self.bannerView.hidden = NO;
            [self addQuanPingADS];
            
            
            break;
        default:
            self.bannerView.hidden = YES;
            break;
    }
}

-(UIImage *)setImage:(CIFilter *)colorControlsFilter context:(CIContext *)context{
    CIImage *outputImage= [colorControlsFilter outputImage];//取得输出图像
    CGImageRef temp=[context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage * newImage = [UIImage imageWithCGImage:temp];
    CGImageRelease(temp);
    return newImage;
}

#pragma mark camera utility

-(void)authorizationStatusDeniedAlertViewType:(UIImagePickerControllerSourceType)type{
    
    NSString *appName = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleName"];
    NSString *tipsString ;
    if (type == UIImagePickerControllerSourceTypePhotoLibrary) {
        tipsString =NSLocalizedString(@"You disabled access, please go to Settings-> Privacy->Photos to set up access", @"You disabled access, please go to Settings-> Privacy->Photos to set up access");
    }else{
        tipsString =[NSString stringWithFormat:NSLocalizedString(@"newAPPname.camera.Allow Camory to access camera", @"Please allow %1@ to access camera in Settings-Privacy-Camera-%2@(Turn on)."),appName,appName];
    }
    UIAlertController * alertCon = [UIAlertController alertControllerWithTitle:nil message:tipsString preferredStyle:(UIAlertControllerStyleAlert)];

    UIAlertAction * cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"common.Cancel", @"Cancel") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction * done = [UIAlertAction actionWithTitle:NSLocalizedString(@"Setting", @"Setting") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        NSURL * settingUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication]canOpenURL:settingUrl]) {
            [[UIApplication sharedApplication]openURL:settingUrl];
        }
    }];
    
    [alertCon addAction:cancel];
    [alertCon addAction:done];
    [self presentViewController:alertCon animated:YES completion:nil];
}

-(void)presentImagePickerController:(UIImagePickerControllerSourceType)sourceType{
    
    BOOL success = [UIImagePickerController isSourceTypeAvailable:sourceType];
    if (success == NO ) {
        return ;
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.navigationBar.barTintColor = color_2083fc;
    imagePicker.navigationBar.tintColor = [UIColor whiteColor];
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePicker.allowsEditing = NO;
    NSDictionary * attri = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    imagePicker.navigationBar.titleTextAttributes = attri;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)addAlertViewController_OK_NothingWithMessage:(NSString *)messsage;{
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:messsage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:ok];
    [self presentViewController:alertVC animated:YES completion:nil];
    
}
-(void)addQuanPingADS{
    if ([[NPCommonConfig shareInstance] shouldShowAdvertise]) {
        [[NPCommonConfig shareInstance] showFullScreenAdORNativeAdForController:self];
    }
}

@end
