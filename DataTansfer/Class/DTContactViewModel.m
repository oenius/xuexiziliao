//
//  DTselfViewModel.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/19.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTContactViewModel.h"
#import "UIWindow+JKHierarchy.h"

@interface DTContactViewModel ()
@property (nonatomic,copy) DTAuthorizationResultBlock block;
@end

@implementation DTContactViewModel


-(NSInteger)numberOfSectionsInTableView{
    return 1;
}
-(NSInteger)numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(DTContactModel *)modelAtIndexPath:(NSIndexPath *)indexPath{
    return self.dataArray[indexPath.row];
}
-(void)setSelectedArrayWithIndexPaths:(NSArray <NSIndexPath *>*)seletctIndexPaths{
    [self.selectedArray removeAllObjects];
    for (NSIndexPath * indexPath in seletctIndexPaths) {
        DTContactModel * model = self.dataArray[indexPath.row];
        model.isSelected = YES;
        //        if (![self.selectedArray containsObject:model]) {
        [self.selectedArray addObject:model];
        //        }
    }
    self.selectedCount = self.selectedArray.count;
}

-(void)getSelectIndexPathsFromModels:(NSMutableArray *) selectedIndexPaths{
    for (DTContactModel * model in self.selectedArray) {
        NSUInteger index = [self.dataArray indexOfObject:model];
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        if (![selectedIndexPaths containsObject:indexPath]) {
            [selectedIndexPaths addObject:indexPath];
        }
    }
}


-(NSArray * )fetchKeys{
    if ([CNContactStore class]){
        return @[CNContactIdentifierKey,
                 CNContactTypeKey,
                 CNContactNamePrefixKey,
                 CNContactGivenNameKey,
                 CNContactMiddleNameKey,
                 CNContactFamilyNameKey,
                 CNContactPreviousFamilyNameKey,
                 CNContactNameSuffixKey,
                 CNContactNicknameKey,
                 CNContactOrganizationNameKey,
                 CNContactDepartmentNameKey,
                 CNContactJobTitleKey,
                 CNContactPhoneticGivenNameKey,
                 CNContactPhoneticMiddleNameKey,
                 CNContactPhoneticFamilyNameKey,
                 CNContactNoteKey,
                 CNContactImageDataKey,
                 CNContactThumbnailImageDataKey,
                 CNContactImageDataAvailableKey,
                 CNContactPhoneNumbersKey,
                 CNContactEmailAddressesKey,
                 CNContactPostalAddressesKey,
                 CNContactUrlAddressesKey,
                 CNContactRelationsKey,
                 CNContactSocialProfilesKey,
                 CNContactInstantMessageAddressesKey,
                 CNContactBirthdayKey,
                 CNContactNonGregorianBirthdayKey,
                 CNContactDatesKey,
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
    UIAlertController * alertCon = [UIAlertController alertControllerWithTitle:[DTConstAndLocal tishi] message:[DTConstAndLocal tongxunlugotset] preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:[DTConstAndLocal cancel] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        if (self.block) {
            self.block(DTAuthorizationResultNO);
        }
    }];
    UIAlertAction * done = [UIAlertAction actionWithTitle:[DTConstAndLocal settings] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
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
            if ([CNContactStore class]) {
                [weakSelf loadDatasFrom_iOS9After];
            }else{
                [weakSelf loadDatasFrom_iOS9Before];
            }
        }else{
            return ;
        }
    }];
}

