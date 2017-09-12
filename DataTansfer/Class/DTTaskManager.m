//
//  DTTaskManager.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/27.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTTaskManager.h"
#import "DTPhotoViewModel.h"
#import "DTContactViewModel.h"
//#import "DTMusicViewModel.h"
@interface DTTaskManager ()<DTDwonTaskDeletage>
///失败的任务
@property (nonatomic,strong,readwrite) NSMutableArray <DTDwonTask *>* failedTaskList;
///正在下载的任务
@property (nonatomic,strong,readwrite) NSMutableArray <DTDwonTask *>* runingTaskList;
///正在等待的任务
@property (nonatomic,strong,readwrite) NSMutableArray <DTDwonTask *>* waitingTaskList;
///
@property (nonatomic,strong,readwrite) NSMutableArray <DTDwonTask *>* successTaskList;

@property (nonatomic,strong) PHAssetCollection * collection;


@property (nonatomic,strong) NSOperationQueue * saveContactQueue;
@property (nonatomic,strong) NSOperationQueue * savePhotoVideoQueue;
@property (nonatomic,strong) NSOperationQueue * saveMusicQueue;
@property (nonatomic,strong) NSString * musicsDir;



@end


@implementation DTTaskManager
Singleton_M(Managaer)


#pragma mark - 懒加载

-(NSString *)musicsDir{
    if (nil == _musicsDir) {
        _musicsDir = [DTConstAndLocal getMusicsDir];
    }
    return _musicsDir;
}

-(NSOperationQueue *)saveContactQueue{
    if (!_saveContactQueue) {
        _saveContactQueue = [[NSOperationQueue alloc]init];
        _saveContactQueue.maxConcurrentOperationCount = 1;
    }
    return _saveContactQueue;
}
-(NSOperationQueue *)savePhotoVideoQueue{
    if (!_savePhotoVideoQueue) {
        _savePhotoVideoQueue = [[NSOperationQueue alloc]init];
        _savePhotoVideoQueue.maxConcurrentOperationCount = 1;
    }
    return _savePhotoVideoQueue;
}

-(NSOperationQueue *)saveMusicQueue{
    if (!_saveMusicQueue) {
        _saveMusicQueue = [[NSOperationQueue alloc]init];
        _saveMusicQueue.maxConcurrentOperationCount = 1;
    }
    return _saveMusicQueue;
}

-(NSMutableArray<DTDwonTask *> *)successTaskList{
    if (!_successTaskList) {
        _successTaskList = [NSMutableArray array];
    }
    return _successTaskList;
}

-(NSMutableArray<DTDwonTask *> *)failedTaskList{
    if (!_failedTaskList) {
        _failedTaskList = [NSMutableArray array];
    }
    return _failedTaskList;
}
-(NSMutableArray <DTDwonTask*>*)runingTaskList{
    if (!_runingTaskList) {
        _runingTaskList = [NSMutableArray array];
    }
    return _runingTaskList;
}
-(NSMutableArray <DTDwonTask*>*)waitingTaskList{
    if (!_waitingTaskList) {
        _waitingTaskList = [NSMutableArray array];
    }
    return _waitingTaskList;
}

-(NSUInteger)maxTaskCount{
    if (_maxTaskCount == 0) {
        _maxTaskCount = 1;
    }
    if (_maxTaskCount > 10) {
        _maxTaskCount = 10;
    }
    return _maxTaskCount;
}



#pragma mark - 任务管理
///添加任务
-(void)addTasks:(NSArray <DTDwonTask *>*)tasks{
    
    for (DTDwonTask * task in tasks) {
        task.delegate = self;
    }
    [self.waitingTaskList addObjectsFromArray:tasks];
    
}
///删除任务
-(void)deleteTask:(DTDwonTask *)task{
    if ([self.runingTaskList containsObject:task]) {
        [self.waitingTaskList removeObject:task];
    }
}

-(void)pauseTask:(DTDwonTask *)task{
    if ([self.runingTaskList containsObject:task]) {
        [task pause];
        [self.runingTaskList removeObject:task];
        [self.waitingTaskList addObject:task];
        [self addTaskToRuningList];
    }
}

-(void)retryTask:(DTDwonTask *)task{
    [task retry];
    if ([self.failedTaskList containsObject:task]) {
        [self.failedTaskList removeObject:task];
    }
    if ([self.waitingTaskList containsObject:task]) {
        [self.waitingTaskList removeObject:task];
    }
    [self.waitingTaskList addObject:task];
    if (self.runingTaskList.count == 0) {
        [self startDownLoad];
    }
}

-(void)resumeTask:(DTDwonTask *)task{
    
    
}


