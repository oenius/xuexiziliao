//
//  DTAssetBaseViewModel.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/18.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTAssetBaseViewModel.h"
#import "UIWindow+JKHierarchy.h"
#import "DTTaskManager.h"
@interface DTAssetBaseViewModel ()

@property (nonatomic,copy) DTAuthorizationResultBlock block;

@end

@implementation DTAssetBaseViewModel

-(void)setSelectedArrayWithIndexNumbers:(NSArray <NSNumber*>*)seletcts{
    [self.selectedArray removeAllObjects];
    for (NSNumber * index in seletcts) {
        DTAssetModel * model = self.dataArray[index.integerValue];
        model.isSelected = YES;
        [self.selectedArray addObject:model];
    }
    self.selectedCount = self.selectedArray.count;
}
-(void)getSelectIndexNumbersFromModels:(NSMutableArray <NSNumber*>*) selecteds{
    for (DTAssetModel * model in self.selectedArray) {
        NSUInteger index = [self.dataArray indexOfObject:model];
        NSNumber * indexNum = [NSNumber numberWithInteger:index];
        if (![selecteds containsObject:indexNum]) {
            [selecteds addObject:indexNum];
        }
    }
}

#pragma mark - 重写父类方法
-(void)authorizationStatus:(DTAuthorizationResultBlock)block{
    self.block = block;
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (PHAuthorizationStatusAuthorized == status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.block) {self.block(DTAuthorizationResultYES);}
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [[DTTaskManager shareManagaer]getAssetCollection:nil];
                        });
                    });
                }else{
                    if (self.block)  {self.block(DTAuthorizationResultNO);}
                }
            }];
        }
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
            [self authorizationStatusDeniedAlertView];
            break;
        case PHAuthorizationStatusAuthorized:
            if (self.block) {
                self.block(DTAuthorizationResultYES);
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[DTTaskManager shareManagaer]getAssetCollection:nil];
                });
            }
            break;
        default:
            break;
    }
}

-(void)loadDatasWithType:(PHAssetMediaType)assetType{
    WEAKSELF_DT
    [self authorizationStatus:^(DTAuthorizationResult result) {
        if (result == DTAuthorizationResultYES) {
            [weakSelf.dataArray removeAllObjects];
            PHFetchOptions *option = [[PHFetchOptions alloc] init];
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", assetType];
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            PHFetchResult * result = [PHAsset fetchAssetsWithMediaType:assetType options:option];
            [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[PHAsset class]]) {
                   
                    DTAssetModel * model = [DTAssetModel modelWithAsset:obj ];
                    [weakSelf.dataArray addObject:model];
                }
            }];
            weakSelf.totleCount = weakSelf.dataArray.count;
        }else{
            return ;
        }
    }];
    
}

-(void)loadDatasInbox:(PHAssetMediaType)assetType{
    WEAKSELF_DT
    [self authorizationStatus:^(DTAuthorizationResult result) {
        if (result == DTAuthorizationResultYES) {
            [weakSelf.dataArray removeAllObjects];
            PHFetchOptions *option = [[PHFetchOptions alloc] init];
            option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", assetType];
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            PHAssetCollection * collection = [self getAssetCollection:nil];
            if (collection) {
                PHFetchResult * result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
                [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[PHAsset class]]) {
                        
                        DTAssetModel * model = [DTAssetModel modelWithAsset:obj ];
                        [weakSelf.dataArray addObject:model];
                    }
                }];
                weakSelf.totleCount = weakSelf.dataArray.count;
            }
            
        }else{
            return ;
        }
    }];
}

+(void)archivedModel:(id)model completed:(void (^)(NSData *))completed{
    completed(nil);
}

