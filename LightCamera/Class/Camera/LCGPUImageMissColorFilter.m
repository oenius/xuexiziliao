//
//  LCGPUImageMissColorFilter.m
//  LightCamera
//
//  Created by 何少博 on 16/12/16.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "LCGPUImageMissColorFilter.h"

@interface LCGPUImageMissColorFilter ()

@property (nonatomic,strong) GPUImagePicture *lookupImageSource;

@end

@implementation LCGPUImageMissColorFilter

- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    UIImage *image = [UIImage imageNamed:@"Lookup_missColor.png"];
#else
    NSImage *image = [NSImage imageNamed:@"Lookup_missColor.png"];
#endif
    
    NSAssert(image, @"To use LCGPUImageMissColorFilter you need to add Lookup_missColor.png from GPUImage/framework/Resources to your application bundle.");
    
    _lookupImageSource = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
    [self addFilter:lookupFilter];
    
    [_lookupImageSource addTarget:lookupFilter atTextureLocation:1];
    [_lookupImageSource processImage];
    
    self.initialFilters = [NSArray arrayWithObjects:lookupFilter, nil];
    self.terminalFilter = lookupFilter;
    
    return self;
}

#pragma mark -
#pragma mark Accessors


@end
