//
//  CVSlider.m
//  VideoCompress
//
//  Created by 何少博 on 17/4/13.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "CVSlider.h"
#import "CVPopImageView.h"
CGFloat const thumViewWidth = 10;

@interface CVSlider ()<UIGestureRecognizerDelegate>

@property (nonatomic,strong) CVPopImageView * popImageView;
@property(nonatomic, strong)UIView * minView;
@property(nonatomic, strong)UIView * maxView;

@property(nonatomic, strong)CAShapeLayer * lineShaper;

@end



@implementation CVSlider

-(CVPopImageView *)popImageView{
    if (_popImageView == nil) {
        _popImageView = [[CVPopImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        _popImageView.borderWidth = 2;
        [self addSubview:_popImageView];
    }
    return _popImageView;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        self.maxValue = 1.0;
        self.sliderMaxValue = 1.0;
        self.minValue = 0.0;
        self.sliderMinValue = 0.0;
        [self setupSubView];
        
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.masksToBounds = YES;
        self.maxValue = 1.0;
        self.sliderMaxValue = 1.0;
        self.minValue = 0.0;
        self.sliderMinValue = 0.0;
        [self setupSubView];
    }
    return self;
}

-(void)setImage:(UIImage *)image{
    _image = image;
    self.popImageView.image = image;
}

-(void)setSliderMaxValue:(CGFloat)sliderMaxValue{
    _sliderMaxValue = sliderMaxValue;
}
-(void)setSliderMinValue:(CGFloat)sliderMinValue{
    _sliderMinValue = sliderMinValue;
}

-(void)setMaxValue:(CGFloat)maxValue{
    _maxValue = maxValue;
    
    CGSize size = CGSizeMake(thumViewWidth, self.frame.size.height);
    CGFloat value_A = self.sliderMaxValue - self.sliderMinValue;
    CGFloat value_T_2 = maxValue - self.sliderMinValue;
    CGPoint maxCenter = self.maxView.center;
    self.minView.frame = CGRectMake(0, 0, size.width, size.height);
    maxCenter.x = (value_T_2/value_A)*(self.frame.size.width-thumViewWidth) + thumViewWidth/2;
    self.minView.center = maxCenter;
}
-(void)setMinValue:(CGFloat)minValue{
    _minValue = minValue;
    CGSize size = CGSizeMake(thumViewWidth, self.frame.size.height);
    CGFloat value_A = self.sliderMaxValue - self.sliderMinValue;
    CGFloat value_T_1 = minValue - self.sliderMinValue;
    CGPoint minCenter = self.minView.center;
    self.minView.frame = CGRectMake(0, 0, size.width, size.height);
    minCenter.x = (value_T_1/value_A)*(self.frame.size.width-thumViewWidth) + thumViewWidth/2;
    self.minView.center = minCenter;
}

-(void)setupSubView{
    self.lineShaper = [CAShapeLayer layer];
    self.lineShaper.strokeColor = [UIColor blackColor].CGColor;
    self.lineShaper.lineWidth = 10;
    [self.layer addSublayer:self.lineShaper];
    
    self.minView = [[UIView alloc]init];
    self.minView.backgroundColor = [UIColor blueColor];
    UIPanGestureRecognizer *minVewPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveMinView:)];
    [self.minView addGestureRecognizer:minVewPan];
    minVewPan.delegate = self;
    [self addSubview:self.minView];
    
    self.maxView = [[UIView alloc]init];
    self.maxView.backgroundColor = [UIColor blueColor];
    UIPanGestureRecognizer *maxViewPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveMaxView:)];
    [self.maxView addGestureRecognizer:maxViewPan];
    maxViewPan.delegate = self;
    
    [self addSubview:self.maxView];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat WIDTH = self.bounds.size.width;
    CGFloat HEIGHT = self.bounds.size.height;
    UIBezierPath * mpath = [UIBezierPath bezierPath];
    [mpath moveToPoint:CGPointMake(thumViewWidth/2, 0)];
    [mpath addLineToPoint:CGPointMake(thumViewWidth/2, WIDTH - thumViewWidth)];
    self.lineShaper.path = mpath.CGPath;
    _maxValue = _sliderMaxValue;
    CGSize size = CGSizeMake(thumViewWidth, HEIGHT);
    CGFloat value_A = self.sliderMaxValue - self.sliderMinValue;
    
    CGFloat value_T_1 = self.minValue - self.sliderMinValue;
    CGPoint minCenter = self.minView.center;
    self.minView.frame = CGRectMake(0, 0, size.width, size.height);
    minCenter.x = (value_T_1/value_A)*(WIDTH-thumViewWidth) + thumViewWidth/2;
    self.minView.center = minCenter;
    
    CGFloat value_T_2 = self.maxValue - self.sliderMinValue;
    CGPoint maxCenter = self.maxView.center;
    self.minView.frame = CGRectMake(0, 0, size.width, size.height);
    maxCenter.x = (value_T_2/value_A)*(WIDTH-thumViewWidth) + thumViewWidth/2;
    self.minView.center = maxCenter;
    
}

