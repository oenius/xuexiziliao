//
//  LCDelayTimePromptView.m
//  LightCamera
//
//  Created by 何少博 on 16/12/15.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "LCDelayTimePromptView.h"

@interface LCDelayTimePromptView ()

@property (strong,nonatomic) UILabel * label;

@end

@implementation LCDelayTimePromptView

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initSomthings];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSomthings];
    }
    return self;
}

-(void)initSomthings{
    
    self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    self.label = [[UILabel alloc]init];
    self.label.textColor = [UIColor whiteColor];
    [self addSubview:self.label];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.layer.cornerRadius = self.bounds.size.height / 2;
    self.layer.masksToBounds = YES;
    self.label.frame = CGRectMake(0, 0, self.bounds.size.width/3*2, self.bounds.size.height/3*2);
    self.label.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.label.font = [UIFont systemFontOfSize:self.bounds.size.height/2-4];
    self.label.adjustsFontSizeToFitWidth = YES;
    self.label.textAlignment = NSTextAlignmentCenter;
}

-(void)setDelayTime:(CGFloat)delayTime{
    
    _delayTime = delayTime;
    self.label.text = [NSString stringWithFormat:@"%.0fs",delayTime];
}

@end