-(void)loadDatasFrom_iOS9After{
    [self.dataArray removeAllObjects];
    CNContactStore * store = [[CNContactStore alloc]init];
    CNContactFetchRequest * request  = [[CNContactFetchRequest alloc]initWithKeysToFetch:[self fetchKeys]];
    request.sortOrder = CNContactSortOrderFamilyName;
    NSError * error;
    [store enumerateContactsWithFetchRequest:request error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        DTContactModel * model = [DTContactModel modelWithContact:contact];
        [self.dataArray addObject:model];
    }];
    self.totleCount = self.dataArray.count;
}
-(void)loadDatasFrom_iOS9Before{
    [self.dataArray removeAllObjects];
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        
        CFArrayRef personsRef = ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSInteger contactsCount = CFArrayGetCount(personsRef);
        
        for (int i = 0; i < contactsCount; i++) {
            
            DTContactModel * model = [[DTContactModel alloc]init];
            ABRecordRef person = CFArrayGetValueAtIndex(personsRef, i);
            
            NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            model.givenName = firstName;
            
            NSString *middleName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
            model.middleName = middleName;
            
            NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
            model.familyName = lastName;
            
            NSString *nikeyName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonNicknameProperty);
            model.nickname = nikeyName;
            
            NSString *oranizationName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
            model.organizationName = oranizationName;
            
            NSString *jobTitle = (__bridge NSString *)ABRecordCopyValue(person, kABPersonJobTitleProperty);
            model.jobTitle = jobTitle;
            
            NSString *note = (__bridge NSString *)ABRecordCopyValue(person, kABPersonNoteProperty);
            model.note = note;
            
            NSMutableArray *phoneNumbers = [NSMutableArray array];
            
            ABMutableMultiValueRef phoneNumRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for (int i = 0; i < ABMultiValueGetCount(phoneNumRef); i++) {
                NSMutableDictionary *phoneDict = [NSMutableDictionary dictionary];
                NSString * label = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phoneNumRef, i));
                NSString * phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumRef, i);
                phoneDict[@"phoneLabel"] = label;
                phoneDict[@"phoneNumber"] = phoneNumber;
                [phoneNumbers addObject:phoneDict];
            }
            model.phoneNumbers = phoneNumbers;
            
           model.imageData = (__bridge NSData *)(ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatOriginalSize));
            [self.dataArray addObject:model];
        }
    });
    self.totleCount = self.dataArray.count;

}


+(void)archivedModel:(DTContactModel *)model completed:(void (^)(NSData *))completed{
    NSData * modelData = [NSData archivedData:model];
    completed(modelData);
}

@end

static NSString * const kContactIDFRKey = @"IDFR";
static NSString * const kContactNameKey = @"nameKey";
static NSString * const kContactTypeKey = @"contactType";
static NSString * const kContactNamePrefixKey = @"namePrefix";
static NSString * const kContactGivenNameKey = @"givenName";
static NSString * const kContactMiddleNameKey = @"middleName";
static NSString * const kContactFamilyNameKey = @"familyName";
static NSString * const kContactPreviousFamilyNameKey = @"previousFamilyName";
static NSString * const kContactNameSuffixKey = @"nameSuffix";
static NSString * const kContactNicknameKey = @"nickname";
static NSString * const kContactOrganizationNameKey = @"organizationName";
static NSString * const kContactDepartmentNameKey = @"departmentName";
static NSString * const kContactJobTitleKey = @"jobTitle";
static NSString * const kContactPhoneticGivenNameKey = @"phoneticGivenName";
static NSString * const kContactPhoneticMiddleNameKey = @"phoneticMiddleName";
static NSString * const kContactPhoneticFamilyNameKey = @"phoneticFamilyName";
static NSString * const kContactNoteKey = @"note";
static NSString * const kContactImageDataKey = @"imageData";
static NSString * const kContactThumbnailImageDataKey = @"thumbnailImageData";
static NSString * const kContactImageDataAvailableKey = @"imageDataAvailable";
static NSString * const kContactPhoneNumbersKey = @"phoneNumbers";
static NSString * const kContactEmailAddressesKey = @"emailAddresses";
static NSString * const kContactPostalAddressesKey = @"postalAddresses";
static NSString * const kContactUrlAddressesKey = @"urlAddresses";
static NSString * const kContactRelationsKey = @"contactRelations";
static NSString * const kContactSocialProfilesKey = @"socialProfiles";
static NSString * const kContactInstantMessageAddressesKey = @"instantMessageAddresses";
static NSString * const kContactBirthdayKey = @"birthday";
static NSString * const kContactNonGregorianBirthdayKey = @"nonGregorianBirthday";
static NSString * const kContactDatesKey = @"dates";
static NSString * const kContactIsSelectedKey = @"isSelected";


@implementation DTContactModel

