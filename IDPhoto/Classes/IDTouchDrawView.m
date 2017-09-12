//
//  IDTouchDrawView.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/27.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDTouchDrawView.h"
#import <Foundation/Foundation.h>
@interface IDTouchDrawView ()
{
    CGPoint points[5];
    uint count;
}


@property (nonatomic, assign) CGRect rectangle;
@property (nonatomic, strong) UIBezierPath *plusPath;
@property (nonatomic, strong) UIBezierPath *minusPath;
@property (nonatomic, strong) UIBezierPath *erasePath;
@property (nonatomic, strong) UIImage *incrementalImage;
@property (nonatomic, assign) CGPoint currentPoint;
@property (nonatomic,assign) BOOL isClear;
@property (nonatomic,assign) BOOL touchEnd;

@end


@implementation IDTouchDrawView
-(void)setCurrentPoint:(CGPoint)currentPoint{
    _currentPoint = currentPoint;
}
-(void)setEraseSize:(CGFloat)eraseSize{
    _eraseSize = eraseSize;
    
    [_erasePath setLineWidth:eraseSize];
}

-(void)setPlusSize:(CGFloat)plusSize{
    _plusSize = plusSize;
    [_plusPath setLineWidth:_plusSize];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self initTouchView];
    }
    return self;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initTouchView];
    }
    return self;
}

-(void)initTouchView{
    _eraseSize= 5.0;
    self.backgroundColor = [UIColor clearColor];
    _plusPath = [UIBezierPath bezierPath];
    [_plusPath setLineWidth:10];
    [_plusPath setLineCapStyle:kCGLineCapRound];
    
    _minusPath = [UIBezierPath bezierPath];
    [_minusPath setLineWidth:5];
    [_minusPath setLineCapStyle:kCGLineCapRound];
    
    _erasePath = [UIBezierPath bezierPath];
    [_erasePath setLineWidth:_eraseSize];
    [_erasePath setLineCapStyle:kCGLineCapRound];
    
    _currentPoint = CGPointMake(-20, -20);
    _currentState = TouchStatePlus;
}


-(void)touchStarted:(CGPoint)point;
{
    self.currentPoint = point;
    if (_currentState == TouchStatePlus ||_currentState == TouchStateMinus||_currentState == TouchStateEarse) {
        count = 0;
        points[0] = point;
    }
}

- (void)touchMoved:(CGPoint)point
{
    self.currentPoint = point;
    if(_currentState == TouchStatePlus || _currentState == TouchStateMinus || _currentState == TouchStateEarse){
        count++;
        points[count] = point;
        
        UIBezierPath * bezierpath;
        if (count == 4)
        {
            points[3] = CGPointMake((points[2].x + points[4].x)/2.0, (points[2].y + points[4].y)/2.0);
            
            if(_currentState == TouchStatePlus){
                [_plusPath moveToPoint:points[0]];
                [_plusPath addCurveToPoint:points[3] controlPoint1:points[1] controlPoint2:points[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
                bezierpath = _plusPath;
                
            }else if(_currentState == TouchStateMinus){
                [_minusPath moveToPoint:points[0]];
                [_minusPath addCurveToPoint:points[3] controlPoint1:points[1] controlPoint2:points[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
                bezierpath = _minusPath;
            }else if (_currentState == TouchStateEarse){
                [_erasePath moveToPoint:points[0]];
                [_erasePath addCurveToPoint:points[3] controlPoint1:points[1] controlPoint2:points[2]];
                bezierpath = _erasePath;
            }
            
            [self setNeedsDisplay];
            points[0] = points[3];
            points[1] = points[4];
            count = 1;
        }
    }
}
- (void)touchEnded:(CGPoint)point
{
    self.currentPoint = point;
    _touchEnd = YES;
    [self setNeedsDisplay];
}

-(void)drawRectangle:(CGRect)rect{
    _currentState = TouchStateRect;
    _rectangle = rect;
    [self setNeedsDisplay];
}
-(void)clear{
    _isClear = YES;
    _rectangle = CGRectZero;
    [_plusPath removeAllPoints];
    [_minusPath removeAllPoints];
    [_erasePath removeAllPoints];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    if (_currentState == TouchStateEarse && _isClear == NO) {
        if (_shadowEnable) {
            CGColorRef color = _eraseColor.CGColor;
            CGContextSetShadowWithColor(context, CGSizeMake(0, 0), _eraseSize/10, color);
        }
    }
    
    if(_currentState == TouchStateRect){
        CGContextSetRGBStrokeColor(context,1,0,0,1.0);
        CGContextSetLineWidth(context, 2.0);
        CGContextStrokeRect(context,_rectangle);
        CGContextFillPath(context);
    }else if(_currentState == TouchStatePlus){
        [[UIColor colorWithRed:255/255.0 green:240/255.0 blue:53/255.0 alpha:1.00] setStroke];
        [_plusPath stroke];
    }else if (_currentState == TouchStateMinus){
        [[UIColor blackColor] setStroke];
        [_minusPath stroke];
    }else if (_currentState == TouchStateEarse){
        [_eraseColor setStroke];
        [_erasePath stroke];
    }
    
    if (_currentState == TouchStateEarse && _isClear == NO && _touchEnd == NO) {
        if (_showCircle) {
            CGContextSetRGBStrokeColor(context, 254/255.0, 112/255.0, 154/255.0, 1);
            CGContextSetLineWidth(context, 2);
            CGContextAddArc(context, self.currentPoint.x, self.currentPoint.y, _eraseSize/2, 0, M_PI * 2, 0);
            CGContextDrawPath(context, kCGPathStroke);
        }
    }
    _isClear = NO;
    _touchEnd = NO;
}

- (UIImage *)maskImageWithPainting
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size,NO,0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
    
}

- (UIImage *)maskImagePaintingAtRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    
    image = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    return  image;
}


@end
