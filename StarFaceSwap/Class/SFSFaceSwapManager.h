//
//  SFSFaceSwapManager.h
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/7.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingletonHelp.h"

typedef void(^faceDetectorBlock)(NSInteger faceCount,NSMutableArray * reslutArray);

typedef void(^swapFaceCompleted)(NSString * imagePath,UIImage * image,BOOL completed);


@interface SFSFaceSwapManager : NSObject

Singleton_H(Manager);
///准备人脸识别
-(void)prepareDetectioin;

///传入图片路径 返回68个特征点，未检测到人脸返回nil
-(void)faceDetector:(NSString *)imagePath completed:(faceDetectorBlock)block;

///交换人脸 key -> 图片路径 value -> image
-(void)swapFaceFirstImage:(NSString *)firstImagePath
                                         firstPointArray:(NSArray *)firstPointArray
                                             secondImage:(NSString *)secondImagePath
                                        secondPointArray:(NSArray *)secondPointArray
                                               completed:(swapFaceCompleted)block;

@end
