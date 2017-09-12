//
//  SNLabel.m
//  MindMap
//
//  Created by 何少博 on 2017/8/8.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNLabel.h"

@implementation SNLabel


#pragma mark - init
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configure];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

-(instancetype)init{
    return  [self initWithFrame:CGRectZero];
}

-(void)configure{
    _cornerRadius = _cornerRadius == 0 ? 5 : _cornerRadius;
    _borderWidth = _borderWidth == 0 ? 1 : _borderWidth;
    _borderColor = _borderColor == nil ? [UIColor lightGrayColor] : _borderColor;
    self.layer.masksToBounds = YES;
    [self update];
}

-(void)update{
    self.layer.cornerRadius = self.cornerRadius;
    self.layer.borderWidth = self.borderWidth;
    self.layer.borderColor = self.borderColor.CGColor;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self update];
}

@end
