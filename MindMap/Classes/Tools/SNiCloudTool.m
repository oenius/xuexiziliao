//
//  SNiCloudTool.m
//  MindMap
//
//  Created by 何少博 on 2017/9/1.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNiCloudTool.h"
#import "SNDocument.h"
#import "SNNodeAsset.h"
#import "SNICloudMap.h"
#import "NPCommonConfig+FeiFan.h"
#import "UIAlertController+SN.h"
static NSString * const kContainerID = @"iCloud.com.bowangliu.mindmap";
static NSString * const kIdentityToken = @"kIdentityToken";


@interface SNiCloudTool ()

@property (nonatomic,assign) NSInteger checkStatus;
@end

@implementation SNiCloudTool


+ (instancetype)shareInstance {
    static dispatch_once_t predicate;
    static SNiCloudTool *instance = nil;
    dispatch_once(&predicate, ^{
        instance = [[SNiCloudTool alloc] init];
        [instance setup];
    });
    return instance;
}


-(void)checkiCloudStatus{
    if (![[NPCommonConfig shareInstance] hasBuySubscription]) {
        return;
    }
    id currentToken = [NSFileManager defaultManager].ubiquityIdentityToken;
    id oldToken = [[NSUserDefaults standardUserDefaults] objectForKey:kIdentityToken];
    if (currentToken != nil) {
        [self synCurrentUbiquityIdentityToken];
    }
    if (currentToken == nil)
    {
        
        NSInteger checkStatusCountPer = 10;
        if (_checkStatus % checkStatusCountPer == 0) {
            NSString * message = NSLocalizedString(@"blurpuzzle.icloud.open", @"请在设置中登录你的icloud账户,并打开iCloud Drive...");
            UIViewController * topM = [self topMostController];
            [UIAlertController alertMessage:message controller:topM okHandler:^(UIAlertAction *okAction) {
                
            }];
        }
        _checkStatus ++;
        
        return;
    }
    else if (oldToken != nil && ![oldToken isEqual:currentToken])
    {
        NSInteger checkStatusCountPer = 10;
        if (_checkStatus % checkStatusCountPer == 0) {
            NSString * message = NSLocalizedString(@"iCloud account changed", @"iCloud账号发生变化");
            UIViewController * topM = [self topMostController];
            [UIAlertController alertMessage:message controller:topM okHandler:^(UIAlertAction *okAction) {
                [self synCurrentUbiquityIdentityToken];
            }];
        }
        _checkStatus ++;
        return;
    }
    
}
-(void)synCurrentUbiquityIdentityToken{
    id token = [NSFileManager defaultManager].ubiquityIdentityToken;
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kIdentityToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSURL *)ubiquityContainer{
    return [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:kContainerID];
}

-(id)ubiquityToken{
    return [NSFileManager defaultManager].ubiquityIdentityToken;
}


-(BOOL)canSynICloud{
    if ([[NPCommonConfig shareInstance] hasBuySubscription]&&self.ubiquityContainer != nil) {
        return YES;
    }
    return NO;
}
//------------------------------------------------------------------------------------
//文件处理
//------------------------------------------------------------------------------------
-(NSArray *)getiCloudUrlWithSeletedPaths:(NSArray <NSString *>*)paths{
    NSMutableArray * array = [NSMutableArray array];
    for (NSString * filePath in paths) {
        if ([filePath containsString:kMapSuffix]) {
            continue;
        }
        NSURL * ulr = [self getiCloudUrlWithLocalPath:filePath];
        if (ulr) {
            [array addObject:ulr];
        }
        
    }
    return array;
}
-(NSURL *)getiCloudUrlWithLocalPath:(NSString *)locPath{
    NSRange range = [locPath rangeOfString:@"Documents"];
    NSString * abPath = [locPath substringWithRange:NSMakeRange(range.location, locPath.length - range.location)];
    NSURL * url = [self.ubiquityContainer URLByAppendingPathComponent:abPath];

    return url;
}

-(NSURL *)getiCloudUrlWithRelativePath:(NSString *)relativePath{
    NSURL * url = [self.ubiquityContainer URLByAppendingPathComponent:relativePath];
    return url;
}



-(void)creatNewFolderToICloudWithUrl:(NSURL *)url{
    
    [self creatFolderToiCloud:url];
}

