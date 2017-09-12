//
//  IDPhotoChoiceViewController.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/24.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDPhotoChoiceViewController.h"
#import <Photos/Photos.h>
#import "IDCameraViewController.h"
#import "IDPhotoEditViewController.h"
#import "UINavigationController+x.h"
#import "NPCommonConfig.h"
typedef enum : NSUInteger {
    IDPhotoPickerTypeAlbum,
    IDPhotoPickerTypeCamera,
} IDPhotoPickerType;

@interface IDPhotoChoiceViewController ()<
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
IDCameraViewControllerDelegate
>

@property (nonatomic,copy) NSString * IDType;

@property (weak, nonatomic) IBOutlet UIButton *whiteBGBtn;
@property (weak, nonatomic) IBOutlet UIImageView *whiteBGSelectedImageView;

@property (weak, nonatomic) IBOutlet UIButton *blueBGBtn;
@property (weak, nonatomic) IBOutlet UIImageView *blueBGSelectedImageView;

@property (weak, nonatomic) IBOutlet UIButton *redBGBtn;
@property (weak, nonatomic) IBOutlet UIImageView *redBGSelectedImageView;


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *remindLabel1;

@property (weak, nonatomic) IBOutlet UILabel *remindLabel2;

@property (weak, nonatomic) IBOutlet UILabel *remindLabel3;

@property (weak, nonatomic) IBOutlet UIButton *albumBtn;

@property (weak, nonatomic) IBOutlet UIButton *cameraBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomCon;

@property (nonatomic,strong) UIImage * selectedImage;

@property (nonatomic,assign) IDPhotoBGType bgType;

@end

@implementation IDPhotoChoiceViewController


#pragma mark - -----

-(UIImage *)selectedImage{
    if (_selectedImage == nil) {
        _selectedImage = [UIImage imageNamed:@"choose"];;
    }
    return _selectedImage;
}

-(instancetype)initWithIDType:(NSString *)idType{
    self = [super initWithNibName:@"IDPhotoChoiceViewController" bundle:nil];
    if (self) {
        self.IDType = idType;
        self.bgType = IDPhotoBGTypeBlue;
    }
   
    return self;
}



#pragma mark - 视图生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(self.IDType, @"");
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.whiteBGBtn addGrayShadow];
    [self.blueBGBtn addGrayShadow];
    [self.redBGBtn addGrayShadow];
    [self initUI];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:(UIBarButtonItemStylePlain) target:self action:@selector(popViewCOntroller)];;
//    UIImage * backImage = [UIImage imageNamed:@"iphonebg"]; ;
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
//        backImage = [UIImage imageNamed:@"ipadbg"];
//    }
//    self.view.layer.contents = (__bridge id _Nullable)(backImage.CGImage);

}

-(void)initUI{

    self.titleLabel.text = [IDConst instance].ChooseBgColor;
    self.remindLabel1.text = [NSString stringWithFormat:@"1.%@",[IDConst instance].TakephotoOptions1];
    self.remindLabel2.text = [NSString stringWithFormat:@"2.%@",[IDConst instance].TakephotoOptions2];
    self.remindLabel3.text = [NSString stringWithFormat:@"3.%@",[IDConst instance].TakephotoOptions3];
    [self.cameraBtn setTitle:[IDConst instance].TakePhoto forState:(UIControlStateNormal)];
    [self.albumBtn setTitle:[IDConst instance].SelectFromAlbum forState:(UIControlStateNormal)];
    self.cameraBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.albumBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.titleLabel.font = [UIFont systemFontOfSize:20];
        self.remindLabel1.font = [UIFont systemFontOfSize:18];
        self.remindLabel2.font = [UIFont systemFontOfSize:18];
        self.remindLabel3.font = [UIFont systemFontOfSize:18];
        self.cameraBtn.titleLabel.font = [UIFont systemFontOfSize:25];
        self.albumBtn.titleLabel.font = [UIFont systemFontOfSize:25];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController usingTheGradient];
    [self.navigationController usingWhiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - actions

-(void)popViewCOntroller{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)whiteBGBtnClick:(UIButton *)sender {
    self.blueBGSelectedImageView.image = nil;
    self.redBGSelectedImageView.image = nil;
    self.whiteBGSelectedImageView.image = self.selectedImage;
    self.bgType = IDPhotoBGTypeWhite;
    [IDConst showADRandom:3 forController:self];
}

- (IBAction)blueBGBtnClick:(UIButton *)sender {
    self.redBGSelectedImageView.image = nil;
    self.whiteBGSelectedImageView.image = nil;
    self.blueBGSelectedImageView.image = self.selectedImage;
    self.bgType = IDPhotoBGTypeBlue;
    [IDConst showADRandom:3 forController:self];
}
- (IBAction)redBGBtnClick:(UIButton *)sender {
    self.blueBGSelectedImageView.image = nil;
    self.whiteBGSelectedImageView.image = nil;
    self.redBGSelectedImageView.image = self.selectedImage;
    self.bgType = IDPhotoBGTypeRed;
    [IDConst showADRandom:3 forController:self];
}

- (IBAction)albumBtnClick:(UIButton *)sender {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (PHAuthorizationStatusAuthorized == status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self pickerImageFromType:IDPhotoPickerTypeAlbum];
                    });
                }
            }];
        }
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
            [self authorizationStatusDeniedAlertViewType:IDPhotoPickerTypeAlbum];
            break;
        case PHAuthorizationStatusAuthorized:
            [self pickerImageFromType:IDPhotoPickerTypeAlbum];
            break;
        default:
            break;
    }
}

