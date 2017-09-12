//
//  IDShareViewController.m
//  IDPhoto
//
//  Created by 何少博 on 17/5/2.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDShareViewController.h"
#import <Photos/Photos.h>
#import <SVProgressHUD.h>
#import "NPCommonConfig.h"
@interface IDShareViewController ()

@property (nonatomic,strong) UIImage * oriImage;

@property (weak, nonatomic) IBOutlet UIView *btnContentView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIButton *printBtn;

@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@property (strong,nonatomic) NSString * idType;




@end

@implementation IDShareViewController

-(instancetype)initWithImage:(UIImage *)image withIdType:(NSString *)idType{
    self = [super initWithNibName:@"IDShareViewController" bundle:nil];
    if (self) {
        self.oriImage = image;
        self.idType = idType;
    }
    return self;
}

#pragma mark - 视图生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = self.oriImage;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"home"] style:(UIBarButtonItemStylePlain) target:self action:@selector(goHome)];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#2c2e30"];
    self.btnContentView.backgroundColor = [UIColor colorWithHexString:@"#2c2e30"];
}


-(UIImage *)getProperSizeImage{
    UIImage * scaleImage = [self.oriImage imageToScale:1];
    CGSize properSize = [self getImageSizeWithType:self.idType];
    scaleImage = [scaleImage jk_resizedImage:properSize interpolationQuality:(kCGInterpolationHigh)];
    return scaleImage;
}

#pragma mark - button actioins

