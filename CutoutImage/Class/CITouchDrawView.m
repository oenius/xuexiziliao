//
//  CITouchDrawView.m
//  CutoutImage
//
//  Created by 何少博 on 17/2/6.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "CITouchDrawView.h"

@interface CITouchDrawView (){
    CGPoint points[5];
    uint count;
}

@property (nonatomic, assign) CGRect rectangle;

@property (nonatomic, strong) UIBezierPath *plusPath;
@property (nonatomic, strong) UIBezierPath *minusPath;
@property (nonatomic, strong) UIBezierPath *erasePath;
@property (nonatomic, strong) UIImage *incrementalImage;

@property (nonatomic, strong) UIColor *earseColor;

@property (nonatomic, strong) UIView *tipView;

@property (nonatomic, assign) CGPoint currentPoint;

//@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end


@implementation CITouchDrawView

//-(CAShapeLayer *)shapeLayer{
//    if (_shapeLayer == nil) {
//        _shapeLayer = [CAShapeLayer layer];
//        _shapeLayer.strokeColor = _earseColor.CGColor;
//        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
//        _shapeLayer.lineWidth = 5;
//        _shapeLayer.lineJoin = kCALineJoinRound;
//        _shapeLayer.lineCap = kCALineCapRound;
//        [self.layer addSublayer:_shapeLayer];
//    }
//    return _shapeLayer;
//}

-(void)setCurrentPoint:(CGPoint)currentPoint{
    _currentPoint = currentPoint;
    if (_currentState == CITouchStateEarse) {
        if (self.tipView == nil) {
            CGFloat width = _eraseSize;
            self.tipView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, width)];
            self.tipView.layer.cornerRadius = width/2;
            self.tipView.layer.masksToBounds = YES;
            self.tipView.backgroundColor = [UIColor blackColor];
            self.tipView.center = currentPoint;
            [self addSubview:self.tipView];
            self.tipView.center = currentPoint;
        }
        self.tipView.center = _currentPoint;
    }
}

-(void)setEraseSize:(CGFloat)eraseSize{
    _eraseSize = eraseSize;
    [_erasePath setLineWidth:eraseSize];
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
    [_plusPath setLineWidth:5];
    [_plusPath setLineCapStyle:kCGLineCapRound];
    
    _minusPath = [UIBezierPath bezierPath];
    [_minusPath setLineWidth:5];
    [_minusPath setLineCapStyle:kCGLineCapRound];
    
    _erasePath = [UIBezierPath bezierPath];
    [_erasePath setLineWidth:_eraseSize];
    [_erasePath setLineCapStyle:kCGLineCapRound];
    
    _currentState = CITouchStateRect;
}


-(void)touchStarted:(CGPoint)point;
{
    self.currentPoint = point;
    if (_currentState == CITouchStatePlus ||_currentState == CITouchStateMinus||_currentState == CITouchStateEarse) {
        count = 0;
        points[0] = point;
    }
}

- (void)touchMoved:(CGPoint)point
{
    self.currentPoint = point;
    if(_currentState == CITouchStatePlus || _currentState == CITouchStateMinus || _currentState == CITouchStateEarse){
        count++;
        points[count] = point;

        UIBezierPath * bezierpath;
        if (count == 4)
        {
            points[3] = CGPointMake((points[2].x + points[4].x)/2.0, (points[2].y + points[4].y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
            
            if(_currentState == CITouchStatePlus){
                [_plusPath moveToPoint:points[0]];
                [_plusPath addCurveToPoint:points[3] controlPoint1:points[1] controlPoint2:points[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
                bezierpath = _plusPath;
                
            }else if(_currentState == CITouchStateMinus){
                [_minusPath moveToPoint:points[0]];
                [_minusPath addCurveToPoint:points[3] controlPoint1:points[1] controlPoint2:points[2]]; // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
                bezierpath = _minusPath;
            }else if (_currentState == CITouchStateEarse){
                [_erasePath moveToPoint:points[0]];
                [_erasePath addCurveToPoint:points[3] controlPoint1:points[1] controlPoint2:points[2]];
                bezierpath = _erasePath;
            }
            
            [self setNeedsDisplay];

//            self.shapeLayer.path = bezierpath.CGPath;
            
            points[0] = points[3];
            points[1] = points[4];
            count = 1;
        }
    }
}
- (void)touchEnded:(CGPoint)point
{
    self.currentPoint = point;
    if (self.tipView) {
        [self.tipView removeFromSuperview];
        self.tipView = nil;
    }
    
}

-(void)drawRectangle:(CGRect)rect{
    _currentState = CITouchStateRect;
    _rectangle = rect;
    [self setNeedsDisplay];
}
-(void)clear{
    _rectangle = CGRectZero;
    [_plusPath removeAllPoints];
    [_minusPath removeAllPoints];
    [_erasePath removeAllPoints];
    [self setNeedsDisplay];
}

-(void)earseWithImage:(UIImage *)image{
    _earseColor = [UIColor colorWithPatternImage:image];
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    if(_currentState == CITouchStateRect){
        CGContextSetRGBStrokeColor(context,1,0,0,1.0);
        CGContextSetLineWidth(context, 2.0);
        CGContextStrokeRect(context,_rectangle);
        CGContextFillPath(context);
    }else if(_currentState == CITouchStatePlus){
        [[UIColor whiteColor] setStroke];
        [_plusPath stroke];
    }else if (_currentState == CITouchStateMinus){
        [[UIColor blackColor] setStroke];
        [_minusPath stroke];
    }else if (_currentState == CITouchStateEarse){
        [_earseColor setStroke];
        [_erasePath stroke];
    }
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
