//
//  MEAudioPlayer.m
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/30.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "MEAudioPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
//#import "MEUserDefaultManager.h"

@interface MEAudioPlayer ()

@property (nonatomic,readwrite,assign) NSTimeInterval duration;

@property (nonatomic,readwrite,assign) NSTimeInterval currentTime;

@property (nonatomic,readwrite,strong) NSArray<NSNumber *>* frequencies;

@property (nonatomic, strong) NSPointerArray * weakDelegates;

@property (strong,readwrite,nonatomic) MEMusic * currentMusic;

@property (nonatomic,readwrite,strong) NSMutableArray<MEMusic *> * musicList;

@property (strong,readwrite,nonatomic) MEEqualizer * currentEqulizer;

@property (nonatomic, readwrite,assign) BOOL playing;

@property (strong,nonatomic) AVAudioEngine * musicEngine;

@property (strong,nonatomic) AVAudioPlayerNode * player;

@property (strong,nonatomic) AVAudioUnitEQ * musicUnitEQ ;

@property (strong,nonatomic) AVAudioFile * musicFile ;

@property (assign,nonatomic) double sampleRate ;

@property (assign,nonatomic) NSTimeInterval offset;

@property (strong,nonatomic) NSTimer * timer;

@property (assign,readwrite,nonatomic) NSInteger currentIndex;

@property (assign,nonatomic) NSTimeInterval breakOffTime;

@end


@implementation MEAudioPlayer

SBSingle_m(Player)

-(NSPointerArray *)weakDelegates{
    if (nil == _weakDelegates) {
        _weakDelegates = [NSPointerArray weakObjectsPointerArray];
    }
    return _weakDelegates;
}


-(NSArray<NSNumber *> *)frequencies{
    if (_frequencies == nil) {
        _frequencies = [self frequencysArray];
    }
    return _frequencies;
}

-(void)setDelegate:(id<MEAudioPlayerDelegate>)delegate{
    _delegate = delegate;
    [self.weakDelegates addPointer:(__bridge void *)delegate];
}

-(void)setCurrentIndex:(NSInteger)currentIndex{
    _currentIndex = currentIndex;
    for (id delegate in self.weakDelegates) {
        if ([delegate conformsToProtocol:@protocol(MEAudioPlayerDelegate)]) {
            if ([delegate respondsToSelector:@selector(audioPlayer:musicIndexChanged:)]) {
                [delegate audioPlayer:self musicIndexChanged:currentIndex];
            }
        }
    }
}

-(void)setPlayModel:(MEAudioPlayerPlayModel)playModel{
    if (_playModel != playModel) {
        _playModel = playModel;
        for (id delegate in self.weakDelegates) {
            if ([delegate conformsToProtocol:@protocol(MEAudioPlayerDelegate)]) {
                if ([delegate respondsToSelector:@selector(audioPlayer:playModelChanged:)]) {
                    [delegate audioPlayer:self playModelChanged:playModel];
                }
            }
        }
    }
    //强迫症
    _playModel = playModel;
}
-(void)playMusicWithIndex:(NSInteger)index{
    MEMusic * music = self.musicList[index];
    self.currentIndex = index;
    
    BOOL isExist = [self checkMusicExistence:music];
    NSInteger count = 1;
    while (isExist == NO) {
        self.currentIndex += 1;
        self.currentIndex = self.currentIndex % self.musicList.count;
        music = self.musicList[self.currentIndex];
        isExist = [self checkMusicExistence:music];
        count++;
        if (count >= self.musicList.count || isExist == YES) {
            break;
        }
    }
    NSURL * url = [self fixMusicModelUrl:music];
    if (isExist) {
        [self playWithUrl:url music:music];
    }else{
        [self nextMusic];
    }
}
//播放URL音乐
-(void)playWithUrl:(NSURL *)musicUrl music:(MEMusic*)music{
    [self resetPrivete];
    
    self.currentMusic = music;
    
    _musicEngine = [[AVAudioEngine alloc] init];
    _player = [[AVAudioPlayerNode alloc]init];
    _musicFile = [[AVAudioFile alloc]initForReading:musicUrl error:nil];
    if (self.musicUnitEQ == nil) {
        _musicUnitEQ = [[AVAudioUnitEQ alloc] initWithNumberOfBands:self.frequencies.count];
    }
    [_musicEngine attachNode:_musicUnitEQ];
    [_musicEngine attachNode:_player];
//    if (self.currentEqulizer) {
//        [self setEqualizer:_currentEqulizer];
//    }
    AVAudioFormat * format = _musicFile.processingFormat;
    [_musicEngine connect:_player to:_musicUnitEQ format:format];
    [_musicEngine connect:_musicUnitEQ to:_musicEngine.mainMixerNode format:format];
    [_player scheduleFile:_musicFile atTime:nil completionHandler:nil];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer  = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(undataCurrentTime) userInfo:nil repeats:YES];
    self.sampleRate = _musicFile.fileFormat.sampleRate;
    [_musicEngine prepare];
    [_musicEngine startAndReturnError:nil];
    self.offset = 0;
    [_player play];
    [self play];
    
}