-(CNMutableContact *)getMutableContact{
    CNMutableContact * contact = [[CNMutableContact alloc]init];
    contact.contactType = self.contactType;
    
    contact.namePrefix = self.namePrefix;
    contact.givenName = self.givenName;
    contact.middleName = self.middleName;
    contact.familyName = self.familyName;
    contact.previousFamilyName = self.previousFamilyName;
    
    contact.nameSuffix = self.nameSuffix;
    contact.nickname = self.nickname;
    
    contact.organizationName  = self.organizationName;
    contact.departmentName = self.departmentName;
    contact.jobTitle = self.jobTitle;
    
    contact.phoneticGivenName = self.phoneticGivenName;
    contact.phoneticMiddleName = self.phoneticMiddleName;
    contact.phoneticFamilyName = self.phoneticFamilyName;
    
    contact.note = self.note;
    
    contact.imageData = self.imageData;
    id test = nil;
    if (self.phoneNumbers.count > 0) {
        test = self.phoneNumbers[0];
    }
    if (test) {
        if ([test isKindOfClass:[NSDictionary class]] || [test isKindOfClass:[NSMutableDictionary class]]) {
            NSMutableArray * numbers = [NSMutableArray array];
            for (NSDictionary * dict in self.phoneNumbers) {
                NSString * label = dict[@"phoneLabel"];
                NSString * phoneNum = dict[@"phoneNumber"];
                CNPhoneNumber * number = [CNPhoneNumber phoneNumberWithStringValue:phoneNum];
                CNLabeledValue * labelValue = [[CNLabeledValue alloc]initWithLabel:label value:number];
                [numbers addObject:labelValue];
            }
            contact.phoneNumbers = numbers;
        }else{
            contact.phoneNumbers = self.phoneNumbers;
        }
    }else{
       contact.phoneNumbers = self.phoneNumbers;
    }
    
    contact.emailAddresses = self.emailAddresses;
    contact.postalAddresses = self.postalAddresses;
    contact.urlAddresses = self.urlAddresses;
    contact.contactRelations = self.contactRelations;
    contact.socialProfiles  = self.socialProfiles;
    contact.instantMessageAddresses = self.instantMessageAddresses;
    
    contact.birthday = self.birthday;
    contact.nonGregorianBirthday = self.nonGregorianBirthday;
    contact.dates = self.dates;
    return contact;
}

