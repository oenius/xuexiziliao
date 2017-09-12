//
//  Ruler.m
//  numberChoose
//
//  Created by 何少博 on 16/9/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "Ruler.h"

#define ZSHeight 8
#define ZSColor [UIColor redColor].CGColor


@interface Ruler ()

@property (strong,nonatomic)RulerScrollView * rulerScrollView;

@end

@implementation Ruler

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.rulerScrollView.rulerHeight = frame.size.height;
        self.rulerScrollView.rulerWidth = frame.size.width;
        self.rulerScrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    return self;
}

-(RulerScrollView *)rulerScrollView{
    if (nil == _rulerScrollView) {
        _rulerScrollView = [[RulerScrollView alloc]init];
        _rulerScrollView.delegate = self;
        _rulerScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _rulerScrollView;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect bouns = self.bounds;
    self.rulerScrollView.frame = bouns;
}
-(void)showInView:(UIView*)view{
    _rulerScrollView.numberArray = self.numberArray;
    [_rulerScrollView drawRuler];
    [self addSubview:_rulerScrollView];
    [self drawRacAndLine];
    [view addSubview:self];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidEndDecelerating:(RulerScrollView *)scrollView {
    [self animationRebound:scrollView];
}

- (void)scrollViewDidEndDragging:(RulerScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self animationRebound:scrollView];
}

- (void)animationRebound:(RulerScrollView *)scrollView {
    CGFloat offSetX = scrollView.contentOffset.x ;
    CGFloat minOffset = [scrollView.offsetArray.firstObject floatValue];
    CGFloat maxOffset = [scrollView.offsetArray.lastObject floatValue];
    CGFloat newOffset;
    int index = 0;
    if (offSetX <= minOffset) {
        newOffset = minOffset;
        index = 0;
    }
    else if (offSetX >= maxOffset){
        newOffset = maxOffset;
        index = (int)scrollView.offsetArray.count - 1;
    }
    else{
        float lastOffset;
        float nextOffset;
        int i = 0;
        for ( i = 0; i < scrollView.offsetArray.count; i++) {
            NSNumber * offset = scrollView.offsetArray[i];
            if (offSetX <= offset.floatValue ) {
                nextOffset = offset.floatValue;
                lastOffset = [scrollView.offsetArray[i-1] floatValue];
                index = i;
                break;
            }
        }
        newOffset = nextOffset;
        if ((ABS(lastOffset - offSetX)<ABS(nextOffset - offSetX))) {
            newOffset = lastOffset;
            index = i -1;
        }
    }
    scrollView.rulerValue = [scrollView.numberArray[index] floatValue];
    [UIView animateWithDuration:.2f animations:^{
        scrollView.contentOffset = CGPointMake(newOffset, 0);
    }];
    
    [UIView animateWithDuration:.2f animations:^{
        scrollView.contentOffset = CGPointMake(newOffset, 0);
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(rulerDidDrag:)]) {
            [self.delegate rulerDidDrag:scrollView.rulerValue];
        }
    }];
}

- (void)drawRacAndLine {
    
    // 渐变
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = self.bounds;
//    
//    gradient.colors = @[(id)[[UIColor blackColor] colorWithAlphaComponent:1.f].CGColor,
//                        (id)[[UIColor whiteColor] colorWithAlphaComponent:0.0f].CGColor,
//                        (id)[[UIColor blackColor] colorWithAlphaComponent:1.f].CGColor];
//    
//    gradient.locations = @[[NSNumber numberWithFloat:0.0f],
//                           [NSNumber numberWithFloat:0.5f]];
//    
//    gradient.startPoint = CGPointMake(0, .5);
//    gradient.endPoint = CGPointMake(1, .5);
//    
//    CGMutablePathRef pathArc = CGPathCreateMutable();
//    
//    CGPathMoveToPoint(pathArc, NULL, 0, DISTANCETOPANDBOTTOM);
//    CGPathAddQuadCurveToPoint(pathArc, NULL, self.frame.size.width / 2, - 20, self.frame.size.width, DISTANCETOPANDBOTTOM);
//
//    [self.layer addSublayer:gradient];
    
    // 红色指示器
    CAShapeLayer *shapeLayerLine = [CAShapeLayer layer];
    shapeLayerLine.strokeColor = [UIColor redColor].CGColor;
    shapeLayerLine.fillColor = ZSColor;
    shapeLayerLine.lineWidth = 1.f;
    shapeLayerLine.lineCap = kCALineCapSquare;
    
    NSUInteger ruleHeight = 20; // 文字高度
    CGMutablePathRef pathLine = CGPathCreateMutable();
    CGPathMoveToPoint(pathLine, NULL, self.frame.size.width / 2, self.frame.size.height - DISTANCETOPANDBOTTOM - ruleHeight);
    CGPathAddLineToPoint(pathLine, NULL, self.frame.size.width / 2, DISTANCETOPANDBOTTOM + ZSHeight);
    
    CGPathAddLineToPoint(pathLine, NULL, self.frame.size.width / 2 - ZSHeight / 2, DISTANCETOPANDBOTTOM);
    CGPathAddLineToPoint(pathLine, NULL, self.frame.size.width / 2 + ZSHeight / 2, DISTANCETOPANDBOTTOM);
    CGPathAddLineToPoint(pathLine, NULL, self.frame.size.width / 2, DISTANCETOPANDBOTTOM + ZSHeight);
    shapeLayerLine.path = pathLine;
    [self.layer addSublayer:shapeLayerLine];
    self.layer.borderColor = color_403f3f.CGColor;
    self.layer.borderWidth = 2.0f;
}

-(void)nextItem{
    CGPoint offset = _rulerScrollView.contentOffset;
    offset.x += _rulerScrollView.distanceValue;
    _rulerScrollView.contentOffset = offset;
    [self animationRebound:_rulerScrollView];
}


@end
