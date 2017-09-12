//
//  SNMindFileViewModel.m
//  MindMap
//
//  Created by 何少博 on 2017/8/7.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNMindFileViewModel.h"
#import "SNFileModel.h"
#import "NSString+x.h"
#import "NSFileManager+x.h"
#import "SNNodeAsset.h"
#import "SNiCloudTool.h"
#import "NSArray+x.h"
#import "SNDocument.h"
#import "SNICloudMap.h"
@interface SNMindFileViewModel ()

@property (nonatomic,readwrite,assign) NSInteger fileCount;
@property (nonatomic,strong) NSMutableArray<SNFileModel *> * dataSource;
@property (nonatomic, strong) NSMetadataQuery *ubiquitousQuery;
@property (nonatomic, strong) NSArray *sortedResults;
@property (nonatomic, strong) NSString * parentPath;
@property (strong, nonatomic) NSTimer *refreshTimer;
@property id metadataQueryStartObserver;
@property id metadataQueryGatherObserver;
@property id metadataQueryUpdateObserver;
@property id metadataQueryFinishObserver;

@end

static NSTimeInterval kDefaultRefreshTimerInterval = 40.0;

@implementation SNMindFileViewModel


-(void)dealloc{
    [_refreshTimer invalidate];
    _refreshTimer = nil;
}

-(instancetype)init{
    self = [self initWithPath:nil];
    return self;
}

-(instancetype)initWithPath:(NSString *)filePath{
    self = [super init];
    if (self) {
        self.currentPath = filePath;
        [self setupQuery];
        [self setupTimer];
    }
    return self;
}

-(NSInteger)fileCount{
    return self.dataSource.count;
}

-(NSMutableArray<SNFileModel *> *)dataSource{
    if (nil == _dataSource) {
        _dataSource = [self getDataSourceArray];
    }
    return _dataSource;
}

-(NSInteger)numberOfSectionsInTableView{
    return 1;
}

-(NSInteger)numberOfRowsInSection:(NSInteger) section{
    return self.dataSource.count;
}

-(SNFileModel *)modelAtIndexPath:(NSIndexPath *)indexPath{
    return self.dataSource[indexPath.row];
}
-(void)reloaData{

    self.dataSource = nil;
}
-(void )setupTimer{
    self.refreshTimer = [NSTimer timerWithTimeInterval:kDefaultRefreshTimerInterval target:self selector:@selector(timerfunc) userInfo:nil repeats:YES];
    NSRunLoop * loop = [NSRunLoop currentRunLoop];
    [loop addTimer:self.refreshTimer forMode:NSRunLoopCommonModes];
    [self.refreshTimer fire];
}

-(void)timerfunc{
    if (self.canBackGroundSearch) {
        [self startScanning];
    }
}

-(NSMutableArray *)getDataSourceArray{
    //TODO: 方式待优化
    NSArray * localFileArray = [self getCurrmtPathFile];
    NSArray * iCloudFileArray = [self getiCloudFile];
    NSMutableArray * datasoruce = [NSMutableArray array];
    if (iCloudFileArray == nil) {
        [datasoruce addObjectsFromArray:localFileArray];
    }else{
        for (SNFileModel * locModel in localFileArray) {
            NSPredicate * pre = [NSPredicate predicateWithFormat:@"SELF.name = %@",locModel.name];
            NSArray * find = [iCloudFileArray filteredArrayUsingPredicate:pre];
            if (find.count == 0) {
                locModel.iCloudStatus = SNFileiCloudStatusNotUpload;
                [datasoruce addOnlyOneObject:locModel];
            }else{
                locModel.iCloudStatus = SNFileiCloudStatusNormal;
                [datasoruce addOnlyOneObject:locModel];
            }
        }
    }
    
    NSArray * onlyICloud = [iCloudFileArray filteredArrayWithBlock:^BOOL(SNFileModel* objc) {
        BOOL isOnlyiCloud = YES;
        NSPredicate * pre = [NSPredicate predicateWithFormat:@"SELF.name = %@",objc.name];
        NSArray * find = [localFileArray filteredArrayUsingPredicate:pre];
        if (find.count > 0) {
            isOnlyiCloud = NO;
        }
        if (isOnlyiCloud) {
            objc.iCloudStatus = SNFileiCloudStatusNotDownload;
        }
        return isOnlyiCloud;
    }];
    [datasoruce addObjectsFromArray:onlyICloud];
    [datasoruce sortUsingComparator:^NSComparisonResult(SNFileModel* obj1, SNFileModel* obj2) {
        return [obj1.name compare:obj2.name];
    }];
    return datasoruce;
}