+(instancetype)modelWithContact:(CNContact *)contact{
    DTContactModel * model = [[DTContactModel alloc]init];
    model.isSelected = NO;
    model.IDFR = [[[NSUUID UUID] UUIDString] copy];//[contact.identifier copy];
    model.contactType = contact.contactType;
    model.namePrefix = [contact.namePrefix copy];
    model.givenName = [contact.givenName copy];
    model.middleName = [contact.middleName copy];
    model.familyName = [contact.familyName copy];
    model.previousFamilyName = [contact.previousFamilyName copy];
    model.nameSuffix = [contact.nameSuffix copy];
    model.nickname = [contact.nickname copy];
    model.organizationName = [contact.organizationName copy];
    model.departmentName = [contact.departmentName copy];
    model.jobTitle = [contact.jobTitle copy];
    model.phoneticGivenName = [contact.phoneticGivenName copy];
    model.phoneticMiddleName = [contact.phoneticMiddleName copy];
    model.phoneticFamilyName = [contact.phoneticFamilyName copy];
    model.note = [contact.note copy];
    model.imageData = [contact.imageData copy];
    model.thumbnailImageData = [contact.thumbnailImageData copy];
    model.imageDataAvailable = contact.imageDataAvailable;
    NSArray *phoneNums = contact.phoneNumbers;
    NSMutableArray * tmpArray = [NSMutableArray array];
    ///为了适配iOS9一下
    for (CNLabeledValue *labeledValue in phoneNums) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        NSString *phoneLabel = labeledValue.label;
        CNPhoneNumber *phoneNumer = labeledValue.value;
        NSString *phoneValue = phoneNumer.stringValue;
        dict[@"phoneLabel"] = phoneLabel;
        dict[@"phoneNumber"] = phoneValue;
        [tmpArray addObject:dict];
    }
    model.phoneNumbers = [tmpArray copy];
    model.emailAddresses = [contact.emailAddresses copy];
    model.postalAddresses = [contact.postalAddresses copy];
    model.urlAddresses = [contact.urlAddresses copy];
    model.contactRelations = [contact.contactRelations copy];
    model.socialProfiles = [contact.socialProfiles copy];
    model.instantMessageAddresses = [contact.instantMessageAddresses copy];
    model.birthday = [contact.birthday copy];
    model.nonGregorianBirthday = [contact.nonGregorianBirthday copy];
    model.dates = [contact.dates copy];
    NSString * name = @"";
    name = [name stringByAppendingFormat:@"%@",model.givenName];
    name = [name stringByAppendingFormat:@" %@",model.familyName];
    NSString * check = [name copy];
    check = [check stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (check.length == 0) {
        name = @"None";
    }
    model.name = name;
    return model;
}
+(instancetype)modelWithModel:(DTContactModel *)model{
    return [model copy];
    
}
///NSCoping
-(id)copyWithZone:(NSZone *)zone{
    DTContactModel * model = [[[self class] allocWithZone:zone]init];
    model.isSelected = self.isSelected;
    model.IDFR = [self.IDFR copy];
    model.contactType = self.contactType;
    model.namePrefix = [self.namePrefix copy];
    model.givenName = [self.givenName copy];
    model.middleName = [self.middleName copy];
    model.familyName = [self.familyName copy];
    model.previousFamilyName = [self.previousFamilyName copy];
    model.nameSuffix = [self.nameSuffix copy];
    model.nickname = [self.nickname copy];
    model.organizationName = [self.organizationName copy];
    model.departmentName = [self.departmentName copy];
    model.jobTitle = [self.jobTitle copy];
    model.phoneticGivenName = [self.phoneticGivenName copy];
    model.phoneticMiddleName = [self.phoneticMiddleName copy];
    model.phoneticFamilyName = [self.phoneticFamilyName copy];
    model.note = [self.note copy];
    model.imageData = [self.imageData copy];
    model.thumbnailImageData = [self.thumbnailImageData copy];
    model.imageDataAvailable = self.imageDataAvailable;
    model.phoneNumbers = [self.phoneNumbers copy];
    model.emailAddresses = [self.emailAddresses copy];
    model.postalAddresses = [self.postalAddresses copy];
    model.urlAddresses = [self.urlAddresses copy];
    model.contactRelations = [self.contactRelations copy];
    model.socialProfiles = [self.socialProfiles copy];
    model.instantMessageAddresses = [self.instantMessageAddresses copy];
    model.birthday = [self.birthday copy];
    model.nonGregorianBirthday = [self.nonGregorianBirthday copy];
    model.dates = [self.dates copy];
    model.name = [self.name copy];
    return model;
}

