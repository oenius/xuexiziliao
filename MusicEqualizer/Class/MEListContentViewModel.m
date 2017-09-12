//
//  MEListContentViewModel.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/3.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "MEListContentViewModel.h"
#import "MECoreDataManager.h"
#import "MEList.h"
#import "MEMusic.h"
#import "MEEqualizer.h"
@interface MEListContentViewModel ()

@property (strong,nonatomic)MEList * musicList;

@property (strong,nonatomic)NSMutableArray * musicModelArray;

@end

@implementation MEListContentViewModel

-(NSMutableArray *)musicModelArray{
    if (nil == _musicModelArray || _musicModelArray.count == 0) {
        NSSet * set = self.musicList.musics;
        NSMutableArray * arr = [NSMutableArray array];
        for (MEMusic * music in set) {
            [arr addObject:music];
        }
        NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        [arr sortUsingDescriptors:@[sort]];
        _musicModelArray = arr;
    }
    return _musicModelArray;
}

-(instancetype)initWithMusicList:(MEList *)musicList{
    self  = [super init];
    if (self) {
        self.musicList = musicList;
    }
    return self;
}

-(NSInteger)numberOfSectionsInTableView{
    return 1;
}

-(NSInteger)numberOfRowsInSection:(NSInteger)section{
    return self.musicModelArray.count;
}

-(MEMusic *)getMusicModelAtIndexPath:(NSIndexPath *)indexPath{
    return [self.musicModelArray objectAtIndex:indexPath.row];
}

-(void)checkMusicModelArray:(NSArray <MEMusic *>*)musicArray{
    NSMutableArray * newModelArray = [NSMutableArray new];

    for (MEMusic * newMusic  in musicArray) {
        NSString * newMusicID  =  newMusic.describe;
        BOOL isHas = NO;
        for (MEMusic * oldMusic in self.musicModelArray) {
            NSString * oldMusicID = oldMusic.describe;
            if ([oldMusicID isEqualToString:newMusicID]) {
                isHas = YES;
                break;
            }
        }
        if (NO == isHas) {
            [newModelArray addObject:newMusic];
        }
    }
    [self.musicModelArray addObjectsFromArray:newModelArray];
}

-(NSURL *)fixMusicModelUrl:(MEMusic*)music{
    
    BOOL isiPod = music.isiPod;
    NSString * UrlSting = (isiPod == YES) ? music.iPodUrl : music.localUrl;
    NSURL * url ;
    if (isiPod) {
        url = [NSURL URLWithString:UrlSting];
    }else{
        NSString * docmentPath = [[MECoreDataManager defaultManager] documentDirectoryPath];
        NSString * strPath = [docmentPath stringByAppendingPathComponent:UrlSting];
        url = [NSURL fileURLWithPath:strPath];
    }
    LOG(@"url:%@",url);
    return url;
    
}
-(NSArray<MEMusic *> *)getAllMusicModel{
    return [NSArray arrayWithArray:self.musicModelArray];
}

-(MEEqualizer *)getCurrentEQ{
    return  [[MECoreDataManager defaultManager]getCurrentEqualizer];
}

-(void)removeMusicFromFavorite:(MEMusic*)music{
    music.isFavorite = NO;
    [[MECoreDataManager defaultManager]save];
    [[MECoreDataManager defaultManager]checkMusicFavoriteSetToYesOrNo:music yesOrNO:NO];
    NSArray * lists = [[MECoreDataManager defaultManager]searchMusicListWithName:@"myFavorite"];
    MEList * favoriteList = lists.firstObject;
    NSSet * set = favoriteList.musics;
    for (MEMusic * oldMusic in set) {
        if (oldMusic.music_id == music.music_id) {
            [[MECoreDataManager defaultManager]deleteObject:oldMusic];
            [[MECoreDataManager defaultManager]save];
            break;
        }
    }
    
}

-(BOOL)addMusic:(MEMusic *)music toList:(MEList *)list{
    
    BOOL success = NO;
    MEMusic * newMusic = [[MECoreDataManager defaultManager]copyMusic:music toList:list];
    if (newMusic) {
        if ([list.name isEqualToString:@"myFavorite"]) {
            music.isFavorite = YES;
            [[MECoreDataManager defaultManager] save];
        }
        success = YES;
    }
    return success;
}

-(void)deleteMusicAtIndexPath:(NSIndexPath *)indexPath{
    MEMusic * music = [self.musicModelArray objectAtIndex:indexPath.row];
    if (music.isFavorite == YES) {
        [[MECoreDataManager defaultManager] checkMusicFavoriteSetToYesOrNo:music yesOrNO:NO];
    }
    [self.musicModelArray removeObject:music];
    [[MECoreDataManager defaultManager] deleteObject:music];
}

-(BOOL)addMusicToFavorite:(MEMusic *)music{
    music.isFavorite = YES;
    [[MECoreDataManager defaultManager]save];
    
    BOOL success = NO;
    NSArray * list = [[MECoreDataManager defaultManager] searchMusicListWithName:@"myFavorite"];
    if (list == nil || list.count == 0) {
        success = NO;
    }else{
        MEList * favoriteList = list.firstObject;

        MEMusic * newList = [[MECoreDataManager defaultManager]copyMusic:music toList:favoriteList];
        if (newList) {
            success = YES;
        }
    }
    [[MECoreDataManager defaultManager] checkMusicFavoriteSetToYesOrNo:music yesOrNO:YES];
    return success;
}

-(void)resetMusicEditState{
    for (MEMusic * music in self.musicModelArray) {
        music.isEditState = NO;
        [[MECoreDataManager defaultManager]save];
    }
}
@end
