//
//  VideoCompress.m
//  VideoCompress
//
//  Created by 何少博 on 16/11/23.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "VideoCompress.h"
#import <UIKit/UIKit.h>
@interface VideoCompress ()

@property (nonatomic ,copy) completed finish;

@property (nonatomic ,strong) AVAsset * asset;

@property (nonatomic ,strong) AVAssetReader * assetReader;

@property (nonatomic ,strong) AVAssetWriter * assetWriter;

@property (nonatomic ,strong) AVAssetReaderOutput * assetReaderAudioOutput;

@property (nonatomic ,strong) AVAssetReaderOutput * assetReaderVideoOutput;

@property (nonatomic ,strong) AVAssetWriterInput * assetWriterAudioInput;

@property (nonatomic ,strong) AVAssetWriterInput * assetWriterVideoInput;

@property (nonatomic ,strong) dispatch_queue_t mainSerializationQueue;

@property (nonatomic ,strong) dispatch_queue_t rwAudioSerializationQueue;

@property (nonatomic ,strong) dispatch_queue_t rwVideoSerializationQueue;

@property (nonatomic ,strong) dispatch_group_t dispatchGroup;

@property (nonatomic ,assign) BOOL cancelled;

@property (nonatomic ,assign) BOOL audioFinished;

@property (nonatomic ,assign) BOOL videoFinished;

@property (nonatomic ,strong) NSURL * cutVideoUrl;

@property (nonatomic ,strong) NSURL * compressTempUrl;

@end


@implementation VideoCompress

-(NSURL *)cutVideoUrl{
    if (_cutVideoUrl == nil) {
        NSString * path = [NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),@"cutvideo.mov"];
        _cutVideoUrl = [NSURL fileURLWithPath:path];
    }
    return _cutVideoUrl;
}

-(NSURL *)compressTempUrl{
    if (_compressTempUrl == nil) {
        NSString * path = [NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),@"compressTemp.mov"];
        _compressTempUrl = [NSURL fileURLWithPath:path];
    }
    return  _compressTempUrl;
}

