//
//  SendEmailManager.h
//  TestArchive
//
//  Created by mayuan on 13-3-9.
//  Copyright (c) 2013年 mayuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>




@interface SendEmailManager : NSObject<MFMailComposeViewControllerDelegate>


+(SendEmailManager *)sharedInstance;

-(BOOL)checkEmailBasement;

-(void)sendFadebackEmail:(NSString *)subject;

-(void)sendEmailWithSubject:(NSString *)subject bodyContent:(NSString *)bodyContent;

@end
