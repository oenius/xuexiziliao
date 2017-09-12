//
//  MEEqualizerScrollView.h
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MEAudioPlayer;
@class MEEqualizer;
typedef void(^SetEQAfterFisrtChangedBlock)(BOOL isChanged);

@interface MEEqualizerScrollView : UIScrollView

@property (weak,nonatomic) MEAudioPlayer *player;

-(instancetype)initWithFrame:(CGRect)frame andPlayer:(MEAudioPlayer *)player;

-(void)setSliderValueWithEqualier:(MEEqualizer *)equalizer;

-(void)setSliderValueWithNumberArray:(NSArray *)values;

-(void)setEQAfterFisrtChangedCallBack:(SetEQAfterFisrtChangedBlock)block;

-(NSArray<NSNumber *>*)getCurrentSliderValues;

@end