-(void)goHome{
//    UIViewController * jjj = self.navigationController.childViewControllers[2];
//    [self.navigationController popToViewController:jjj animated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)shareBtnClick:(id)sender {
    NSArray *activityItem = [NSArray arrayWithObject:[self getProperSizeImage]];
    UIActivityViewController *activity = [[UIActivityViewController alloc]
                                          initWithActivityItems:activityItem
                                          applicationActivities:nil];
    UIPopoverPresentationController *popoverVC = activity.popoverPresentationController;
    activity.completionWithItemsHandler = ^(UIActivityType  activityType, BOOL completed, NSArray *  returnedItems, NSError *  activityError){
        if (completed) {
            [self delayTimeShowAD:1];
        }
    };
    
    if (popoverVC) {
        popoverVC.sourceView = self.shareBtn;
        popoverVC.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController:activity animated:YES completion:nil];
}
- (IBAction)printBtnClick:(id)sender {
    [self printActionsbutton:sender];
    //-------------------------------------------------------------------
//    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
//    if(!controller){
//        NSLog(@"Couldn't get shared UIPrintInteractionController!");
//        return;
//    }
//    // We need a completion handler block for printing.
//    UIPrintInteractionCompletionHandler completionHandler = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
//        if(completed && error)
//            NSLog(@"FAILED! due to error in domain %@ with error code %u", error.domain, error.code);
//    };
//    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
//    UIImage *image = self.oriImage;
//    printInfo.outputType = UIPrintInfoOutputPhoto;
//    printInfo.jobName = @"fdfd";
//    if(!controller.printingItem && image.size.width > image.size.height)
//        printInfo.orientation = UIPrintInfoOrientationLandscape;
//    controller.printInfo = printInfo;
//    controller.printingItem = nil;
//    
//    if(!controller.printingItem){
//        UIPrintPageRenderer *pageRenderer = [[UIPrintPageRenderer alloc]init];
//        pageRenderer.printFormatters = @[image];
//        controller.printPageRenderer = pageRenderer;
//    }
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        [controller presentFromRect:self.printBtn.bounds inView:self.printBtn animated:YES completionHandler:completionHandler];
//    }else
//        [controller presentAnimated:YES completionHandler:completionHandler];  // iPhone
    //-------------------------------------------------------------------
//    NSURL *fileURL = document.fileURL; // Document file URL
    
//    if ([UIPrintInteractionController canPrintURL:fileURL] == YES)
//    {
//        printInteraction = [UIPrintInteractionController sharedPrintController];
//        
//        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
//        printInfo.duplex = UIPrintInfoDuplexLongEdge;
//        printInfo.outputType = UIPrintInfoOutputGeneral;
//        printInfo.jobName = document.fileName;
//        
//        printInteraction.printInfo = printInfo;
//        printInteraction.printingItem = fileURL;
//        printInteraction.showsPageRange = YES;
//        
//        if (userInterfaceIdiom == UIUserInterfaceIdiomPad) // Large device printing
//        {
//            [printInteraction presentFromRect:button.bounds inView:button animated:YES completionHandler:
//             ^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
//             {
//#ifdef DEBUG
//                 if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
//#endif
//             }
//             ];
//        }
//        else // Handle printing on small device
//        {
//            [printInteraction presentAnimated:YES completionHandler:
//             ^(UIPrintInteractionController *pic, BOOL completed, NSError *error)
//             {
//#ifdef DEBUG
//                 if ((completed == NO) && (error != nil)) NSLog(@"%s %@", __FUNCTION__, error);
//#endif
//             }
//             ];
//        }
//    }
}
-(void)printActionsbutton:(id)sender{
    //获取要打印的图片
    UIImage * printImage = [self getProperSizeImage];
    //剪切原图（824 * 2235）  这里需要说明下 因为A4 纸的72像素的 大小是（595，824） 为了打印出A4 纸 之类把原图转化成A4 的宽度，高度可适当调高 以适应页面内容的需求 ，调这个很简单地，打开你目前截取的图片，点击工具，然后点击调整大小，把宽度设置成595 就可以了，看高度是多少 除以 824 就是 几页 ，不用再解释了吧。。。ios打印功能实现（ScrollerView打印）
//    UIImage * scanImage = [self scaleToSize:printImage size:CGSizeMake(595, 1660)];
//    
//    UIImage *jietuImage = [self imageFromImage:scanImage inRect:CGRectMake(0, 0, 595, 880)];
    
    UIPrintInteractionController *printC = [UIPrintInteractionController sharedPrintController];//显示出打印的用户界面。
//    printC.delegate = self;
    
    if (!printC) {
        [SVProgressHUD showErrorWithStatus:nil];
        [SVProgressHUD dismissWithDelay:1.5];
//        [self showAlertView:@"初始化失败"];
    }
    printC.showsNumberOfCopies = YES;
    printC.showsPageRange = YES;
    NSData *imgDate = UIImagePNGRepresentation(printImage);
    NSData *data = [NSData dataWithData:imgDate];
    if (printC && [UIPrintInteractionController canPrintData:data]) {
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];//准备打印信息以预设值初始化的对象。
        printInfo.outputType = UIPrintInfoOutputPhoto;//设置输出类型。
        printC.showsPageRange = YES;//显示的页面范围
        
        //printInfo.jobName = @"my.job";
        printC.printInfo = printInfo;
        printC.printingItem = data;//single NSData, NSURL, UIImage, ALAsset
        
        // 等待完成
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
        ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            if (!completed && error) {
                [self runAsyncOnMainThread:^{
                    [SVProgressHUD showErrorWithStatus:nil];
                    [SVProgressHUD dismissWithDelay:1.5];
                }];
            }
        };
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:sender];//调用方法的时候，要注意参数的类型－下面presentFromBarButtonItem:的参数类型是 UIBarButtonItem..如果你是在系统的UIToolbar or UINavigationItem上放的一个打印button，就不需要转换了。
            [printC presentFromBarButtonItem:item animated:YES completionHandler:completionHandler];//在ipad上弹出打印那个页面
        } else {
            [printC presentAnimated:YES completionHandler:completionHandler];//在iPhone上弹出打印那个页面
        }
    }
}
- (IBAction)saveBtnClick:(id)sender {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (PHAuthorizationStatusAuthorized == status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self saveImageToAlbum];
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
            [self saveImageToAlbum];
            break;
            
        default:
            break;
    }
}
// Adds a photo to the saved photos album.  The optional completionSelector should have the form:
//  - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
-(void)saveImageToAlbum{
    UIImage * scaleImage = [self getProperSizeImage];
    UIImageWriteToSavedPhotosAlbum(scaleImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSLog(@"%@",error);
    if (!error) {
        [SVProgressHUD showSuccessWithStatus:[IDConst instance].MsgSuccess];
    }else{
        [SVProgressHUD showErrorWithStatus:[IDConst instance].FailedSave];
    };
    [SVProgressHUD dismissWithDelay:1.5];
    [self delayTimeShowAD:1.5];
    
}



-(void)authorizationStatusDeniedAlertView{
    
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

-(BOOL)needLoadBannerAdView{
    return NO;
}
-(BOOL)needLoadNativeAdView{
    return YES;
}
-(void)showNativeAdView:(UIView *)nativeAdView{
    CGRect frame = nativeAdView.frame;
    frame.origin.y = self.view.bounds.size.height - frame.size.height;
    frame.origin.x = 0;
    nativeAdView.frame = frame;
    [self.view addSubview:nativeAdView];
}
-(void)delayTimeShowAD:(CGFloat) time{
    if (![[NPCommonConfig shareInstance] shouldShowAdvertise]) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NPCommonConfig shareInstance]showFullScreenAdWithNativeAdAlertViewForController:self];
    });
}

@end
