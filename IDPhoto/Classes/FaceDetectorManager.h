//
//  FaceDetectorManager.h
//  DeformPicture
//
//  Created by 何少博 on 17/4/19.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaceDetectorManager : NSObject

+ (instancetype)manager;

///coreImage检测
-(NSArray <CIFaceFeature*>*)faceDetectWithImage:(UIImage *)image;

@end
