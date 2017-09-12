//
//  DTipsViews.m
//  IDPhoto
//
//  Created by 何少博 on 17/5/9.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTipsViews.h"

@interface DTipsViews ()

@property (strong,nonatomic) DTipsView1 * tip1;
@property (strong,nonatomic) DTipsView2 * tip2;
@property (strong,nonatomic) DTipsView3 * tip3;

@end

@implementation DTipsViews

-(instancetype)init{
    self = [super init];
    if (self) {
        _tipViews = [[NSBundle mainBundle]loadNibNamed:@"DTipsViews" owner:nil options:nil];
        _tip1 = _tipViews[0];
        _tip2 = _tipViews[1];
        _tip3 = _tipViews[2];
        _tip1.tipLabel.text = [IDConst instance].TipsOptions1;
        _tip2.tipLabel.text = [IDConst instance].TipsOptions2;
        _tip3.label1.text = [IDConst instance].TipsOptions3;
        _tip3.label2.text = [IDConst instance].TipsOptions4;
        _tip3.label3.text = [IDConst instance].TipsOptions5;
        _tip3.label4.text = [IDConst instance].TipsOptions6;
        [_tip3.knowBtn setTitle:[IDConst instance].OK forState:(UIControlStateNormal)];
    }
    return self;
}


-(void)addKnowBtnTarget:(id)target action:(SEL)action{
    [_tip3.knowBtn addTarget:target action:action forControlEvents:(UIControlEventTouchUpInside)];
}

@end
@implementation DTipsView1

@end
@implementation DTipsView2

@end
@implementation DTipsView3
-(void)layoutSubviews{
    [super layoutSubviews];
    self.knowBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
}
@end
