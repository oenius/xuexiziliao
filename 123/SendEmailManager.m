//
//  SendEmailManager.m
//  TestArchive
//
//  Created by mayuan on 13-3-9.
//  Copyright (c) 2013年 mayuan. All rights reserved.
//

#import "SendEmailManager.h"
#import "SettingsLocalizeUtil.h"
#import "Macros.h"
#import "MBProgressHUD.h"
#import "NPCommonConfig.h"


@implementation SendEmailManager
static SendEmailManager *sharedInstance = nil;

+(SendEmailManager *)sharedInstance{
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
    
}

+(id)allocWithZone:(NSZone *)zone{
    return [SendEmailManager sharedInstance];
}


-(id) init{
    if (sharedInstance) {
        return sharedInstance;
    }
    return [super init];
}


// dataArray's item is dictionary which contains  data, filename,
-(BOOL)checkEmailBasement{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        if ([mailClass canSendMail]) {
            return YES;
        }else{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:"]];
//            NSURL* mailURL = [NSURL URLWithString:@"message://"];
//            if ([[UIApplication sharedApplication] canOpenURL:mailURL]) {
//                [[UIApplication sharedApplication] openURL:mailURL];
//            }
            
            return NO;
            NSString *okStr = [SettingsLocalizeUtil localizedStringForKey:@"Sure" withDefault:@"OK"];
            NSString *emailCannotUseMsg = [SettingsLocalizeUtil localizedStringForKey:@"sendPhoto.System messages was unable to send the email.Please esnure that the email account is valid." withDefault:@"Unable to send email, Please activiate your mail service."];
            
            UIViewController *topController = [UIApplication sharedApplication].delegate.window.rootViewController;
            while (topController.presentedViewController)
            {
                topController = topController.presentedViewController;
            }
            
            if ([UIAlertController class] && topController)
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:emailCannotUseMsg preferredStyle:UIAlertControllerStyleAlert];
                
                //rate action
                [alert addAction:[UIAlertAction actionWithTitle:okStr style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
                }]];
                
                [topController presentViewController:alert animated:YES completion:NULL];
                
            }else{
                UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:nil message:emailCannotUseMsg delegate:nil
                                                       cancelButtonTitle:okStr otherButtonTitles:nil];
                [dialog show];
            }
        }
    }else{
    }
    return NO;
}


-(void)sendFadebackEmail:(NSString *)subject{
    if ([self checkEmailBasement]) {
        MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
        mailPicker.mailComposeDelegate = self;
        //设置主题
        [mailPicker setSubject:subject];    // eMail主题
        NSString *fadebackEmail = [NPCommonConfig shareInstance].fadebackEmail;
        NSAssert(fadebackEmail != nil, @"fadeback email address cann't be nil");
        NSArray *toRecipients = [NSArray arrayWithObject:fadebackEmail];
        [mailPicker setToRecipients: toRecipients];
        
        NSString *emailBody = @"";//正文 should add text
        [mailPicker setMessageBody:emailBody isHTML:YES];
        
        [[self topMostController] presentViewController:mailPicker animated:YES completion:nil];
    }
}


-(void)sendEmailWithSubject:(NSString *)subject bodyContent:(NSString *)bodyContent{
    if ([self checkEmailBasement]) {
        MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
        mailPicker.mailComposeDelegate = self;
        //设置主题
        [mailPicker setSubject:subject];    // eMail主题
        
        NSString *emailBody = bodyContent;//正文 should add text
        [mailPicker setMessageBody:emailBody isHTML:YES];
        [[self topMostController] presentViewController:mailPicker animated:YES completion:nil];
    }
}


- (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}


#pragma -mark MFMessageComposeViewControllerDelegate
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"邮件发送取消");
            break;
        case MFMailComposeResultSaved:
//            [Toast toastWithMessage:NSLocalizedString(@"Save success", @"Save success")];
            NSLog(@"邮件保存成功");
            break;
        case MFMailComposeResultSent:{
//                NSLog(@"邮件发送成功");
            NSString *sendSuccessStr = [SettingsLocalizeUtil localizedStringForKey:@"email.send email successful" withDefault:@"Email sent successfully"];
            [self showTipViewWithMessage:sendSuccessStr];
        }
            break;
        case MFMailComposeResultFailed:{
            NSLog(@"邮件发送失败");
            NSString *sendSuccessStr = [SettingsLocalizeUtil localizedStringForKey:@"email.send email failed" withDefault:@"Failed to send Email"];
            [self showTipViewWithMessage:sendSuccessStr];

        }
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)showTipViewWithMessage:(NSString *)message {
    UIView *view = [UIApplication sharedApplication].delegate.window;

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
//    // YES代表需要蒙版效果
//    hud.dimBackground = YES;
    // 1秒之后再消失
    [hud hideAnimated:YES afterDelay:1];
}

//-(void)launchMailAppOnDevice
// {
//     NSString *recipients = @"np2016.ant@gmail.com";
//    //@"mailto:first@example.com?cc=second@example.com,third@example.com&subject=my email!";
//     NSString *body = @"&body=email body!";
//    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
//     email = [email stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
//  
//    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:email]];
// }

@end