-(void)startCompressWithAsset:(AVAsset *)asset completed:(completed)finish{
    self.finish = finish;
    self.asset = asset;
    
    if (_isPreview) {
//        [self cutVideoAndCompress];
        CMTime start = CMTimeMakeWithSeconds(0, self.asset.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds(10, self.asset.duration.timescale);
        [self cutVideoWithAsset:self.asset start:start andEnd:duration outUrl:self.cutVideoUrl isCompress:YES complete:nil];
//        [self startCompress];
    }else{
        [self startCompress];
    }
    
    
    
//    //处理初始设置
//    NSString *serializationQueueDescription = [NSString stringWithFormat:@"%@ serialization queue", self];
//    // Create the main serialization queue.
//    self.mainSerializationQueue = dispatch_queue_create([serializationQueueDescription UTF8String], NULL);
//    NSString *rwAudioSerializationQueueDescription = [NSString stringWithFormat:@"%@ rw audio serialization queue", self];
//    
//    // Create the serialization queue to use for reading and writing the audio data.
//    self.rwAudioSerializationQueue = dispatch_queue_create([rwAudioSerializationQueueDescription UTF8String], NULL);
//    NSString *rwVideoSerializationQueueDescription = [NSString stringWithFormat:@"%@ rw video serialization queue", self];
//    
//    // Create the serialization queue to use for reading and writing the video data.
//    self.rwVideoSerializationQueue = dispatch_queue_create([rwVideoSerializationQueueDescription UTF8String], NULL);
//    //加载资产轨道，并开始重新编码过程
//    self.cancelled = NO;
//    // Asynchronously load the tracks of the asset you want to read.
//    [self.asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
//        // Once the tracks have finished loading, dispatch the work to the main serialization queue.
//        dispatch_async(self.mainSerializationQueue, ^{
//            // Due to asynchronous nature, check to see if user has already cancelled.
//            if (self.cancelled){
//                return;
//            }
//            BOOL success = YES;
//            NSError *localError = nil;
//            // Check for success of loading the assets tracks.
//            success = ([self.asset statusOfValueForKey:@"tracks" error:&localError] == AVKeyValueStatusLoaded);
//            if (success)
//            {
//                // If the tracks loaded successfully, make sure that no file exists at the output path for the asset writer.
//                NSFileManager *fm = [NSFileManager defaultManager];
//                NSString *localOutputPath = [self.outputURL path];
//                if ([fm fileExistsAtPath:localOutputPath])
//                    success = [fm removeItemAtPath:localOutputPath error:&localError];
//            }
//            if (success){
//                success = [self setupAssetReaderAndAssetWriter:&localError];            }
//            if (success){
//                success = [self startAssetReaderAndWriter:&localError];
//            }
//            if (!success){
//                [self readingAndWritingDidFinishSuccessfully:success withError:localError];
//            }
//        });
//    }];
}


-(void)startCompress{
    //处理初始设置
    NSString *serializationQueueDescription = [NSString stringWithFormat:@"%@ serialization queue", self];
    // Create the main serialization queue.
    self.mainSerializationQueue = dispatch_queue_create([serializationQueueDescription UTF8String], NULL);
    NSString *rwAudioSerializationQueueDescription = [NSString stringWithFormat:@"%@ rw audio serialization queue", self];
    
    // Create the serialization queue to use for reading and writing the audio data.
    self.rwAudioSerializationQueue = dispatch_queue_create([rwAudioSerializationQueueDescription UTF8String], NULL);
    NSString *rwVideoSerializationQueueDescription = [NSString stringWithFormat:@"%@ rw video serialization queue", self];
    
    // Create the serialization queue to use for reading and writing the video data.
    self.rwVideoSerializationQueue = dispatch_queue_create([rwVideoSerializationQueueDescription UTF8String], NULL);
    //加载资产轨道，并开始重新编码过程
    self.cancelled = NO;
    // Asynchronously load the tracks of the asset you want to read.
    [self.asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        // Once the tracks have finished loading, dispatch the work to the main serialization queue.
        dispatch_async(self.mainSerializationQueue, ^{
            // Due to asynchronous nature, check to see if user has already cancelled.
            if (self.cancelled){
                return;
            }
            BOOL success = YES;
            NSError *localError = nil;
            // Check for success of loading the assets tracks.
            success = ([self.asset statusOfValueForKey:@"tracks" error:&localError] == AVKeyValueStatusLoaded);
            if (success)
            {
                // If the tracks loaded successfully, make sure that no file exists at the output path for the asset writer.
                NSFileManager *fm = [NSFileManager defaultManager];
                NSString *localOutputPath = [self.outputURL path];//[self.compressTempUrl path];
                if ([fm fileExistsAtPath:localOutputPath])
                    success = [fm removeItemAtPath:localOutputPath error:&localError];
            }
            if (success){
                success = [self setupAssetReaderAndAssetWriter:&localError];            }
            if (success){
                success = [self startAssetReaderAndWriter:&localError];
            }
            if (!success){
                [self readingAndWritingDidFinishSuccessfully:success withError:localError];
            }
        });
    }];
}
 //初始化资产读取器和写入器
