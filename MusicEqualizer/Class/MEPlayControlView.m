//
//  MEPlayControlView.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/9.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "MEPlayControlView.h"
#import "MEAudioPlayer.h"
#import "UIImage+x.h"
#import "UIColor+x.h"

@interface MEPlayControlView ()<MEAudioPlayerDelegate>

@property (strong,nonatomic)UISlider * musicSlider;

@property (strong,nonatomic)UIButton * nextPlayBtn;

@property (strong,nonatomic)UIButton * pausePlayBtn;

@property (strong,nonatomic)UILabel * musicNameLabel;

@property (strong,nonatomic)UIView * leftContentView;

@property (strong,nonatomic)UIView * rightContentView;

@property (strong,nonatomic)UIImageView * imageView;

@property (weak,nonatomic) MEAudioPlayer * player;

@property (copy,nonatomic) LeftContenViewTapBlock block;
//是唯一的
@property (copy, nonatomic) NSString * currentMusicDescribe_ID;

@end

@implementation MEPlayControlView

#pragma mark - 懒加载

-(MEAudioPlayer *)player{
    if (nil == _player) {
        _player = [MEAudioPlayer defaultPlayer];
        _player.delegate = self;
    }
    return _player;
}


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self  = [super initWithCoder:aDecoder];
    if (self) {
        [self setupViews];
    }
    return self;
}

-(void)setupViews{
    
    self.backgroundColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1];
    
    self.imageView = [UIImageView new];
    [self addSubview:_imageView];
    UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(leftContentViewTap:)];
    [_imageView addGestureRecognizer:tap1];
    _imageView.userInteractionEnabled = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.musicSlider = [UISlider new];
    [_musicSlider addTarget:self action:@selector(musicSliderTouchEnd:) forControlEvents:UIControlEventTouchUpInside];
    [_musicSlider addTarget:self action:@selector(musicSliderTouchEnd:) forControlEvents:UIControlEventTouchCancel];
    [_musicSlider addTarget:self action:@selector(musicSliderTouchEnd:) forControlEvents:UIControlEventTouchUpOutside];
    
    
    UIImage *minImage = [UIImage createCircleImageWithColor:[UIColor colorWithHexString:@"a20707"] andX:6 andY:6];
    UIImage *maxImage = [UIImage createCircleImageWithColor:[UIColor blackColor] andX:6 andY:6];
    
    UIImage *imageMin = [minImage stretchableImageWithLeftCapWidth:minImage.size.width/2 topCapHeight:minImage.size.height/2];
    UIImage *imageMax = [maxImage  stretchableImageWithLeftCapWidth:maxImage.size.width/2 topCapHeight:maxImage.size.height/2];
    
    [self.musicSlider setThumbImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
    [self.musicSlider setMinimumTrackImage:imageMin forState:UIControlStateNormal];
    [self.musicSlider setMaximumTrackImage:imageMax forState:UIControlStateNormal];
    
    [self addSubview:_musicSlider];
    
    self.leftContentView = [UIView new];
    
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(leftContentViewTap:)];
    [_leftContentView addGestureRecognizer:tap2];
    
    [self addSubview:_leftContentView];
    self.musicNameLabel = [UILabel new];
    _musicNameLabel.numberOfLines = 2;
    _musicNameLabel.textColor = [UIColor whiteColor];
//    _musicNameLabel.adjustsFontSizeToFitWidth = YES;
    [_leftContentView addSubview:_musicNameLabel];
    
    self.rightContentView = [UIView new];
    [self addSubview:_rightContentView];
    self.nextPlayBtn = [UIButton new];
    [_nextPlayBtn addTarget:self action:@selector(nextPlayBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_nextPlayBtn setImage:[UIImage imageNamed:@"next_one"] forState:UIControlStateNormal];
    _nextPlayBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_rightContentView addSubview:_nextPlayBtn];
    
    
    self.pausePlayBtn = [UIButton new];
    [_pausePlayBtn addTarget:self action:@selector(pausePlayBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_pausePlayBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    _pausePlayBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_rightContentView addSubview:_pausePlayBtn];
    
    
}


