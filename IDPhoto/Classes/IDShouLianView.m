//
//  IDShouLianView.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/24.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDShouLianView.h"

CGFloat const kShouLianViewHeight = 100;


@interface IDShouLianView ()

@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;

@property (weak, nonatomic) IBOutlet UIButton *doneBnt;

@property (weak, nonatomic) IBOutlet UIButton *shoudongBtn;

@property (weak, nonatomic) IBOutlet UIButton *zidongBtn;

@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (copy, nonatomic) ShouLianViewActionBlock block;

@property (assign,nonatomic) ShouLianViewActionType currentType;

@end


@implementation IDShouLianView

-(instancetype)initWithAction:(ShouLianViewActionBlock)block{
    IDShouLianView * view = [[NSBundle mainBundle]loadNibNamed:@"IDShouLianView" owner:nil options:nil].firstObject;
    if (view) {
        self = view;
        self.block = block;
        self.currentType = ShouLianViewActionTypeZiDongValueChanged;
    }
    return self;
}

- (IBAction)doneBtnClick:(id)sender {
    if (self.block) {
        self.block(ShouLianViewActionTypeDone,MAXFLOAT);
    }
}

- (IBAction)shoudongBtnClick:(id)sender {
    self.currentType = ShouLianViewActionTypeShouDongValueChanged;
    if (self.block) {
        self.block(ShouLianViewActionTypeShouDongValueChanged,_slider.value);
    }
}

- (IBAction)cancleBtnClick:(id)sender {
    if (self.block) {
        self.block(ShouLianViewActionTypeCancel,MAXFLOAT);
    }
}

- (IBAction)zidongBtnClick:(id)sender {
    self.currentType = ShouLianViewActionTypeZiDongValueChanged;
    if (self.block) {
        self.block(ShouLianViewActionTypeZiDongValueChanged,_slider.value);
    }
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    if (self.block) {
        self.block(_currentType,sender.value);
    }
}

@end