- (BOOL)setupAssetReaderAndAssetWriter:(NSError **)outError
{
    // Create and initialize the asset reader.
    self.assetReader = [[AVAssetReader alloc] initWithAsset:self.asset error:outError];
    BOOL success = (self.assetReader != nil);
    if (success)
    {
        // If the asset reader was successfully initialized, do the same for the asset writer.
        self.assetWriter = [[AVAssetWriter alloc] initWithURL:self.outputURL//self.compressTempUrl
                                                     fileType:AVFileTypeQuickTimeMovie
                                                        error:outError];
        success = (self.assetWriter != nil);
    }
    
    if (success)
    {
        // If the reader and writer were successfully initialized, grab the audio and video asset tracks that will be used.
        AVAssetTrack *assetAudioTrack = nil;
        AVAssetTrack *assetVideoTrack = nil;
        NSArray *audioTracks = [self.asset tracksWithMediaType:AVMediaTypeAudio];
        if ([audioTracks count] > 0){
            assetAudioTrack = [audioTracks objectAtIndex:0];
        }
        NSArray *videoTracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
        if ([videoTracks count] > 0){
            assetVideoTrack = [videoTracks objectAtIndex:0];
//            if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
//                
//            }else{
//                assetVideoTrack.preferredTransform = CGAffineTransformMakeRotation(M_PI_2);
//            }
            
        }
        
//        AVMutableComposition *mainComposition = [[AVMutableComposition alloc]init];
//              AVMutableCompositionTrack * assetAudioTrack =[mainComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//        AVMutableCompositionTrack * assetVideoTrack=[mainComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//        
//        CMTime start = CMTimeMakeWithSeconds(0, 1);
//        CMTime duration = CMTimeMakeWithSeconds(3, 1);
//        CMTimeRange range = CMTimeRangeMake(start, duration);
//
//        
//        NSArray *audioTracks = [self.asset tracksWithMediaType:AVMediaTypeAudio];
//        [assetAudioTrack insertTimeRange:range ofTrack:audioTracks.firstObject atTime:kCMTimeZero error:nil];
//        
//        NSArray *videoTracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
//        [assetVideoTrack insertTimeRange:range ofTrack:videoTracks.firstObject atTime:kCMTimeZero error:nil];
        
        if (assetAudioTrack)
        {
            // If there is an audio track to read, set the decompression settings to Linear PCM and create the asset reader output.
            NSDictionary *decompressionAudioSettings = @{ AVFormatIDKey : [NSNumber numberWithUnsignedInt:kAudioFormatLinearPCM] };
            self.assetReaderAudioOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:assetAudioTrack
                                                                                     outputSettings:decompressionAudioSettings];
            [self.assetReader addOutput:self.assetReaderAudioOutput];
            // Then, set the compression settings to 128kbps AAC and create the asset writer input.
            AudioChannelLayout stereoChannelLayout = {
                .mChannelLayoutTag = kAudioChannelLayoutTag_Stereo,
                .mChannelBitmap = 0,
                .mNumberChannelDescriptions = 0
            };
            NSData *channelLayoutAsData = [NSData dataWithBytes:&stereoChannelLayout length:offsetof(AudioChannelLayout, mChannelDescriptions)];
            NSDictionary *compressionAudioSettings = @{
                                                       AVFormatIDKey         : [NSNumber numberWithUnsignedInt:kAudioFormatMPEG4AAC],
                                                       AVEncoderBitRateKey   : [NSNumber numberWithInteger:128000],
                                                       AVSampleRateKey       : [NSNumber numberWithInteger:44100],
                                                       AVChannelLayoutKey    : channelLayoutAsData,
                                                       AVNumberOfChannelsKey : [NSNumber numberWithUnsignedInteger:2]
                                                       };
            self.assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:[assetAudioTrack mediaType]
                                                                            outputSettings:compressionAudioSettings];
            [self.assetWriter addInput:self.assetWriterAudioInput];
        }
        
        if(assetVideoTrack)
        {
            // If there is a video track to read, set the decompression settings for YUV and create the asset reader output.
            NSDictionary *decompressionVideoSettings = @{
                                                         (id)kCVPixelBufferPixelFormatTypeKey     : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_422YpCbCr8],
                                                         (id)kCVPixelBufferIOSurfacePropertiesKey : [NSDictionary dictionary]
                                                         };
            self.assetReaderVideoOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:assetVideoTrack
                                                                                     outputSettings:decompressionVideoSettings];
            [self.assetReader addOutput:self.assetReaderVideoOutput];
            CMFormatDescriptionRef formatDescription = NULL;
            // Grab the video format descriptions from the video track and grab the first one if it exists.
            NSArray *videoFormatDescriptions = [assetVideoTrack formatDescriptions];
            if ([videoFormatDescriptions count] > 0){
                formatDescription = (__bridge CMFormatDescriptionRef)[videoFormatDescriptions objectAtIndex:0];
            }
            CGSize trackDimensions = {
                .width = 0.0,
                .height = 0.0,
            };
            // If the video track had a format description, grab the track dimensions from there. Otherwise, grab them direcly from the track itself.
            if (formatDescription){
                trackDimensions = CMVideoFormatDescriptionGetPresentationDimensions(formatDescription, false, false);
            }
            else{
                trackDimensions = [assetVideoTrack naturalSize];
            }
            NSDictionary *compressionSettings = nil;
            // If the video track had a format description, attempt to grab the clean aperture settings and pixel aspect ratio used by the video.
            if (formatDescription)
            {
                NSDictionary *cleanAperture = nil;
                NSDictionary *pixelAspectRatio = nil;
                CFDictionaryRef cleanApertureFromCMFormatDescription = CMFormatDescriptionGetExtension(formatDescription, kCMFormatDescriptionExtension_CleanAperture);
                if (cleanApertureFromCMFormatDescription)
                {
                    cleanAperture = @{
                                      AVVideoCleanApertureWidthKey            : (id)CFDictionaryGetValue(cleanApertureFromCMFormatDescription, kCMFormatDescriptionKey_CleanApertureWidth),
                                      AVVideoCleanApertureHeightKey           : (id)CFDictionaryGetValue(cleanApertureFromCMFormatDescription, kCMFormatDescriptionKey_CleanApertureHeight),
                                      AVVideoCleanApertureHorizontalOffsetKey : (id)CFDictionaryGetValue(cleanApertureFromCMFormatDescription, kCMFormatDescriptionKey_CleanApertureHorizontalOffset),
                                      AVVideoCleanApertureVerticalOffsetKey   : (id)CFDictionaryGetValue(cleanApertureFromCMFormatDescription, kCMFormatDescriptionKey_CleanApertureVerticalOffset)
                                      };
                }
                CFDictionaryRef pixelAspectRatioFromCMFormatDescription = CMFormatDescriptionGetExtension(formatDescription, kCMFormatDescriptionExtension_PixelAspectRatio);
                if (pixelAspectRatioFromCMFormatDescription)
                {
                    pixelAspectRatio = @{
                                         AVVideoPixelAspectRatioHorizontalSpacingKey : (id)CFDictionaryGetValue(pixelAspectRatioFromCMFormatDescription, kCMFormatDescriptionKey_PixelAspectRatioHorizontalSpacing),
                                         AVVideoPixelAspectRatioVerticalSpacingKey   : (id)CFDictionaryGetValue(pixelAspectRatioFromCMFormatDescription, kCMFormatDescriptionKey_PixelAspectRatioVerticalSpacing)
                                         };
                }
                // Add whichever settings we could grab from the format description to the compression settings dictionary.
                if (cleanAperture || pixelAspectRatio)
                {
                    NSMutableDictionary *mutableCompressionSettings = [NSMutableDictionary dictionary];
                    if (cleanAperture)
                        [mutableCompressionSettings setObject:cleanAperture forKey:AVVideoCleanApertureKey];
                    if (pixelAspectRatio)
                        [mutableCompressionSettings setObject:pixelAspectRatio forKey:AVVideoPixelAspectRatioKey];
                    
                    [mutableCompressionSettings setObject:@60000 forKey:AVVideoAverageBitRateKey];
                    [mutableCompressionSettings setObject:AVVideoProfileLevelH264High40 forKey:AVVideoProfileLevelKey];
                    compressionSettings = mutableCompressionSettings;
                }
            }
            // Create the video settings dictionary for H.264.
