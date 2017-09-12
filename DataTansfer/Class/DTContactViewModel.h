//
//  DTContactViewModel.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/19.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTDataBaseViewModel.h"

@class DTContactModel;



@interface DTContactViewModel : DTDataBaseViewModel
-(NSInteger)numberOfSectionsInTableView;
-(NSInteger)numberOfRowsInSection:(NSInteger)section;
-(DTContactModel *)modelAtIndexPath:(NSIndexPath *)indexPath;
-(void)setSelectedArrayWithIndexPaths:(NSArray <NSIndexPath *>*)seletctIndexPaths;
-(void)getSelectIndexPathsFromModels:(NSMutableArray *) selectedIndexPaths;
@end

@interface DTContactModel : NSObject<NSCopying,NSCoding>

@property (copy, nonatomic) NSString *IDFR;

@property (nonatomic,copy) NSString * name;

@property (assign, nonatomic) CNContactType contactType;

@property (assign,nonatomic) BOOL isSelected;

@property (copy, nonatomic) NSString *namePrefix;
@property (copy, nonatomic) NSString *givenName;
@property (copy, nonatomic) NSString *middleName;
@property (copy, nonatomic) NSString *familyName;
@property (copy, nonatomic) NSString *previousFamilyName;
@property (copy, nonatomic) NSString *nameSuffix;
@property (copy, nonatomic) NSString *nickname;

@property (copy, nonatomic) NSString *organizationName;
@property (copy, nonatomic) NSString *departmentName;
@property (copy, nonatomic) NSString *jobTitle;

@property (copy, nonatomic) NSString *phoneticGivenName;
@property (copy, nonatomic) NSString *phoneticMiddleName;
@property (copy, nonatomic) NSString *phoneticFamilyName;
//@property (copy, nonatomic) NSString *phoneticOrganizationName NS_AVAILABLE(10_12, 10_0);

@property (copy, nonatomic) NSString *note;

@property (copy, nonatomic) NSData *imageData;
@property (copy, nonatomic) NSData *thumbnailImageData;
@property (nonatomic) BOOL imageDataAvailable ;

@property (copy, nonatomic) NSArray *phoneNumbers;///<CNLabeledValue<CNPhoneNumber*>*>
@property (copy, nonatomic) NSArray *emailAddresses;///<CNLabeledValue<NSString*>*>
@property (copy, nonatomic) NSArray *postalAddresses;///<CNLabeledValue<CNPostalAddress*>*>
@property (copy, nonatomic) NSArray *urlAddresses;///<CNLabeledValue<NSString*>*>
@property (copy, nonatomic) NSArray *contactRelations;///<CNLabeledValue<CNContactRelation*>*>
@property (copy, nonatomic) NSArray *socialProfiles;///<CNLabeledValue<CNSocialProfile*>*>
@property (copy, nonatomic) NSArray *instantMessageAddresses;///<CNLabeledValue<CNInstantMessageAddress*>*>

/*! The Gregorian birthday. */
@property (copy,  nonatomic) NSDateComponents *birthday;

/*! The alternate birthday (Lunisolar). */
@property (copy,  nonatomic) NSDateComponents *nonGregorianBirthday;

/*! Other Gregorian dates (anniversaries, etc). */
@property (copy, nonatomic) NSArray<CNLabeledValue<NSDateComponents*>*> *dates;

+(instancetype)modelWithContact:(CNContact  *) contact;
-(CNMutableContact *)getMutableContact;


@end