-(void)creatMapToICloud:(SNICloudMap *)map url:(NSURL *)url isNewMap:(BOOL)newMap{
    
    if (newMap) {
        [self creatMapToiCloud:map url:url completed:^(BOOL success) {
            
        }];
    }else{
        SNDocument * mapDocument = [[SNDocument alloc]initWithFileURL:url];
        mapDocument.map = map;
        [mapDocument saveToURL:url forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"map UIDocumentSaveForOverwriting save success");
            }else{
                NSLog(@"map UIDocumentSaveForOverwriting save fail");
            }
        }];
    }
}

-(BOOL)uploadFolderWithPath:(NSString *)floderPath{
    
    NSURL * url = [self getiCloudUrlWithLocalPath:floderPath];
    BOOL success = [self creatFolderToiCloud:url];
    return success;
}
-(void)uplaodMapWithAssetPath:(NSString *)assetPath completed:(void(^)(BOOL success)) completed{
    
    NSString * mapPath = [assetPath stringByReplacingOccurrencesOfString:kAssetSuffix withString:kMapSuffix];
    NSData * assetData = [NSData dataWithContentsOfFile:assetPath];
    NSData * mapData = [NSData dataWithContentsOfFile:mapPath];
    if (assetData != nil && mapData != nil) {
        SNICloudMap * map = [[SNICloudMap alloc]init];
        map.assetData = assetData;
        map.mapData = mapData;
        NSURL * iCloudUrl = [self getiCloudUrlWithLocalPath:assetPath];
        [self creatMapToiCloud:map url:iCloudUrl completed:completed];
    }
}

-(void)creatMapToiCloud:(SNICloudMap *)map url:(NSURL *) url completed:(void(^)(BOOL success)) completed{
    
    SNDocument * mapDocument = [[SNDocument alloc]initWithFileURL:url];
    mapDocument.map = map;
    [mapDocument saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"map save success");
        }else{
            NSLog(@"map save fail");
        }
        if (completed) {
            completed(success);
        }
    }];
}

-(BOOL)creatFolderToiCloud:(NSURL *)url{
    
    NSFileCoordinator* fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    NSError * coordinatorError;
    __block BOOL success = YES;
    [fileCoordinator coordinateWritingItemAtURL:url options:NSFileCoordinatorWritingForReplacing error:&coordinatorError byAccessor:^(NSURL * _Nonnull newURL) {
        NSError * error;
        success = [[NSFileManager defaultManager] createDirectoryAtURL:newURL withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"创建ICloud文件夹%@",error);
        }else{
            NSLog(@"创建ICloud文件夹成功");
        }
    }];
    if (coordinatorError) {
        NSLog(@"创建文件夹协调器失败:%@",coordinatorError);
    }
    return success;
}

-(void)deleteFileFormICouldWithUrls:(NSArray *)fileUrls{
   
    for (NSURL * url in fileUrls) {
        [self deleteFileFormICloudUrl:url];
    }
    
}

