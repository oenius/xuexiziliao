//
//  MEListContentViewModel.h
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/3.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class MEList;
@class MEMusic;
@class MEEqualizer;
@interface MEListContentViewModel : NSObject

-(instancetype)initWithMusicList:(MEList *)musicList;

-(NSInteger)numberOfSectionsInTableView;

-(NSInteger)numberOfRowsInSection:(NSInteger)section;

-(MEMusic *)getMusicModelAtIndexPath:(NSIndexPath *)indexPath;

-(void)checkMusicModelArray:(NSArray <MEMusic *>*)musicArray;

-(NSURL *)fixMusicModelUrl:(MEMusic*)music;

-(NSArray<MEMusic *> *)getAllMusicModel;

-(MEEqualizer *)getCurrentEQ;

-(void)resetMusicEditState;

-(void)removeMusicFromFavorite:(MEMusic*)music;

-(BOOL)addMusicToFavorite:(MEMusic *)music;

-(void)deleteMusicAtIndexPath:(NSIndexPath *)indexPath;

-(BOOL)addMusic:(MEMusic *)music toList:(MEList *)list;

@end
