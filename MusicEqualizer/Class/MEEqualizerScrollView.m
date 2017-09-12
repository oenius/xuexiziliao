//
//  MEEqualizerScrollView.m
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "MEEqualizerScrollView.h"
#import "MEEqualizerAdjustSlider.h"
#import "MEAudioPlayer.h"
#import "MEEqualizer.h"

@interface MEEqualizerScrollView ()

@property (strong,nonatomic)NSMutableArray<MEEqualizerAdjustSlider *> * slidersArray;

@property (assign,nonatomic) BOOL isAllowCallBlock;

@property (copy,nonatomic) SetEQAfterFisrtChangedBlock block;

@end

@implementation MEEqualizerScrollView

-(void)setPlayer:(MEAudioPlayer *)player{
    _player = player;
}

-(NSMutableArray<MEEqualizerAdjustSlider *> *)slidersArray{
    if (nil == _slidersArray) {
        _slidersArray = [NSMutableArray array];
    }
    return _slidersArray;
}

-(instancetype)initWithFrame:(CGRect)frame andPlayer:(MEAudioPlayer *)player {
    self = [super initWithFrame:frame];
    if (self) {
        self.player = player;
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

-(void)setupSubViews{
//    self.clipsToBounds = NO;
    NSInteger count = 10;
    self.isAllowCallBlock = YES;
    for (int i = 0; i < count; i ++) {
        MEEqualizerAdjustSlider * slider = [[MEEqualizerAdjustSlider alloc]init];
        slider.tag = i;
        slider.maximumValue = 24.0;
        slider.minimumValue = -24.0;
        slider.value = 0;
        [self addSubview:slider];
        [slider addTarget:self action:@selector(equalizerSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.slidersArray addObject:slider];
    }
}

-(void)awakeFromNib{
    [super awakeFromNib];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat spacing = 10.0;
    CGFloat weight = 30.0;
    CGFloat height = self.bounds.size.height;
    NSInteger count = self.slidersArray.count;
    CGFloat totleWeight = count * weight + (count + 1) * spacing;
    if (totleWeight < self.bounds.size.width) {
        spacing = (self.bounds.size.width - count * weight) / (count+1);
    }
    
    NSArray *frequencyArray = self.player.frequencies;
    for (int i = 0; i < count; i ++) {
        NSString *frequencyStr = nil;
        NSInteger frequency = [[frequencyArray objectAtIndex:i] integerValue];
        if (frequency >= 1000){
            frequencyStr = [NSString stringWithFormat:@"%zdk", frequency / 1000];
        }else{
            frequencyStr = [NSString stringWithFormat:@"%zd", frequency];
        }
        MEEqualizerAdjustSlider * slider = self.slidersArray[i];
        CGFloat x = spacing + i * (weight + spacing);
        slider.frame = CGRectMake(x, 0, weight , height);
        totleWeight = x + weight;
        slider.bottomLabel.text = frequencyStr;
    }
    self.contentSize = CGSizeMake(totleWeight+15, 0);
}
-(void)setEQAfterFisrtChangedCallBack:(SetEQAfterFisrtChangedBlock)block{
    self.block = block;
}

-(void)setSliderValueWithNumberArray:(NSArray *)values{
    if (values.count < 10) {
        return;
    }
    MEEqualizerAdjustSlider * slider_0 = self.slidersArray[0];
    slider_0.value = [[values objectAtIndex:0] floatValue];
    
    MEEqualizerAdjustSlider * slider_1 = self.slidersArray[1];
    slider_1.value = [[values objectAtIndex:1] floatValue];
    
    MEEqualizerAdjustSlider * slider_2 = self.slidersArray[2];
    slider_2.value = [[values objectAtIndex:2] floatValue];
    
    MEEqualizerAdjustSlider * slider_3 = self.slidersArray[3];
    slider_3.value = [[values objectAtIndex:3] floatValue];
    
    MEEqualizerAdjustSlider * slider_4 = self.slidersArray[4];
    slider_4.value = [[values objectAtIndex:4] floatValue];
    
    MEEqualizerAdjustSlider * slider_5 = self.slidersArray[5];
    slider_5.value = [[values objectAtIndex:5] floatValue];
    
    MEEqualizerAdjustSlider * slider_6 = self.slidersArray[6];
    slider_6.value = [[values objectAtIndex:6] floatValue];
    
    MEEqualizerAdjustSlider * slider_7 = self.slidersArray[7];
    slider_7.value = [[values objectAtIndex:7] floatValue];
    
    MEEqualizerAdjustSlider * slider_8 = self.slidersArray[8];
    slider_8.value = [[values objectAtIndex:8] floatValue];
    
    MEEqualizerAdjustSlider * slider_9 = self.slidersArray[9];
    slider_9.value = [[values objectAtIndex:9] floatValue];
    
    self.isAllowCallBlock = YES;
}

-(void)setSliderValueWithEqualier:(MEEqualizer *)equalizer{
    
    MEEqualizerAdjustSlider * slider_0 = self.slidersArray[0];
    slider_0.value = equalizer.eq_31;
    
    MEEqualizerAdjustSlider * slider_1 = self.slidersArray[1];
    slider_1.value = equalizer.eq_62;
    
    MEEqualizerAdjustSlider * slider_2 = self.slidersArray[2];
    slider_2.value = equalizer.eq_125;
    
    MEEqualizerAdjustSlider * slider_3 = self.slidersArray[3];
    slider_3.value = equalizer.eq_250;
    
    MEEqualizerAdjustSlider * slider_4 = self.slidersArray[4];
    slider_4.value = equalizer.eq_500;
    
    MEEqualizerAdjustSlider * slider_5 = self.slidersArray[5];
    slider_5.value = equalizer.eq_1k;
    
    MEEqualizerAdjustSlider * slider_6 = self.slidersArray[6];
    slider_6.value = equalizer.eq_2k;
    
    MEEqualizerAdjustSlider * slider_7 = self.slidersArray[7];
    slider_7.value = equalizer.eq_4k;
    
    MEEqualizerAdjustSlider * slider_8 = self.slidersArray[8];
    slider_8.value = equalizer.eq_8k;
    
    MEEqualizerAdjustSlider * slider_9 = self.slidersArray[9];
    slider_9.value = equalizer.eq_16k;
    
    self.isAllowCallBlock = YES;
}

-(NSArray<NSNumber *>*)getCurrentSliderValues{
    NSMutableArray * array  = [NSMutableArray array];
    for (MEEqualizerAdjustSlider * slider in self.slidersArray) {
        NSNumber * number = [NSNumber numberWithFloat:slider.value];
        [array addObject:number];
    }
    return array;
}

#pragma mark - sliderValuedChanged

-(void)equalizerSliderValueChanged:(MEEqualizerAdjustSlider *)sender{
    
    [self.player setEQGain:sender.value atIndex:sender.tag];
    if (self.isAllowCallBlock == YES) {
        self.isAllowCallBlock = NO;
        if (self.block) {
            self.block(YES);
        }
    }
}

@end