-(void)deleteFileFormICloudUrl:(NSURL *)url{
    NSFileCoordinator * coordinator = [[NSFileCoordinator alloc]initWithFilePresenter:nil];
    NSError * coorError;
    [coordinator coordinateWritingItemAtURL:url options:NSFileCoordinatorWritingForDeleting error:&coorError byAccessor:^(NSURL * _Nonnull newURL) {
        NSError * error;
        [[NSFileManager defaultManager] removeItemAtURL:newURL error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
    }];
    if (coordinator) {
        NSLog(@"%@",coordinator);
    }
}

-(void)copyFilesFromICloudWithUrls:(NSArray *)files toDir:(NSURL *)toDir{
    
    for (NSURL * copyUrl in files) {
        NSString * fileName = [copyUrl lastPathComponent];
        NSURL * newUrl = [toDir URLByAppendingPathComponent:fileName];
        [self copyItem:copyUrl toDir:newUrl];
    }
}

-(void)copyItem:(NSURL *) oriUrl toDir:(NSURL *)toDir{
    NSFileCoordinator * coordinator = [[NSFileCoordinator alloc]initWithFilePresenter:nil];
    NSError * coorError;
    [coordinator coordinateWritingItemAtURL:oriUrl options:NSFileCoordinatorWritingForReplacing writingItemAtURL:toDir options:NSFileCoordinatorWritingForReplacing error:&coorError byAccessor:^(NSURL * _Nonnull newURL1, NSURL * _Nonnull newURL2) {
        NSError * error;
        [[NSFileManager defaultManager] copyItemAtURL:newURL1 toURL:newURL2 error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
    }];
    if (coordinator) {
        NSLog(@"%@",coordinator);
    }
}

-(void)moveFilesFromICloudWithUrls:(NSArray *)files toDir:(NSURL *)toDir{
    
    for (NSURL * moveUrl in files) {
        NSString * fileName = [moveUrl lastPathComponent];
        NSURL * newUrl = [toDir URLByAppendingPathComponent:fileName];
        [self moveItem:moveUrl toDir:newUrl];
    }
}
-(void)moveItem:(NSURL *) oriUrl toDir:(NSURL *)toDir{
    NSFileCoordinator * coordinator = [[NSFileCoordinator alloc]initWithFilePresenter:nil];
    NSError * coorError;
    [coordinator coordinateWritingItemAtURL:oriUrl options:NSFileCoordinatorWritingForMoving writingItemAtURL:toDir options:NSFileCoordinatorWritingForReplacing error:&coorError byAccessor:^(NSURL * _Nonnull newURL1, NSURL * _Nonnull newURL2) {
        NSError * error;
        [[NSFileManager defaultManager] moveItemAtURL:newURL1 toURL:newURL2 error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
    }];
    if (coordinator) {
        NSLog(@"%@",coordinator);
    }
}
-(void)renamefileICloudUrl:(NSURL *)oriUrl newNameUrl:(NSURL *)newNameUrl;{
    
    [self moveItem:oriUrl toDir:newNameUrl];
}
//------------------------------------------------------------------------------------
//测试使用
//------------------------------------------------------------------------------------

-(BOOL)removeAllFileAtiCloud{
    NSFileCoordinator * coordinator = [[NSFileCoordinator alloc]initWithFilePresenter:nil];
    NSError * coorError;
//    [coordinator prepareForReadingItemsAtURLs:<#(nonnull NSArray<NSURL *> *)#> options:<#(NSFileCoordinatorReadingOptions)#> writingItemsAtURLs:<#(nonnull NSArray<NSURL *> *)#> options:<#(NSFileCoordinatorWritingOptions)#> error:<#(NSError * _Nullable __autoreleasing * _Nullable)#> byAccessor:<#^(void (^ _Nonnull completionHandler)(void))batchAccessor#>]
    [coordinator coordinateWritingItemAtURL:self.iCloudDocumnetUrl options:NSFileCoordinatorWritingForDeleting error:&coorError byAccessor:^(NSURL * _Nonnull newURL) {
        NSError * error;
        NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:newURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:&error];
        for (NSURL *url in files) {
            NSError * removeError;
            [[NSFileManager defaultManager] removeItemAtURL:url error:&removeError];
            NSLog(@"%@",removeError);
        }
        NSLog(@"%@",files);
        NSLog(@"%@",error);
    }];
    return coorError == nil ? YES : NO;
}



//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------

-(void)setup{
    
    _ubiquityContainer = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:kContainerID];
    _ubiquityToken = [NSFileManager defaultManager].ubiquityIdentityToken;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ubiquityIdentityChanged:) name:NSUbiquityIdentityDidChangeNotification object:nil];

}


-(NSURL *)iCloudDocumnetUrl{
    return [self.ubiquityContainer URLByAppendingPathComponent:@"Documents" isDirectory:YES];
}

#pragma mark - 监听当前 ubiquity identity 变化通知 （账号变化或者权限变化）
- (void)ubiquityIdentityChanged:(NSNotification *)note
{
    id token = [NSFileManager defaultManager].ubiquityIdentityToken;
    NSString * message = @"";
    if (token == nil){
        _ubiquityContainer = nil;
        message = NSLocalizedString(@"blurpuzzle.icloud.open", @"请在设置中登录你的icloud账户,并打开iCloud Drive...");
        UIViewController * topM = [self topMostController];
        [UIAlertController alertMessage:message controller:topM okHandler:^(UIAlertAction *okAction) {
            [self synCurrentUbiquityIdentityToken];
        }];
    }
    else{
        if ([self.ubiquityToken isEqual:token]){
            
        }
        else{
            message = NSLocalizedString(@"iCloud account changed", @"iCloud账号发生变化");
            _ubiquityContainer = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:kContainerID];
            self.ubiquityToken = token;
            UIViewController * topM = [self topMostController];
            [UIAlertController alertMessage:message controller:topM okHandler:^(UIAlertAction *okAction) {
                [self synCurrentUbiquityIdentityToken];
            }];
        }
        
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



-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
@end