//            NSMutableDictionary *videoSettings = (NSMutableDictionary *) @{
//                                                                           AVVideoCodecKey  : AVVideoCodecH264,
//                                                                           AVVideoWidthKey  : [NSNumber numberWithDouble:trackDimensions.width],
//                                                                           AVVideoHeightKey : [NSNumber numberWithDouble:trackDimensions.height]
//                                                                           };
            
            
            //处理旋转问题
            NSInteger width = 480;
            NSInteger height = 640;
            NSInteger bitRate = 1280000;
            NSInteger  jiaodu = [self degressFromVideoFileWithURL:assetVideoTrack];
//            NSLog(@"视频角度%ld",(long)jiaodu);
            if (jiaodu == 90 || jiaodu == 270) {
                width = self.settings.height;
                height = self.settings.width;
                bitRate = self.settings.bitRate > 50000 ? self.settings.bitRate : 50000;
            }else{
                width = self.settings.width;
                height = self.settings.height;
                bitRate = self.settings.bitRate > 50000 ? self.settings.bitRate : 50000;
            }
            
            NSMutableDictionary *videoSettingsTemp = (NSMutableDictionary *) @
                {
                        AVVideoCodecKey: AVVideoCodecH264,
                        AVVideoWidthKey: @(width),
                        AVVideoHeightKey: @(height),
                        AVVideoCompressionPropertiesKey: @
                                                        {
                                                        AVVideoAverageBitRateKey: @(bitRate),
                                                        AVVideoProfileLevelKey:AVVideoProfileLevelH264High40,
                                                        },
                };
