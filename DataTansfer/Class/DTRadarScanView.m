//
//  DTRadarScanView.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/24.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTRadarScanView.h"
#import "DTRadarCell.h"
#define RADAR_DEFAULT_RADIUS 100.f
#define RADAR_ROTATE_SPEED 60.f
#define INDICATOR_START_COLOR [UIColor colorWithRed:8.0/255.0 green:242.0/255.0 blue: 46.0/255.0 alpha:1]
#define INDICATOR_END_COLOR [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue: 250.0/255.0 alpha:0]
#define INDICATOR_ANGLE 90.f
#define INDICATOR_CLOCKWISE YES
#define DEGREES_TO_RADIANS(d) (d * M_PI / 180)

@interface DTRadarScanView ()<CAAnimationDelegate,DTRadarCellDelegate>

@property (nonatomic,assign) BOOL animating;

@property (nonatomic,strong) CAShapeLayer * contentLayer;

@property (nonatomic,strong) UIView * cellContentView;

@property (nonatomic,assign) CGFloat alphaScale;

@end

static NSString * const rotationAnimationKey = @"rotationAnimation";

@implementation DTRadarScanView
-(void)setReversedRadar:(BOOL)reversedRadar{
    _reversedRadar= reversedRadar;
    [self initialSetup];
}
-(void)setNumberOfWaves:(NSInteger)numberOfWaves{
    _numberOfWaves = numberOfWaves;
    [self initialSetup];
}
-(void)setRadarColor:(UIColor *)radarColor{
    _radarColor = radarColor;
    [self initialSetup];
}
-(void)setInnerRadius:(CGFloat)innerRadius{
    _innerRadius = innerRadius;
    [self initialSetup];
}
-(void)setIconImage:(UIImage *)iconImage{
    _iconImage = iconImage;
    [self initialSetup];
}
-(void)setIconSize:(CGSize)iconSize{
    _iconSize = iconSize;
    [self initialSetup];
}
-(void)setWaveWidth:(CGFloat)waveWidth{
    _waveWidth = waveWidth;
    [self initialSetup];
}
-(void)setMaxWaveAlpha:(CGFloat)maxWaveAlpha{
    _maxWaveAlpha = maxWaveAlpha;
    [self initialSetup];
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.animating = NO;
        self.reversedRadar = NO;
        self.numberOfWaves = 4;
        self.radarColor = [UIColor blueColor];
        self.innerRadius = 0;
        self.iconSize = CGSizeMake(20, 20);
        self.waveWidth = 2;
        self.maxWaveAlpha = 0.8;
        
        DTRadarIndictorView *indicatorView = [[DTRadarIndictorView alloc] initWithFrame:self.bounds];
        [self addSubview:indicatorView];
        self.indicatorView = indicatorView;
        UIView *cellContentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:cellContentView];
        self.cellContentView = cellContentView;
        [self initialSetup];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.indicatorView.frame = self.bounds;
    self.cellContentView.frame = self.bounds;
    [self initialSetup];
}

