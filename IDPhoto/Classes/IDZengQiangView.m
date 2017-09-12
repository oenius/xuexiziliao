//
//  IDZengQiangView.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/24.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDZengQiangView.h"
#import "UIButton+LZCategory.h"

CGFloat const kZengQiangViewHeight = 145;

@interface IDZengQiangView ()
{
    CGFloat baoHeDuCurrentValue;
    CGFloat liangDuDuCurrentValue;
    CGFloat duiBiDuCurrentValue;
    CGFloat baoGuangDuCurrentValue;
}

@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet UIButton *baoHeDu;

@property (weak, nonatomic) IBOutlet UIButton *liangdu;

@property (weak, nonatomic) IBOutlet UIButton *duibidu;

@property (weak, nonatomic) IBOutlet UIButton *baoguangdu;

@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;

@property (weak, nonatomic) IBOutlet UIButton *doneBtn;



@property (copy,nonatomic) ZengQiangActionBlock block;

@property (assign,nonatomic) ZengQiangActionType currentType;

@end



@implementation IDZengQiangView


-(instancetype)initWithAction:(ZengQiangActionBlock) block {
    IDZengQiangView * view = [[NSBundle mainBundle] loadNibNamed:@"IDZengQiangView" owner:nil options:nil].firstObject;
    if (view) {
        self = view;
        self.block = block;
        self.currentType = ZengQiangActionTypeLiangDu;
        baoHeDuCurrentValue = 1;
        duiBiDuCurrentValue = 1;
        baoGuangDuCurrentValue = 0;
        liangDuDuCurrentValue = 0;
        self.slider.maximumValue = 0.6;
        self.slider.minimumValue = -0.6;
        self.slider.value = 0;
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self.slider defaultUI];
    [self setButton:self.liangdu withTitle:[IDConst instance].Brightness];
    [self setButton:self.duibidu withTitle:[IDConst instance].Contrast];
    [self setButton:self.baoHeDu withTitle:[IDConst instance].Saturation];
    [self setButton:self.baoguangdu withTitle:[IDConst instance].Exposure];
    self.liangdu.selected = YES;
}

- (IBAction)boheduClick:(id)sender {
    [self setBoaHeDuSliderAndButton];
    
    if (self.block) {
        self.block(ZengQiangActionTypeBaoHeDu,_slider.value);
    }
}

- (IBAction)liangduClick:(id)sender {
    [self setLiangDuSliderAndButton];
    
    if (self.block) {
        self.block(ZengQiangActionTypeLiangDu,_slider.value);
    }
}

- (IBAction)duibiduClick:(id)sender {
    [self setDuiBiDuSliderAndButton];
    
    if (self.block) {
        self.block(ZengQiangActionTypeDuiBiDu,_slider.value);
    }
}
- (IBAction)baoguangdu:(id)sender {
    [self setBaoGuangDuSliderAndButton];
    
    if (self.block) {
        self.block(ZengQiangActionTypeBaoGuangDu,_slider.value);
    }
}
- (IBAction)sliderValueChanged:(UISlider *)sender {
    if (self.block) {
        self.block(_currentType,sender.value);
    }
    switch (self.currentType) {
        case ZengQiangActionTypeBaoGuangDu:
            baoGuangDuCurrentValue = sender.value;
            break;
        case ZengQiangActionTypeBaoHeDu:
            baoHeDuCurrentValue = sender.value;
            break;
        case ZengQiangActionTypeLiangDu:
            liangDuDuCurrentValue = sender.value;
            break;
        case ZengQiangActionTypeDuiBiDu:
            duiBiDuCurrentValue = sender.value;
            break;
        default:
            break;
    }
}
- (IBAction)cancelBtnClick:(id)sender {
    if (self.block) {
        self.block(ZengQiangActionTypeCancel,MAXFLOAT);
    }
}

- (IBAction)doneBtnClick:(id)sender {
    if (self.block) {
        self.block(ZengQiangActionTypeDone,MAXFLOAT);
    }
}


-(void)setLiangDuSliderAndButton{
    self.currentType = ZengQiangActionTypeLiangDu;
    self.liangdu.selected = YES;
    self.baoHeDu.selected = NO;
    self.duibidu.selected = NO;
    self.baoguangdu.selected = NO;
    self.slider.maximumValue = 0.60;
    self.slider.minimumValue = -0.60;
    self.slider.value = liangDuDuCurrentValue;
}

-(void)setDuiBiDuSliderAndButton{
    self.currentType = ZengQiangActionTypeDuiBiDu;
    self.liangdu.selected = NO;
    self.baoHeDu.selected = NO;
    self.duibidu.selected = YES;
    self.baoguangdu.selected = NO;
    self.slider.maximumValue = 4.0;
    self.slider.minimumValue = 0.0;
    self.slider.value = duiBiDuCurrentValue;
    
}

-(void)setBoaHeDuSliderAndButton{
    self.currentType = ZengQiangActionTypeBaoHeDu;
    self.liangdu.selected = NO;
    self.baoHeDu.selected = YES;
    self.duibidu.selected = NO;
    self.baoguangdu.selected = NO;
    self.slider.maximumValue = 2.0;
    self.slider.minimumValue = -0.0;
    self.slider.value = baoHeDuCurrentValue;
    
}

-(void)setBaoGuangDuSliderAndButton{
    self.currentType = ZengQiangActionTypeBaoGuangDu;
    self.liangdu.selected = NO;
    self.baoHeDu.selected = NO;
    self.duibidu.selected = NO;
    self.baoguangdu.selected = YES;
    self.slider.maximumValue = 3;
    self.slider.minimumValue = -3;
    self.slider.value = baoGuangDuCurrentValue;
    
}

-(void)setButton:(UIButton * ) button withTitle:(NSString *)title{
    [button setTitleColor:[UIColor colorWithHexString:@"#5C6064"] forState:(UIControlStateNormal)];
    [button setTitle:title forState:(UIControlStateNormal)];
    [button setTitleColor:[UIColor colorWithHexString:@"#5A92FC"] forState:(UIControlStateSelected)];
    [button LZSetbuttonType:(LZCategoryTypeBottom)];
}








@end