- (IBAction)cameraBtnClick:(UIButton *)sender {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {//相机权限
                if (granted) {
                    [self pickerImageFromType:IDPhotoPickerTypeCamera];
                }
            }];
        }
            break;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            [self authorizationStatusDeniedAlertViewType:IDPhotoPickerTypeCamera];
            break;
        case AVAuthorizationStatusAuthorized:
            [self pickerImageFromType:IDPhotoPickerTypeCamera];
            break;
        default:
            break;
    }

}

-(void)gotoEdit:(UIImage *)image{
    
    CGSize properSize = [self getImageSizeWithType:self.IDType];
    CGFloat whScale = properSize.width/properSize.height;
    CGSize imageSize = image.size;
    
    CGFloat heigth = imageSize.height;
    CGFloat width = heigth * whScale;
    CGPoint orig = CGPointMake((imageSize.width - width)/2, 0);
    if (width > imageSize.width) {
        width = imageSize.width;
        heigth = width / whScale;
        orig = CGPointMake(0, (imageSize.height - heigth)/2);
    }
    CGSize newSize = CGSizeMake(width, heigth);
    CGRect newIamgeRect= {orig,newSize};
    UIImage * newImage = [image imageClipRect:newIamgeRect];
//    newImage = [newImage jk_resizedImage:properSize interpolationQuality:(kCGInterpolationHigh)];
    IDPhotoEditViewController * editViewController =
    [[IDPhotoEditViewController alloc]initWithChiCunType:self.IDType
                                                  BGType:self.bgType
                                               editImage:newImage];
    [self.navigationController pushViewController:editViewController animated:YES];
}




#pragma mark - 图片选择

-(void)pickerImageFromType:(IDPhotoPickerType)type{
    
    if (type == IDPhotoPickerTypeCamera) {
        [self pickerPhotoFormCamera];
    }else{
        [self pickerPhotoFormAlbum];
    }
   
}

-(BOOL)pickerPhotoFormAlbum{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    BOOL success = [UIImagePickerController isSourceTypeAvailable:sourceType];
    if (success == NO ) {
        return NO;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    [imagePicker usingTheGradient];
    [imagePicker usingWhiteColor];
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
//    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage]; 默认是kUTTypeImage
    imagePicker.allowsEditing = NO;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
    return YES;
}
-(void)pickerPhotoFormCamera{
    IDCameraViewController * cameraVC = [[IDCameraViewController alloc]initWithNibName:@"IDCameraViewController" bundle:nil];
    cameraVC.delegate = self;
    [self presentViewController:cameraVC animated:YES completion:nil];
}
-(void)authorizationStatusDeniedAlertViewType:(IDPhotoPickerType)type{
    
    UIAlertController * alertCon = [UIAlertController alertControllerWithTitle:[IDConst instance].Reminder message:[IDConst instance].NoPermissions preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:[IDConst instance].Cancel style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction * done = [UIAlertAction actionWithTitle:[IDConst instance].Settings style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        NSURL * settingUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication]canOpenURL:settingUrl]) {
            [[UIApplication sharedApplication]openURL:settingUrl];
        }
    }];
    
    [alertCon addAction:cancel];
    [alertCon addAction:done];
    
    [self presentViewController:alertCon animated:YES completion:nil];
}

#pragma mark - 照片选择代理

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info{
    UIImage *originalImage, *editedImage, *resultImage;
    editedImage = (UIImage *) [info objectForKey:
                               UIImagePickerControllerEditedImage];
    originalImage = (UIImage *) [info objectForKey:
                                 UIImagePickerControllerOriginalImage];
    
    if (editedImage) {
        resultImage = editedImage;
    } else {
        resultImage = originalImage;
    }
    UIImageOrientation imageOrientation = resultImage.imageOrientation;
    if(imageOrientation != UIImageOrientationUp)
    {
        // 以下为调整图片角度的部分
        UIGraphicsBeginImageContext(resultImage.size);
        [resultImage drawInRect:CGRectMake(0, 0, resultImage.size.width, resultImage.size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    if (picker) {
        WeakSelf
        [picker dismissViewControllerAnimated:NO completion:^{ [weakSelf gotoEdit:resultImage]; }];
        picker = nil;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
   
    [picker dismissViewControllerAnimated:YES completion:^{}];
    picker = nil;
}

-(void)cameraTakePhoto:(IDCameraViewController *)cameraController didFinish:(UIImage *)image{
    WeakSelf
    [cameraController dismissViewControllerAnimated:YES completion:^{[weakSelf gotoEdit:image];}];
}

-(void)cameraDidCancel:(IDCameraViewController *)cameraController{
    [cameraController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 广告相关

-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    self.bottomCon.constant = contentInsets.bottom + 15;
    [self.view setViewLayoutAnimation];
    
}

@end
