//
//  IDClotehsEraseView.m
//  IDPhoto
//
//  Created by 何少博 on 17/5/2.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDClotehsEraseView.h"

@interface IDClotehsEraseView ()

@property (nonatomic,strong) UIView * circleView;

@property (nonatomic,strong) UISlider * slider;

@property (nonatomic,weak) NSLayoutConstraint * circleHeight;

@property (nonatomic,copy) ClothesEraseBlock block;

@end



@implementation IDClotehsEraseView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubView];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSubView];
    }
    return self;
}

-(void)setupSubView{
    
    self.slider = [[UISlider alloc]init];
    self.slider.maximumValue = 30;
    self.slider.minimumValue = 2;
    self.slider.value = 10;
    [self.slider defaultUI];
    [self.slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:(UIControlEventValueChanged)];
    [self addSubview:self.slider];
    self.circleView = [[UIView alloc]init];
    self.circleView.layer.masksToBounds = YES;
    self.circleView.layer.cornerRadius = 5;
    self.circleView.backgroundColor = [UIColor blackColor];
    self.circleView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.circleView.layer.shadowOffset = CGSizeMake(0, 0);
    self.circleView.layer.shadowOpacity = 5;
    self.circleView.layer.shadowRadius = 5;
    [self addSubview:self.circleView];
    
    self.cancelBtn = [[UIButton alloc]init];
    [self.cancelBtn setImage:[UIImage imageNamed:@"cha"] forState:(UIControlStateNormal)];
    [self addSubview:self.cancelBtn];
    
    self.okBtn = [[UIButton alloc]init];
    [self.okBtn setImage:[UIImage imageNamed:@"gou"] forState:(UIControlStateNormal)];
    [self addSubview:self.okBtn];
    
    
    self.circleView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint * circleHeight =
    [NSLayoutConstraint constraintWithItem:_circleView
                                 attribute:(NSLayoutAttributeHeight)
                                 relatedBy:(NSLayoutRelationEqual)
                                    toItem:nil
                                 attribute:(NSLayoutAttributeNotAnAttribute)
                                multiplier:1.0 constant:10];
    self.circleHeight=  circleHeight;
    
    NSLayoutConstraint * circelWidth =
    [NSLayoutConstraint constraintWithItem:_circleView
                                 attribute:(NSLayoutAttributeWidth)
                                 relatedBy:(NSLayoutRelationEqual)
                                    toItem:_circleView
                                 attribute:(NSLayoutAttributeHeight)
                                multiplier:1.0
                                  constant:0];
    [self.circleView addConstraints:@[circleHeight,circelWidth]];
    
    NSLayoutConstraint * circleCenterX =
    [NSLayoutConstraint constraintWithItem:_circleView
                                 attribute:(NSLayoutAttributeCenterX)
                                 relatedBy:(NSLayoutRelationEqual)
                                    toItem:self
                                 attribute:(NSLayoutAttributeCenterX)
                                multiplier:0.1
                                  constant:10];
    
    NSLayoutConstraint * circleTop  =
    [NSLayoutConstraint constraintWithItem:_circleView
                                 attribute:(NSLayoutAttributeCenterY)
                                 relatedBy:(NSLayoutRelationEqual)
                                    toItem:self
                                 attribute:(NSLayoutAttributeTop)
                                multiplier:1.0
                                  constant:20];
    
    
    self.slider.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint * sliderHeight =
    [NSLayoutConstraint constraintWithItem:_slider
                                 attribute:(NSLayoutAttributeHeight)
                                 relatedBy:(NSLayoutRelationEqual)
                                    toItem:nil
                                 attribute:(NSLayoutAttributeNotAnAttribute)
                                multiplier:1.0
                                  constant:31];
    [self.slider addConstraint:sliderHeight];
    
    NSLayoutConstraint * sliderLeft =
    [NSLayoutConstraint constraintWithItem:_slider
                                 attribute:(NSLayoutAttributeLeft)
                                 relatedBy:(NSLayoutRelationEqual)
                                    toItem:_circleView
                                 attribute:(NSLayoutAttributeRight)
                                multiplier:1.0
                                  constant:10];
    
    NSLayoutConstraint * sliderRight =
    [NSLayoutConstraint constraintWithItem:_slider
                                 attribute:(NSLayoutAttributeRight)
                                 relatedBy:(NSLayoutRelationEqual)
                                    toItem:self
                                 attribute:(NSLayoutAttributeRight)
                                multiplier:1.0 constant:-10];
    
    NSLayoutConstraint * sliderCenterY =
    [NSLayoutConstraint constraintWithItem:_slider
                                 attribute:(NSLayoutAttributeCenterY)
                                 relatedBy:(NSLayoutRelationEqual)
                                    toItem:_circleView
                                 attribute:(NSLayoutAttributeCenterY)
                                multiplier:1.0
                                  constant:0];
    
    [self addConstraints:@[circleCenterX,circleTop,sliderLeft,sliderCenterY,sliderRight]];
    
    self.cancelBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint * cancleWidth =
    [NSLayoutConstraint constraintWithItem:_cancelBtn
                                 attribute:(NSLayoutAttributeWidth)
                                 relatedBy:(NSLayoutRelationEqual)
                                    toItem:nil
                                 attribute:(NSLayoutAttributeNotAnAttribute)
                                multiplier:1
                                  constant:40];
    NSLayoutConstraint * cancleHeight =
    [NSLayoutConstraint constraintWithItem:_cancelBtn
                                 attribute:(NSLayoutAttributeHeight)
                                 relatedBy:(NSLayoutRelationEqual)
                                    toItem:nil
                                 attribute:(NSLayoutAttributeNotAnAttribute)
                                multiplier:1
                                  constant:40];
    [self.cancelBtn addConstraints:@[cancleWidth,cancleHeight]];
    
    NSLayoutConstraint * cancelLeft =
    [NSLayoutConstraint constraintWithItem:_cancelBtn
                                 attribute:(NSLayoutAttributeLeft)
                                 relatedBy:(NSLayoutRelationEqual)
                                    toItem:self
                                 attribute:(NSLayoutAttributeLeft)
                                multiplier:1
                                  constant:5];
    NSLayoutConstraint * cancelBottom =
    [NSLayoutConstraint constraintWithItem:_cancelBtn
                                 attribute:(NSLayoutAttributeBottom)
                                 relatedBy:(NSLayoutRelationEqual)
                                    toItem:self
                                 attribute:(NSLayoutAttributeBottom)
                                multiplier:1
                                  constant:0];
    
    self.okBtn.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint * okWidth =
    [NSLayoutConstraint constraintWithItem:_okBtn
                                 attribute:(NSLayoutAttributeWidth)
                                 relatedBy:(NSLayoutRelationEqual)
                                    toItem:nil
                                 attribute:(NSLayoutAttributeNotAnAttribute)
                                multiplier:1
                                  constant:40];
    NSLayoutConstraint * okHeight =
    [NSLayoutConstraint constraintWithItem:_okBtn
                                 attribute:(NSLayoutAttributeHeight)
                                 relatedBy:(NSLayoutRelationEqual)
                                    toItem:nil
                                 attribute:(NSLayoutAttributeNotAnAttribute)
                                multiplier:1
                                  constant:40];
    [self.okBtn addConstraints:@[okHeight,okWidth]];
    
    NSLayoutConstraint * okRight =
    [NSLayoutConstraint constraintWithItem:_okBtn
                                 attribute:(NSLayoutAttributeRight)
                                 relatedBy:(NSLayoutRelationEqual)
                                    toItem:self
                                 attribute:(NSLayoutAttributeRight)
                                multiplier:1
                                  constant:-5];
    NSLayoutConstraint * okBottom =
    [NSLayoutConstraint constraintWithItem:_okBtn
                                 attribute:(NSLayoutAttributeBottom)
                                 relatedBy:(NSLayoutRelationEqual)
                                    toItem:self
                                 attribute:(NSLayoutAttributeBottom)
                                multiplier:1
                                  constant:0];
    
    [self addConstraints:@[cancelLeft,cancelBottom,okRight,okBottom]];
  
}

-(void)setEraseColor:(UIColor *)eraseColor{
    _eraseColor = eraseColor;
    self.circleView.backgroundColor = _eraseColor;
}

-(void)sliderValueChanged{
    self.circleHeight.constant = self.slider.value;
    self.circleView.layer.cornerRadius = self.slider.value/2;
    if (self.block){
        self.block(_slider.value);
    }
}

-(void)valueChanged:(ClothesEraseBlock)block{
    self.block = block;
}

@end