-(void)playMusicWithPlayModel:(MEAudioPlayerPlayModel)model{
    switch (model) {
        case MEAudioPlayerPlayModelOrder:
        {
            self.currentIndex += 1;
            self.currentIndex = self.currentIndex % self.musicList.count;

        }
            break;
        case MEAudioPlayerPlayModelSingle:

            break;
        case MEAudioPlayerPlayModelRandom:
        {
            int count = (int)self.musicList.count;
            NSInteger tempIndex = arc4random() % count;
            if (count > 1) {
                while (tempIndex == self.currentIndex) {
                    tempIndex = arc4random() % count;
                }
            }
            
            self.currentIndex = tempIndex;
        }
            break;
        default:
            break;
    }
    
    [self playMusicWithIndex:self.currentIndex];
}

-(void)checkMusicList{
    for (int i = 0; i < self.musicList.count; i ++) {
        MEMusic * music = self.musicList[i];
        if (music.name == nil) {
            [self.musicList removeObjectAtIndex:i];
        }
    }
}

//下一曲
-(void)nextMusic{
    if (MEAudioPlayerPlayModelSingle == self.playModel) {
        self.currentIndex += 1;
        self.currentIndex = self.currentIndex % self.musicList.count;
        [self playMusicWithIndex:self.currentIndex];
    }else{
        [self playMusicWithPlayModel:self.playModel];
    }
}
//上一曲
-(void)lastMusic{
    self.currentIndex -= 1;
    if (self.currentIndex < 0) {
        self.currentIndex = self.musicList.count - 1;
    }
    [self playMusicWithIndex:self.currentIndex];
}
//设置EQ
-(void)setEqualizer:(MEEqualizer *)equalizer{
    self.currentEqulizer = equalizer;
    CGFloat volume = self.player.volume;
    self.player.volume = 0;
    NSArray * initEqs = [self getInitialEQValue:equalizer];
    for (int i = 0; i < self.frequencies.count; i ++) {
        float gain = [[initEqs objectAtIndex:i] floatValue];
        [self privateSetEQGain:gain atIndex:i];
    }
    self.player.volume = volume;
}
//删除播放列表的音乐
-(void)deleteMusicAtIndex:(NSInteger)index{
    if (self.musicList.count == 1) {
        return;
    }
    [self.musicList removeObjectAtIndex:index];
    
    if (self.currentIndex == index) {
        if (self.currentIndex >= self.musicList.count) {
            self.currentIndex = 0;
        }
        [self playMusicWithIndex:self.currentIndex];
    }
    else if (self.currentIndex > index){
        self.currentIndex -= 1;
    }
}

-(void)insertMusicPlayAtNext:(MEMusic *)music{
    [self.musicList insertObject:music atIndex:self.currentIndex+1];
}
//设置均衡参数(内部部调节接口)
-(void)privateSetEQGain:(CGFloat)gain atIndex:(NSInteger)index{
    if(_player != nil && _musicUnitEQ != nil) {
        AVAudioUnitEQFilterParameters* filterParameters = _musicUnitEQ.bands[index];
        NSNumber* currentFreq = [self.frequencies objectAtIndex:index];;
        filterParameters.filterType = AVAudioUnitEQFilterTypeParametric;
        filterParameters.frequency = currentFreq.intValue;
        filterParameters.bandwidth = 5.0;
        filterParameters.bypass = NO;
        filterParameters.gain = gain;
    }
}

//设置均衡参数(外部调节接口)
-(void)setEQGain:(CGFloat)gain atIndex:(NSInteger)index{
    if(_player != nil && _musicUnitEQ != nil) {
        self.currentEqulizer = nil;
        AVAudioUnitEQFilterParameters* filterParameters = _musicUnitEQ.bands[index];
        NSNumber* currentFreq = [self.frequencies objectAtIndex:index];;
        filterParameters.filterType = AVAudioUnitEQFilterTypeParametric;
        filterParameters.frequency = currentFreq.intValue;
        filterParameters.bandwidth = 5.0;
        filterParameters.bypass = NO;
        filterParameters.gain = gain;
    }
}

-(BOOL)playing{
    return self.player.isPlaying;
}

-(void)stop{
    [self.player stop];
}

