//
//  MESongsViewModel.h
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/27.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MEMusic.h"
#import "MEEqualizer.h"

@interface MESongsViewModel : NSObject


-(NSArray<MEMusic *> *)refreshDocument;

-(NSArray<MEMusic *> *)refreshiPod;

-(NSInteger)numberOfRowsInSection:(NSInteger)sectoin;

-(NSInteger)numberOfSectionsInTableView;

-(MEMusic *)getMusicModelAtIndexPath:(NSIndexPath *)indexPath;

-(NSArray <MPMediaItem*>*)musicMediaItemArray;

-(MPMediaItem *)selecedMediaItemWithMusic:(MEMusic *)music;

-(NSURL *)fixMusicModelUrl:(MEMusic*)music; 

-(NSArray<MEMusic *> *)getAllMusicModel;

-(MEEqualizer *)getCurrentEQ;

-(void)removeMusicFromFavorite:(MEMusic*)music;

-(BOOL)addMusicToFavorite:(MEMusic *)music;

-(void)resetMusicEditState;

-(BOOL)addMusic:(MEMusic *)music toList:(MEList *)list;

-(void)deleteMusicAtIndexPath:(NSIndexPath *)indexPath;
@end
