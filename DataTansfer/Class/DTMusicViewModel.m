//
//  DTMusicViewModel.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/19.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTMusicViewModel.h"
#import "UIDevice+x.h"
#import "UIWindow+JKHierarchy.h"
@interface DTMusicViewModel ()

@property(copy,nonatomic) DTAuthorizationResultBlock block;

@end

@implementation DTMusicViewModel

-(NSInteger)numberOfSectionsInTableView{
    return 1;
}
-(NSInteger)numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
-(DTMusicModel *)modelAtIndexPath:(NSIndexPath *)indexPath{
    return self.dataArray[indexPath.row];
}
-(void)setSelectedArrayWithIndexPaths:(NSArray <NSIndexPath *>*)seletctIndexPaths{
    [self.selectedArray removeAllObjects];
    for (NSIndexPath * indexPath in seletctIndexPaths) {
        DTMusicModel * model = self.dataArray[indexPath.row];
        model.isSelected = YES;
//        if (![self.selectedArray containsObject:model]) {
            [self.selectedArray addObject:model];
//        }
    }
    self.selectedCount = self.selectedArray.count;
}

-(void)getSelectIndexPathsFromModels:(NSMutableArray *) selectedIndexPaths{
    for (DTMusicModel * model in self.selectedArray) {
        NSUInteger index = [self.dataArray indexOfObject:model];
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        if (![selectedIndexPaths containsObject:indexPath]) {
            [selectedIndexPaths addObject:indexPath];
        }
    }
}

-(void)authorizationStatus:(DTAuthorizationResultBlock)block{
    self.block = block;
    if ([UIDevice systemVersionGreaterThan9_3]) {
        MPMediaLibraryAuthorizationStatus mediaStatus = [MPMediaLibrary authorizationStatus];
        switch (mediaStatus) {
            case MPMediaLibraryAuthorizationStatusNotDetermined:{
                [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
                    if (status == MPMediaLibraryAuthorizationStatusAuthorized) {
                        if (self.block) {
                            self.block(DTAuthorizationResultYES);
                        }
                    }else{
                        if (self.block) {
                            self.block(DTAuthorizationResultNO);
                        }
                    }
                }];
            }
                break;
            case MPMediaLibraryAuthorizationStatusAuthorized:
                if (self.block) {
                    self.block(DTAuthorizationResultYES);
                }
                break;
            case MPMediaLibraryAuthorizationStatusDenied:
            case MPMediaLibraryAuthorizationStatusRestricted:
                [self authorizationStatusDeniedAlertView];
                break;
                
            default:
                break;
        }
    }else{
        if (self.block) {
            self.block(DTAuthorizationResultYES);
        }
    }
}

-(void)authorizationStatusDeniedAlertView{
    UIAlertController * alertCon = [UIAlertController alertControllerWithTitle:[DTConstAndLocal tishi] message:[DTConstAndLocal meidaLiabrygoset] preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:[DTConstAndLocal cancel] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        if (self.block) {
            self.block(DTAuthorizationResultNO);
        }
    }];
    UIAlertAction * done = [UIAlertAction actionWithTitle:[DTConstAndLocal settings] style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        NSURL * settingUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication]canOpenURL:settingUrl]) {
            [[UIApplication sharedApplication]openURL:settingUrl];
        }
    }];
    
    [alertCon addAction:cancel];
    [alertCon addAction:done];
    
    UIViewController * preset = [[UIApplication sharedApplication].keyWindow jk_topMostController];
    [preset presentViewController:alertCon animated:YES completion:nil];
}

-(void)loadDatas{
    WEAKSELF_DT
    if([UIDevice systemVersionGreaterThan9_3]){
        [self authorizationStatus:^(DTAuthorizationResult result) {
            if (result == DTAuthorizationResultYES) {
                [weakSelf loadMusics];
            }else{
                return ;
            }
        }];
    }else{
        [self loadMusics];
    }
    
}
-(void)loadMusics{
    [self.dataArray removeAllObjects];
    NSArray * mediaItemArray = [[MPMediaQuery songsQuery]items];
    for (MPMediaItem * item in mediaItemArray) {
        NSURL * iPodUrl = item.assetURL;
        if (iPodUrl == nil) { continue; }
        DTMusicModel * model = [DTMusicModel modelWithMeidaItem:item];
        [self.dataArray addObject:model];
    }
    self.totleCount = self.dataArray.count;
}

