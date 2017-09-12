//
//  HSGPUImageBigEyeFilter.h
//  IDPhoto
//
//  Created by 何少博 on 17/4/26.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "GPUImage.h"

@interface HSGPUImageBigEyeFilter : GPUImageFilter
{
    GLint aspectRatioUniform, radiusUniform,leftEyeCenterPositionUniform, rightEyeCenterPositionUniform, scaleRatioUniform;
}


@property(readwrite, nonatomic) CGPoint leftEyeCenterPosition;

@property(readwrite, nonatomic) CGPoint rightEyeCenterPosition;

@property(readwrite, nonatomic) CGFloat scaleRatio;

@property(readwrite, nonatomic) CGFloat radius;

@end