-(NSMutableArray *)getiCloudFile{
    NSMutableArray * tmpArray = [NSMutableArray array];
    if (_sortedResults == nil) {
        return nil;
    }
    for (NSMetadataItem * item in _sortedResults) {
        
        NSString * iCloudPath = [item valueForAttribute:NSMetadataItemPathKey];
        if ([iCloudPath containsString:kMapSuffix]) {
            continue;
        }
        SNFileModel * model = [[SNFileModel alloc]init];
        model.relativePath = [self getRelativePathPath:iCloudPath];
        NSString * disPlayName = [iCloudPath lastPathComponent];
        model.name = [disPlayName stringByDeletingPathExtension];
        if ([model.name containsString:@"."]) {
            continue;
        }
        model.iCloudStatus = SNFileiCloudStatusNormal;
        BOOL isDir = ![disPlayName containsString:@"."];
        if (isDir) {
            model.fileType = SNFileTypeFolder;
            NSArray * subPaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:iCloudPath error:nil];
            NSLog(@"iCloudsubPaths:%@",subPaths);
            NSMutableArray * filterPaths = [NSMutableArray array];
            for (NSString * sub in subPaths) {
                if (![sub containsString:kMapSuffix]) {
                    [filterPaths addObject:sub];
                }
            }
            model.subPaths = [filterPaths copy];
        }else{
            model.fileType = SNFileTypeMindMap;
        }
        [tmpArray addObject:model];
    }
    _sortedResults = nil;
    return tmpArray;
};




-(NSMutableArray <SNFileModel*>*)getCurrmtPathFile{
    NSString * currentPath = self.currentPath;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError * error;
    NSArray * subPaths = [fileManager contentsOfDirectoryAtPath:currentPath error:&error];
    if (error) {
        return [NSMutableArray array];
    }
    subPaths = [subPaths sortedArrayUsingComparator:^(NSString * firstPath, NSString* secondPath) {
         return [firstPath compare:secondPath];
    }];
    NSMutableArray<SNFileModel *> * fileArray = [NSMutableArray array];
    for (NSString * path in subPaths) {
        if ([path containsString:kMapSuffix]) {
            continue;
        }
        NSString * filePath = [currentPath stringByAppendingPathComponent:path];
        SNFileModel * model = [self creatModelWithPath:filePath];
        if (model) {
            [fileArray addObject:model];
        }
        
    }
    return fileArray;
}

-(SNFileModel *)creatModelWithPath:(NSString *)filePath{
    if (filePath.length <= 0 || filePath == nil) {
        return nil;
    }
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSError * error ;
    NSDictionary * attri = [fileManager attributesOfItemAtPath:filePath error:&error];
    if (error) {
        [fileManager removeItemAtPath:filePath error:&error];
        return nil;
    }
    BOOL isDir = NO;
    BOOL isExist = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if (!isExist) { return nil;}
    NSString * name = [[filePath lastPathComponent] stringByDeletingPathExtension];
    if ([name containsString:@"."]) {
        return nil;
    }
    SNFileModel * model = [[SNFileModel alloc]init];
    model.name = name;
    model.filePath = [filePath copy];
    NSDate * creatData = [attri objectForKey:NSFileCreationDate];
    model.creatDate = creatData;
    model.iCloudStatus = SNFileiCloudStatusNormal;
    model.relativePath = [self getRelativePathPath:filePath];
    if (isDir) {
        model.fileType = SNFileTypeFolder;
        NSArray * subPaths = [fileManager contentsOfDirectoryAtPath:filePath error:nil];
        NSLog(@"subPaths:%@",subPaths);
        NSMutableArray * filterPaths = [NSMutableArray array];
        for (NSString * sub in subPaths) {
            if (![sub containsString:kMapSuffix]) {
                NSString * assetPath = [self.currentPath stringByAppendingFormat:@"/%@/%@",name,sub];
                NSLog(@"assetPath:%@",assetPath);
                [filterPaths addObject:assetPath];
            }
        }
        model.subPaths = [filterPaths copy];
    }else{
        model.fileType = SNFileTypeMindMap;
        model.mapPath = [self getMapPathWithAssetFilePath:filePath];
        NSURL * fileUrl = [NSURL fileURLWithPath:filePath];
        NSData * data = [NSData dataWithContentsOfURL:fileUrl];
        NSKeyedUnarchiver * unarchive = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        SNNodeAsset * asset = [unarchive decodeObject];
        model.nodeAsset = asset;
        [model.nodeAsset setupWithPath:filePath];
        if (asset.creatDate) {
            model.creatDate = asset.creatDate;
        }else{
            asset.creatDate = creatData;
        }
    }
    return model;
}

