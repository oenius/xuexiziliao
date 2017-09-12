//
//  CIIntelligentChooseView.m
//  CutoutImage
//
//  Created by 何少博 on 17/2/6.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "CIIntelligentChooseView.h"
#import "UIColor+x.h"

@interface CIIntelligentChooseView ()

@property (nonatomic,strong) UIButton *rectButton;

@property (nonatomic,strong) UIButton *plusButton;

@property (nonatomic,strong) UIButton *minusButton;


@end

@implementation CIIntelligentChooseView


-(void)setTouchState:(CITouchState)touchState{
    _touchState = touchState;
    switch (touchState) {
            ///设置选中态
        case CITouchStateRect:
            
            self.rectButton.backgroundColor = [UIColor colorWithHexString:@"f08d33"];
            self.plusButton.backgroundColor =  [UIColor colorWithHexString:@"1d1d1d"];
            self.minusButton.backgroundColor = [UIColor colorWithHexString:@"1d1d1d"];
            break;
        case CITouchStatePlus:
            self.rectButton.backgroundColor = [UIColor colorWithHexString:@"1d1d1d"];
            self.plusButton.backgroundColor = [UIColor colorWithHexString:@"f08d33"];
            self.minusButton.backgroundColor = [UIColor colorWithHexString:@"1d1d1d"];
            break;
        case CITouchStateMinus:
            self.rectButton.backgroundColor = [UIColor colorWithHexString:@"1d1d1d"];
            self.plusButton.backgroundColor = [UIColor colorWithHexString:@"1d1d1d"];
            self.minusButton.backgroundColor = [UIColor colorWithHexString:@"f08d33"];
            break;
        case CITouchStateEarse:
            
            break;
        default:
            break;
    }
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // 初始化代码
        [self addButton];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //初始化代码
        [self addButton];
    }
    return self;
}

-(void)addButton{
    
    self.rectButton = [[UIButton alloc]init];
    [_rectButton setImage:[UIImage imageNamed:@"rect" ]  forState:UIControlStateNormal];
    [self addSubview:_rectButton];
    
    self.plusButton = [[UIButton alloc]init];
    [_plusButton setImage:[UIImage imageNamed:@"1" ] forState:UIControlStateNormal];
    [self addSubview:_plusButton];
    
    self.minusButton = [[UIButton alloc]init];
    [_minusButton setImage:[UIImage imageNamed:@"2" ] forState:UIControlStateNormal];
    [self addSubview:_minusButton];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    _rectButton.frame = CGRectMake(0, 0, width/3, height);
    _plusButton.frame = CGRectMake(width/3, 0, width/3, height);
    _minusButton.frame = CGRectMake(width/3*2, 0, width/3, height);
    
}

-(void)setRectButtonEnable:(BOOL)enable{
    _rectButton.enabled = enable;
}
-(void)setPlusButtonEnable:(BOOL)enable{
    _plusButton.enabled = enable;
}
-(void)setMinusButtonEnable:(BOOL)enable{
    _minusButton.enabled = enable;
}

-(void)rectButtonAddTarget:(id)target action:(SEL)action{
    [_rectButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}
-(void)plusButtonAddTarget:(id)target action:(SEL)action{
    [_plusButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}
-(void)minusButtonAddTarget:(id)target action:(SEL)action{
    [_minusButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}
@end