-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat spacing = 5;
    
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat selfHeight = self.bounds.size.height;
    
    
    self.imageView.frame = CGRectMake(spacing, spacing, selfHeight-spacing*2, selfHeight-spacing*2);
    
    self.imageView.layer.cornerRadius = (selfHeight-spacing*2)/2;
    self.imageView.layer.masksToBounds = YES;
    
    CGFloat sliderWidth = selfWidth - selfHeight;
    
    self.musicSlider.frame = CGRectMake(selfHeight, 0, sliderWidth, 30);
    
    self.leftContentView.frame = CGRectMake(selfHeight, 30, sliderWidth/3*2, selfHeight-30-spacing);
    
    self.rightContentView.frame = CGRectMake(sliderWidth/3*2+selfHeight, 30, sliderWidth/3, selfHeight-30-spacing);
    
    self.musicNameLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.leftContentView.frame), CGRectGetHeight(self.leftContentView.frame));
    
    self.pausePlayBtn.frame = CGRectMake(0, 0, CGRectGetWidth(self.rightContentView.frame)/2, CGRectGetHeight(self.rightContentView.frame));
    
    self.nextPlayBtn.frame = CGRectMake(CGRectGetWidth(self.rightContentView.frame)/2, 0, CGRectGetWidth(self.rightContentView.frame)/2, CGRectGetHeight(self.rightContentView.frame));
    
    NSString * musicInfo;
    UIImage * image;
    if (self.player.currentMusic == nil) {
        musicInfo = MEL_none;
        image = [UIImage imageNamed:@"default_picture"];
    }else{
        musicInfo = [NSString stringWithFormat:@"%@ - %@",self.player.currentMusic.name,self.player.currentMusic.singer];
        image = [UIImage imageWithData:self.player.currentMusic.image];
        self.musicSlider.maximumValue = self.player.duration;
        self.musicSlider.minimumValue = 0;
        self.musicSlider.value = self.player.currentTime;
    }
    self.musicNameLabel.text = musicInfo;
    self.imageView.image = image;
    
}

#pragma  mark - actions

-(void)musicSliderTouchEnd:(UISlider *)sender{
    LOG(@"musicSliderValueChanged");
    if (self.player.musicList.count <=0) {
        return;
    }
    BOOL isPlay = self.player.playing;
    [self.player setPlayTime:sender.value];
    if (!isPlay) {
        [self.player pause];
    }
}

-(void)nextPlayBtnClick:(UIButton *)sender{

    if (self.player.musicList.count>0) {
        [self.player nextMusic];
    }
}

-(void)pausePlayBtnClick:(UIButton *)sender{
    if (self.player.musicList.count <=0) {
        return;
    }
    if (self.player.playing) {
        [self.player pause];
    }else{
        [self.player play];
    }
}

-(void)leftContentViewTap:(UITapGestureRecognizer *)sender{
    if (self.player.musicList.count <=0) {
        return;
    }
    if (self.block) {
        self.block(YES);
    }
}

-(void)viewTapCallBack:(LeftContenViewTapBlock) block{
    self.block = block;
}

-(void)reset{
    self.musicNameLabel.text = MEL_none;
    self.imageView.image = [UIImage imageNamed:@"default_picture"];
    self.musicSlider.value = self.musicSlider.minimumValue;
}

#pragma mark - MEAudioPlayerDelegate
-(void)audioPlayer:(MEAudioPlayer *)player updateTime:(CGFloat)currentTime mucsicID:(NSString *)currentMusicDescribe_ID{
    if (self.musicSlider.isTracking) { return;}
    
    if (![self.currentMusicDescribe_ID isEqualToString:currentMusicDescribe_ID]) {
        self.currentMusicDescribe_ID = currentMusicDescribe_ID;
        self.musicSlider.maximumValue = player.duration;
        self.musicSlider.minimumValue = 0;
        MEMusic * currentMusic = self.player.currentMusic;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (currentMusic) {
                self.musicNameLabel.text = [NSString stringWithFormat:@"%@ - %@",currentMusic.name,currentMusic.singer];
            }else{
                self.musicNameLabel.text = MEL_none;
            }
            self.imageView.image = [UIImage imageWithData:player.currentMusic.image];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.musicSlider.value = currentTime;
    });
    LOG(@"%@--%g",[self class],currentTime);
}
-(void)audioPlayerPlayCompleted:(MEAudioPlayer *)player{
    
}

-(void)audioPlayer:(MEAudioPlayer *)player playOrPauseChanged:(BOOL)isPause{
   
    if (isPause) {
        [self.pausePlayBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }else{
        [self.pausePlayBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
}

#pragma mark - Other


@end