-(NSArray *)getSelectedFilePath:(NSArray<NSIndexPath *> *)selectedIndexPaths{
    NSMutableArray * tmp = [NSMutableArray array];
    for (NSIndexPath * indexPath in selectedIndexPaths) {
        SNFileModel * model = [self modelAtIndexPath:indexPath];
        BOOL isDir = [[NSFileManager defaultManager]isDirectory: model.filePath];
        if (isDir) {
            [tmp addObject:[model.filePath copy]];
        }else{
            [tmp addObject:model.filePath];
            [tmp addObject:model.mapPath];
        }
    }
    return tmp;
}




-(NSString *)getMapPathWithAssetFilePath:(NSString *)assetPath{
    return [assetPath stringByReplacingOccurrencesOfString:kAssetSuffix withString:kMapSuffix];
}

-(NSString *)checkReName:(NSString *)rename{
    if ([rename containsString:@"."]||
        [rename containsString:@"/"]||
        rename.length <= 0) {
        return NSLocalizedString(@"Name is not available", @"名称不可用");
    }
    for (SNFileModel * model in self.dataSource) {
        if ([model.name isEqualToString:rename]) {
            return NSLocalizedString(@"over.name", @"名称重复");
        }
    }
    return @"";
}

-(BOOL)creatNewFolderName:(NSString *)name parentDir:(NSString *)parent{
    
    NSError * locError;
    NSString * folderPath = [parent stringByAppendingPathComponent:name];
    __block BOOL success = NO;
    success = [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES  attributes:nil  error:&locError];
    if (locError) {
        NSLog(@"创建文件夹locError:%@",locError);
    }
    if (success) {
        if ([[SNiCloudTool shareInstance] canSynICloud]) {
            NSURL * url = [[SNiCloudTool shareInstance] getiCloudUrlWithLocalPath:folderPath];
            [[SNiCloudTool shareInstance] creatNewFolderToICloudWithUrl:url];
        }
    }
    if (success) {
        SNFileModel * newModel = [self creatModelWithPath:folderPath];
        [self addModeToDataSource:newModel];
        if ([self.delegate respondsToSelector:@selector(saveMapSuccess)]) {
            [self.delegate saveMapSuccess];
        }
    }
    return success;
}

-(BOOL)saveMapWithAsset:(SNNodeAsset*)nodeAsset
                  nodes:(NSArray *)nodes
               isNewMap:(BOOL)newMap{
    
    NSData * mapData = [nodeAsset save:nodes autoReName:newMap];
    NSData * assetData = [nodeAsset saveSelf];
    if (mapData == nil || assetData == nil) {
        return NO;
    }
    
    if ([[SNiCloudTool shareInstance] canSynICloud]) {
        SNICloudMap * map = [[SNICloudMap alloc]init];
        map.assetData = assetData;
        map.mapData = mapData;
        NSURL * iCloudUrl = [[SNiCloudTool shareInstance] getiCloudUrlWithLocalPath:nodeAsset.assetPath];
        [[SNiCloudTool shareInstance] creatMapToICloud:map url:iCloudUrl isNewMap:newMap];
    }
    SNFileModel * newModel = [self creatModelWithPath:nodeAsset.assetPath];
    if (!newMap) {
        for (SNFileModel * model in self.dataSource) {
            if ([model.name isEqualToString:newModel.name]) {
                [self.dataSource removeObject:model];
                break;
            }
        }
    }
    [self addModeToDataSource:newModel];
    if ([self.delegate respondsToSelector:@selector(saveMapSuccess)]) {
        [self.delegate saveMapSuccess];
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:kSNMindFilePathDidChangedNotification object:nil];
    return YES;
}



