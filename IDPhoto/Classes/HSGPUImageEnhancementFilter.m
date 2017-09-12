//
//  HSGPUImageEnhancementFilter.m
//  IDPhoto
//
//  Created by 何少博 on 17/5/3.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "HSGPUImageEnhancementFilter.h"
//#import "GPUImageBrightnessFilter.h"                //亮度
//#import "GPUImageExposureFilter.h"                  //曝光
//#import "GPUImageContrastFilter.h"                  //对比度
//#import "GPUImageSaturationFilter.h"                //饱和度

@interface HSGPUImageEnhancementFilter ()

@property (nonatomic,strong) GPUImageBrightnessFilter * brightnessFilter;

@property (nonatomic,strong) GPUImageExposureFilter * exposureFilter;

@property (nonatomic,strong) GPUImageContrastFilter * contrastFilter;

@property (nonatomic,strong) GPUImageSaturationFilter * saturationFilter;

@end


@implementation HSGPUImageEnhancementFilter


-(instancetype)init{
    self = [super init];
    if (self) {
        _brightnessFilter = [[GPUImageBrightnessFilter alloc]init];
        [_brightnessFilter setBrightness:0.0];//(-1,1)
        _exposureFilter = [[GPUImageExposureFilter alloc]init];
        [_exposureFilter setExposure:0.0];//(-10,10)
        _contrastFilter = [[GPUImageContrastFilter alloc]init];
        [_contrastFilter setContrast:1];//(0,4)
        _saturationFilter = [[GPUImageSaturationFilter alloc]init];
        [_saturationFilter setSaturation:1];//(0,2)
        
        [self addFilter:_brightnessFilter];
        [self addFilter:_exposureFilter];
        [self addFilter:_contrastFilter];
        [self addFilter:_saturationFilter];
        
        [_brightnessFilter addTarget:_exposureFilter];
        [_exposureFilter addTarget:_contrastFilter];
        [_contrastFilter addTarget:_saturationFilter];
        
        [self setInitialFilters:@[_brightnessFilter]];
        [self setTerminalFilter:_saturationFilter];
//        [self addGPUImageFilter:_brightnessFilter];
//        [self addGPUImageFilter:_exposureFilter];
//        [self addGPUImageFilter:_contrastFilter];
//        [self addGPUImageFilter:_saturationFilter];
    }
    return self;
}

-(void)setBrightness:(CGFloat)brightness{
    _brightness = brightness;
    [_brightnessFilter setBrightness:brightness];
}

-(void)setExposure:(CGFloat)exposure{
    _exposure = exposure;
    [_exposureFilter setExposure:exposure];
}

-(void)setContrast:(CGFloat)contrast{
    _contrast = contrast;
    [_contrastFilter setContrast:contrast];
}

-(void)setSaturation:(CGFloat)saturation{
    _saturation = saturation;
    [_saturationFilter setSaturation:saturation];
}


- (void)addGPUImageFilter:(GPUImageOutput<GPUImageInput> *)filter
{
    [self addFilter:filter];
    
    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;
    
    NSInteger count = self.filterCount;
    
    if (count == 1)
    {
        self.initialFilters = @[newTerminalFilter];
        self.terminalFilter = newTerminalFilter;
        
    } else
    {
        GPUImageOutput<GPUImageInput> *terminalFilter    = self.terminalFilter;
        NSArray *initialFilters                          = self.initialFilters;
        
        [terminalFilter addTarget:newTerminalFilter];
        
        self.initialFilters = @[initialFilters[0]];
        self.terminalFilter = newTerminalFilter;
    }
}
@end
