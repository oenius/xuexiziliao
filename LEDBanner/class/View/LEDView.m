//
//  HSLedView.m
//  LED_MySelf
//
//  Created by Mac_H on 16/6/22.
//  Copyright © 2016年 何少博. All rights reserved.
//

#import "LEDView.h"


@interface LEDView ()
@property (nonatomic,strong)NSMutableArray * subViewArray;
@property (nonatomic,assign)int lieshu;
@end

@implementation LEDView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.showModel = NSShowModel32;
        self.dotModel = NSDotModelSquare;
    }
    return self;
}

-(void)setShowModel:(NSShowModel)showModel{
    if (_showModel == showModel) {
        return;
    }
    _showModel = showModel;
    [self.subViewArray removeAllObjects];
    for (UIView * subView in self.subviews) {
        [subView removeFromSuperview];
    }
    CGFloat W = [UIScreen mainScreen].bounds.size.width;
    CGFloat H = [UIScreen mainScreen].bounds.size.height;
    CGFloat space = 2;
    if (W>H) {
        W = W + H;
        H = W - H;
        W = W - H;
    }
    CGFloat dw = (W - space)/_showModel - space;
    CGFloat dh = dw;
    int flag = -1;
    for (int i = 0; ; i++) {
        for (int j = 0 ;j <_showModel;j++) {
            CGFloat y = i * (dh + space) + space;
            CGFloat x = j * (dw + space) + space;
            CGRect Subframe = CGRectMake(x, y, dw, dh);
            UIView * subView = [[UIView alloc]initWithFrame:Subframe];
            subView.backgroundColor = CLEARCOLOR;
            if (self.dotModel == NSDotModelCircle) {
                subView.layer.cornerRadius = dh/2;
                subView.layer.masksToBounds = YES;
            }
            if (Subframe.origin.y >= H && (i)%6==0) {//对6取余是为了方便速度的调节
                flag = 0;
                break;
            }
            [self.subViewArray addObject:subView];
            [self addSubview:subView];
        }
        if (flag == 0) return;
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];

    CGFloat W = self.bounds.size.width;
    CGFloat H = self.bounds.size.height;
    CGFloat space = 2;
    if (W>H) {
        W = W + H;
        H = W - H;
        W = W - H;
    }
    CGFloat dw = (W - space)/self.showModel - space;
    CGFloat dh = dw;
    int count = (self.subViewArray.count/self.showModel);
 
    for (int i = 0; i < count; i++) {
        for (int j = 0 ;j <self.showModel;j++) {
            CGFloat y = i * (dh + space) + space;
            CGFloat x = j * (dw + space) + space;
            CGRect Subframe = CGRectMake(x, y, dw, dh);
            NSInteger index = i * _showModel + j;
            UIView * subView = self.subViewArray[index];
            subView.frame = Subframe;
            subView.backgroundColor = CLEARCOLOR;
            if (self.dotModel == NSDotModelCircle) {
                subView.layer.cornerRadius = dh/2;
                subView.layer.masksToBounds = YES;
            }
        }
    }
}
//返回子控件
-(NSMutableArray*)getLEDViewSubViews{
    NSMutableArray * tempArray = [NSMutableArray array];
    for (int i = 0; i < self.subViewArray.count/_showModel; i ++) {
        NSMutableArray * columnViews = [NSMutableArray array];
        for (int j = 0; j < self.showModel; j++) {
            NSInteger index = i * _showModel + j;
            UIView * view = self.subViewArray[index];
            [columnViews addObject:view];
        }
        [tempArray addObject:columnViews];
        columnViews = nil;
    }
    
    return  tempArray;
}

-(NSMutableArray *)subViewArray{
    if (_subViewArray == nil) {
        _subViewArray = [NSMutableArray array];
    }
    return _subViewArray;
}

-(void)dealloc{
    LOG(@"%s", __func__);
    
}

@end
