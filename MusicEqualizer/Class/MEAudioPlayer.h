//
//  MEAudioPlayer.h
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/30.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SBSingletonTool.h"
#import "MEEqualizer.h"
#import "MEMusic.h"

#define MEEQualizerCount 10

typedef enum : NSUInteger {
    MEAudioPlayerPlayModelOrder,
    MEAudioPlayerPlayModelRandom,
    MEAudioPlayerPlayModelSingle,
} MEAudioPlayerPlayModel;


@protocol MEAudioPlayerDelegate ;


@interface MEAudioPlayer : NSObject

@property (nonatomic, readonly) BOOL playing;

@property (nonatomic,readonly) NSTimeInterval duration;

@property (nonatomic,readonly) NSTimeInterval currentTime;

@property (nonatomic,readonly,strong) MEMusic *currentMusic;

@property (nonatomic,readonly,strong) NSMutableArray<MEMusic *> * musicList;

@property (nonatomic,readonly,strong) NSArray<NSNumber *>* frequencies;

@property (nonatomic,weak) id<MEAudioPlayerDelegate> delegate;

@property (nonatomic,assign) MEAudioPlayerPlayModel playModel;

@property (assign,readonly,nonatomic) NSInteger currentIndex;

@property (strong,readonly,nonatomic) MEEqualizer * currentEqulizer;

SBSingle_h(Player)

-(void)nextMusic;

-(void)lastMusic;

-(void)reset;

-(void)checkMusicList;

-(void)playWithUrl:(NSURL *)musicUrl music:(MEMusic*)music;

-(void)playMusicWithIndex:(NSInteger)index;

-(void)setEQGain:(CGFloat)gain atIndex:(NSInteger)index;

-(void)setPlayTime:(NSTimeInterval)time;

-(void)setMusicList:(NSArray <MEMusic *>*) musicList andIndex:(NSInteger)index;

-(void)setEqualizer:(MEEqualizer *)equalizer;

-(void)deleteMusicAtIndex:(NSInteger)index;

-(void)insertMusicPlayAtNext:(MEMusic *)music;

//避免用户从iPod/ituns删除音乐后出现bug
-(BOOL)checkMusicExistence:(MEMusic*)music;
//- (void)setPan:(CGFloat)pan;//左右声道
//
//- (void)setOverallGain:(CGFloat)overallGain;//引擎gain

- (void)play;

- (void)pause;

- (void)stop;

@end

@protocol MEAudioPlayerDelegate <NSObject>

@optional

-(void)audioPlayer:(MEAudioPlayer*)player updateTime:(CGFloat)currentTime mucsicID:(NSString*)currentMusicDescribe_ID ;

-(void)audioPlayerPlayCompleted:(MEAudioPlayer*)player;

-(void)audioPlayer:(MEAudioPlayer*)player playModelChanged:(MEAudioPlayerPlayModel) playModel;

-(void)audioPlayer:(MEAudioPlayer*)player musicIndexChanged:(NSInteger)index;

-(void)audioPlayer:(MEAudioPlayer*)player playOrPauseChanged:(BOOL)isPause;

@end

