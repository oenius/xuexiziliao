//
//  CIAddBackGroundToolView.m
//  CutoutImage
//
//  Created by 何少博 on 17/2/14.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "CIAddBackGroundToolView.h"
#import "UIColor+x.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
@interface CIAddBackGroundToolView ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic,strong) UIButton *backGroundButton;

@property (nonatomic,strong) UIButton *alphaButton;

@property (nonatomic,strong) UIView *contentView;

@property (nonatomic,strong) UISlider *alphaSlider;

@property (nonatomic,strong) UIButton *cameraButton;

@property (nonatomic,strong) UIButton *albumButton;


@end

@implementation CIAddBackGroundToolView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubview];
    }
    return self;
}

-(void)setupSubview{
    self.backgroundColor = [UIColor colorWithHexString:@"1d1d1d"];
    self.backGroundButton = [[UIButton alloc]init];
    [self addSubview:_backGroundButton];
    [_backGroundButton setTitle:CI_Background forState:UIControlStateNormal];
    [_backGroundButton setBackgroundColor:[UIColor colorWithHexString:@"f08d33"]];
    [_backGroundButton addTarget:self action:@selector(backGroundButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.alphaButton = [[UIButton alloc]init];
    [self addSubview:_alphaButton];
    [_alphaButton setBackgroundColor:[UIColor colorWithHexString:@"1d1d1d"]];
    [_alphaButton setTitle:CI_myAlpha forState:UIControlStateNormal];
    [_alphaButton addTarget:self action:@selector(alphaButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.contentView = [[UIView alloc]init];
    [self addSubview:_contentView];
    
    self.cameraButton = [[UIButton alloc]init];
    [self.contentView addSubview:self.cameraButton];
    [self.cameraButton setImage:[UIImage imageNamed:@"CAMERA"]forState:UIControlStateNormal];
    
    [self.cameraButton addTarget:self action:@selector(cameraButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.albumButton = [[UIButton alloc]init];
    [self.contentView addSubview:self.albumButton];
    [self.albumButton setImage:[UIImage imageNamed:@"PHOTO"] forState:UIControlStateNormal];
    [self.albumButton addTarget:self action:@selector(albumButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.alphaSlider = [[UISlider alloc]init];
    [self.contentView addSubview:self.alphaSlider];
    self.alphaSlider.maximumValue = 1.0;
    self.alphaSlider.minimumValue = 0.0;
    self.alphaSlider.value = 1.0;
    [self.alphaSlider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat buttonHeight = 40;
    self.backGroundButton.frame = CGRectMake(0, 0, width/2, buttonHeight);
    self.alphaButton.frame = CGRectMake(width/2, 0, width/2, buttonHeight);
    CGFloat contentViewHeight = height-buttonHeight;
    self.contentView.frame = CGRectMake(0, buttonHeight, width*2, contentViewHeight);
    self.cameraButton.frame = CGRectMake(0, 0, contentViewHeight/2, contentViewHeight/2);
    self.cameraButton.center = CGPointMake(width/4, contentViewHeight/2);
    self.albumButton.frame = CGRectMake(0, 0, contentViewHeight/2, contentViewHeight/2);
    self.albumButton.center = CGPointMake(width/4*3, contentViewHeight/2);
    self.alphaSlider.frame = CGRectMake(width, 0, width-30, 30);
    self.alphaSlider.center = CGPointMake(width*1.5, contentViewHeight/2);
}

#pragma mark - button acions 


-(void)backGroundButtonClick{
    _backGroundButton.backgroundColor = [UIColor colorWithHexString:@"f08d33"];
    _alphaButton.backgroundColor = [UIColor colorWithHexString:@"1d1d1d"];
    CGRect frame = self.contentView.frame;
    frame.origin.x = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.frame = frame;
    }];
}

-(void)alphaButtonClick{
    _backGroundButton.backgroundColor = [UIColor colorWithHexString:@"1d1d1d"];
    _alphaButton.backgroundColor = [UIColor colorWithHexString:@"f08d33"];
    CGFloat width = self.bounds.size.width;
    CGRect frame = self.contentView.frame;
    frame.origin.x = -width;
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.frame = frame;
    }];
}

-(void)cameraButtonClick{
    
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
    
}

-(void)albumButtonClick{
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
}


-(void)authorizationStatusDeniedAlertViewType:(UIImagePickerControllerSourceType)type{
    
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
    UIViewController * viewController = [self topMostController];
    [viewController presentViewController:alertCon animated:YES completion:nil];
}

-(void)sliderValueChanged{
    if ([self.delegate respondsToSelector:@selector(alphaValueChanged:)]) {
        [self.delegate alphaValueChanged:self.alphaSlider.value];
    }
}

-(void)presentImagePickerController:(UIImagePickerControllerSourceType)sourceType{
    
    BOOL success = [UIImagePickerController isSourceTypeAvailable:sourceType];
    if (success == NO ) {
        return ;
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePicker.allowsEditing = NO;
    UIViewController * presentViewController = [self topMostController];
    NSDictionary * attri = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    imagePicker.navigationBar.titleTextAttributes = attri;
    [presentViewController presentViewController:imagePicker animated:YES completion:nil];
}

#pragma  mark - imagePickeDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *resultImage;
    
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            resultImage = editedImage;
        } else {
            resultImage = originalImage;
        }
    }
    
    if (picker) {
        [picker dismissViewControllerAnimated:NO completion:nil];
        picker = nil;
    }
    
    if ([self.delegate respondsToSelector:@selector(imageDidChoosed:)]) {
        [self.delegate imageDidChoosed:resultImage];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
    picker = nil;
}

- (UIViewController*)topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}



@end