+(void)archivedModel:(DTMusicModel*)model completed:(void (^)(NSData *))completed{
    AVURLAsset *musicAsset = [AVURLAsset URLAssetWithURL:model.iPodUrl options:nil];
    NSString * tempPath = NSTemporaryDirectory();
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset: musicAsset presetName: AVAssetExportPresetPassthrough];
    exporter.outputFileType = @"com.apple.coreaudio-format";//@"com.apple.m4a-audio";//
    NSString *fname = [model.IDFR stringByAppendingString:@".caf"];
    model.fileUrlPath = fname;
    NSString *exportFile = [tempPath stringByAppendingString:fname];
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportFile]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportFile error:nil];
    }
    NSURL *audioFile = [NSURL fileURLWithPath:exportFile];
    exporter.outputURL = audioFile;
    ///导出音乐
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        switch (exporter.status) {
            case AVAssetExportSessionStatusCompleted:{
                NSData * modelData = [NSData archivedData:model];
                completed(modelData);
            }
                break;
            case AVAssetExportSessionStatusFailed:
                completed(nil);
                break;
            case AVAssetExportSessionStatusCancelled:
                completed(nil);
                break;
                
            default:
                break;
        }
    }];
}
//-(void)addMetaDataToMP3File:(NSString*)songFilePath withAlbumArtFile:(NSString*)artworkImgPath
//
//{
//    
//    
//    
//    ID3_Tag tag;
//    
//    tag.Link([songFilePath UTF8String]);
//    
//    tag.Strip(ID3TT_ALL);
//    
//    tag.Clear();
//    
//    ID3_Frame frame;
//    
//    frame.SetID(ID3FID_PICTURE);
//    
//    frame.GetField(ID3FN_MIMETYPE)->Set((constchar *)[@"image/jpeg"cStringUsingEncoding:NSUTF8StringEncoding]);
//    
//    frame.GetField(ID3FN_PICTURETYPE)->Set(ID3PT_COVERFRONT);
//    
//    frame.GetField(ID3FN_DATA)->FromFile((constchar *)[artworkImgPath cStringUsingEncoding:NSUTF8StringEncoding]);
//    
//    tag.AddFrame(frame);
//    
//    tag.SetPadding(false);
//    
//    tag.SetUnsync(false);
//    
//    tag.Update(ID3TT_ID3V2);
//    
//    
//}
-(void)exportCAF:(DTMusicModel*)model completed:(void (^)(NSData *))completed{
    
    AVURLAsset *musicAsset = [AVURLAsset URLAssetWithURL:model.iPodUrl options:nil];
    NSString * tempPath = NSTemporaryDirectory();
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset: musicAsset presetName: AVAssetExportPresetPassthrough];
    exporter.outputFileType = @"com.apple.coreaudio-format";//@"com.apple.m4a-audio";//
    NSString *fname = [model.IDFR stringByAppendingString:@".caf"];
    model.fileUrlPath = fname;
    NSString *exportFile = [tempPath stringByAppendingString:fname];
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportFile]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportFile error:nil];
    }
    NSURL *audioFile = [NSURL fileURLWithPath:exportFile];
    exporter.outputURL = audioFile;
    ///导出音乐
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        
        switch (exporter.status) {
            case AVAssetExportSessionStatusCompleted:{
                NSData * modelData = [NSData archivedData:model];
                completed(modelData);
            }
                break;
            case AVAssetExportSessionStatusFailed:
                completed(nil);
                break;
            case AVAssetExportSessionStatusCancelled:
                completed(nil);
                break;
                
            default:
                break;
        }
    }];
 
}
-(void)exportMP3:(NSURL*)url toFileUrl:(NSString*)fileURL
{
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetReader *reader=[[AVAssetReader alloc] initWithAsset:asset error:nil] ;
    NSMutableArray *myOutputs =[[NSMutableArray alloc] init];
    for(id track in [asset tracks])
    {
        AVAssetReaderTrackOutput *output=[AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:nil];
        [myOutputs addObject:output];
        [reader addOutput:output];
    }
    [reader startReading];
    NSFileHandle *fileHandle ;
    NSFileManager *fm=[NSFileManager defaultManager];
    if(![fm fileExistsAtPath:fileURL])
    {
        [fm createFileAtPath:fileURL contents:[[NSData alloc] init] attributes:nil];
    }
    fileHandle=[NSFileHandle fileHandleForUpdatingAtPath:fileURL];
    [fileHandle seekToEndOfFile];
    
    AVAssetReaderOutput *output=[myOutputs objectAtIndex:0];
    int totalBuff=0;
    while(TRUE)
    {
        CMSampleBufferRef ref=[output copyNextSampleBuffer];
        if(ref==NULL)
            break;
        //copy data to file
        //read next one
        AudioBufferList audioBufferList;
        NSMutableData *data=[[NSMutableData alloc] init];
        CMBlockBufferRef blockBuffer;
        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(ref, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, 0, &blockBuffer);
        
        for( int y=0; y<audioBufferList.mNumberBuffers; y++ )
        {
            AudioBuffer audioBuffer = audioBufferList.mBuffers[y];
            Float32 *frame = audioBuffer.mData;
            
            
            //  Float32 currentSample = frame[i];
            [data appendBytes:frame length:audioBuffer.mDataByteSize];
            
            //  written= fwrite(frame, sizeof(Float32), audioBuffer.mDataByteSize, f);
            ////NSLog(@"Wrote %d", written);
            
        }
        totalBuff++;
        CFRelease(blockBuffer);
        CFRelease(ref);
        [fileHandle writeData:data];
        //  //NSLog(@"writting %d frame for amounts of buffers %d ", data.length, audioBufferList.mNumberBuffers);
    }
    //  //NSLog(@"total buffs %d", totalBuff);
    //    fclose(f);
    [fileHandle closeFile];
    
}

