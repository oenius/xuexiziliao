//
//  CIEraserSizeChooseView.m
//  CutoutImage
//
//  Created by 何少博 on 17/2/9.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "CIEraserSizeChooseView.h"

@interface CIEraserSizeChooseView ()

@property (nonatomic,strong) UISlider * slider;

//@property (nonatomic,strong) UILabel * titleLabel;

@property (nonatomic,strong) UIView *sizeView;


@end

@implementation CIEraserSizeChooseView


-(instancetype)initWithFrame:(CGRect)frame sliderMaxValue:(CGFloat)maxValue{
    self = [super initWithFrame:frame];
    if (self) {
        self.slider = [[UISlider alloc]init];
        self.slider.minimumValue = 1;
        self.slider.maximumValue = maxValue;
        self.slider.value = 5;
        [self.slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_slider];
        
        
        self.sizeView = [[UIView alloc]init];
        self.sizeView.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:_sizeView];
        
    }
    return self;
}


-(void)valueChanged:(UISlider *)slider{
    
    CGFloat height = self.bounds.size.height;
    self.sizeView.frame = CGRectMake(0, 0, _slider.value, _slider.value);
    self.sizeView.center = CGPointMake(30, height/2);
    self.sizeView.layer.cornerRadius = slider.value/2;
    self.sizeView.layer.masksToBounds = YES;
    if ([self.delegate respondsToSelector:@selector(sizeChanged:size:)]) {
        [self.delegate sizeChanged:self size:slider.value];
    }
}

-(void)drawRect:(CGRect)rect{
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    self.slider.frame = CGRectMake(60, 0, width-70, 30);
    self.slider.center = CGPointMake(60+CGRectGetWidth(self.slider.frame)/2, height/2);
    self.sizeView.frame = CGRectMake(0, 0, _slider.value, _slider.value);
    self.sizeView.center = CGPointMake(30, height/2);
    self.sizeView.layer.cornerRadius = self.slider.value/2;
    self.sizeView.layer.masksToBounds = YES;
}


@end
