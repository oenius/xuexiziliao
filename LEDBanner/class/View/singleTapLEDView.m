//
//  singleTapLEDView.m
//  LEDBanner
//
//  Created by 何少博 on 16/7/5.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "singleTapLEDView.h"

@interface singleTapLEDView ()
@property (weak, nonatomic) IBOutlet UIButton *zantingBtn;
@end

@implementation singleTapLEDView

-(void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect frame = self.frame;
    frame.size.height = 50;
    self.frame = frame;
    
}

- (IBAction)tuiChuClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(tuiChu)]) {
        [self.delegate tuiChu];
    }
}
- (IBAction)zanTingClick:(UIButton *)sender {
    self.isPause = self.isPause?NO:YES;
    if ([self.delegate respondsToSelector:@selector(zanTing:)]) {
        [self.delegate zanTing:self.isPause];
    }
}
- (IBAction)fenXiangClick:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(fenXiang)]) {
        [self.delegate fenXiang];
    }
}
-(void)setIsPause:(BOOL)isPause{
    _isPause = isPause;
    if (!isPause) {
        [self.zantingBtn setBackgroundImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    }else{
        [self.zantingBtn setBackgroundImage:[UIImage imageNamed:@"bofang"] forState:UIControlStateNormal];
    }
}

-(void)dealloc{
    LOG(@"%s", __func__);
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