//            AVVideoExpectedSourceFrameRateKey
            NSMutableDictionary * videoSettings = [NSMutableDictionary dictionaryWithDictionary:videoSettingsTemp];
            // Put the compression settings into the video settings dictionary if we were able to grab them.
//            if (compressionSettings){
//                [videoSettings setValue:compressionSettings forKey:AVVideoCompressionPropertiesKey];
////                [videoSettings setObject:compressionSettings forKey:AVVideoCompressionPropertiesKey];
//            }
            // Create the asset writer input and add it to the asset writer.
            self.assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:assetVideoTrack.mediaType
                                                                            outputSettings:videoSettings];
//            if (self.settings.width < self.settings.height) {
//                self.assetWriterVideoInput.transform = CGAffineTransformMakeRotation(M_PI_2);
//            }
            switch (jiaodu) {
                case 0:
                    
                    break;
                case 90:
                    self.assetWriterVideoInput.transform = CGAffineTransformMakeRotation(M_PI_2);
                    break;
                case 180:
                    self.assetWriterVideoInput.transform = CGAffineTransformMakeRotation(M_PI);
                    break;
                case 270:
                    self.assetWriterVideoInput.transform = CGAffineTransformMakeRotation(M_PI_2 + M_PI);
                    break;
                default:
                    break;
            }
            [self.assetWriter addInput:self.assetWriterVideoInput];
        }
    }
    return success;
}
- (NSUInteger)degressFromVideoFileWithURL:(AVAssetTrack *)videoTrack
{
    NSUInteger degress = 0;
        CGAffineTransform t = videoTrack.preferredTransform;
        
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    return degress;
}