-(void)pause{
    
    if(_musicFile == nil && _player == nil) {
        return;
    }
    LOG(@"pause:musicEngine.isRunning:%d",self.musicEngine.isRunning);
    if (self.musicEngine.isRunning) {
        [self.musicEngine pause];
    }
    LOG(@"pause:musicEngine.isRunning:%d",self.musicEngine.isRunning);
    if (self.player.isPlaying) {
        [self.player pause];
        [self playOrPauseChanged:YES];
    }
}

-(void)play{
    
    LOG(@"play:musicEngine.isRunning:%d",self.musicEngine.isRunning);
    if (!self.musicEngine.isRunning) {
        [self.musicEngine startAndReturnError:nil];
    }
    LOG(@"play:musicEngine.isRunning:%d",self.musicEngine.isRunning);
    if (!self.player.isPlaying) {
        [self.player play];
    }
    [self playOrPauseChanged:NO];
}

-(void)playOrPauseChanged:(BOOL)isPause{
    
    for (id delegate in self.weakDelegates) {
        if ([delegate conformsToProtocol:@protocol(MEAudioPlayerDelegate)]) {
            if ([delegate respondsToSelector:@selector(audioPlayer:playOrPauseChanged:)]) {
                [delegate audioPlayer:self playOrPauseChanged:isPause];
            }
        }
    }
}
//当前播放歌曲总时长
- (NSTimeInterval)duration
{
    if(_sampleRate == 0)
        return 0;
    return (((NSTimeInterval)_musicFile.length/_sampleRate));
}
- (NSTimeInterval)currentTime
{
    if(_sampleRate == 0)
    {
        return 0;
    }
    
    NSTimeInterval currentTime = ((NSTimeInterval)[_player playerTimeForNodeTime:_player.lastRenderTime].sampleTime / _sampleRate) + self.offset;//offset 偏移修正
    return currentTime;
}

-(void)setPlayTime:(NSTimeInterval)time{
    if(_sampleRate == 0){
        return;
    }
    [self pause];

    AVAudioFramePosition newsampletime = _sampleRate * time;
    // 残り時間取得（sec）
    CGFloat length = self.duration - time;
    // 残りフレーム数（AVAudioFrameCount）取得
    AVAudioFrameCount framestoplay = _sampleRate * length;
    [self stop];
    
    if (framestoplay  > 100) {
        [self.player scheduleSegment:_musicFile startingFrame:newsampletime frameCount:framestoplay atTime:nil completionHandler:nil];
        
    }
    [self play];
    self.offset = time;
}
//更新当前时间
-(void)undataCurrentTime{
    
    if (!self.playing) {return;}
    //遍历所有代理
    for (id delegate in self.weakDelegates) {
        //检查代理是否遵守了协议
        if ([delegate conformsToProtocol:@protocol(MEAudioPlayerDelegate)]) {
            //用来决定实现那个代理方法（播放完成和更新时间）
            if (self.currentTime >= self.duration) {
                //检查代理是否实现了播放完成的代理方法
                if ([delegate respondsToSelector:@selector(audioPlayerPlayCompleted:)]) {
                    [delegate audioPlayerPlayCompleted:self];
                    [self playMusicWithPlayModel:self.playModel];
                }
            }
            //检查代理是否实现了更新时间的代理方法
            if ([delegate respondsToSelector:@selector(audioPlayer:updateTime:mucsicID:)]) {                    [delegate audioPlayer:self updateTime:self.currentTime mucsicID:self.currentMusic.describe ];
            }
        }
    }
}
//设置播放列表
-(void)setMusicList:(NSArray <MEMusic *>*) musicList andIndex:(NSInteger)index;{
    self.musicList = [NSMutableArray arrayWithArray:musicList];
    self.currentIndex = index;
    
}

-(void)resetPrivete{
    //处理”铃声/静音”开关切换，使程序在这两种状态下都能正常输出音乐
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDuckOthers error:nil];
    [session setActive:YES error:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //中断处理 比如电话呼入,闹钟响起等情况 通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    //线路改变处理 比如用户插入耳机或断开USB麦克风 通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRouteChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    
    if (self.musicEngine) {
        [self.musicEngine stop];
        [self.musicEngine reset];
//        self.musicEngine = nil;
    }
    if (self.player) {
        [self.player stop];
    }
//    self.player = nil;
//        if (self.musicUnitEQ) {
//            self.musicUnitEQ = nil;
//        }
    if (self.musicFile) {
        self.musicFile = nil;
    }
}
//重置外部调用
-(void)reset{
    [self.musicList removeAllObjects];
    [self resetPrivete];
}

