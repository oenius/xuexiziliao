//
//  MEUserDefaultManager.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/5.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "MEUserDefaultManager.h"

#define kPlayerModelKey      @"kPlayerModelKey"
#define kFirstLaunchMark     @"kFirstLaunchMark"
#define kCurrnetEQID         @"kCurrnetEQID"
#define kCurrentMuiscID      @"kCurrentMuiscID"
#define kIsShowAD            @"kIsShowAD"


#define kEQ_31               @"kEQ_31"
#define kEQ_62               @"kEQ_62"
#define kEQ_125              @"kEQ_125"
#define kEQ_250              @"kEQ_250"
#define kEQ_500              @"kEQ_500"
#define kEQ_1k               @"kEQ_1k"
#define kEQ_2k               @"kEQ_2k"
#define kEQ_4k               @"kEQ_4k"
#define kEQ_8k               @"kEQ_8k"
#define kEQ_16k              @"kEQ_16k"
#define kEQ_name             @"kEQ_name"

@implementation MEUserDefaultManager

SBSingle_m(Manager)


-(void)setADFlagAddOne{
    NSInteger  flag = [[NSUserDefaults standardUserDefaults] integerForKey:kIsShowAD];
    flag ++;
    [[NSUserDefaults standardUserDefaults] setInteger:flag forKey:kIsShowAD];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(BOOL)isShouldShowAD{
    BOOL showAD = NO;
    NSInteger  flag = [[NSUserDefaults standardUserDefaults] integerForKey:kIsShowAD];
    if (flag >= 5) {
        flag = 0;
        showAD = YES;
        [[NSUserDefaults standardUserDefaults] setInteger:flag forKey:kIsShowAD];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return showAD;
}


-(void)setTempEQValues:(NSArray <NSNumber *>*)values andName:(NSString *)name{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setFloat:[[values objectAtIndex:0] floatValue] forKey:kEQ_31];
    [userDefault setFloat:[[values objectAtIndex:1] floatValue] forKey:kEQ_62];
    [userDefault setFloat:[[values objectAtIndex:2] floatValue] forKey:kEQ_125];
    [userDefault setFloat:[[values objectAtIndex:3] floatValue] forKey:kEQ_250];
    [userDefault setFloat:[[values objectAtIndex:4] floatValue] forKey:kEQ_500];
    [userDefault setFloat:[[values objectAtIndex:5] floatValue] forKey:kEQ_1k];
    [userDefault setFloat:[[values objectAtIndex:6] floatValue] forKey:kEQ_2k];
    [userDefault setFloat:[[values objectAtIndex:7] floatValue] forKey:kEQ_4k];
    [userDefault setFloat:[[values objectAtIndex:8] floatValue] forKey:kEQ_8k];
    [userDefault setFloat:[[values objectAtIndex:9] floatValue] forKey:kEQ_16k];
    [userDefault setObject:name forKey:kEQ_name];
    [userDefault synchronize];
}
//最后一个为名字
-(NSArray *)getTempEQValuesAndName{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray * array = [NSMutableArray array];
    NSNumber * eq_31    = [NSNumber numberWithFloat: [userDefault floatForKey:kEQ_31]];
    NSNumber * eq_62    = [NSNumber numberWithFloat: [userDefault floatForKey:kEQ_62]];
    NSNumber * eq_125   = [NSNumber numberWithFloat: [userDefault floatForKey:kEQ_125]];
    NSNumber * eq_250   = [NSNumber numberWithFloat: [userDefault floatForKey:kEQ_250]];
    NSNumber * eq_500   = [NSNumber numberWithFloat: [userDefault floatForKey:kEQ_500]];
    NSNumber * eq_1k    = [NSNumber numberWithFloat: [userDefault floatForKey:kEQ_1k]];
    NSNumber * eq_2k    = [NSNumber numberWithFloat: [userDefault floatForKey:kEQ_2k]];
    NSNumber * eq_4k    = [NSNumber numberWithFloat: [userDefault floatForKey:kEQ_4k]];
    NSNumber * eq_8k    = [NSNumber numberWithFloat: [userDefault floatForKey:kEQ_8k]];
    NSNumber * eq_16k   = [NSNumber numberWithFloat: [userDefault floatForKey:kEQ_16k]];
    NSString * eq_name  = [userDefault objectForKey:kEQ_name];
    [array addObject:eq_31];
    [array addObject:eq_62];
    [array addObject:eq_125];
    [array addObject:eq_250];
    [array addObject:eq_500];
    [array addObject:eq_1k];
    [array addObject:eq_2k];
    [array addObject:eq_4k];
    [array addObject:eq_8k];
    [array addObject:eq_16k];
    if (eq_name == nil) {
        eq_name = MEL_Customize;
    }
    [array addObject:eq_name];
    return array;
}

-(void)setCurrentMuiscID:(NSString *)musicDes_ID{
    [[NSUserDefaults standardUserDefaults] setValue:musicDes_ID forKey:kCurrentMuiscID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)getcurrentMusicID{
    NSString * musicID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentMuiscID];
    return musicID;
}

-(void)setCurrentEQID:(NSString * )eqID{
    [[NSUserDefaults standardUserDefaults] setValue:eqID forKey:kCurrnetEQID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)getCurrentEQID{
    NSString * EQID = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrnetEQID];
    return EQID;
}


-(void)setFirstLaunchMark:(BOOL)first{
    BOOL newFirst = !first;
    [[NSUserDefaults standardUserDefaults] setBool:newFirst forKey:kFirstLaunchMark];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)getFirstLaunchMark{
    BOOL firstLaunchMark = [[NSUserDefaults standardUserDefaults]boolForKey:kFirstLaunchMark];
    return !firstLaunchMark;
}

-(void)setPlayModel:(MEAudioPlayerPlayModel)playModel{
    [[NSUserDefaults standardUserDefaults] setInteger:playModel forKey:kPlayerModelKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(MEAudioPlayerPlayModel)getPlayModel{
    MEAudioPlayerPlayModel  model = [[NSUserDefaults standardUserDefaults] integerForKey:kPlayerModelKey];
    return model;
}

@end
