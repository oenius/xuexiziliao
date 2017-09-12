//
//  MECoreDataManager.m
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/26.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "MECoreDataManager.h"
#import "MEUserDefaultManager.h"
#import "MEMusic.h"
#import "MEList.h"
#import "MEEqualizer.h"
@interface MECoreDataManager ()

@property (readwrite, strong, nonatomic) NSPersistentContainer *persistentContainer;

@property (readwrite, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (readwrite, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (readwrite, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation MECoreDataManager

SBSingle_m(Manager)

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"MEMusicEqualizer"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    LOG(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }else{
                    
                }
            }];
        }
    }
    self.managedObjectContext = _persistentContainer.viewContext;
    self.managedObjectModel = _persistentContainer.managedObjectModel;
    self.persistentStoreCoordinator = _persistentContainer.persistentStoreCoordinator;
    return _persistentContainer;
}

-(NSURL *)defaultDirectoryURL{
    NSURL * url = [NSPersistentContainer defaultDirectoryURL];
    if (url == nil) {
        url = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
    }
    return url;
}

-(NSString *)documentDirectoryPath{
    NSString * docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return docPath;
}

-(NSManagedObjectModel *)managedObjectModel{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = self.persistentContainer.managedObjectModel;
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL * modeUrl = [[NSBundle mainBundle] URLForResource:@"MEMusicEqualizer" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modeUrl];
    return _managedObjectModel;
}

-(NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    _managedObjectContext = self.persistentContainer.viewContext;
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    if (self.persistentStoreCoordinator == nil) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    return  _managedObjectContext;
}


-(NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    //数据迁移 CoreData
    //    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
    //                             [NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption,
    //                             [NSNumber numberWithBool:YES],NSInferMappingModelAutomaticallyOption, nil];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:self.managedObjectModel];
    NSURL * storeUrl = [[self defaultDirectoryURL]URLByAppendingPathComponent:@"MEMusicEqualizer.sqlite"];
    if (storeUrl == nil) {
        NSString * path = [[self documentDirectoryPath] stringByAppendingPathComponent:@"MEMusicEqualizer.sqlite"];
        storeUrl = [NSURL fileURLWithPath:path];
    }
    
    NSError * error;
    NSString * failureReason = @"There was on error creating or loading the apliation's data";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"failed to initaliza the application's save data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        LOG(@"Unresloved error %@,%@",error,[error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    if (context == nil) {
        context = self.managedObjectContext;
    }
    if (context == nil) {
        return;
    }
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        LOG(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}
-(void)save{
    NSError * error;
    [self.managedObjectContext save:&error];
    if (error) {
        LOG(@"保存失败：%@",error);
    }
}

-(void)deleteObject:(NSManagedObject *)object{
    [self.managedObjectContext deleteObject:object];
    [self.managedObjectContext save:nil];
}

#pragma mark - list相关


-(MEList *)insertMusicList{
    MEList *list = [NSEntityDescription insertNewObjectForEntityForName:[MEList entityName] inManagedObjectContext:self.managedObjectContext];
    return list;
}

-(NSArray<MEList*>*)getAllMusicList{
    NSFetchRequest * request = [MEList fetchRequest];
    
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    request.sortDescriptors = @[sort];
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}

//-(NSArray <MEList*>*)searchAllMusic{
//    NSFetchRequest * request = [MEList fetchRequest];
//    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
//    request.sortDescriptors = @[sort];
//    
//    return [self.managedObjectContext executeFetchRequest:request error:nil];
//}

-(NSArray <MEList*>*)searchMusicListWithName:(NSString *)name{
    NSFetchRequest * request = [MEList fetchRequest];
    
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"name = %@",name];
    request.predicate = pre;
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    request.sortDescriptors = @[sort];
    
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}

#pragma mark - music相关
-(MEMusic *)insertMusic{
    MEMusic * music = [NSEntityDescription insertNewObjectForEntityForName:[MEMusic entityName] inManagedObjectContext:self.managedObjectContext];

    return music;
}

-(void)checkMusicFavoriteSetToYesOrNo:(MEMusic *)music yesOrNO:(BOOL)isFavorite{
    NSFetchRequest * request = [MEMusic fetchRequest];
//    NSPredicate * pre = [NSPredicate predicateWithFormat:@"isFavorite = YES"];
//    if (isFavorite == YES) {
//        pre = [NSPredicate predicateWithFormat:@"isFavorite = NO"];
//    }
//    request.predicate = pre;
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    request.sortDescriptors = @[sort];
    NSArray * array = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (MEMusic * oldMusic in array) {
        if (oldMusic.music_id == music.music_id) {
            oldMusic.isFavorite = isFavorite;
            [self save];
        }
    }
}

