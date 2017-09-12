//
//  HSGPUImageBigEyeFilter.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/26.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "HSGPUImageBigEyeFilter.h"
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kHSGPUImageBigEyeFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform highp float scaleRatio;// 缩放系数，0无缩放，大于0则放大
 uniform highp float radius;// 缩放算法的作用域半径
 uniform highp vec2 leftEyeCenterPosition; // 左眼控制点，越远变形越小
 uniform highp vec2 rightEyeCenterPosition; // 右眼控制点
 uniform float aspectRatio; // 所处理图像的宽高比
 
 highp vec2 warpPositionToUse(vec2 centerPostion, vec2 currentPosition, float radius, float scaleRatio, float aspectRatio)
 {
     vec2 positionToUse = currentPosition;
     
     vec2 currentPositionToUse = vec2(currentPosition.x, currentPosition.y * aspectRatio + 0.5 - 0.5 * aspectRatio);
     vec2 centerPostionToUse = vec2(centerPostion.x, centerPostion.y * aspectRatio + 0.5 - 0.5 * aspectRatio);
     
     float r = distance(currentPositionToUse, centerPostionToUse);
     
     if(r < radius)
     {
         float alpha = 1.0 - scaleRatio * (r / radius - 1.0)*(r / radius - 1.0);
         positionToUse = centerPostion + alpha * (currentPosition - centerPostion);
     }
     return positionToUse;
 }
 
 void main()
 {
     vec2 positionToUse = warpPositionToUse(leftEyeCenterPosition, textureCoordinate, radius, scaleRatio, aspectRatio);
     
     positionToUse = warpPositionToUse(rightEyeCenterPosition, positionToUse, radius, scaleRatio, aspectRatio);
     
     gl_FragColor = texture2D(inputImageTexture, positionToUse);
 }
 );
#else
NSString *const kHSGPUImageBigEyeFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform highp float scaleRatio;// 缩放系数，0无缩放，大于0则放大
 uniform highp float radius;// 缩放算法的作用域半径
 uniform highp vec2 leftEyeCenterPosition; // 左眼控制点，越远变形越小
 uniform highp vec2 rightEyeCenterPosition; // 右眼控制点
 uniform float aspectRatio; // 所处理图像的宽高比
 
 highp vec2 warpPositionToUse(vec2 centerPostion, vec2 currentPosition, float radius, float scaleRatio, float aspectRatio)
 {
     vec2 positionToUse = currentPosition;
     vec2 currentPositionToUse = vec2(currentPosition.x, currentPosition.y * aspectRatio + 0.5 - 0.5 * aspectRatio);
     vec2 centerPostionToUse = vec2(centerPostion.x, centerPostion.y * aspectRatio + 0.5 - 0.5 * aspectRatio);
     
     float r = distance(currentPositionToUse, centerPostionToUse);
     
     if(r < radius)
     {
         float alpha = 1.0 - scaleRatio * pow(r / radius - 1.0, 3.0);
         positionToUse = centerPostion + alpha * (currentPosition - centerPostion);
     }
     
     return positionToUse;
 }
 
 void main()
 {
     vec2 positionToUse = warpPositionToUse(leftEyeCenterPosition, textureCoordinate, radius, scaleRatio, aspectRatio);
     
     positionToUse = warpPositionToUse(rightEyeCenterPosition, positionToUse, radius, scaleRatio, aspectRatio);
     
     gl_FragColor = texture2D(inputImageTexture, positionToUse);
 }
 );
#endif


@interface HSGPUImageBigEyeFilter ()

@property (readwrite, nonatomic) CGFloat aspectRatio;

- (void)adjustAspectRatio;

@end

@implementation HSGPUImageBigEyeFilter

@synthesize rightEyeCenterPosition = _rightEyeCenterPosition;
@synthesize leftEyeCenterPosition = _leftEyeCenterPosition;
@synthesize aspectRatio = _aspectRatio;
@synthesize scaleRatio = _scaleRatio;
@synthesize radius = _radius;

-(instancetype)init{
    self = [super initWithFragmentShaderFromString:kHSGPUImageBigEyeFragmentShaderString];
    if (self) {
        radiusUniform = [filterProgram uniformIndex:@"radius"];
        scaleRatioUniform = [filterProgram uniformIndex:@"scaleRatio"];
        aspectRatioUniform = [filterProgram uniformIndex:@"aspectRatio"];
        leftEyeCenterPositionUniform = [filterProgram uniformIndex:@"leftEyeCenterPosition"];
        rightEyeCenterPositionUniform = [filterProgram uniformIndex:@"rightEyeCenterPosition"];
        self.radius = 0.25;
        self.scaleRatio = 0.0;
        self.leftEyeCenterPosition = CGPointMake(0.5, 0.5);
        self.rightEyeCenterPosition = CGPointMake(0.5, 0.5);
    }
    return self;
}

- (void)adjustAspectRatio;
{
    if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
    {
        [self setAspectRatio:(inputTextureSize.width / inputTextureSize.height)];
    }
    else
    {
        [self setAspectRatio:(inputTextureSize.height / inputTextureSize.width)];
    }
}
- (void)forceProcessingAtSize:(CGSize)frameSize;
{
    [super forceProcessingAtSize:frameSize];
    [self adjustAspectRatio];
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    CGSize oldInputSize = inputTextureSize;
    [super setInputSize:newSize atIndex:textureIndex];
    
    if ( (!CGSizeEqualToSize(oldInputSize, inputTextureSize)) && (!CGSizeEqualToSize(newSize, CGSizeZero)) )
    {
        [self adjustAspectRatio];
    }
}

- (void)setAspectRatio:(CGFloat)aspectRatio;
{
    _aspectRatio = aspectRatio;
    
    [self setFloat:_aspectRatio forUniform:aspectRatioUniform program:filterProgram];
}
- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
{
    [super setInputRotation:newInputRotation atIndex:textureIndex];
    [self setLeftEyeCenterPosition:self.leftEyeCenterPosition];
    [self setRightEyeCenterPosition:self.rightEyeCenterPosition];
    [self adjustAspectRatio];
}

-(void)setRadius:(CGFloat)radius{
    _radius = radius;
    [self setFloat:_radius forUniform:radiusUniform program:filterProgram];
}

-(void)setScaleRatio:(CGFloat)scaleRatio{
    _scaleRatio = scaleRatio;
    [self setFloat:_scaleRatio forUniform:scaleRatioUniform program:filterProgram];
}

-(void)setRightEyeCenterPosition:(CGPoint)rightEyeCenterPosition{
    _rightEyeCenterPosition = rightEyeCenterPosition;
    CGPoint rotatedPoint  = [self rotatedPoint:_rightEyeCenterPosition forRotation:inputRotation];
    [self setPoint:rotatedPoint forUniform:rightEyeCenterPositionUniform program:filterProgram];
}
-(void)setLeftEyeCenterPosition:(CGPoint)leftEyeCenterPosition{
    _leftEyeCenterPosition = leftEyeCenterPosition;
    CGPoint rotatedPoint  = [self rotatedPoint:_leftEyeCenterPosition forRotation:inputRotation];
    [self setPoint:rotatedPoint forUniform:leftEyeCenterPositionUniform program:filterProgram];
}


@end