#pragma mark - ------
/// 提示设置权限
-(void)authorizationStatusDeniedAlertView{
    UIAlertController * alertCon = [UIAlertController alertControllerWithTitle:[DTConstAndLocal tishi] message:[DTConstAndLocal photoLibraygoset] preferredStyle:(UIAlertControllerStyleAlert)];
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

#pragma mark - 获取收件箱

//  获得相簿
-(PHAssetCollection *)getAssetCollection:(NSError **)error{
    NSString * collectionName = [[NSUserDefaults standardUserDefaults] objectForKey:@"collectionName"];
    if (collectionName == nil) {
        collectionName = [self getAppName];
        [[NSUserDefaults standardUserDefaults] setObject:collectionName forKey:@"collectionName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    //判断是否已存在
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection * assetCollection in assetCollections) {
        if ([assetCollection.localizedTitle isEqualToString:collectionName]) {
            
            return assetCollection;
        }
    }
    //创建新的相簿
    __block NSString *assetCollectionLocalIdentifier = nil;
    
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        assetCollectionLocalIdentifier = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:collectionName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:error];
    if (error) {
        return nil;
    }
    PHAssetCollection * collection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[assetCollectionLocalIdentifier] options:nil].lastObject;
    return collection;
}
-(NSString *)getAppName{
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if ([appName length] == 0 || appName == nil)
    {
        appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey];
    }
    return appName;
}
@end


static NSString * const kAssetDataKey       = @"assetData";
static NSString * const kCreationDateKey    = @"creationDate";
static NSString * const kFileSizeKey        = @"fileSize";
static NSString * const kIsSelectedKey      = @"isSelected";
static NSString * const kLocationKey        = @"location";
static NSString * const kFavoriteKey        = @"favorite";
static NSString * const kIDFRKey            = @"IDFR";
static NSString * const kMediaTypeKey       = @"mediaType";
static NSString * const kFileUrlPathKey     = @"fileUrlPath";
static NSString * const kNameKey            = @"name_chenjia";


@implementation DTAssetModel

+(instancetype)modelWithAsset:(PHAsset *)asset{
    DTAssetModel *model = [[DTAssetModel alloc] init];
    model.asset = asset;
    model.name = @"";
    model.isSelected = NO;
    model.creationDate = asset.creationDate;
    model.favorite = asset.favorite;
    model.location = asset.location;
    model.IDFR = asset.localIdentifier;
    model.mediaType = asset.mediaType;
    
    return model;
}


///NSCoping
-(id)copyWithZone:(NSZone *)zone{
    DTAssetModel * model = [[[self class] allocWithZone:zone]init];
    model.assetData = [self.assetData copy];
    model.name = [self.name copy];
    model.fileUrlPath = [self.fileUrlPath copy];
    model.creationDate = [self.creationDate copy];
    model.fileSize = self.fileSize;
    model.asset = nil;
    model.isSelected = self.isSelected;
    model.location = [self.location copy];
    model.favorite = self.favorite;
    model.IDFR = [self.IDFR copy];
    model.mediaType = self.mediaType;
    return model;
}
///NSCoding
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.assetData      = [aDecoder decodeObjectForKey:kAssetDataKey];
        self.name           = [aDecoder decodeObjectForKey:kNameKey];
        self.fileUrlPath    = [aDecoder decodeObjectForKey:kFileUrlPathKey];
        self.creationDate   = [aDecoder decodeObjectForKey:kCreationDateKey];
        self.fileSize       = [aDecoder decodeFloatForKey:kFileSizeKey];
        self.isSelected     = [aDecoder decodeBoolForKey:kIsSelectedKey];
        self.location       = [aDecoder decodeObjectForKey:kLocationKey];
        self.favorite       = [aDecoder decodeBoolForKey:kFavoriteKey];
        self.IDFR           = [aDecoder decodeObjectForKey:kIDFRKey];
        self.mediaType      = [aDecoder decodeIntegerForKey:kMediaTypeKey];
        self.asset          = nil;
    }
    return self;
}
///NSCoding
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.assetData forKey:kAssetDataKey];
    [aCoder encodeObject:self.name forKey:kNameKey];
    [aCoder encodeObject:self.fileUrlPath forKey:kFileUrlPathKey];
    [aCoder encodeObject:self.creationDate forKey:kCreationDateKey];
    [aCoder encodeFloat:self.fileSize forKey:kFileSizeKey];
    [aCoder encodeBool:self.isSelected forKey:kIsSelectedKey];
    [aCoder encodeObject:self.location forKey:kLocationKey];
    [aCoder encodeBool:self.favorite forKey:kFavoriteKey];
    [aCoder encodeObject:self.IDFR forKey:kIDFRKey];
    [aCoder encodeInteger:self.mediaType forKey:kMediaTypeKey];
}

@end
