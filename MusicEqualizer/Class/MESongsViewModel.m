//
//  MESongsViewModel.m
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/27.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "MESongsViewModel.h"
#import <AVFoundation/AVFoundation.h>
#import "MECoreDataManager.h"
#import "MEList.h"
#import "UIDevice+x.h"
@interface MESongsViewModel ()

@property (nonatomic,strong)NSMutableArray * musicModelArray;

@end

@implementation MESongsViewModel

-(NSArray <MPMediaItem*>*)musicMediaItemArray{
    return [[MPMediaQuery songsQuery] items];
}

-(MPMediaItem *)selecedMediaItemWithMusic:(MEMusic *)music{
    NSArray * items = [self musicMediaItemArray];

    for (MPMediaItem * item in items) {
        if (item.persistentID == music.music_id) {
            return item;
        }
    }
    return nil;
}

-(NSArray<MEMusic *> *)refreshDocument{
    //删除数据库中所有在Documen下的文件夹
    [[MECoreDataManager defaultManager] deleteAllDocumentMusicNoList];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString * docPath = [[MECoreDataManager defaultManager] documentDirectoryPath];
    LOG(@"%@",docPath);
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:docPath error:nil];
    LOG(@"fileList%@",fileList);
    NSMutableArray * musicPaths = [NSMutableArray array];
    for (NSString * name in fileList) {
        NSString * songsPath = [docPath stringByAppendingPathComponent:name];
        LOG(@"songsPath:%@",songsPath);
        [musicPaths addObject:songsPath];
    }
    
    NSMutableArray * musicItemArray = [NSMutableArray array];
    NSInteger musicID = arc4random()%1000;
    for (NSString *filePath in musicPaths) {
        NSURL *url = [NSURL fileURLWithPath:filePath];
        NSString *musicName = [filePath lastPathComponent];
        AVURLAsset *musicAsset = [AVURLAsset URLAssetWithURL:url options:nil];
        LOG(@"%@",musicAsset);
        for (NSString *format in [musicAsset availableMetadataFormats]) {
            MEMusic * music = [[MECoreDataManager defaultManager]insertMusic];
            music.describe = [[NSUUID UUID]UUIDString];
            music.name = musicName;
            music.isiPod = NO;
            music.localUrl = musicName;
            LOG(@"format type = %@",format);
            for (AVMetadataItem *metadataItem in [musicAsset metadataForFormat:format]) {
                LOG(@"commonKey = %@",metadataItem.commonKey);
                
                if ([metadataItem.commonKey isEqualToString:@"artwork"]) {
                    LOG(@"%@",[metadataItem.value class]);
                    NSData * imageData = (NSData *)metadataItem.value;
                    music.image = imageData;
                }
                else if([metadataItem.commonKey isEqualToString:@"title"])
                {
                    NSString *title = (NSString *)metadataItem.value;
                    if (title != nil && title.length != 0) {
                        music.name = title;
//                        [title stringByAddingPercentEscapesUsingEncoding:NSUTF16StringEncoding];
                    }
                    LOG(@"title:%@",musicName);
                    LOG(@"title:%@",music.name);
                }
                else if([metadataItem.commonKey isEqualToString:@"artist"])
                {
                    NSString *artist = (NSString *)metadataItem.value;
                    music.singer = artist;
                    LOG(@"artist: %@",artist);
                }
            }
            if (music.image == nil) {
                UIImage *image = [UIImage imageNamed:@"default_picture"];
                music.image = UIImageJPEGRepresentation(image, 1);
            }
            if (music.singer == nil) {
                music.singer = @"none";
            }
            music.order = [[NSDate date] timeIntervalSince1970];
            music.music_id = musicID;
            musicID ++;
            [musicItemArray addObject:music];
            [[MECoreDataManager defaultManager] save];
        }
    }
    if (_musicModelArray != nil) {
        _musicModelArray = nil;
    }
    return musicItemArray;
}

