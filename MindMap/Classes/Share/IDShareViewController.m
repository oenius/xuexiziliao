//
//  IDShareViewController.m
//  IDPhoto
//
//  Created by 何少博 on 17/5/2.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDShareViewController.h"
#import <Photos/Photos.h>
#import "MBProgressHUD.h"
#import "UIAlertController+SN.h"
@interface IDShareViewController ()

@property (nonatomic,strong) UIImage * oriImage;

@property (weak, nonatomic) IBOutlet UIView *btnContentView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIButton *printBtn;

@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@property (weak, nonatomic) IBOutlet UIButton *shareBtn;




@end

@implementation IDShareViewController

-(instancetype)initWithImage:(UIImage *)image{
    self = [super initWithNibName:@"IDShareViewController" bundle:nil];
    if (self) {
        self.oriImage = image;
    }
    return self;
}

#pragma mark - 视图生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = self.oriImage;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"fanhui"] style:(UIBarButtonItemStylePlain) target:self action:@selector(goHome)];
}




#pragma mark - button actioins

-(void)goHome{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareBtnClick:(id)sender {
    NSArray *activityItem = [NSArray arrayWithObject:self.oriImage];
    UIActivityViewController *activity = [[UIActivityViewController alloc]
                                          initWithActivityItems:activityItem
                                          applicationActivities:nil];
    UIPopoverPresentationController *popoverVC = activity.popoverPresentationController;
    activity.completionWithItemsHandler = ^(UIActivityType  activityType, BOOL completed, NSArray *  returnedItems, NSError *  activityError){
        if (completed) {
            [self delayTimeShowAD:1.5];
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
    
}
-(void)printActionsbutton:(id)sender{
//    paperSize = CGSizeMake(595, 880)
    UIImage * printImage = self.oriImage;
    
    UIPrintInteractionController *printC = [UIPrintInteractionController sharedPrintController];
    printC.showsNumberOfCopies = YES;
    printC.showsPageRange = YES;
    NSData *imgDate = UIImagePNGRepresentation(printImage);
    NSData *data = [NSData dataWithData:imgDate];
    if (printC && [UIPrintInteractionController canPrintData:data]) {
        UIPrintInfo *printInfo = [UIPrintInfo printInfo];
        printInfo.outputType = UIPrintInfoOutputPhoto;
        printC.showsPageRange = YES;
        
        printC.printInfo = printInfo;
        printC.printingItem = data;
        
        // 等待完成
        void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
        ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
            if (!completed && error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIAlertController alertMessage:error.localizedDescription controller:self okHandler:^(UIAlertAction *okAction) {
                        return ;
                    }];
                });
            }
        };
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:sender];
            [printC presentFromBarButtonItem:item animated:YES completionHandler:completionHandler];
        } else {
            [printC presentAnimated:YES completionHandler:completionHandler];
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

-(void)saveImageToAlbum{
    UIImageWriteToSavedPhotosAlbum(self.oriImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSLog(@"%@",error);
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    if (!error) {
        hud.label.text = NSLocalizedString(@"BB_Minecraft_successs", @"");
    }else{
        hud.label.text = NSLocalizedString(@"common.Failed to save", @"");
    };
    [hud hideAnimated:YES afterDelay:1];
    [self delayTimeShowAD:1];
    
}



-(void)authorizationStatusDeniedAlertView{
    UIAlertController * alertCon = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"layout_tips", @"") message:NSLocalizedString(@"Failed to get the album permissions, please go to the system settings to open", @"") preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction * done = [UIAlertAction actionWithTitle:NSLocalizedString(@"SetPage", @"") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
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
    return YES;
}
-(BOOL)needLoadNativeAdView{
    return NO;
}
-(void)showNativeAdView:(UIView *)nativeAdView{
    CGRect frame = nativeAdView.frame;
    frame.origin.y = self.view.bounds.size.height - frame.size.height;
    frame.origin.x = 0;
    nativeAdView.frame = frame;
    [self.view addSubview:nativeAdView];
}
-(void)delayTimeShowAD:(CGFloat) time{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SNTools showADRandom:1 forController:self];
    });
}

@end