-(NSURL *)fixMusicModelUrl:(MEMusic*)music{
    
    BOOL isiPod = music.isiPod;
    NSString * UrlSting = (isiPod == YES) ? music.iPodUrl : music.localUrl;
    NSURL * url ;
    if (isiPod) {
        url = [NSURL URLWithString:UrlSting];
    }else{
        NSString * docmentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString * strPath = [docmentPath stringByAppendingPathComponent:UrlSting];
        url = [NSURL fileURLWithPath:strPath];
    }
    LOG(@"url:%@",url);
    return url;
    
}
//避免用户从iPod/ituns删除音乐后出现bug
-(BOOL)checkMusicExistence:(MEMusic*)music{
    BOOL isExistence = NO;
    if (music.isiPod) {
        NSArray * array = [[MPMediaQuery songsQuery]items];
        for (MPMediaItem * item in array) {
            if (item.persistentID == music.music_id) {
                isExistence = YES;
                break;
            }
        }
    }else{
        NSString * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString * musicPath = [path stringByAppendingPathComponent:music.localUrl];
       isExistence = [[NSFileManager defaultManager] fileExistsAtPath:musicPath];
    }
    return isExistence;
}

#pragma mark - Other
//中断处理通知
- (void)handleInterruption:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType type = [[info objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    
    if (type == AVAudioSessionInterruptionTypeBegan) {
        [self pause];
    }else{
        [self play];
//        AVAudioSessionInterruptionOptions options = [[info objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
//        if (options == AVAudioSessionInterruptionOptionShouldResume) {
//            LOG(@"开始");
//            [self play];
//        }
    }
}

//输出设备改变处理通知
- (void)handleRouteChange:(NSNotification                               *)notification
{
    [self pause];
//    NSDictionary *info = notification.userInfo;
//    AVAudioSessionRouteChangeReason reason = [info[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
//    if (reason == AVAudioSessionRouteChangeReasonNewDeviceAvailable) {
//        if ([self playing]) {
//            [self pause];
//            self.breakOffTime = self.currentTime;
//            [self playMusicWithIndex:self.currentIndex];
//            [self setPlayTime:self.breakOffTime];
//            self.breakOffTime = 0;
//        }
//    }
//    else if (reason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {  //旧音频设备断开
//        //获取上一线路描述信息
//        AVAudioSessionRouteDescription *previousRoute = [info objectForKey:AVAudioSessionRouteChangePreviousRouteKey];
//        //获取上一线路的输出设备类型
//        AVAudioSessionPortDescription *previousOutput = previousRoute.outputs[0];
//        NSString *portType = previousOutput.portType;
//        LOG(@"portType:%@",portType);
//        if ([portType isEqualToString:AVAudioSessionPortHeadphones]) {
//          [self pause];
//        }else{
//            [self play];
//        }
////        if ([portType isEqualToString:AVAudioSessionPortLineOut]) {
////            
////        }
//    }
//    else if(reason == AVAudioSessionRouteChangeReasonRouteConfigurationChange){
//        
//    }
//    else{
//        [self pause];
//    }
}
//均衡器频率
-(NSArray<NSNumber *> *)frequencysArray{
    return  @[
              [NSNumber numberWithInteger:31],
              [NSNumber numberWithInteger:62],
              [NSNumber numberWithInteger:125],
              [NSNumber numberWithInteger:250],
              [NSNumber numberWithInteger:500],
              [NSNumber numberWithInteger:1000],
              [NSNumber numberWithInteger:2000],
              [NSNumber numberWithInteger:4000],
              [NSNumber numberWithInteger:8000],
              [NSNumber numberWithInteger:16000]
              ];
}
-(NSArray *)getInitialEQValue:(MEEqualizer *)equalizer{
    NSArray * array = @[
                        [NSNumber numberWithFloat:equalizer.eq_31],
                        [NSNumber numberWithFloat:equalizer.eq_62],
                        [NSNumber numberWithFloat:equalizer.eq_125],
                        [NSNumber numberWithFloat:equalizer.eq_250],
                        [NSNumber numberWithFloat:equalizer.eq_500],
                        [NSNumber numberWithFloat:equalizer.eq_1k],
                        [NSNumber numberWithFloat:equalizer.eq_2k],
                        [NSNumber numberWithFloat:equalizer.eq_4k],
                        [NSNumber numberWithFloat:equalizer.eq_8k],
                        [NSNumber numberWithFloat:equalizer.eq_16k]
                        ];
    return array;
}
//    AVAudioFormat * format1 = [_audioEngine.mainMixerNode outputFormatForBus:0];
//    AVAudioFormat * format2 = [_audioEngine.outputNode outputFormatForBus:0];
//    LOG(@"format%@",format);
//    LOG(@"format1%@",format1);
//    LOG(@"format2%@",format2);

@end
