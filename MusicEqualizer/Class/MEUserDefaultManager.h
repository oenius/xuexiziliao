//
//  MEUserDefaultManager.h
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/5.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBSingletonTool.h"
#import "MEAudioPlayer.h"

@interface MEUserDefaultManager : NSObject

SBSingle_h(Manager)
//第一次启动相关
-(void)setFirstLaunchMark:(BOOL)first;
-(BOOL)getFirstLaunchMark;

//播放模式持久化
-(void)setPlayModel:(MEAudioPlayerPlayModel)playModel;
-(MEAudioPlayerPlayModel)getPlayModel;

//EQ持久化
-(void)setCurrentEQID:(NSString * )eqID;
-(NSString *)getCurrentEQID;

-(void)setTempEQValues:(NSArray <NSNumber *>*)values andName:(NSString *)name;
-(NSArray *)getTempEQValuesAndName;//最后一个为名字

-(void)setADFlagAddOne;
-(BOOL)isShouldShowAD;

@end
