//
//  HSGPUImageEnhancementFilter.h
//  IDPhoto
//
//  Created by 何少博 on 17/5/3.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface HSGPUImageEnhancementFilter : GPUImageFilterGroup

///亮度 Brightness ranges from -1.0 to 1.0, with 0.0 as the normal level
@property (nonatomic,assign) CGFloat brightness;

///曝光  Exposure ranges from -10.0 to 10.0, with 0.0 as the normal level
@property (nonatomic,assign) CGFloat exposure;

///对比度 Contrast ranges from 0.0 to 4.0 (max contrast), with 1.0 as the normal level
@property (nonatomic,assign) CGFloat contrast;

///饱和度 Saturation ranges from 0.0 (fully desaturated) to 2.0 (max saturation), with 1.0 as the normal level
@property (nonatomic,assign) CGFloat saturation;

@end
