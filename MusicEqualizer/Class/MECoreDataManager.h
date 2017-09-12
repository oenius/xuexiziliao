//
//  MECoreDataManager.h
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/26.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SBSingletonTool.h"

#define kTempEQID  @"temppppp"

@class MEMusic;
@class MEList;
@class MEEqualizer;

@interface MECoreDataManager : NSObject

SBSingle_h(Manager)

//@property (readonly, strong, nonatomic) NSPersistentContainer *persistentContainer;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;

-(void)save;

-(NSString *)documentDirectoryPath;

-(NSURL *)defaultDirectoryURL;

-(void)deleteObject:(NSManagedObject *)object;

#pragma music
-(MEMusic *)insertMusic;

-(NSArray<MEMusic*>*)getAllMusicNoList;

-(void)deleteAllDocumentMusicNoList;

-(void)deleteAlliPodMusicNoList;

-(void)checkMusicFavoriteSetToYesOrNo:(MEMusic *)music yesOrNO:(BOOL)isFavorite;

/* 复制和insert一个音乐实体*/
-(MEMusic *)copyMusic:(MEMusic *)music toList:(MEList *)list;

#pragma List

-(MEList *)insertMusicList;

-(NSArray<MEList*>*)getAllMusicList;

//-(NSArray <MEList*>*)searchAllMusic;

-(NSArray <MEList*>*)searchMusicListWithName:(NSString *)name;

#pragma MEEqualizer

-(void)setDefalultEqualizer;

-(MEEqualizer *)insertEqualizer;

-(MEEqualizer *)getEmptyEqualizer;

-(MEEqualizer *)getCurrentEqualizer;

-(NSArray <MEEqualizer *>*)getAllEQArray;

-(NSInteger)getDefaultEQCount;

-(MEEqualizer *)saveEqualizerWithEQArray:(NSArray <NSNumber *>*)EQArray andName:(NSString *)name;

@end
