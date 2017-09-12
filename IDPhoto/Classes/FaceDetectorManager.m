//
//  FaceDetectorManager.m
//  DeformPicture
//
//  Created by 何少博 on 17/4/19.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "FaceDetectorManager.h"

@implementation FaceDetectorManager

+(instancetype)manager{
    static FaceDetectorManager * manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FaceDetectorManager alloc]init];
    });
    return manager;
}
-(NSArray <CIFaceFeature*>*)faceDetectWithImage:(UIImage *)image{
    
    //设置识别能力
    NSDictionary * options = @{CIDetectorAccuracy:CIDetectorAccuracyHigh};
    
    CIImage * faceImage = [CIImage imageWithCGImage:image.CGImage];
    //生成识别器
    CIDetector * faceDectector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:options];
    //识别结果
    NSArray * features = [faceDectector featuresInImage:faceImage];
    return features;
  
}
@end