-(NSArray<MEMusic*>*)getAllMusicNoList{
    NSFetchRequest * request = [MEMusic fetchRequest];
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    request.sortDescriptors = @[sort];
    NSArray * array = [self.managedObjectContext executeFetchRequest:request error:nil];
    NSMutableArray * noListArray = [NSMutableArray array];
    for (MEMusic * music in array) {
        if (music.list == nil) {
            [noListArray addObject:music];
        }
    }
    return noListArray;
}

-(void)deleteAllDocumentMusicNoList{
    
    NSFetchRequest * request = [MEMusic fetchRequest];
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"isiPod = NO"];
    request.predicate = pre;
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    request.sortDescriptors = @[sort];
    NSArray * array = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (MEMusic * music in array) {
        if (music.list == nil) {
            [self.managedObjectContext deleteObject:music];
        }
    }
    [self save];
}

-(void)deleteAlliPodMusicNoList{
    
    NSFetchRequest * request = [MEMusic fetchRequest];
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"isiPod = YES"];
    request.predicate = pre;
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    request.sortDescriptors = @[sort];
    NSArray * array = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (MEMusic * music in array) {
        if (music.list == nil) {
            [self.managedObjectContext deleteObject:music];
        }
    }
    [self save];
}

-(MEMusic *)copyMusic:(MEMusic *)music toList:(MEList *)list{
    
    NSSet * set = list.musics;
    
    for (MEMusic * oldMusic in set) {
        if (oldMusic.music_id == music.music_id) {
            return nil;
        }
    }
    MEMusic * newMusic = [self insertMusic];
    newMusic.describe = [[NSUUID UUID] UUIDString];;
    newMusic.image = [NSData dataWithData:music.image];
    newMusic.iPodUrl = music.iPodUrl;
    if ([list.name isEqualToString:@"myFavorite"]) {
        music.isFavorite = YES;
        newMusic.isFavorite = YES;
    }else{
        newMusic.isFavorite = music.isFavorite;
    }
    newMusic.isiPod = music.isiPod;
    newMusic.localUrl = music.localUrl;
    newMusic.music_id = music.music_id;
    newMusic.name = music.name;
    newMusic.order = [[NSDate date]timeIntervalSince1970];
    newMusic.singer = music.singer;
    newMusic.isEditState = NO;
    newMusic.duration = music.duration;
    newMusic.list = list;
    [self save];
    return newMusic;
}
#pragma MEEqualizer

-(MEEqualizer *)saveEqualizerWithEQArray:(NSArray <NSNumber *>*)EQArray andName:(NSString *)name{
    MEEqualizer *equalizer = [self insertEqualizer];
    equalizer.eq_31  = [[EQArray objectAtIndex:0] floatValue];
    equalizer.eq_62  = [[EQArray objectAtIndex:1] floatValue];
    equalizer.eq_125 = [[EQArray objectAtIndex:2] floatValue];
    equalizer.eq_250 = [[EQArray objectAtIndex:3] floatValue];
    equalizer.eq_500 = [[EQArray objectAtIndex:4] floatValue];
    equalizer.eq_1k  = [[EQArray objectAtIndex:5] floatValue];
    equalizer.eq_2k  = [[EQArray objectAtIndex:6] floatValue];
    equalizer.eq_4k  = [[EQArray objectAtIndex:7] floatValue];
    equalizer.eq_8k  = [[EQArray objectAtIndex:8] floatValue];
    equalizer.eq_16k = [[EQArray objectAtIndex:9] floatValue];
    equalizer.eq_id  = [[NSUUID UUID]UUIDString];
    equalizer.name   = name;
    equalizer.order  = [[NSDate date]timeIntervalSince1970];
    [self save];
    return equalizer;
}

-(NSInteger)getDefaultEQCount{
    NSDictionary * defaultDic = [self defaulutEqualizerDic];
    NSArray * EQs = [defaultDic objectForKey:@"EQs"];
    return EQs.count;
}

-(MEEqualizer *)insertEqualizer{
    MEEqualizer * equalizer = [NSEntityDescription insertNewObjectForEntityForName:[MEEqualizer entityName] inManagedObjectContext:self.managedObjectContext];
    return equalizer;
}

