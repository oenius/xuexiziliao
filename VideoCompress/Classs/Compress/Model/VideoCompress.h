//
//  VideoCompress.h
//  VideoCompress
//
//  Created by 何少博 on 16/11/23.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
typedef void(^completed)(BOOL finish);
typedef void(^cutComplete)(NSError * error);
typedef struct CompressDetail {
    NSInteger width ;
    NSInteger height ;
    NSInteger bitRate ;
} CompressDetail;



@interface VideoCompress : NSObject

@property (nonatomic ,strong) NSURL * outputURL;

//@property (nonatomic ,strong) NSDictionary * outPutSettings;
@property (nonatomic,assign) CompressDetail settings;

@property (nonatomic ,assign) BOOL isPreview;

-(void)startCompressWithAsset:(AVAsset * )asset completed:(completed)finish;

-(void)cutVideoWithAsset:(AVAsset *) asset start:(CMTime)start andEnd:(CMTime)end outUrl:(NSURL *) outputUrl complete:(cutComplete)complete;

-(void)cutVideoWithAsset:(AVAsset *) asset start:(CMTime)start andEnd:(CMTime)end outUrl:(NSURL *) outputUrl isCompress:(BOOL)isCompress complete:(cutComplete)complete;

- (void)cancel;

@end