-(void)startDownloadFileAtIndexPath:(NSIndexPath *)indexPath completed:(void(^)(BOOL success)) completed{
    if (![[SNiCloudTool shareInstance]canSynICloud]) {
        if (completed) {
            completed(NO);
        }
    }
    SNFileModel * model = [self modelAtIndexPath:indexPath];
    NSString * locPath = [self getLocalPathWithRelativePath:model.relativePath];
    if (model.fileType == SNFileTypeFolder) {
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:locPath
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:nil];
        if (success) {
            SNFileModel * newModel = [self creatModelWithPath:locPath];
            [self.dataSource removeObject:model];
            [self addModeToDataSource:newModel];
        }
        if (completed) {
            completed(success);
        }
    }else if (model.fileType == SNFileTypeMindMap){
        NSString * assetPath = [locPath copy];
        NSString * mapPath = [locPath stringByReplacingOccurrencesOfString:kAssetSuffix withString:kMapSuffix];
        NSURL * iCUrl = [[SNiCloudTool shareInstance] getiCloudUrlWithRelativePath:model.relativePath];
        SNDocument * doc = [[SNDocument alloc]initWithFileURL:iCUrl];
        [doc openWithCompletionHandler:^(BOOL success) {
            BOOL newSuccess = NO;
            if (success) {
                
                BOOL s1 = [doc.map.assetData writeToFile:assetPath atomically:YES];
                BOOL s2 = [doc.map.mapData writeToFile:mapPath atomically:YES];
                newSuccess = s1&&s2;
            }
            [doc closeWithCompletionHandler:nil];
            if (newSuccess) {
                SNFileModel * newModel = [self creatModelWithPath:locPath];
                [self.dataSource removeObject:model];
                [self addModeToDataSource:newModel];
            }
            if (completed) {
                completed(newSuccess);
            }
        }];
    }
}

-(void)addModeToDataSource:(SNFileModel *)model{
    if (model) {
        [self.dataSource addObject:model];
        [self.dataSource sortUsingComparator:^NSComparisonResult(SNFileModel * obj1, SNFileModel * obj2) {
            return [obj1.name compare:obj2.name];
        }];
    }
}

-(NSString *)getLocalPathWithRelativePath:(NSString *)relativePath{
    NSString * docment = [SNTools documentPath];
    NSString * fixRP = [relativePath stringByReplacingOccurrencesOfString:@"Documents" withString:@""];
    NSString * lp = [docment stringByAppendingString:fixRP];
    return lp;
}


-(void)startUploadFileAtIndexPath:(NSIndexPath *)indexPath completed:(void (^)(BOOL))completed{
    if (![[SNiCloudTool shareInstance]canSynICloud]) {
        if (completed) {
            completed(NO);
        }
    }
    SNFileModel * model = [self modelAtIndexPath:indexPath];
    NSString * locPath = [self getLocalPathWithRelativePath:model.relativePath];
    if (model.fileType == SNFileTypeFolder) {
        BOOL success = [[SNiCloudTool shareInstance] uploadFolderWithPath:locPath];
        if (success) {
            model.iCloudStatus = SNFileiCloudStatusNormal;
        }
        if (completed) {
            completed(success);
        }
    }else if (model.fileType == SNFileTypeMindMap){
        [[SNiCloudTool shareInstance] uplaodMapWithAssetPath:locPath completed:^(BOOL success) {
            if (success) {
                model.iCloudStatus = SNFileiCloudStatusNormal;
            }
            if (completed) {
                completed(success);
            }
        }];
    }
}


-(NSString *)getPathName:(NSString *)name suffix:(NSString *)suffix{
    NSString * newPath = [NSString stringWithFormat:@"%@/%@%@",self.currentPath,name,suffix];
    return newPath;
}