//重新编码资产
- (BOOL)startAssetReaderAndWriter:(NSError **)outError
{
    BOOL success = YES;
    // Attempt to start the asset reader.
    success = [self.assetReader startReading];
    if (!success)
        *outError = [self.assetReader error];
    if (success)
    {
        // If the reader started successfully, attempt to start the asset writer.
        success = [self.assetWriter startWriting];
        if (!success)
            *outError = [self.assetWriter error];
    }
    
    if (success)
    {
        // If the asset reader and writer both started successfully, create the dispatch group where the reencoding will take place and start a sample-writing session.
        self.dispatchGroup = dispatch_group_create();
        [self.assetWriter startSessionAtSourceTime:kCMTimeZero];
//        [self.assetWriter endSessionAtSourceTime:CMTimeMake(100, 30)];
        self.audioFinished = NO;
        self.videoFinished = NO;
        
        if (self.assetWriterAudioInput)
        {
            // If there is audio to reencode, enter the dispatch group before beginning the work.
            dispatch_group_enter(self.dispatchGroup);
            // Specify the block to execute when the asset writer is ready for audio media data, and specify the queue to call it on.
            [self.assetWriterAudioInput requestMediaDataWhenReadyOnQueue:self.rwAudioSerializationQueue usingBlock:^{
                // Because the block is called asynchronously, check to see whether its task is complete.
                if (self.audioFinished)
                    return;
                BOOL completedOrFailed = NO;
                // If the task isn't complete yet, make sure that the input is actually ready for more media data.
                while ([self.assetWriterAudioInput isReadyForMoreMediaData] && !completedOrFailed)
                {
                    // Get the next audio sample buffer, and append it to the output file.
                    CMSampleBufferRef sampleBuffer = [self.assetReaderAudioOutput copyNextSampleBuffer];
                    if (sampleBuffer != NULL)
                    {
                        BOOL success = [self.assetWriterAudioInput appendSampleBuffer:sampleBuffer];
                        CFRelease(sampleBuffer);
                        sampleBuffer = NULL;
                        completedOrFailed = !success;
                    }
                    else
                    {
                        completedOrFailed = YES;
                    }
                }
                if (completedOrFailed)
                {
                    // Mark the input as finished, but only if we haven't already done so, and then leave the dispatch group (since the audio work has finished).
                    BOOL oldFinished = self.audioFinished;
                    self.audioFinished = YES;
                    if (oldFinished == NO)
                    {
                        [self.assetWriterAudioInput markAsFinished];
                    }
                    dispatch_group_leave(self.dispatchGroup);
                }
            }];
        }
        if (self.assetWriterVideoInput)
        {
            // If we had video to reencode, enter the dispatch group before beginning the work.
            dispatch_group_enter(self.dispatchGroup);
            // Specify the block to execute when the asset writer is ready for video media data, and specify the queue to call it on.
//            __block NSInteger  count = 0;
            [self.assetWriterVideoInput requestMediaDataWhenReadyOnQueue:self.rwVideoSerializationQueue usingBlock:^{
                // Because the block is called asynchronously, check to see whether its task is complete.
                if (self.videoFinished)
                    return;
                BOOL completedOrFailed = NO;
//                NSLog(@"count:%d",(int)count);
//                count ++;
                // If the task isn't complete yet, make sure that the input is actually ready for more media data.
                while ([self.assetWriterVideoInput isReadyForMoreMediaData] && !completedOrFailed)
                {
                    
                    // Get the next video sample buffer, and append it to the output file.
//                    CGImageRef image = [inClip copyImageAtIndex:frameCounter withSize:CGSizeZero error:&error];
//                    CGFloat progress = (CGFloat)frameCounter / (CGFloat)inRange.length;
                    
                    CMSampleBufferRef sampleBuffer = [self.assetReaderVideoOutput copyNextSampleBuffer];
                    if (sampleBuffer != NULL)
                    {
                        BOOL success = [self.assetWriterVideoInput appendSampleBuffer:sampleBuffer];
                        CFRelease(sampleBuffer);
                        sampleBuffer = NULL;
                        completedOrFailed = !success;
                    }
                    else
                    {
                        completedOrFailed = YES;
                    }
                }
                
                if (completedOrFailed)
                {
                    // Mark the input as finished, but only if we haven't already done so, and then leave the dispatch group (since the video work has finished).
                    BOOL oldFinished = self.videoFinished;
                    self.videoFinished = YES;
                    if (oldFinished == NO)
                    {
                        [self.assetWriterVideoInput markAsFinished];
                    }
                    dispatch_group_leave(self.dispatchGroup);
                }
            }];
        }
        // Set up the notification that the dispatch group will send when the audio and video work have both finished.
        dispatch_group_notify(self.dispatchGroup, self.mainSerializationQueue, ^{
            BOOL finalSuccess = YES;
            NSError *finalError = nil;
            
            // Check to see if the work has finished due to cancellation.
            if (self.cancelled)
            {
                // If so, cancel the reader and writer.
                [self.assetReader cancelReading];
                [self.assetWriter cancelWriting];
            }
            else
            {
                // If cancellation didn't occur, first make sure that the asset reader didn't fail.
                if ([self.assetReader status] == AVAssetReaderStatusFailed)
                {
                    finalSuccess = NO;
                    finalError = [self.assetReader error];
                }
                // If the asset reader didn't fail, attempt to stop the asset writer and check for any errors.
                if (finalSuccess)
                {
                    
                    finalSuccess = [self.assetWriter finishWriting];
//                    __weak typeof(self) weakSelf = self;
//                    [self.assetWriter finishWritingWithCompletionHandler:^{
//                        if(weakSelf.assetWriter.status == AVAssetWriterStatusCompleted){
//                            finalSuccess = YES;
//                        }
//                        if (weakSelf.assetWriter.status == AVAssetWriterStatusFailed) {
//                            finalError = [weakSelf.assetWriter error];
//                        }
//                    }];
                    if (!finalSuccess)
                        finalError = [self.assetWriter error];
                }
            }
            // Call the method to handle completion, and pass in the appropriate parameters to indicate whether reencoding was successful.
            [self readingAndWritingDidFinishSuccessfully:finalSuccess withError:finalError];
        });
    }
    // Return success here to indicate whether the asset reader and writer were started successfully.
    return success;
}
#pragma mark - 处理完成
- (void)readingAndWritingDidFinishSuccessfully:(BOOL)success withError:(NSError *)error
{
    if (!success)
    {
        // If the reencoding process failed, we need to cancel the asset reader and writer.
        [self.assetReader cancelReading];
        [self.assetWriter cancelWriting];
        [self emptyOperation];
        [self removeCutVideoUrl];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Handle any UI tasks here related to failure.
            
            self.finish(NO);
//            NSLog(@"failure,%@",error);
        });
    }
    else
    {
        // Reencoding was successful, reset booleans.
        [self emptyOperation];
        NSFileManager * fm =[NSFileManager defaultManager];
        NSString* cutVideoPath = self.cutVideoUrl.path;
        [fm fileExistsAtPath:cutVideoPath];
        if ([fm fileExistsAtPath:cutVideoPath]) {
            [[NSFileManager defaultManager]removeItemAtURL:self.cutVideoUrl error:nil];
            self.cutVideoUrl = nil;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // Handle any UI tasks here related to success.
            self.finish(YES);
//            [self adjustVideoOrgin];
//            NSLog(@"compressSuccess");
        });
    }
}

