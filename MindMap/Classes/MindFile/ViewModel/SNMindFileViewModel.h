//
//  SNMindFileViewModel.h
//  MindMap
//
//  Created by 何少博 on 2017/8/7.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SNFileModel;
@protocol SNMindFileViewModelDelegate;
@interface SNMindFileViewModel : NSObject

@property (weak, nonatomic) id<SNMindFileViewModelDelegate> delegate;
@property (nonatomic,readonly,assign) NSInteger fileCount;
@property (copy, nonatomic) NSString *currentPath;
@property (assign, nonatomic) BOOL canBackGroundSearch;

-(instancetype)initWithPath:(NSString *)filePath;

-(NSInteger)numberOfSectionsInTableView;
-(NSInteger)numberOfRowsInSection:(NSInteger) section;
-(SNFileModel *)modelAtIndexPath:(NSIndexPath *)indexPath;
-(NSArray *)getSelectedFilePath:(NSArray<NSIndexPath *>*)selectedIndexPaths;
//-(NSArray *)getiCloudUrlWithSeletedPaths:(NSArray <NSString *>*)paths;
-(NSString *)deleteSelectedFile:(NSArray<NSIndexPath *>*)selectedIndexPaths;
-(NSString *)checkReName:(NSString *) rename;
-(BOOL)renameAtIndexPath:(NSIndexPath *)indexpath name:(NSString *)name;
-(void)reloaData;
-(BOOL)startScanning;
- (void)removeQuery;
-(BOOL)checkCanEidt;
//-(void)synchronizeAlliCloudFile;
-(void)startDownloadFileAtIndexPath:(NSIndexPath *)indexPath completed:(void(^)(BOOL success)) completed;
-(void)startUploadFileAtIndexPath:(NSIndexPath *)indexPath completed:(void(^)(BOOL success)) completed;
-(BOOL)creatNewFolderName:(NSString *)name parentDir:(NSString *)parent;
-(BOOL)saveMapWithAsset:(SNNodeAsset*)nodeAsset
                  nodes:(NSArray *)nodes
               isNewMap:(BOOL)newMap;

-(void)copyFiles:(NSArray *)files toDir:(NSString *) toDir
       completed:(void(^)(BOOL success ,NSString * errorMessage)) completed;
-(void)moveFiles:(NSArray *)files toDir:(NSString *) toDir
       completed:(void(^)(BOOL success ,NSString * errorMessage)) completed;
@end

@protocol SNMindFileViewModelDelegate <NSObject>

-(void)saveMapSuccess;
-(void)didRetrieveCloud;
-(void)didStartRetrievingCloud;

@end