-(BOOL)renameAtIndexPath:(NSIndexPath *)indexpath name:(NSString *)name{
    SNFileModel * model = [self modelAtIndexPath:indexpath];
    NSError * error;
    BOOL success = NO;
    NSString * newPath ;
    if (model.fileType == SNFileTypeFolder) {
        newPath = [self getPathName:name suffix:@""];
        if ([[SNiCloudTool shareInstance]canSynICloud]) {
            NSURL * fileUrl = [[SNiCloudTool shareInstance] getiCloudUrlWithLocalPath:model.filePath];
            NSURL * newICloudUrl = [[SNiCloudTool shareInstance] getiCloudUrlWithLocalPath:newPath];
            [[SNiCloudTool shareInstance] renamefileICloudUrl:fileUrl newNameUrl:newICloudUrl];
        }
        success = [[NSFileManager defaultManager] moveItemAtPath:model.filePath toPath:newPath error:&error];
    }else{
        NSString * newAssetPath = [self getPathName:name suffix:kAssetSuffix];
        NSString * newMapPath = [self getPathName:name suffix:kMapSuffix];
        if ([[SNiCloudTool shareInstance]canSynICloud]) {
            newPath = newAssetPath;
            NSURL * fileUrl = [[SNiCloudTool shareInstance] getiCloudUrlWithLocalPath:model.filePath];
            NSURL * newICloudUrl = [[SNiCloudTool shareInstance] getiCloudUrlWithLocalPath:newAssetPath];
            [[SNiCloudTool shareInstance] renamefileICloudUrl:fileUrl newNameUrl:newICloudUrl];
        }
        BOOL s1 = [[NSFileManager defaultManager] moveItemAtPath:model.filePath toPath:newAssetPath error:&error];
        NSLog(@"%@",error);
        BOOL s2 = [[NSFileManager defaultManager] moveItemAtPath:model.mapPath toPath:newMapPath error:&error];
        success = s1 && s2;
        
    }
    NSLog(@"%@",error);
    if (success) {
        SNFileModel * newModel = [self creatModelWithPath:newPath];
        [self.dataSource removeObject:model];
        [self addModeToDataSource:newModel];
    }
//   [[NSNotificationCenter defaultCenter] postNotificationName:kSNMindFilePathDidChangedNotification object:nil];
    return success;
}

-(NSString *)deleteSelectedFile:(NSArray<NSIndexPath *>*)selectedIndexPaths{
    NSArray * paths = [self getSelectedFilePath:selectedIndexPaths];
    NSError *error;
    BOOL removeRet = YES;
    NSString *msg = @"";
    for (NSString *filePath in paths) {
        NSString *fileName = [filePath lastPathComponent];
        BOOL ret = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (!ret) {
            fileName = [fileName stringByDeletingPathExtension];
            NSLog(@"error%@",error);
            if (![msg containsString:fileName]) {
                msg = [msg stringByAppendingFormat:@"%@ ",fileName];
            }
            removeRet = ret;
        }
    }
    if ([[SNiCloudTool shareInstance]canSynICloud]) {
        NSArray * urls = [[SNiCloudTool shareInstance] getiCloudUrlWithSeletedPaths:paths];
        [[SNiCloudTool shareInstance] deleteFileFormICouldWithUrls:urls];
    }
    return msg;
}
-(void)copyFiles:(NSArray *)files toDir:(NSString *) toDir
       completed:(void(^)(BOOL success ,NSString * errorMessage)) completed{
    NSError *error;
    BOOL copyRet = YES;
    NSString *msg = @"";
    for (NSString *copyFilePath in files) {
        NSString *fileName = [copyFilePath lastPathComponent];
        NSString *dstFilePath = [toDir stringByAppendingPathComponent:fileName];
        BOOL ret = [[NSFileManager defaultManager] copyItemAtPath:copyFilePath toPath:dstFilePath error:&error];
        
        if (!ret) {
            NSLog(@"%@error",error);
            fileName = [fileName stringByDeletingPathExtension];
            if (![msg containsString:fileName]) {
                msg = [msg stringByAppendingFormat:@"%@ ",fileName];
            }
            copyRet = ret;
        }
    }
    if ([[SNiCloudTool shareInstance]canSynICloud]) {
        NSArray * urls = [[SNiCloudTool shareInstance] getiCloudUrlWithSeletedPaths:files];
        NSURL * toDirUrl = [[SNiCloudTool shareInstance] getiCloudUrlWithLocalPath:toDir];
        [[SNiCloudTool shareInstance] copyFilesFromICloudWithUrls:urls toDir:toDirUrl];
    }
    
    if (completed) {
        completed(copyRet,msg);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kSNMindFilePathDidChangedNotification object:nil];
}
-(void)moveFiles:(NSArray *)files toDir:(NSString *) toDir
       completed:(void(^)(BOOL success ,NSString * errorMessage)) completed{
    NSError *error;
    BOOL moveRet = YES;
    NSString *msg = @"";
    for (NSString *moveFilePath in files) {
        NSString *fileName = [moveFilePath lastPathComponent];
        NSString *dstFilePath = [toDir stringByAppendingPathComponent:fileName];
        BOOL ret = [[NSFileManager defaultManager] moveItemAtPath:moveFilePath toPath:dstFilePath error:&error];
        if (!ret) {
            fileName = [fileName stringByDeletingPathExtension];
            if (![msg containsString:fileName]) {
                msg = [msg stringByAppendingFormat:@"%@ ",fileName];
            }
            moveRet = ret;
        }
    }
    if ([[SNiCloudTool shareInstance]canSynICloud]) {
        NSArray * urls = [[SNiCloudTool shareInstance] getiCloudUrlWithSeletedPaths:files];
        NSURL * toDirUrl = [[SNiCloudTool shareInstance] getiCloudUrlWithLocalPath:toDir];
        [[SNiCloudTool shareInstance] moveFilesFromICloudWithUrls:urls toDir:toDirUrl];
    }
   
    if (completed) {
        completed(moveRet,msg);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kSNMindFilePathDidChangedNotification object:nil];
}