-(void)emptyOperation{
    self.cancelled = NO;
    self.videoFinished = NO;
    self.audioFinished = NO;
    self.asset = nil;
    self.assetReader = nil;
    self.assetWriter = nil;
    self.assetReaderAudioOutput = nil;
    self.assetReaderVideoOutput = nil;
    self.assetWriterAudioInput = nil;
    self.assetWriterVideoInput = nil;
    self.mainSerializationQueue = nil;
    self.rwAudioSerializationQueue = nil;
    self.rwVideoSerializationQueue = nil;
    self.dispatchGroup = nil;
}

#pragma mark - 处理注销
- (void)cancel
{
    // Handle cancellation asynchronously, but serialize it with the main queue.
    dispatch_async(self.mainSerializationQueue, ^{
        // If we had audio data to reencode, we need to cancel the audio work.
        if (self.assetWriterAudioInput)
        {
            // Handle cancellation asynchronously again, but this time serialize it with the audio queue.
            dispatch_async(self.rwAudioSerializationQueue, ^{
                // Update the Boolean property indicating the task is complete and mark the input as finished if it hasn't already been marked as such.
                BOOL oldFinished = self.audioFinished;
                self.audioFinished = YES;
                if (oldFinished == NO)
                {
                    [self.assetWriterAudioInput markAsFinished];
                }
                // Leave the dispatch group since the audio work is finished now.
                dispatch_group_leave(self.dispatchGroup);
            });
        }
        
        if (self.assetWriterVideoInput)
        {
            // Handle cancellation asynchronously again, but this time serialize it with the video queue.
            dispatch_async(self.rwVideoSerializationQueue, ^{
                // Update the Boolean property indicating the task is complete and mark the input as finished if it hasn't already been marked as such.
                BOOL oldFinished = self.videoFinished;
                self.videoFinished = YES;
                if (oldFinished == NO)
                {
                    [self.assetWriterVideoInput markAsFinished];
                }
                // Leave the dispatch group, since the video work is finished now.
                dispatch_group_leave(self.dispatchGroup);
            });
        }
        // Set the cancelled Boolean property to YES to cancel any work on the main queue as well.
        self.cancelled = YES;
    });
}
#pragma mark - 预览剪切前⑩秒

-(void)cutVideoWithAsset:(AVAsset *) asset start:(CMTime)start andEnd:(CMTime)end outUrl:(NSURL *) outputUrl complete:(cutComplete)complete{
    [self cutVideoWithAsset:asset start:start andEnd:end outUrl:outputUrl isCompress:NO complete:complete];
}

