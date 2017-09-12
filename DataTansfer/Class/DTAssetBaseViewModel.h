//
//  DTAssetBaseViewModel.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/18.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTDataBaseViewModel.h"


@interface DTAssetBaseViewModel : DTDataBaseViewModel

-(void)loadDatasWithType:(PHAssetMediaType) assetType;

-(void)setSelectedArrayWithIndexNumbers:(NSArray <NSNumber*>*)seletcts;

-(void)getSelectIndexNumbersFromModels:(NSMutableArray <NSNumber*>*) selecteds;

-(void)loadDatasInbox:(PHAssetMediaType)assetType;
@end

@interface DTAssetModel : NSObject<NSCopying,NSCoding>
@property (nonatomic, copy) NSData * assetData;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * fileUrlPath;
@property (nonatomic, copy) NSDate * creationDate;
@property (nonatomic, assign) CGFloat fileSize;
@property (nonatomic, strong) PHAsset * asset;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, copy) CLLocation *location;
@property (nonatomic, assign) BOOL favorite;
@property (nonatomic, copy) NSString * IDFR;
@property (nonatomic, assign) PHAssetMediaType mediaType;
+(instancetype)modelWithAsset:(PHAsset *)asset;
@end