- (void)moveMaxView:(UIPanGestureRecognizer *)pan{
    CGPoint po = [pan translationInView:self];
    static CGPoint center;
    if (pan.state == UIGestureRecognizerStateBegan) {
        center = pan.view.center;
        [self showPopImageView];
        [self sendActionsForControlEvents:UIControlEventTouchDown];
    }
    else if (pan.state == UIGestureRecognizerStateEnded){
        [self hiddenPopImageView];
        [self sendActionsForControlEvents:UIControlEventTouchCancel];
    }
    pan.view.center = CGPointMake(center.x+po.x, center.y);
    
    if (pan.view.center.x > self.frame.size.width - thumViewWidth/2) {
        pan.view.center = CGPointMake(self.frame.size.width - thumViewWidth/2, center.y);
    }else{
        if (pan.view.center.x - self.minView.center.x < thumViewWidth) {
            pan.view.center = CGPointMake(self.minView.center.x + thumViewWidth, center.y);
        }
    }
    CGFloat value_A = self.sliderMaxValue - self.sliderMinValue;
    CGFloat K = value_A/(self.frame.size.width-thumViewWidth);
    CGFloat B = (self.sliderMinValue*(self.frame.size.width-thumViewWidth/2) - thumViewWidth/2*self.sliderMaxValue)/(self.frame.size.width-thumViewWidth);
    _maxValue = pan.view.center.x*K + B;
    CGFloat ViewY = pan.view.frame.origin.y;
    CGFloat ViewCenterX = pan.view.center.x;
    CGFloat PopImageHeight = self.popImageView.bounds.size.height;
    self.popImageView.center = CGPointMake(ViewCenterX, ViewY-PopImageHeight/2);
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
}
- (void)moveMinView:(UIPanGestureRecognizer *)pan{
    NSLog(@"%@", self);
    CGPoint po = [pan translationInView:self];
    static CGPoint center;
    if (pan.state == UIGestureRecognizerStateBegan) {
        center = pan.view.center;
        [self showPopImageView];
        [self sendActionsForControlEvents:UIControlEventTouchDown];
    }
    else if (pan.state == UIGestureRecognizerStateEnded){
        [self hiddenPopImageView];
        [self sendActionsForControlEvents:UIControlEventTouchCancel];
    }
    pan.view.center = CGPointMake(center.x+po.x, center.y);
    
    if (pan.view.center.x < thumViewWidth/2) {
        pan.view.center = CGPointMake(thumViewWidth/2, center.y);
    }else{
        if (self.maxView.center.x - pan.view.center.x < thumViewWidth) {
            pan.view.center = CGPointMake(self.maxView.center.x - thumViewWidth, center.y);
        }
    }
    CGFloat value_A = self.sliderMaxValue - self.sliderMinValue;
    CGFloat K = value_A/(self.frame.size.width-thumViewWidth);
    CGFloat B = (self.sliderMinValue*(self.frame.size.width-thumViewWidth/2) - thumViewWidth/2*self.sliderMaxValue)/(self.frame.size.width-thumViewWidth);
    _minValue = pan.view.center.x*K + B;
    CGFloat ViewY = pan.view.frame.origin.y;
    CGFloat ViewCenterX = pan.view.center.x;
    CGFloat PopImageHeight = self.popImageView.bounds.size.height;
    self.popImageView.center = CGPointMake(ViewCenterX, ViewY-PopImageHeight/2);
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma make - actions

-(void)showPopImageView{
    [UIView animateWithDuration:0.35 animations:^{
        self.popImageView.alpha = 1;
    }];
    [self scaleAnimationForView:self.popImageView];
}
-(void)hiddenPopImageView{
    [UIView animateWithDuration:0.75 animations:^{
        self.popImageView.alpha = 0;
    }];
    [self scaleAnimationForView:self.popImageView];
}


- (void)scaleAnimationForView:(UIView *)view {
    CGAffineTransform originalTransform = view.transform;
    view.transform = CGAffineTransformMakeScale(1.2, 1.2);
    [UIView animateWithDuration:.5 delay:0.0 usingSpringWithDamping:0.1 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.transform = originalTransform;
    } completion:^(BOOL finished) {
    }];
}

@end