///管理任务
-(void)startDownLoad{
    if (self.waitingTaskList.count >= self.maxTaskCount) {
        for (int i = 0; i < self.maxTaskCount; i ++) {
            DTDwonTask * task = [self.waitingTaskList objectAtIndex:i];
            [task resume];
            [self.runingTaskList addObject:task];
        }
        [self.waitingTaskList removeObjectsInRange:NSMakeRange(0, self.maxTaskCount)];
    }else{
        [self.runingTaskList addObjectsFromArray:self.waitingTaskList];
        [self.waitingTaskList removeAllObjects];
    }
    
    
}

-(void)pauseDownLoad{
    for (DTDwonTask * task in self.runingTaskList) {
        [task pause];
    }
}

-(void)resumeDownload{
    for (DTDwonTask * task in self.runingTaskList) {
        [task resume];
    }
}

-(void)cancelDownLoad{
    for (DTDwonTask * task in self.runingTaskList) {
        [task cancel];
    }
    NSIndexSet * indexs = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.runingTaskList.count)];
    [self.waitingTaskList insertObjects:self.runingTaskList atIndexes:indexs];
    [self.runingTaskList removeAllObjects];
    [self.waitingTaskList removeAllObjects];
    [self.failedTaskList removeAllObjects];
    [self.successTaskList removeAllObjects];
}

-(void)addTaskToRuningList{
    if (self.waitingTaskList.count > 0) {
        DTDwonTask * task =[self.waitingTaskList objectAtIndex:0];
        [task resume];
        [self.runingTaskList addObject:task];
        [self.waitingTaskList removeObject:task];
    }
    else if (self.runingTaskList.count <= 0) {
        if ([self.delegate respondsToSelector:@selector(allTaskDidDownload:)]) {
            [self.delegate allTaskDidDownload:self];
        }
    }
}
#pragma mark  - DTDwonTaskDeletage


-(void)downTaskBeginDownload:(DTDwonTask *)task{
    LOG(@"%s - %@",__func__,task);
    if ([self.delegate respondsToSelector:@selector(currentTaskBeginDwonload:)]) {
        [self.delegate currentTaskBeginDwonload:task];
    }
}

-(void)downTask:(DTDwonTask *)task statusChanged:(DTDwonTaskStatus) status{
    LOG(@"%s - %@",__func__,task);
    if ([self.delegate respondsToSelector:@selector(currentTask:statusChanged:)]) {
        [self.delegate currentTask:task statusChanged:status];
    }
}

-(void)downTask:(DTDwonTask *)task didError:(NSError *)error{
    LOG(@"%s - %@",__func__,task);
    [self.failedTaskList addObject:task];
    [self.runingTaskList removeObject:task];
    [self addTaskToRuningList];
    if ([self.delegate respondsToSelector:@selector(currentTask:didError:)]) {
        [self.delegate currentTask:task didError:error];
    }
}

-(void)downTask:(DTDwonTask *)task didSuccessPath:(NSURL *)filePath dataModel:(id) dataModel{
    
    [self.successTaskList addObject:task];
    [self.runingTaskList removeObject:task];
    [self addTaskToRuningList];    
    [self addTaskToQueue:task model:dataModel];
    
}

-(void)downTask:(DTDwonTask *)task progress:(CGFloat)progress{
    LOG(@"%s - %@",__func__,task);
    LOG(@"progress->%g",progress);
    if ([self.delegate respondsToSelector:@selector(currentTask:progress:)]) {
        [self.delegate currentTask:task progress:progress];
    }
}

#pragma mark - 创建保存任务
-(void)addTaskToQueue:(DTDwonTask *)task model:(id)model{
    switch (task.downType) {
        case DTFileTypeContact:{
           NSOperation * operation = [self creatSaveContactOperation:task model:model];
            [self.saveContactQueue addOperation:operation];
        }
            break;
        case DTFileTypePhtoto:{
             NSOperation * operation = [self creatSavePhotoOperation:task model:model];
            [self.savePhotoVideoQueue addOperation:operation];

        }
            break;
        case DTFileTypeVideo:{
            NSOperation * operation = [self creatSaveVideoOperation:task model:model];
            [self.savePhotoVideoQueue addOperation:operation];
        }
            break;
        case DTFileTypeMusic:{
//            NSOperation * operation =  [self creatSaveMusicOperation:task model:model];
//            [self.saveMusicQueue addOperation:operation];
        }
            break;
            
        default:
            break;
    }
}

-(NSOperation *)creatSaveContactOperation:(DTDwonTask *)task model:(DTContactModel *)model{
    NSBlockOperation * operation = [NSBlockOperation blockOperationWithBlock:^{
        [self saveContact:model completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                task.status = DTDwonTaskStatusSaveSuccesse;
            }else{
                task.status = DTDwonTaskStatusSaveFailed;
            }
        }];
        
    }];
    return operation;
}