-(void)initialSetup{
    if (self.contentLayer==nil) {
        self.contentLayer = [CAShapeLayer layer];
    }
    [self.layer insertSublayer:self.contentLayer atIndex:0];
    self.contentLayer.frame = self.bounds;
    self.contentLayer.sublayers = @[];
    CGRect animationRect = CGRectInset(self.contentLayer.bounds, 20, 20);
    CGFloat insetOffsetDelta = (animationRect.size.height/2 - self.innerRadius) / self.numberOfWaves;
    CGFloat currentInsetOffset = 0;
    self.alphaScale = self.maxWaveAlpha/self.numberOfWaves;
    CGFloat currentAlpha = self.maxWaveAlpha;
    if (self.reversedRadar) {
        for (int i = 1; i < self.numberOfWaves; i ++) {
            currentAlpha /= _alphaScale;
        }
    }
    
    for (int i = 0; i < self.numberOfWaves; i ++) {
        CAShapeLayer * sublayer = [CAShapeLayer layer];
        CGRect frame = CGRectInset(animationRect, currentInsetOffset, currentInsetOffset);
        sublayer.frame = frame;
        UIBezierPath * circle = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        sublayer.path = circle.CGPath;
        sublayer.strokeColor = _radarColor.CGColor;
        sublayer.lineWidth = _waveWidth;
        sublayer.fillColor = [UIColor clearColor].CGColor;
        sublayer.opacity = currentAlpha;
//        sublayer.contentsCenter
        [self.contentLayer addSublayer:sublayer];
        currentInsetOffset += insetOffsetDelta;
        if(_reversedRadar){
            currentAlpha *= _alphaScale;
        } else {
            currentAlpha /= _alphaScale;
        }
    }
    
    if (_iconImage) {
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:
                                   CGRectMake((self.bounds.size.width - _iconSize.width) / 2.0,
                                              (self.bounds.size.height - _iconSize.height) / 2.0,
                                              _iconSize.width, _iconSize.height)];
        imageView.image = _iconImage;
        
        [self.contentLayer addSublayer:imageView.layer];
    }
    
    CGFloat radius = RADAR_DEFAULT_RADIUS;
    if (self.radius) {
        radius = self.radius;
    }
    
    CGFloat indicatorAngle = INDICATOR_ANGLE;
    if (self.indicatorAngle) {
        indicatorAngle = self.indicatorAngle;
    }
    
    BOOL indicatorClockwise = INDICATOR_CLOCKWISE;
    if (self.indicatorClockwise) {
        indicatorClockwise = self.indicatorClockwise;
    }
    
    UIColor *indicatorStartColor = INDICATOR_START_COLOR;
    if (self.indicatorStartColor) {
        indicatorStartColor = self.indicatorStartColor;
    }
    
    UIColor *indicatorEndColor = INDICATOR_END_COLOR;
    if (self.indicatorEndColor) {
        indicatorEndColor = self.indicatorEndColor;
    }
    
    if (self.indicatorView) {
        self.indicatorView.frame = self.bounds;
        self.indicatorView.backgroundColor = [UIColor clearColor];
        self.indicatorView.radius = self.radius;
        self.indicatorView.angle = indicatorAngle;
        self.indicatorView.clockwise = indicatorClockwise;
        self.indicatorView.startColor = indicatorStartColor;
        self.indicatorView.endColor = indicatorEndColor;
    }
}


-(void)startScan{
    _animating = YES;
    NSArray * sublayers = self.contentLayer.sublayers;
    if ( sublayers ) {
        for (int index = 0; index < sublayers.count; index ++) {
            CAShapeLayer * sublayer = sublayers[index];
            if (sublayer) {
                CAKeyframeAnimation * animation = [[CAKeyframeAnimation alloc]init];
                animation.keyPath = @"opacity";
                animation.values = @[@(0),@(0),@(0),@(1)];
                animation.duration = 2.5;
                animation.repeatCount = MAXFLOAT;
                CGFloat beginTime;
                if (!_reversedRadar){
                    beginTime = animation.duration/(_numberOfWaves + 1) * (sublayers.count - 1.0 - index);
                } else {
                    beginTime = (animation.duration/(_numberOfWaves + 1)) * index;
                }
                animation.keyTimes = @[@(0),
                                       @(beginTime/animation.duration),
                                       @(beginTime/animation.duration),
                                       @((beginTime + animation.duration/(_numberOfWaves - 2.5))/animation.duration)];
//                animation.delegate = self;
                [sublayer addAnimation:animation forKey:[NSString stringWithFormat:@"animForLayer%d",index]];
                sublayer.opacity = 0;
            }
        }
    }
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    BOOL indicatorClockwise = INDICATOR_CLOCKWISE;
    if (self.indicatorClockwise) {
        indicatorClockwise = self.indicatorClockwise;
    }
    rotationAnimation.toValue = [NSNumber numberWithFloat:(indicatorClockwise?1:-1) * M_PI * 2.0];
    rotationAnimation.duration = 360.f / RADAR_ROTATE_SPEED;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = INT_MAX;
    [self.indicatorView.layer addAnimation:rotationAnimation forKey:rotationAnimationKey];
}

-(void)stopScan{
    _animating = NO;
    NSArray * sublayers = self.contentLayer.sublayers;
    if ( sublayers ) {
        for (int index = 0; index < sublayers.count; index ++) {
            CAShapeLayer * sublayer = sublayers[index];
            if (sublayer) {
                [sublayer removeAllAnimations];
            }
        }
    }

    [self.indicatorView.layer removeAnimationForKey:rotationAnimationKey];
}