-(BOOL)checkCanEidt{
    BOOL can = YES;
    for (SNFileModel * model in self.dataSource) {
        if (model.iCloudStatus != SNFileiCloudStatusNormal) {
            can = NO;
            break;
        }
    }
    return can;
}

#pragma mark - iCloud

-(void)setCurrentPath:(NSString *)currentPath{
    _currentPath = currentPath;
    self.parentPath = [self getRelativePathPath:[currentPath copy]];
}

-(NSString *)getRelativePathPath:(NSString *)filePath{
    NSRange range = [filePath rangeOfString:@"Documents" options:NSBackwardsSearch];
    NSString * relative = [filePath substringWithRange:NSMakeRange(range.location, filePath.length - range.location)];
    return relative;
}





// -------------------------------------------------------------------------------
//  handleQueryUpdates:ubiquitousQuery
//
//  Used for examining what new results came from our NSMetadataQuery.
//  This method is shared between "finishGathering" and "didUpdate" methods.
// -------------------------------------------------------------------------------

-(BOOL)justCurrentPathItem:(NSMetadataItem *)item{
    
    
    NSString *path = [item valueForAttribute:NSMetadataItemPathKey];
    NSString *displayName = [path lastPathComponent];
    NSString * relativePath = [self getRelativePathPath:path];
    NSString * removeString = [NSString stringWithFormat:@"/%@",displayName];
    NSString * parentPath = [relativePath stringByReplacingOccurrencesOfString:removeString withString:@""];
    if ([parentPath isEqualToString:self.parentPath]) {
        return YES;
    }
    return NO;
}

- (void)handleQueryUpdates:(NSMetadataQuery *)ubiquitousQuery
{
    // sort the results
    _sortedResults = [self.ubiquitousQuery.results sortedArrayUsingComparator:^NSComparisonResult(id firstObj, id secondObj) {
        NSString *firstTitle = [firstObj valueForAttribute:NSMetadataItemDisplayNameKey];
        NSString *secondTitle = [secondObj valueForAttribute:NSMetadataItemDisplayNameKey];
        return [firstTitle compare:secondTitle];
    }];
    _sortedResults = [_sortedResults filteredArrayWithBlock:^BOOL(id objc) {
        return [self justCurrentPathItem:objc];
    }];

    if ([self.delegate respondsToSelector:@selector(didRetrieveCloud)])
    {
        [self.delegate didRetrieveCloud];
    }
    [self stopScanning];
}