-(NSArray <MEEqualizer *>*)getAllEQArray{
    NSFetchRequest * request = [MEEqualizer fetchRequest];
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    request.sortDescriptors = @[sort];
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}


-(MEEqualizer *)getCurrentEqualizer{
    NSString * currentEQID = [[MEUserDefaultManager defaultManager] getCurrentEQID];
//    if (currentEQID == nil) {
//        return [self getEmptyEqualizer];
//    }
    NSFetchRequest * ruslt = [MEEqualizer fetchRequest];
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"eq_id = %@",currentEQID];
    ruslt.predicate = pre;
    NSArray * array = [self.managedObjectContext executeFetchRequest:ruslt error:nil];
//    if (array == nil || array.count == 0) {
//        return [self insertEqualizer];
//    }
    return array.firstObject;
}


-(MEEqualizer *)getEmptyEqualizer{
    NSFetchRequest * ruslt = [MEEqualizer fetchRequest];
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"name = %@",MEL_none];
    ruslt.predicate = pre;
    NSArray * array = [self.managedObjectContext executeFetchRequest:ruslt error:nil];
    return array.firstObject;
}

-(void)setDefalultEqualizer{
    NSDictionary * defaultDic = [self defaulutEqualizerDic];
    NSArray * EQs = [defaultDic objectForKey:@"EQs"];
    NSArray * names = [defaultDic objectForKey:@"names"];

    for (int i = 0; i < names.count; i ++) {
        NSString * name = names[i];
        NSArray * eqArray = EQs[i];
        MEEqualizer * eq = [[MECoreDataManager defaultManager]insertEqualizer];
        eq.eq_31    = [[eqArray objectAtIndex:0] floatValue];
        eq.eq_62    = [[eqArray objectAtIndex:1] floatValue];
        eq.eq_125   = [[eqArray objectAtIndex:2] floatValue];
        eq.eq_250   = [[eqArray objectAtIndex:3] floatValue];
        eq.eq_500   = [[eqArray objectAtIndex:4] floatValue];
        eq.eq_1k    = [[eqArray objectAtIndex:5] floatValue];
        eq.eq_2k    = [[eqArray objectAtIndex:6] floatValue];
        eq.eq_4k    = [[eqArray objectAtIndex:7] floatValue];
        eq.eq_8k    = [[eqArray objectAtIndex:8] floatValue];
        eq.eq_16k   = [[eqArray objectAtIndex:9] floatValue];
        eq.eq_id    = [[NSUUID UUID] UUIDString];
        eq.name     = name;
        eq.order    = [[NSDate date]timeIntervalSince1970];
        [[MECoreDataManager defaultManager]save];
    }
}

#pragma mark - other

