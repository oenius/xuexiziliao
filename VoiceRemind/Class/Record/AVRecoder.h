//
//  AVRecoder.h
//  AVRecorder
//
//  Created by vae on 16/8/17.
//  Copyright © 2016年 vae. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@protocol AVRecoderDelegate ;



@interface AVRecoder : NSObject


@property(readonly,assign) BOOL recording;

/** 是否正在播放录音 */
@property(readonly,assign) BOOL playRecodering;


/**
 *  开启录音 失败返回 NO
 *
 *  @param fileUrl 文件存储的路径
 */
-(BOOL)RecorderWithFileUrl:(NSString *)fileUrl;

-(BOOL)RecorderWithFileUrl:(NSString *)fileUrl OpenTimerdelegate:(id<AVRecoderDelegate>)deleagte;

/** 暂停录音 */
-(void)pauseRecord;

/**  暂停后重新开始录音 失败返回 NO*/
-(BOOL)resumeRecord;

/** 结束录音 */
-(void)stopRecord;

/**
 *  播放录音 失败返回 NO
 *
 *  @param fileUrl 文件存储的路径
 */
-(BOOL)PlayRecoderWithFileUrl:(NSString *)fileUrl;

-(BOOL)PlayRecoderWithFileUrl:(NSString *)fileUrl delegate:(id<AVRecoderDelegate>)deleagte;

/** 暂停播放 */
-(void)pausePlayRecoder;

/** 暂停后重新播放 失败返回 NO*/
-(BOOL)resumePlayRecord;

/** 停止播放 */
- (void)stopPlayRecoder;


@end

@protocol AVRecoderDelegate <NSObject>

@optional

-(void)currentRecoderTime:(NSTimeInterval)time timeString:(NSString*)timeString;
-(void)recoderDidFinishPlaying:(AVRecoder*) recoder successfully:(BOOL)flag;

@end