-(NSOperation *)creatSavePhotoOperation:(DTDwonTask *)task model:( DTAssetModel *)model{
    NSBlockOperation * operation = [NSBlockOperation blockOperationWithBlock:^{
        [self savePhoto:model completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                task.status = DTDwonTaskStatusSaveSuccesse;
            }else{
                task.status = DTDwonTaskStatusSaveFailed;
            }
        }];
    }];

    return operation;
}

-(NSOperation *)creatSaveVideoOperation:(DTDwonTask *)task model:(DTAssetModel *)model{
    NSBlockOperation * operation = [NSBlockOperation blockOperationWithBlock:^{
        [self saveVideo:model fileUrl:task.downloadFilePath completionHandler:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               [[NSFileManager defaultManager] removeItemAtURL:task.downloadFilePath error:nil];
            });
                           
            if (success) {
                task.status = DTDwonTaskStatusSaveSuccesse;
            }else{
                task.status = DTDwonTaskStatusSaveFailed;
            }
        }];
    }];
    return operation;
}

//-(NSOperation *)creatSaveMusicOperation:(DTDwonTask *)task model:(DTMusicModel *)model{
//    
//    NSBlockOperation * operation = [NSBlockOperation blockOperationWithBlock:^{
//        [self saveMusic:model fileUrl:task.downloadFilePath completionHandler:^(BOOL success, NSError *error) {
//            if (success) {
//                task.status = DTDwonTaskStatusSaveSuccesse;
//            }else{
//                task.status = DTDwonTaskStatusSaveFailed;
//                LOG(@"%@",error);
//            }
//        }];
//    }];
//    return operation;
//}

#pragma mark - 保存相关

-(void)saveContact:(DTContactModel *)model completionHandler:(void(^)(BOOL success, NSError * error))completionHandler{
    if ([CNContactStore class]) {
        CNMutableContact * contact = [model getMutableContact];
        CNSaveRequest * request = [[CNSaveRequest alloc]init];
        [request addContact:contact toContainerWithIdentifier:nil];
        CNContactStore * store = [[CNContactStore alloc]init];
        NSError * error;
        [store executeSaveRequest:request error:&error];
        if (error) {
            completionHandler(NO,[NSError new]);
        }else{
            completionHandler(YES,nil);
        }
    }else{
        [self saveContactiOS9Before:model completionHandler:completionHandler];
    }
    
    
}
- (void)saveContactiOS9Before:(DTContactModel *)model completionHandler:(void(^)(BOOL success, NSError * error))completionHandler{

    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABRecordRef person = ABPersonCreate();
    
    CFErrorRef error;
    
    ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)(model.givenName), nil);
    ABRecordSetValue(person, kABPersonMiddleNameProperty, (__bridge CFTypeRef)(model.middleName), nil);
    ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFTypeRef)(model.familyName), nil);
    ABRecordSetValue(person, kABPersonNicknameProperty, (__bridge CFTypeRef)(model.nickname), nil);
    ABRecordSetValue(person, kABPersonOrganizationProperty, (__bridge CFTypeRef)(model.organizationName), nil);
    ABRecordSetValue(person, kABPersonNoteProperty, (__bridge CFTypeRef)(model.note), nil);
    
    ABMutableMultiValueRef phoneNumRef = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    NSArray * phones = model.phoneNumbers;
    NSMutableArray *phoneNumbers = [NSMutableArray array];
    if (phones.count>0) {
        id testClass = phones[0];
        if (testClass) {
            if ([testClass isKindOfClass:[NSDictionary class]] ||
                [testClass isKindOfClass:[NSMutableDictionary class]]) {
                for (int i = 0; i < phones.count; i++) {
                    NSDictionary *phoneDict = phones[i];
                    [phoneNumbers addObject:phoneDict[@"phoneNumber"]];
                    ABMultiValueInsertValueAndLabelAtIndex(phoneNumRef, (__bridge CFTypeRef)(phoneDict[@"phoneNumber"]), (__bridge CFStringRef)(phoneDict[@"phoneLabel"]), i, NULL);
                }
            }
        }
    }
    
   
    
    ABPersonSetImageData(person, (__bridge CFDataRef)(model.imageData), nil);
    
    // Elimnate double
    NSString *fetchName = [NSString stringWithFormat:@"%@%@%@",model.givenName,model.middleName,model.familyName];
    NSArray *persons = (__bridge NSArray *)(ABAddressBookCopyPeopleWithName(addressBook, (__bridge CFStringRef)(fetchName)));
    for (int i = 0; i < persons.count; i++) {
        
        ABRecordRef personHas = (__bridge ABRecordRef)(persons[i]);
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(personHas, kABPersonFirstNameProperty);
        if (firstName == nil) {
            firstName = @"";
        }
        NSString *middleName = (__bridge NSString *)ABRecordCopyValue(personHas, kABPersonMiddleNameProperty);
        if (middleName == nil) {
            middleName = @"";
        }
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(personHas, kABPersonLastNameProperty);
        if (lastName == nil) {
            lastName = @"";
        }
        
        NSString *targetName = [NSString stringWithFormat:@"%@%@%@",firstName,middleName,lastName];
        
        if ([fetchName isEqualToString:targetName]) {
            
            ABMutableMultiValueRef phoneNumRefHas = ABRecordCopyValue(personHas, kABPersonPhoneProperty);
            for (int i = 0 ; i < ABMultiValueGetCount(phoneNumRefHas); i++) {
                NSString * phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumRefHas, i);
                NSString * label = (__bridge NSString *)(ABMultiValueCopyLabelAtIndex(phoneNumRefHas, i));
                if (![phoneNumbers containsObject:phoneNumber]) {
                    ABMultiValueAddValueAndLabel(phoneNumRef, (__bridge CFTypeRef)(phoneNumber), (__bridge CFStringRef)(label), NULL);
                }
            }
            ABAddressBookRemoveRecord(addressBook, personHas, nil);
        }
    }
    
    ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumRef, nil);
    ABAddressBookAddRecord(addressBook, person, nil);
    ABAddressBookSave(addressBook, &error);
    if (error) {
        completionHandler(NO,[NSError new]);
    }else{
        completionHandler(YES,nil);
    }
    
}