-(NSDictionary *)defaulutEqualizerDic{

    NSArray * EmptyEQ       =     @[@0, @0, @0, @0, @0, @0, @0, @0, @0, @0];
    NSArray * ZhongDiYinEQ  =     @[@6, @8, @7, @4, @0, @(-1), @(-5), @1, @2, @(-2)];
    NSArray * RenShengEQ    =     @[@(-3), @(-5), @(-2), @2, @4, @9, @5, @1, @(-2), @(-3)];
    NSArray * XianChangEQ   =     @[@(-4), @(-3), @3, @5, @5, @5, @4, @3, @2, @1];
    NSArray * LiuXingEQ     =     @[@(-1), @(-1), @0, @2, @3, @3, @2, @0, @(-1), @(-1)];
    NSArray * YaoGunEQ      =     @[@7, @1, @4, @2, @(-3), @2, @5, @5, @7, @5];
    NSArray * MinYaoEQ      =     @[@(-5), @(-4), @2, @4, @4, @3, @(-1), @(-2), @(-4), @(-5)];
    NSArray * DianZiEQ      =     @[@8, @6, @2, @0, @3, @4, @6, @3, @(-1), @0];
    NSArray * JueShiEQ      =     @[@3, @6, @3, @(-4), @(-5), @3, @8, @(-1), @(-2), @3];
    NSArray * GuDianEQ      =     @[@5, @4, @2, @1, @(-1), @0, @2, @3, @3, @3];
    NSArray * ZhongJinShuEQ =     @[@(-2), @2, @3, @(-4), @(-5), @(-4), @0, @4, @6, @2];
    
    NSArray * EQs = @[
                            EmptyEQ,
                            ZhongDiYinEQ,
                            RenShengEQ,
                            XianChangEQ,
                            LiuXingEQ,
                            YaoGunEQ,
                            MinYaoEQ,
                            DianZiEQ,
                            JueShiEQ,
                            GuDianEQ,
                            ZhongJinShuEQ
                          ];
    
    //TODO:可以设置为国际化词条的key 改变的时候注意获取空EQ的方法
    NSArray * names = @[
                        @"none",
                        @"Subwoofer",
                        @"man_voice",
                        @"on_site",
                        @"Pop",
                        @"Rock_Roll",
                        @"ballad",
                        @"Drum & Bass",
                        @"Jazz",
                        @"classical",
                        @"Heavy_metals"
                        ];
//    NSArray * names1 = @[
//                        MEL_none,
//                        MEL_MegaBass,
//                        MEL_Vocal,
//                        MEL_Live,
//                        MEL_Pop,
//                        MEL_Rock_Roll,
//                        MEL_Ballad,
//                        MEL_Drum_Bass,
//                        MEL_Jazz,
//                        MEL_Classic,
//                        MEL_HeavyMetal
//                       ];
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setObject:EQs forKey:@"EQs"];
    [dic setObject:names forKey:@"names"];
    
    return dic;
}
/*
-(NSDictionary *)defaulutEqualizerDic{
    //     Default  { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    //     Club  { 0, 0, 0, 1, 2, 3, 3, 2, 1, 0 }
    //     Dance  { 9, 8, 5, 2, 1, 0, -3, -4, -3,0 }
    //     Full Buss  { 8, 8, 8, 7, 4, 0, -3, -5,-7,-9 }
    //     Full Treble  { -9, -8, -7, -6, -3, 1, 5, 8, 10, 12 }
    //     Pope  { -2, -1, 0, 2, 3, 2, 0, -2, -2, -1 }
    //     Rock  { 6, 5, 2, -2, -5, -2, 0, 3, 5, 6 }
    //     Soft   { 2, 1, 0, 0, -1, 0, 1, 2, 3, 4 }
    //     Large Hall  { 8, 7, 6, 3, 2, 0, -1, -2, -1, 0 }
    //     Party   { 4, 4, 3, 2, 0, 0, 0, 0, 0, 4 }
    NSArray * EmptyEQ =       @[@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0)];
    NSArray * ClubEQ =          @[@(0),@(0),@(0),@(1),@(2),@(3),@(3),@(2),@(1),@(0)];
    NSArray * DanceEQ =         @[@(9),@(8),@(5),@(2),@(1),@(0),@(-3),@(-4),@(-3),@(0)];
    NSArray * FullBussEQ =      @[@(8),@(8),@(8),@(7),@(4),@(0),@(-3),@(-5),@(-7),@(-9)];
    NSArray * FullTrebleEQ =    @[@(-9),@(-8),@(-7),@(-6),@(-3),@(1),@(5),@(8),@(10),@(12)];
    NSArray * PopeEQ =          @[@(-2),@(-1),@(0),@(2),@(3),@(2),@(0),@(-2),@(-2),@(-1)];
    NSArray * RockEQ =          @[@(6),@(5),@(2),@(-2),@(-5),@(-2),@(0),@(3),@(5),@(6)];
    NSArray * SoftEQ =          @[@(2),@(1),@(0),@(0),@(-1),@(0),@(1),@(2),@(3),@(4)];
    NSArray * LargeHallEQ =     @[@(8),@(7),@(6),@(3),@(2),@(0),@(-1),@(-2),@(-1),@(0)];
    NSArray * PartyEQ =         @[@(4),@(4),@(3),@(2),@(0),@(0),@(0),@(0),@(0),@(4)];
    NSArray * objects = @[
                          EmptyEQ,
                          ClubEQ,
                          DanceEQ,
                          FullBussEQ,
                          FullTrebleEQ,
                          PopeEQ,
                          RockEQ,
                          SoftEQ,
                          LargeHallEQ,
                          PartyEQ
                          ];
    
    //TODO:可以设置为国际化词条的key 改变的时候注意获取空EQ的方法
    NSArray * keys = @[
                       @"EmptyEQ",
                       @"ClubEQ",
                       @"DanceEQ",
                       @"FullBussEQ",
                       @"FullTrebleEQ",
                       @"PopeEQ",
                       @"RockEQ",
                       @"SoftEQ",
                       @"LargeHallEQ",
                       @"PartyEQ",
                       ];
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    
    for (int i = 0; i < keys.count; i ++) {
        [dic setObject:objects[i] forKey:keys[i]];
    }
    return dic;
}
*/
@end
