//
//  CrossView.m
//  AngleMeter
//
//  Created by 何少博 on 16/9/19.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//
#define lineW 3

#import "CrossView.h"

@interface CrossView ()

@property (strong,nonatomic)UIView * H_view;
@property (strong,nonatomic)UIView * V_view;

@end

@implementation CrossView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSubViews];
    }
    return self;
}
-(void)awakeFromNib{
    [super awakeFromNib];
}

-(void)initSubViews{
    _H_view = [[UIView alloc]init];
    _H_view.backgroundColor = [UIColor redColor];
    [self addSubview:_H_view];
    _V_view = [[UIView alloc]init];
    _V_view.backgroundColor = [UIColor redColor];
    [self addSubview:_V_view];
    self.backgroundColor = [UIColor clearColor];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    _H_view.frame = CGRectMake(0, bounds.size.height - lineW, bounds.size.width, lineW);
    _V_view.frame = CGRectMake((bounds.size.width-lineW)/2, 0, lineW, bounds.size.height);

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