-(NSArray<MEMusic *> *)refreshiPod{
    
    
    //删除数据库中所有是iPod的Music
    [[MECoreDataManager defaultManager]deleteAlliPodMusicNoList];
    NSMutableArray * array = [NSMutableArray array];
    NSArray * mediaItemArray = [[MPMediaQuery songsQuery]items];
    for (MPMediaItem * item in mediaItemArray) {
        NSURL * iPodUrl = item.assetURL;
        if (iPodUrl == nil) { continue;  }
        MEMusic * music = [[MECoreDataManager defaultManager]insertMusic];
        music.iPodUrl = [iPodUrl absoluteString];
        MPMediaItemArtwork *artwork = item.artwork;
        UIImage *image = [artwork imageWithSize:artwork.bounds.size];
        if (image == nil) {
            image = [UIImage imageNamed:@"default_picture"];
        }
        music.image = UIImageJPEGRepresentation(image, 1);
        music.singer = item.artist;
        music.name = item.title;
        music.isiPod = YES;
        music.duration = item.playbackDuration;
        music.isEditState = NO;
        music.music_id = item.persistentID;
        music.describe = [[NSUUID UUID] UUIDString];
        music.order = [[NSDate date] timeIntervalSince1970];
        [array addObject:music];
        [[MECoreDataManager defaultManager] save];
    }
  
    if (_musicModelArray != nil) {
        _musicModelArray = nil;
    }
    
    return array;
}
+ (NSArray *)supportedAudioFileTypes
{
    return @
    [
     @"aac",
     @"caf",
     @"aif",
     @"aiff",
     @"aifc",
     @"mp3",
     @"mp4",
     @"m4a",
     @"snd",
     @"au",
     @"sd2",
     @"wav"
     ];
}
-(NSMutableArray *)musicModelArray{
    if (_musicModelArray == nil ) {
        NSMutableArray * musicArray = [NSMutableArray array];
        [musicArray addObjectsFromArray:[[MECoreDataManager defaultManager]getAllMusicNoList]];
        if (musicArray == nil || musicArray.count == 0) {
            if ([UIDevice systemVersionGreaterThan9_3]) {
                MPMediaLibraryAuthorizationStatus status = [MPMediaLibrary authorizationStatus];
                if (status == MPMediaLibraryAuthorizationStatusAuthorized) {
                    [musicArray addObjectsFromArray:[self refreshiPod]];
                }
            }else{
               [musicArray addObjectsFromArray:[self refreshiPod]];
            }
            [musicArray addObjectsFromArray:[self refreshDocument]];
        }
        _musicModelArray = musicArray;
    }
    return _musicModelArray;
}

-(NSInteger)numberOfSectionsInTableView{
    return 1;
}

-(NSInteger)numberOfRowsInSection:(NSInteger)sectoin{
    return self.musicModelArray.count;
}

-(MEMusic *)getMusicModelAtIndexPath:(NSIndexPath *)indexPath{
    return [self.musicModelArray objectAtIndex:indexPath.row];
}
-(MEEqualizer *)getCurrentEQ{
    return  [[MECoreDataManager defaultManager] getCurrentEqualizer];
}

-(NSURL *)fixMusicModelUrl:(MEMusic*)music{
    
    BOOL isiPod = music.isiPod;
    NSString * UrlSting = (isiPod == YES) ? music.iPodUrl : music.localUrl;
    NSURL * url ;
    if (isiPod) {
        url = [NSURL URLWithString:UrlSting];
    }else{
        NSString * docmentPath = [[MECoreDataManager defaultManager]documentDirectoryPath];
        NSString * strPath = [docmentPath stringByAppendingPathComponent:UrlSting];
        url = [NSURL fileURLWithPath:strPath];
    }
    LOG(@"url:%@",url);
    return url;
    
}

-(NSArray<MEMusic *> *)getAllMusicModel{
    return [NSArray arrayWithArray:self.musicModelArray];
}

-(void)resetMusicEditState{
    for (MEMusic * music in self.musicModelArray) {
        music.isEditState = NO;
        [[MECoreDataManager defaultManager]save];
    }
}

-(void)removeMusicFromFavorite:(MEMusic*)music{
    music.isFavorite = NO;
    [[MECoreDataManager defaultManager]save];
    [[MECoreDataManager defaultManager]checkMusicFavoriteSetToYesOrNo:music yesOrNO:NO];
    
    NSArray * lists = [[MECoreDataManager defaultManager] searchMusicListWithName:@"myFavorite"];
    MEList * favoriteList = lists.firstObject;
    NSSet * set = favoriteList.musics;
    for (MEMusic * oldMusic in set) {
        if (oldMusic.music_id == music.music_id) {
            [[MECoreDataManager defaultManager] deleteObject:oldMusic];
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
-(BOOL)addMusicToFavorite:(MEMusic *)music{
    music.isFavorite = YES;
    [[MECoreDataManager defaultManager]save];
    
    BOOL success = NO;
    NSArray * list = [[MECoreDataManager defaultManager]searchMusicListWithName:@"myFavorite"];
    if (list == nil || list.count == 0) {
        success = NO;
    }else{
        MEList * favoriteList = list.firstObject;
        MEMusic * newList = [[MECoreDataManager defaultManager]copyMusic:music toList:favoriteList];
        if (newList) {
            success = YES;
        }
    }
    [[MECoreDataManager defaultManager]checkMusicFavoriteSetToYesOrNo:music yesOrNO:YES];
    return success;
}

-(void)deleteMusicAtIndexPath:(NSIndexPath *)indexPath{
    MEMusic * music = [self.musicModelArray objectAtIndex:indexPath.row];
    
    [self.musicModelArray removeObject:music];
    [[MECoreDataManager defaultManager] deleteObject:music];
}
@end