///NSCoding
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.isSelected = [aDecoder decodeBoolForKey:kContactIsSelectedKey];
        self.IDFR = [aDecoder decodeObjectForKey:kContactIDFRKey];
        self.name = [aDecoder decodeObjectForKey:kContactNameKey];
        self.contactType = [aDecoder decodeIntegerForKey:kContactTypeKey];
        self.namePrefix = [aDecoder decodeObjectForKey:kContactNamePrefixKey];
        self.givenName = [aDecoder decodeObjectForKey:kContactGivenNameKey];
        self.middleName = [aDecoder decodeObjectForKey:kContactMiddleNameKey];
        self.familyName = [aDecoder decodeObjectForKey:kContactFamilyNameKey];
        self.previousFamilyName = [aDecoder decodeObjectForKey:kContactPreviousFamilyNameKey];
        self.nameSuffix = [aDecoder decodeObjectForKey:kContactNameSuffixKey];
        self.nickname = [aDecoder decodeObjectForKey:kContactNicknameKey];
        self.organizationName = [aDecoder decodeObjectForKey:kContactOrganizationNameKey];
        self.departmentName = [aDecoder decodeObjectForKey:kContactDepartmentNameKey];
        self.jobTitle = [aDecoder decodeObjectForKey:kContactJobTitleKey];
        self.phoneticGivenName = [aDecoder decodeObjectForKey:kContactPhoneticGivenNameKey];
        self.phoneticMiddleName = [aDecoder decodeObjectForKey:kContactPhoneticMiddleNameKey];
        self.phoneticFamilyName = [aDecoder decodeObjectForKey:kContactPhoneticFamilyNameKey];
        self.note = [aDecoder decodeObjectForKey:kContactNoteKey];
        self.imageData = [aDecoder decodeObjectForKey:kContactImageDataKey];
        self.thumbnailImageData = [aDecoder decodeObjectForKey:kContactThumbnailImageDataKey];
        self.imageDataAvailable = [aDecoder decodeBoolForKey:kContactImageDataAvailableKey];
        self.phoneNumbers = [aDecoder decodeObjectForKey:kContactPhoneNumbersKey];
        self.emailAddresses = [aDecoder decodeObjectForKey:kContactEmailAddressesKey];
        self.postalAddresses = [aDecoder decodeObjectForKey:kContactPostalAddressesKey];
        self.urlAddresses = [aDecoder decodeObjectForKey:kContactUrlAddressesKey];
        self.contactRelations = [aDecoder decodeObjectForKey:kContactRelationsKey];
        self.socialProfiles = [aDecoder decodeObjectForKey:kContactSocialProfilesKey];
        self.instantMessageAddresses = [aDecoder decodeObjectForKey:kContactInstantMessageAddressesKey];
        self.birthday = [aDecoder decodeObjectForKey:kContactBirthdayKey];
        self.nonGregorianBirthday = [aDecoder decodeObjectForKey:kContactNonGregorianBirthdayKey];
        self.dates = [aDecoder decodeObjectForKey:kContactDatesKey];
    }
    return self;
}
///NSCoding
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeBool:self.isSelected forKey:kContactIsSelectedKey];
    [aCoder encodeInteger:self.contactType forKey:kContactTypeKey];
    [aCoder encodeBool:self.imageDataAvailable forKey:kContactImageDataAvailableKey];
    [aCoder encodeObject:self.IDFR forKey:kContactIDFRKey];
    [aCoder encodeObject:self.name forKey:kContactNameKey];
    [aCoder encodeObject:self.namePrefix forKey:kContactNamePrefixKey];
    [aCoder encodeObject:self.givenName forKey:kContactGivenNameKey];
    [aCoder encodeObject:self.middleName forKey:kContactMiddleNameKey];
    [aCoder encodeObject:self.familyName forKey:kContactFamilyNameKey];
    [aCoder encodeObject:self.previousFamilyName forKey:kContactPreviousFamilyNameKey];
    [aCoder encodeObject:self.nameSuffix forKey:kContactNameSuffixKey];
    [aCoder encodeObject:self.nickname forKey:kContactNicknameKey];
    [aCoder encodeObject:self.organizationName forKey:kContactOrganizationNameKey];
    [aCoder encodeObject:self.departmentName forKey:kContactDepartmentNameKey];
    [aCoder encodeObject:self.jobTitle forKey:kContactJobTitleKey];
    [aCoder encodeObject:self.phoneticGivenName forKey:kContactPhoneticGivenNameKey];
    [aCoder encodeObject:self.phoneticMiddleName forKey:kContactPhoneticMiddleNameKey];
    [aCoder encodeObject:self.phoneticFamilyName forKey:kContactPhoneticFamilyNameKey];
    [aCoder encodeObject:self.note forKey:kContactNoteKey];
    [aCoder encodeObject:self.imageData forKey:kContactImageDataKey];
    [aCoder encodeObject:self.thumbnailImageData forKey:kContactThumbnailImageDataKey];
    [aCoder encodeObject:self.phoneNumbers forKey:kContactPhoneNumbersKey];
    [aCoder encodeObject:self.emailAddresses forKey:kContactEmailAddressesKey];
    [aCoder encodeObject:self.postalAddresses forKey:kContactPostalAddressesKey];
    [aCoder encodeObject:self.urlAddresses forKey:kContactUrlAddressesKey];
    [aCoder encodeObject:self.contactRelations forKey:kContactRelationsKey];
    [aCoder encodeObject:self.socialProfiles forKey:kContactSocialProfilesKey];
    [aCoder encodeObject:self.instantMessageAddresses forKey:kContactInstantMessageAddressesKey];
    [aCoder encodeObject:self.birthday forKey:kContactBirthdayKey];
    [aCoder encodeObject:self.nonGregorianBirthday forKey:kContactNoteKey];
    [aCoder encodeObject:self.dates forKey:kContactDatesKey];
}



@end

















