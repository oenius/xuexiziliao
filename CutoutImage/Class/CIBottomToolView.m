//
//  CIBottomToolView.m
//  CutoutImage
//
//  Created by 何少博 on 17/2/5.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "CIBottomToolView.h"
#import "UIColor+x.h"

@interface CIBottomToolView ()


@property(nonatomic,strong)UIButton *intelligentButton;

@property(nonatomic,strong)UIButton *eraserButton;

@end


@implementation CIBottomToolView

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self adbButton];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self adbButton];
    }
    return self;
}

-(void)adbButton{
//    self.backgroundColor = [UIColor clearColor];
    
    _intelligentButton = [[UIButton alloc]init];
    _intelligentButton.backgroundColor = [UIColor orangeColor];
    [_intelligentButton setImage:[UIImage imageNamed:@"Intelligence"] forState:UIControlStateNormal];
    [self addSubview:_intelligentButton];
    _intelligentButton.layer.borderColor = [UIColor colorWithHexString:@"1d1d1d"].CGColor;
    _intelligentButton.layer.borderWidth = 1.0;
    
    _eraserButton = [[UIButton alloc]init];
    _eraserButton.backgroundColor = [UIColor purpleColor];
    [_eraserButton setImage:[UIImage imageNamed:@"eraser"] forState:UIControlStateNormal];
    [self addSubview:_eraserButton];
    _eraserButton.layer.borderColor = [UIColor colorWithHexString:@"1d1d1d"].CGColor;
    _eraserButton.layer.borderWidth = 1.0;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    _intelligentButton.frame = CGRectMake(0, 0, width/2, height);
    _eraserButton.frame = CGRectMake( width/2,0,width/2, height);
    
    
}

-(void)intelligentButtonAddTarget:(id)target action:(SEL)action{
    [_intelligentButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

-(void)eraserButtonButtonAddTarget:(id)target action:(SEL)action{
    [_eraserButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

-(void)setLightState:(CIBottomToolViewHightState)state{
    switch (state) {
        case CIBottomToolViewHightStateEraser:
            self.intelligentButton.backgroundColor = [UIColor colorWithHexString:@"1d1d1d"];
            self.eraserButton.backgroundColor = [UIColor colorWithHexString:@"f08d33"];
            break;
        case CIBottomToolViewHightStateInteli:
            self.intelligentButton.backgroundColor = [UIColor colorWithHexString:@"f08d33"];
            self.eraserButton.backgroundColor = [UIColor colorWithHexString:@"1d1d1d"];
            break;
        default:
            break;
    }
}

@end