//-(void)saveMusic:(DTMusicModel *)model fileUrl:(NSURL *)fileUrl
//                             completionHandler:(void(^)(BOOL success, NSError * error))completionHandler{
//    
//    NSString * newMusicPath = [self.musicsDir stringByAppendingPathComponent:model.fileUrlPath];
//    NSURL * newMusicUrl = [NSURL fileURLWithPath: newMusicPath] ;
//    NSError * error;
//    if ([[NSFileManager defaultManager] fileExistsAtPath:newMusicPath]) {
//        [[NSFileManager defaultManager] removeItemAtPath:newMusicPath error:nil];
//    }
//    
//    [[NSFileManager defaultManager] moveItemAtURL:fileUrl toURL:newMusicUrl error:&error];
//    if (error) {
//        completionHandler(NO,error);
//        return;
//    }
//    completionHandler(YES,nil);
//    
//}

-(void)saveVideo:(DTAssetModel *)model fileUrl:(NSURL *)fileUrl
                             completionHandler:(void(^)(BOOL success, NSError * error))completionHandler{
    WEAKSELF_DT
    NSError * error;
    if (self.collection == nil) {
        self.collection = [weakSelf getAssetCollection:&error];
    }
    
    LOG(@"%@",error);
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest * creationRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileUrl];
        creationRequest.creationDate = model.creationDate;
        creationRequest.favorite = model.favorite;
        creationRequest.location = model.location;
        
        if (_collection) {
            PHAssetCollectionChangeRequest * addAssetRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:_collection];
            [addAssetRequest addAssets:@[creationRequest.placeholderForCreatedAsset]];
        }
    } completionHandler:completionHandler];
}


-(void)savePhoto:(DTAssetModel *)model completionHandler:(void(^)(BOOL success, NSError * error))completionHandler{
    WEAKSELF_DT
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        UIImage * image = [UIImage imageWithData:model.assetData];
        PHAssetChangeRequest * creationRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        creationRequest.creationDate = model.creationDate;
        creationRequest.favorite = model.favorite;
        creationRequest.location = model.location;
        NSError * error;
        if (self.collection == nil) {
            self.collection = [weakSelf getAssetCollection:&error];
        }
        if (_collection) {
            PHAssetCollectionChangeRequest * addAssetRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:_collection];
            [addAssetRequest addAssets:@[creationRequest.placeholderForCreatedAsset]];
        }
        LOG(@"%@",error);
    } completionHandler:completionHandler];
    
}

-(NSString *)getAppName{
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if ([appName length] == 0 || appName == nil)
    {
        appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey];
    }
    return appName;
}

//  获得相簿
-(PHAssetCollection *)getAssetCollection:(NSError **)error{
    NSString * collectionName = [[NSUserDefaults standardUserDefaults] objectForKey:@"collectionName"];
    if (collectionName == nil) {
        collectionName = [self getAppName];
        [[NSUserDefaults standardUserDefaults]setObject:collectionName forKey:@"collectionName"];
        [[NSUserDefaults standardUserDefaults]synchronize];
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

@end