+ (void)saveMusicFromURL: (NSURL *)sourceURL
                  toFile: (NSURL *)destURL
              completion: (void(^)(BOOL success))_completion
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:sourceURL options:nil];
    
    NSError *err = nil;
    AVAssetReader *reader = [AVAssetReader assetReaderWithAsset: asset
                                                           error: &err];
    if(err)
    {
        _completion(NO);
        return;
    }
    
    AVAssetReaderOutput *output = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks: asset.tracks audioSettings: nil];
    if(![reader canAddOutput:output])
    {
        _completion(NO);
        return;
    }
    
    [reader addOutput:output];
    
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL: destURL
                                                      fileType: AVFileTypeCoreAudioFormat
                                                         error: &err];
    if(err)
    {
        _completion(NO);
        return;
    }
    
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                    [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                    [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                    [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                                    [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                    [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                    nil];
    
    AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType: AVMediaTypeAudio
                                                                    outputSettings: outputSettings];
    if(![writer canAddInput:input])
    {

        _completion(NO);
        return;
    }
    [writer addInput:input];
    input.expectsMediaDataInRealTime = NO;
    
    [writer startWriting];
    [reader startReading];
    
    
    AVAssetTrack *soundtrack = [asset.tracks objectAtIndex:0];
    CMTime startTime = CMTimeMake (0, soundtrack.naturalTimeScale);
    [writer startSessionAtSourceTime: startTime];
    
    __block UInt64 convertedByteCount = 0;
    
    dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
    [input requestMediaDataWhenReadyOnQueue: mediaInputQueue
                                 usingBlock: ^
     {
         while (input.readyForMoreMediaData)
         {
             CMSampleBufferRef nextBuffer = [output copyNextSampleBuffer];
             if(nextBuffer)
             {
                 [input appendSampleBuffer: nextBuffer];
                 convertedByteCount += CMSampleBufferGetTotalSampleSize (nextBuffer);
                 CFRelease(nextBuffer);
             }
             else
             {
                 [input markAsFinished];
                 [writer finishWriting];
                 [reader cancelReading];
                 
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     _completion(YES);
                 });
                 
                 
                 break;
             }
         }
     }];
    return;
}

@end


static NSString * const kIsSelectedKey      = @"isSelected";
static NSString * const kIDFRKey            = @"IDFR";
static NSString * const kNameKey            = @"name";
static NSString * const kIPodUrlKey         = @"iPodUrl";
static NSString * const kImageDataKey       = @"imageData";
static NSString * const kSingerKey          = @"singer";
static NSString * const kMusicDataKey       = @"musicData";
static NSString * const kLocalPathKey       = @"localPath";

@implementation DTMusicModel

+(instancetype)modelWithMeidaItem:(MPMediaItem *)item{
    DTMusicModel * music = [[DTMusicModel alloc]init];
    music.IDFR = [NSString stringWithFormat:@"%llu",item.persistentID];
    music.name = item.title;
    MPMediaItemArtwork *artwork = item.artwork;
    UIImage *image = [artwork imageWithSize:artwork.bounds.size];
    music.imageData = UIImageJPEGRepresentation(image, 1);
    music.singer = item.artist;
    music.iPodUrl = item.assetURL;
    music.isSelected = NO;
    return music;
}
///NSCoping
-(id)copyWithZone:(NSZone *)zone{
    DTMusicModel * model = [[[self class]allocWithZone:zone]init];
    model.isSelected = self.isSelected;
    model.IDFR = [self.IDFR copy];
    model.name = [self.name copy];
    model.iPodUrl = [self.iPodUrl copy];
    model.imageData = [self.imageData copy];
    model.singer = [self.singer copy];
    model.musicData = [self.musicData copy];
    model.fileUrlPath = [self.fileUrlPath copy];
    return model;
}
///NSCoding
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.isSelected = [aDecoder decodeBoolForKey:kIsSelectedKey];
        self.IDFR = [aDecoder decodeObjectForKey:kIDFRKey];
        self.name = [aDecoder decodeObjectForKey:kNameKey];
        self.iPodUrl = [aDecoder decodeObjectForKey:kIPodUrlKey];
        self.imageData = [aDecoder decodeObjectForKey:kImageDataKey];
        self.singer = [aDecoder decodeObjectForKey:kSingerKey];
        self.musicData = [aDecoder decodeObjectForKey:kMusicDataKey];
        self.fileUrlPath = [aDecoder decodeObjectForKey:kLocalPathKey];
    }
    return self;
}
///NSCoding
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeBool:self.isSelected forKey:kIsSelectedKey];
    [aCoder encodeObject:self.IDFR forKey:kIDFRKey];
    [aCoder encodeObject:self.name forKey:kNameKey];
    [aCoder encodeObject:self.iPodUrl forKey:kIPodUrlKey];
    [aCoder encodeObject:self.imageData forKey:kImageDataKey];
    [aCoder encodeObject:self.singer forKey:kSingerKey];
    [aCoder encodeObject:self.musicData forKey:kMusicDataKey];
    [aCoder encodeObject:self.fileUrlPath forKey:kLocalPathKey];
}






@end
