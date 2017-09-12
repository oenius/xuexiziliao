//
//  AVRecoder.m
//  AVRecorder
//
//  Created by vae on 16/8/17.
//  Copyright © 2016年 vae. All rights reserved.
//

#import "AVRecoder.h"
#import "XTimer.h"

@interface AVRecoder ()<AVAudioPlayerDelegate>

@property (weak,nonatomic) id<AVRecoderDelegate> deleagte;
/** 录音 */
@property (nonatomic, strong) AVAudioRecorder *recorder;

/** 播放 */
@property (nonatomic, strong) AVAudioPlayer   *player;

/** 定时器 */
@property (nonatomic, strong) XTimer *timer;

@property (nonatomic,assign)NSTimeInterval timeInterval;

@end


@implementation AVRecoder

-(instancetype)init{
    self = [super init];
    if (self) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *sessionError;
        //AVAudioSessionCategoryPlayAndRecord用于录音和播放
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        if(session == nil)
            NSLog(@"Error creating session: %@", [sessionError description]);
        else
            [session setActive:YES error:nil];
    }
    return self;

}

#pragma mark - 录音相关

-(BOOL)RecorderWithFileUrl:(NSString *)fileUrl OpenTimerdelegate:(id<AVRecoderDelegate>)deleagte{
    BOOL result = [self RecorderWithFileUrl:fileUrl];
    if (result) {
        self.deleagte = deleagte;
        self.timeInterval = 0;
        self.timer = [XTimer scheduledTimerWithTimeInterval:0.99 target:self selector:@selector(returnDelegateTimer) userInfo:nil repeats:YES];
    }
    return result;
}

-(BOOL)RecorderWithFileUrl:(NSString *)fileUrl{
    if (self.recorder) {
        NSLog(@"录音已被初始化或正在录音");
        return NO;
    }
  NSDictionary *  recorderSettingsDict =[[NSDictionary alloc] initWithObjectsAndKeys:
                                [NSNumber numberWithInt:kAudioFormatMPEG4AAC],AVFormatIDKey,
                                [NSNumber numberWithInt:44100.0],AVSampleRateKey,
                                [NSNumber numberWithInt:2],AVNumberOfChannelsKey,
                                [NSNumber numberWithInt:8],AVLinearPCMBitDepthKey,
                                [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                nil];
    
    NSError *error = nil;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:fileUrl]
                                                   settings:recorderSettingsDict
                                                      error:&error];
    
    // 打开音量检测
    self.recorder.meteringEnabled = YES;
    
    // 创建文件准备录音
    BOOL result = [self.recorder prepareToRecord];
    if (result) {
        // 开始录音
       result = [self.recorder record];
    }else{
        NSLog(@"准备录音失败");
    }
    return result;
}

-(BOOL)recording{
    return self.recorder.recording;
}

-(void)pauseRecord{
    [self.recorder pause];
    if (_timer) [_timer stop];
}

-(BOOL)resumeRecord{
    if (_timer) [_timer reStart];
    return [self.recorder record];
}

-(void)stopRecord{
    [self.recorder stop];
    self.recorder = nil;
    if (_timer) [_timer invalidate];
}

#pragma mark - 播放录音相关

-(BOOL)PlayRecoderWithFileUrl:(NSString *)fileUrl delegate:(id<AVRecoderDelegate>)deleagte{
    BOOL result = [self PlayRecoderWithFileUrl:fileUrl];
    if (result) {
        self.deleagte = deleagte;
    }
    return result;
}

-(BOOL)PlayRecoderWithFileUrl:(NSString *)fileUrl{
    
    NSError *error = nil;
     self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:fileUrl] error:&error];
    self.player.delegate = self;
     AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
   BOOL result = [self.player prepareToPlay];
    if (result) {
       result = [self.player play];
    }else{
        NSLog(@"准备播放失败");
    }
    return result;
}

-(BOOL)playRecodering{
    return self.player.playing;
}

-(void)pausePlayRecoder{
    [self.player pause];
}

-(BOOL)resumePlayRecord{
    return [self.player play];
}

- (void)stopPlayRecoder{
    [self.player stop];
    self.player = nil;
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if ([self.deleagte respondsToSelector:@selector(recoderDidFinishPlaying:successfully:)]) {
        
        [self.deleagte recoderDidFinishPlaying:self successfully:flag];
    }
}

#pragma mark- timer相关

-(void)returnDelegateTimer{
    if (!_timer) return;
    self.timeInterval ++;
    int totalSeconds = (int)ceil(_timeInterval);
    int hourComponent = totalSeconds / 3600;
    int secondsComponent = totalSeconds % 60;
    int minutesComponent = (totalSeconds / 60) % 60;
    NSString * timeString = [NSString stringWithFormat:@"%02d:%02d:%02d",hourComponent, minutesComponent, secondsComponent];
    if ([self.deleagte respondsToSelector:@selector(currentRecoderTime:timeString:)]) {
        [self.deleagte currentRecoderTime:_timeInterval timeString:timeString];
    }
}

@end
