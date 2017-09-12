//
//  MEEqualizerAdjustSlider.m
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "MEEqualizerAdjustSlider.h"
#import "METextPopView.h"
#import "UIImage+x.h"
#import "UIColor+x.h"
#define LabelHeight     28
#define TopSpacing      28
#define BottomSpacing   0
#define PopViewWidth    40

@interface MEEqualizerAdjustSlider ()

@property (strong,nonatomic) UISlider * slider;

@property (strong,nonatomic) METextPopView * textView;

@end


@implementation MEEqualizerAdjustSlider

-(METextPopView *)textView{
    if (_textView == nil) {
        _textView = [[METextPopView alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];
        _textView.borderWidth = 2;
        [self addSubview:_textView];
    }
    return _textView;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self setupSubViews];
    }
    return self;
}


-(void)setupSubViews{
    self.clipsToBounds = NO;
    
//    self.imageView = [[UIImageView alloc]init];
//    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
//    [self addSubview:self.imageView];
    
    self.slider = [[UISlider alloc]init];
    [self addSubview:self.slider];
    
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.slider addTarget:self action:@selector(sliderTouchBegin:) forControlEvents:UIControlEventTouchDown];
    [self.slider addTarget:self action:@selector(sliderTouchEnd:) forControlEvents:UIControlEventTouchCancel];
    [self.slider addTarget:self action:@selector(sliderTouchEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self.slider addTarget:self action:@selector(sliderTouchEnd:) forControlEvents:UIControlEventTouchUpOutside];
    UIImage *minImage = [UIImage createCircleImageWithColor:[UIColor colorWithHexString:@"a20707"] andX:8 andY:8];
    UIImage *maxImage = [UIImage createCircleImageWithColor:[UIColor blackColor] andX:8 andY:8];
    
    UIImage *imageMin = [minImage stretchableImageWithLeftCapWidth:minImage.size.width/2 topCapHeight:minImage.size.height/2];
    UIImage *imageMax = [maxImage  stretchableImageWithLeftCapWidth:maxImage.size.width/2 topCapHeight:maxImage.size.height/2];
    
    [self.slider setThumbImage:[UIImage imageNamed:@"button"]forState:UIControlStateNormal];
    [self.slider setMinimumTrackImage:imageMin forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:imageMax forState:UIControlStateNormal];
    
    
    self.bottomLabel = [[UILabel alloc]init];
    self.bottomLabel.textAlignment = NSTextAlignmentCenter;
    self.bottomLabel.adjustsFontSizeToFitWidth = YES;
    self.bottomLabel.textColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1];
    self.bottomLabel.text = @"500";
    [self addSubview:self.bottomLabel];
}

-(void)awakeFromNib{
    [super awakeFromNib];

}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.bottomLabel.frame = CGRectMake(0, self.bounds.size.height - LabelHeight, self.bounds.size.width, LabelHeight);
    self.slider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.slider.frame = CGRectMake(0, TopSpacing, self.bounds.size.width, self.bounds.size.height - (TopSpacing+BottomSpacing) - LabelHeight);
}

-(void)setMaximumValue:(CGFloat)maximumValue{
    _maximumValue = maximumValue;
    self.slider.maximumValue = maximumValue;
}

-(void)setMinimumValue:(CGFloat)minimumValue{
    _minimumValue = minimumValue;
    self.slider.minimumValue = minimumValue;
}

-(void)setValue:(CGFloat)value{
    _value = value;
    self.slider.value = value;
}
- (CGRect)thumbRect
{
    return [self.slider thumbRectForBounds:self.slider.bounds
                          trackRect:[self.slider trackRectForBounds:self.slider.bounds]
                              value:self.slider.value];
}

-(void)updatePopViewFrame{
    CGRect thumbRect = [self thumbRect];
    CGFloat thumbX = thumbRect.origin.x;
    CGFloat thumbHeight = thumbRect.size.height;
    CGFloat selfHeight = self.bounds.size.height;
    CGFloat Y = selfHeight - (thumbHeight + LabelHeight + BottomSpacing +thumbX + LabelHeight);
    CGFloat X = (self.bounds.size.width - PopViewWidth)/2;
    self.textView.frame = CGRectMake(X, Y, PopViewWidth, LabelHeight);
}
#pragma make - actions

-(void)sliderTouchBegin:(UISlider *)sender{
    [UIView animateWithDuration:0.35 animations:^{
        self.textView.alpha = 1;
    }];
    [self scaleAnimationForView:self.textView];
}
-(void)sliderTouchEnd:(UISlider *)sender{
    [UIView animateWithDuration:0.75 animations:^{
        self.textView.alpha = 0;
    }];
    [self scaleAnimationForView:self.textView];
}

-(void)sliderValueChanged:(UISlider *)sender{
    _value = sender.value;
    self.textView.text = [NSString stringWithFormat:@"%.1f",sender.value];
    [self updatePopViewFrame];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
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
