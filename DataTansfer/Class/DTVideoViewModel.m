//
//  DTVideoViewModel.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/18.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTVideoViewModel.h"

@implementation DTVideoViewModel

+(void)archivedModel:(DTAssetModel *)model completed:(void (^)(NSData *))completed{
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:model.asset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        
        model.fileUrlPath = [[[NSUUID UUID] UUIDString] stringByAppendingString:@".mov"];
        
        NSString *path = NSTemporaryDirectory();
        NSString * outputURL = [path stringByAppendingPathComponent:model.fileUrlPath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:outputURL]) {
            [[NSFileManager defaultManager] removeItemAtPath:outputURL error:nil];
        }


        AVAssetExportSession * exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
        exportSession.outputURL = [NSURL fileURLWithPath:outputURL];
        exportSession.outputFileType=AVFileTypeQuickTimeMovie;
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void){
            switch (exportSession.status) {
                case AVAssetExportSessionStatusCompleted:{
                    NSData * modelData = [NSData archivedData:model];
                    completed(modelData);
                }
                    break;
                case AVAssetExportSessionStatusFailed:
                    model.fileUrlPath = nil;
                    completed(nil);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    model.fileUrlPath = nil;
                    completed(nil);
                    break;
                default:
                    break;
            }
        }];


    }];
    
}
//+(void)exportAsset:(nonnull AVAsset *)asset audioMix:(nullable AVMutableAudioMix *)audioMix videoComposition:(nullable AVMutableVideoComposition *)videoComposition saveToLibrary:(BOOL)isSave exportQuality:(CDPVideoEditorExportQuality)exportQuality{
//    
//    if (asset==nil||[asset isKindOfClass:[NSNull class]]) {
//        CDPLog(@"视频压缩导出:传入的AVAsset为nil");
//        [CDPNotificationCenter postNotificationName:CDPVideoEditorExportFail object:@"视频压缩导出:传入的AVAsset为nil"];
//        return;
//    }
//    
//    //创建导出路径
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//    NSString *outputURL = paths[0];
//    
//    NSFileManager *manager=[NSFileManager defaultManager];
//    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
//    
//    outputURL=[outputURL stringByAppendingPathComponent:@"CDPVideoEditorOutput.mp4"];
//    //移除文件
//    [manager removeItemAtPath:outputURL error:nil];
//    
//    
//    //根据asset对象创建exportSession视频导出对象
//    AVAssetExportSession *exportSession=[[AVAssetExportSession alloc] initWithAsset:asset presetName:[self getVideoExportQuality:exportQuality]];
//    //音频混合器
//    exportSession.audioMix=audioMix;
//    //视频组合器
//    exportSession.videoComposition=videoComposition;
//    //视频导出路径
//    exportSession.outputURL=[NSURL fileURLWithPath:outputURL];
//    //导出格式
//    exportSession.outputFileType=AVFileTypeMPEG4;
//    
//    //开始异步导出
//    [[UIApplication sharedApplication] delegate].window.userInteractionEnabled=NO;
//    
//    [exportSession exportAsynchronouslyWithCompletionHandler:^(void){
//        [[UIApplication sharedApplication] delegate].window.userInteractionEnabled=YES;
//        
//        switch (exportSession.status) {
//            case AVAssetExportSessionStatusCompleted:
//                //导出成功
//                
//                break;
//            case AVAssetExportSessionStatusFailed:
//                //导出失败
//                
//                break;
//            case AVAssetExportSessionStatusCancelled:
//                //导出取消
//               
//                break;
//            default:
//                break;
//        }
//    }];
//}
@end
