//
//  SNiCloudTool.h
//  MindMap
//
//  Created by 何少博 on 2017/9/1.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SNNodeAsset;
@class SNICloudMap;
@interface SNiCloudTool : NSObject
//可做持久化 用户打开应用时和当前的 token 对比 用来检测账号和权限
@property (strong, nonatomic) id ubiquityToken;
@property (strong, nonatomic) NSURL * ubiquityContainer;
@property (strong, nonatomic) NSURL * iCloudDocumnetUrl;

+(instancetype)shareInstance;

-(void)synCurrentUbiquityIdentityToken;
-(void)checkiCloudStatus;
-(BOOL)canSynICloud;

-(void)creatNewFolderToICloudWithUrl:(NSURL *)url;
-(void)creatMapToICloud:(SNICloudMap*)map url:(NSURL *)url isNewMap:(BOOL)newMap;
-(BOOL)uploadFolderWithPath:(NSString *)floderPath;
-(void)uplaodMapWithAssetPath:(NSString *)assetPath completed:(void(^)(BOOL success)) completed;

-(void)deleteFileFormICouldWithUrls:(NSArray*)fileUrls;
-(void)moveFilesFromICloudWithUrls:(NSArray *)files toDir:(NSURL *) toDir;
-(void)copyFilesFromICloudWithUrls:(NSArray *)files toDir:(NSURL *) toDir;
-(void)renamefileICloudUrl:(NSURL *)oriUrl newNameUrl:(NSURL *)newNameUrl;

-(NSURL *)getiCloudUrlWithRelativePath:(NSString *)relativePath;
-(NSURL *)getiCloudUrlWithLocalPath:(NSString *)locPath;
-(NSArray *)getiCloudUrlWithSeletedPaths:(NSArray <NSString *>*)paths;
//------------------------------------------
//测试使用
//------------------------------------------
-(BOOL)removeAllFileAtiCloud;
//------------------------------------------
@end
