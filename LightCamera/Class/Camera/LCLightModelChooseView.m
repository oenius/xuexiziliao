//
//  LCLightModelChooseView.m
//  LightCamera
//
//  Created by 何少博 on 16/12/15.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "LCLightModelChooseView.h"

@interface LCLightModelChooseView ()

@property (nonatomic,copy) lightModelBlock block;

@property (nonatomic,strong) UIButton * modelAutoBtn;

@property (nonatomic,strong) UIButton * modelOneBtn;

@property (nonatomic,strong) UIButton * modelTwoBtn;

@end

@implementation LCLightModelChooseView

-(instancetype)initWithFrame:(CGRect)frame chooseBlock:(lightModelBlock)block{
    self = [super initWithFrame:frame];
    self.block = block;
    if (self) {
        self.modelAutoBtn = [[UIButton alloc]init];
//        [self.modelAutoBtn setTitle:@"Auto" forState:UIControlStateNormal];
//        [self.modelAutoBtn setImage:[UIImage imageNamed:@"icon_auto"] forState:UIControlStateNormal];
        [self.modelAutoBtn setBackgroundImage:[UIImage imageNamed:@"icon_auto"] forState:UIControlStateNormal];
        self.modelAutoBtn.tag = 0;
        self.modelAutoBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.modelAutoBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.modelAutoBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.modelAutoBtn];
        
        self.modelOneBtn  = [[UIButton alloc]init];
//        [self.modelOneBtn setTitle:@"M1" forState:UIControlStateNormal];
        [self.modelOneBtn setBackgroundImage:[UIImage imageNamed:@"icon_m1"] forState:UIControlStateNormal];
        self.modelOneBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.modelOneBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.modelOneBtn.tag = 1;
        [self.modelOneBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.modelOneBtn];
        
        self.modelTwoBtn = [[UIButton alloc]init];
//        [self.modelTwoBtn setTitle:@"M2" forState:UIControlStateNormal];
        [self.modelTwoBtn setBackgroundImage:[UIImage imageNamed:@"icon_m2"] forState:UIControlStateNormal];
        self.modelTwoBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.modelTwoBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.modelTwoBtn.tag = 2;
        [self.modelTwoBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.modelTwoBtn];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat spacing = 5;
    CGFloat W = self.bounds.size.width - spacing * 4;
    CGFloat H = self.bounds.size.height - spacing * 2;
    
    self.modelTwoBtn.frame = CGRectMake(spacing, spacing, W/3, H);
    self.modelTwoBtn.layer.cornerRadius = H/6;
    self.modelTwoBtn.layer.masksToBounds = YES;
    
    self.modelOneBtn.frame = CGRectMake(W/3 + spacing* 2, spacing , W/3, H);
    self.modelOneBtn.layer.cornerRadius = H/6;
    self.modelOneBtn.layer.masksToBounds = YES;
    
    self.modelAutoBtn.frame = CGRectMake(W/3*2 + spacing* 3, spacing , W/3, H);
    self.modelAutoBtn.layer.cornerRadius = H/6;
    self.modelAutoBtn.layer.masksToBounds = YES;
}

-(void)buttonClick:(UIButton*)sender{
    LightModel model = kLightModelAuto;
    switch (sender.tag) {
        case 0:
            model = kLightModelAuto;
            break;
        case 1:
            model = kLightModelOne;
            break;
        case 2:
            model = kLightModelTwo;
            break;
        default:
            break;
    }
    if (self.block) {
        self.block(model);
    }
}

@end