//-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
//    if (flag){
//        NSArray * sublayers = self.contentLayer.sublayers;
//        if (sublayers) {
//            for (int index = 0; index < sublayers.count; index ++) {
//                if(index == sublayers.count - 1 && _animating){
//                    [self startScan];
//                } else {
//                    [self restoreInitialAlphas];
//                }
//            }
//        }
//    }
//}

-(void)restoreInitialAlphas{
    __block CGFloat currentAlpha = _maxWaveAlpha;
    if (_reversedRadar) {
        for (int i = 1; i < self.numberOfWaves; i ++) {
            currentAlpha /= _alphaScale;
        }
    }
    
    [UIView animateWithDuration:0.6 animations:^{
        for (CALayer * layer in self.contentLayer.sublayers) {
            if ([layer isKindOfClass:[CAShapeLayer class]]) {
                layer.opacity = currentAlpha;
                if(self.reversedRadar){
                    currentAlpha *= _alphaScale;
                } else {
                    currentAlpha /= _alphaScale;
                }
            }
        }
    }];
   
}
- (void)show
{
    for (UIView *subView in self.cellContentView.subviews) {
        [subView removeFromSuperview];
    }
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfPointsInRadarView:)]) {
        NSUInteger pointsNum = [self.dataSource numberOfPointsInRadarView:self];
        for (int index = 0; index < pointsNum; index++) {
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(radarView:viewForIndex:)]) {
                if(self.dataSource && [self.dataSource respondsToSelector:@selector(radarView:positionForIndex:)]){
                    
                    CGPoint point = [self.dataSource radarView:self positionForIndex:index];
                    int posDirection = point.x;     // 方向（角度）
                    int posDistance = point.y;      // 距离(半径)
                    
                    DTRadarCell *cell = [self.dataSource radarView:self viewForIndex:index];
                    cell.tag = index;
                    cell.center = CGPointMake(self.center.x + posDistance*sin(DEGREES_TO_RADIANS(posDirection)), self.center.y + posDistance * cos(DEGREES_TO_RADIANS(posDirection)));
                    cell.delegate = self;
                    
                    [self.cellContentView addSubview:cell];
                }
            }
        }
    }
}

- (void)didSelectItemRadarPointView:(DTRadarCell *)radarPointView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(radarView:didSelectItemAtIndex:)]) {
        [self.delegate radarView:self didSelectItemAtIndex:radarPointView.tag];
    }
}



@end

@implementation DTRadarIndictorView

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // 画布
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 画扇形
    UIColor *startColor = self.startColor;
    CGContextSetFillColorWithColor(context, startColor.CGColor); // 填充颜色
    CGContextSetLineWidth(context, 0);  // 线宽
    CGContextMoveToPoint(context, self.center.x, self.center.y); // 圆心
    CGContextAddArc(context, self.center.x, self.center.y, self.radius, (self.clockwise?self.angle:0) * M_PI / 180, (self.clockwise?(self.angle - 1):1) * M_PI / 180, self.clockwise);  // 半径为 self.radius
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);  // 绘制
    
    const CGFloat *startColorComponents = CGColorGetComponents(self.startColor.CGColor);    //开始颜色的 RGB components
    const CGFloat *endColorComponents = CGColorGetComponents(self.endColor.CGColor);    //结束颜色的 RGB components
    
    CGFloat R, G, B, A;
    for (int i = 0; i <= self.angle; i++)
    {
        CGFloat ratio = (self.clockwise?(self.angle - i):i)/self.angle;
        R = startColorComponents[0] - (startColorComponents[0] - endColorComponents[0]) * ratio;
        G = startColorComponents[1] - (startColorComponents[1] - endColorComponents[1]) * ratio;
        B = startColorComponents[2] - (startColorComponents[2] - endColorComponents[2]) * ratio;
        A = startColorComponents[3] - (startColorComponents[3] - endColorComponents[3]) * ratio;
        
        UIColor *startColor = [UIColor colorWithRed:R green:G blue:B alpha:A];
        
        CGContextSetFillColorWithColor(context, startColor.CGColor);
        CGContextSetLineWidth(context, 0);
        CGContextMoveToPoint(context, self.center.x, self.center.y);
        CGContextAddArc(context, self.center.x, self.center.y, self.radius, i * M_PI / 180, (i + (self.clockwise?-1:1)) * M_PI / 180, self.clockwise);
        CGContextClosePath(context);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
    
}


@end
