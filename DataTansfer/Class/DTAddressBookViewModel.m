//
//  DTAddressBookViewModel.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/18.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTAddressBookViewModel.h"
#import "UIWindow+JKHierarchy.h"
@interface DTAddressBookViewModel ()

@property (nonatomic,copy) DTAuthorizationResultBlock block;


@end

@implementation DTAddressBookViewModel

-(NSArray * )fetchKeys{
    if ([CNContactStore class]){
        return @[CNContactIdentifierKey,
                 CNContactGivenNameKey,
                 CNContactMiddleNameKey,
                 CNContactFamilyNameKey,
                 CNContactNicknameKey,
                 CNContactOrganizationNameKey,
                 CNContactNoteKey,
                 CNContactImageDataKey,
                 CNContactThumbnailImageDataKey,
                 CNContactPhoneNumbersKey,
                 CNContactJobTitleKey,
                 CNContactDepartmentNameKey,
                 CNContactBirthdayKey,
                 CNContactEmailAddressesKey,
                 ];
    }else{
        return @[];
    }
    
}

-(void)authorizationStatus:(DTAuthorizationResultBlock)block{
    self.block = block;
    if ([CNContactStore class]) {
        CNContactStore * store = [[CNContactStore alloc]init];
       CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:(CNEntityTypeContacts)];
        switch (status) {
            case CNAuthorizationStatusNotDetermined:{
                [store requestAccessForEntityType:(CNEntityTypeContacts) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    if (granted) {
                        if (self.block) {
                            self.block(DTAuthorizationResultYES);
                        }
                    }else{
                        if (self.block) {
                            self.block(DTAuthorizationResultNO);
                        }
                    }
                }];
            }
                break;
            case CNAuthorizationStatusAuthorized:
                if (self.block) {
                    self.block(DTAuthorizationResultYES);
                }
                break;
            case CNAuthorizationStatusRestricted:
            case CNAuthorizationStatusDenied:
                [self authorizationStatusDeniedAlertView];
                break;
                
            default:
                break;
        }
    }else{
        ABAddressBookRef addressBook = ABAddressBookCreate();
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        switch (status) {
            case kABAuthorizationStatusNotDetermined:{
                ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                    if (granted) {
                        if (self.block) {
                            self.block(DTAuthorizationResultYES);
                        }
                    }else{
                        if (self.block) {
                            self.block(DTAuthorizationResultNO);
                        }
                    }
                });
            }
                break;
            case kABAuthorizationStatusAuthorized:
                if (self.block) {
                    self.block(DTAuthorizationResultYES);
                }
                break;
            case kABAuthorizationStatusDenied:
            case kABAuthorizationStatusRestricted:
                [self authorizationStatusDeniedAlertView];
                break;
        
            default:
                break;
        }
    }

    
}
-(void)authorizationStatusDeniedAlertView{
    UIAlertController * alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"没有权限" preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        if (self.block) {
            self.block(DTAuthorizationResultNO);
        }
    }];
    UIAlertAction * done = [UIAlertAction actionWithTitle:@"设置" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        NSURL * settingUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication]canOpenURL:settingUrl]) {
            [[UIApplication sharedApplication]openURL:settingUrl];
        }
    }];
    
    [alertCon addAction:cancel];
    [alertCon addAction:done];
    
    UIViewController * preset = [[UIApplication sharedApplication].keyWindow jk_topMostController];
    [preset presentViewController:alertCon animated:YES completion:nil];
}

-(void)loadDatas{
    WEAKSELF_DT
    [self authorizationStatus:^(DTAuthorizationResult result) {
        if (result == DTAuthorizationResultYES) {
            
        }else{
            return ;
        }
    }];
}


@end