// -------------------------------------------------------------------------------
//  setupQuery
// -------------------------------------------------------------------------------
- (void)setupQuery
{
    _ubiquitousQuery = [[NSMetadataQuery alloc] init];
    self.ubiquitousQuery.notificationBatchingInterval = 15;
    self.ubiquitousQuery.searchScopes = @[NSMetadataQueryUbiquitousDocumentsScope];
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    
    self.ubiquitousQuery.operationQueue = queue;
    
    __weak SNMindFileViewModel *weakSelf = self;
    
    self.metadataQueryStartObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NSMetadataQueryDidStartGatheringNotification object:self.ubiquitousQuery queue:queue usingBlock:^(NSNotification *gatherNotification)
                                       {
                                           // use "weakSelf" to refer back to the object that owns this query
                                           if (weakSelf != nil)
                                           {
                                               NSMetadataQuery *const query = gatherNotification.object;
                                               
                                               // we should invoke this method before iterating over query results that could change due to live updates
                                               [query disableUpdates];
                                               
                                               NSLog(@"didStart...");
                                               
                                               // call our delegate that we started scanning out ubiquitous container
                                               if ([weakSelf.delegate respondsToSelector:@selector(didStartRetrievingCloud)])
                                               {
                                                   [weakSelf.delegate didStartRetrievingCloud];
                                               }
                                               
                                               // enable updates again
                                               [query enableUpdates];
                                           }
                                       }];
    
    self.metadataQueryGatherObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NSMetadataQueryDidFinishGatheringNotification object:self.ubiquitousQuery queue:queue usingBlock:^(NSNotification *gatherNotification)
                                        {
                                            // use "weakSelf" to refer back to the object that owns this query
                                            if (weakSelf != nil)
                                            {
                                                NSMetadataQuery *const query = gatherNotification.object;
                                                
                                                // we should invoke this method before iterating over query results that could change due to live updates
                                                [query disableUpdates];
                                                
                                                NSLog(@"finishGathering...");
                                                
                                                [weakSelf handleQueryUpdates:self.ubiquitousQuery];
                                                
                                                // enable updates again
                                                [query enableUpdates];
                                            }
                                        }];
    
    self.metadataQueryUpdateObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NSMetadataQueryDidUpdateNotification object:self.ubiquitousQuery queue:queue usingBlock:^(NSNotification *queryUpdateNotification)
                                        {
                                            // use "weakSelf" to refer back to the object that owns this query
                                            if (weakSelf != nil)
                                            {
                                                NSMetadataQuery *const query = queryUpdateNotification.object;
                                                
                                                // we should invoke this method before iterating over query results that could change due to live updates
                                                [query disableUpdates];
                                                
                                                NSLog(@"didUpdate...");
                                                [weakSelf handleQueryUpdates:self.ubiquitousQuery];
                                                
                                                // enable updates again
                                                [query enableUpdates];
                                            }
                                        }];
    
    self.metadataQueryGatherObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NSMetadataQueryGatheringProgressNotification object:self.ubiquitousQuery queue:queue usingBlock:^(NSNotification *queryUpdateNotification)
                                        {
                                            // use "weakSelf" to refer back to the object that owns this query
                                            if (weakSelf != nil)
                                            {
                                                NSMetadataQuery *const query = queryUpdateNotification.object;
                                                
                                                // we should invoke this method before iterating over query results that could change due to live updates
                                                [query disableUpdates];
                                                
                                                NSLog(@"gathering...");
                                                //.. do what ever you need to do while gathering results
                                                
                                                // enable updates again
                                                [query enableUpdates];
                                            }
                                        }];
}

- (void)removeQuery
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.metadataQueryStartObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.metadataQueryGatherObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.metadataQueryFinishObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.metadataQueryUpdateObserver];
    [self stopScanning];
    _ubiquitousQuery = nil;
}

// -------------------------------------------------------------------------------
//  startScanning
// -------------------------------------------------------------------------------
- (BOOL)startScanning
{
    
    if ([[SNiCloudTool shareInstance] canSynICloud]) {
        return [self.ubiquitousQuery startQuery];
    }else{
        return NO;
    }
    
}

// -------------------------------------------------------------------------------
//  stopScanning
// -------------------------------------------------------------------------------
- (void)stopScanning
{
    [self.ubiquitousQuery stopQuery];
}

// -------------------------------------------------------------------------------
//  restartScan
// -------------------------------------------------------------------------------
- (void)restartScan
{
    [self stopScanning];
    [self startScanning];
}



@end