-(void)cutVideoWithAsset:(AVAsset *) asset start:(CMTime)start andEnd:(CMTime)end outUrl:(NSURL *) outputUrl isCompress:(BOOL)isCompress complete:(cutComplete)complete{
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        
        [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                                   initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
            
            exportSession.outputURL = outputUrl;
            exportSession.outputFileType = AVFileTypeQuickTimeMovie;
            

            CMTimeRange range = CMTimeRangeMake(start, end);
            exportSession.timeRange = range;
            
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                
                switch ([exportSession status]) {
                    case AVAssetExportSessionStatusFailed:
                        if (isCompress) {
                            [self removeCutVideoUrl];
                            self.finish(NO);
                        }
                        else if (complete) {
                            complete(exportSession.error);
                        }
                        NSLog(@"Export failed: %@", [exportSession error]);
                        break;
                    case AVAssetExportSessionStatusCancelled:
                        if (isCompress) {
                            [self removeCutVideoUrl];
                            self.finish(NO);
                        }
                        else if (complete) {
                            complete(exportSession.error);
                        }
                        NSLog(@"Export canceled");
                        break;
                    case AVAssetExportSessionStatusCompleted:{
                        
                        if (isCompress) {
                            NSLog(@"Export Completed");
                            AVAsset *newAsset = [AVAsset assetWithURL:self.cutVideoUrl];
                            self.asset = newAsset;
                            [self startCompress];;
                        }
                        else if (complete) {
                            complete(exportSession.error);
                        }
                    }
                        break;
                    default:{
                        if (isCompress) {
                            NSLog(@"Export Completed");
                            AVAsset *newAsset = [AVAsset assetWithURL:self.cutVideoUrl];
                            self.asset = newAsset;
                            [self startCompress];;
                        }
                        else if (complete) {
                            complete(exportSession.error);
                        }
                    }
                        break;
                }
            }];
        }];
        
    }
    
}


-(void)removeCutVideoUrl{
    if([[NSFileManager defaultManager] fileExistsAtPath:self.cutVideoUrl.path]){
        [[NSFileManager defaultManager] removeItemAtURL:self.cutVideoUrl error:nil];
    }
}

- (void)dealloc
{
//    NSLog(@"compressTool dealloc");
}
- (void)adjustVideoOrgin{
    
    AVAsset *compressedAsset = [AVAsset assetWithURL:self.compressTempUrl];
    
    AVMutableComposition *compostion = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *video = [compostion addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:0];
    
    [video insertTimeRange:CMTimeRangeMake(kCMTimeZero, compressedAsset.duration) ofTrack:[compressedAsset tracksWithMediaType:AVMediaTypeVideo].firstObject atTime:kCMTimeZero error:nil];
    
    AVMutableCompositionTrack *audio = [compostion addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    
    [audio insertTimeRange:CMTimeRangeMake(kCMTimeZero, compressedAsset.duration) ofTrack:[compressedAsset tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:kCMTimeZero error:nil];
    
    AVAssetTrack *videoAssetTrack =[[compressedAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    //    AVAssetTrack *audioAssetTrack =[[compressedAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, compressedAsset.duration);
    
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:video];
    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
    BOOL isVideoAssetPortrait_  = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ = UIImageOrientationRight;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ =  UIImageOrientationLeft;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation_ =  UIImageOrientationUp;
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation_ = UIImageOrientationDown;
    }
    [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    [videolayerInstruction setOpacity:0.0 atTime:compressedAsset.duration];
    
    // 3.3 - Add instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    
    CGSize naturalSize;
    if(isVideoAssetPortrait_){
        naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    } else {
        naturalSize = videoAssetTrack.naturalSize;
    }
    float renderWidth, renderHeight;
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1,30);
    mainCompositionInst.renderScale = 1.0;
    
    AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:compostion presetName:AVAssetExportPresetHighestQuality];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *localOutputPath = [self.outputURL path];
    if ([fm fileExistsAtPath:localOutputPath]){
        [fm removeItemAtPath:localOutputPath error:nil];
    }
    //    NSLog(@"%@",session.supportedFileTypes);
    
    
    session.outputURL = self.outputURL;
    session.outputFileType = @"com.apple.quicktime-movie";
    session.shouldOptimizeForNetworkUse = YES;
    session.videoComposition = mainCompositionInst;
    
    [session exportAsynchronouslyWithCompletionHandler:^{
        
        switch ([session status]) {
            case AVAssetExportSessionStatusFailed:
                self.finish(NO);
                //                NSLog(@"Export failed: %@", [[session error] localizedDescription]);
                break;
            case AVAssetExportSessionStatusCancelled:
                self.finish(NO);
                //                NSLog(@"Export canceled");
                break;
            case AVAssetExportSessionStatusCompleted:{
                self.finish(YES);
                //                NSLog(@"Export Completed");
            }
                break;
            default:{
                self.finish(YES);
                //                NSLog(@"Export none");
            }
                break;
        }
    }];
    
}

@end
