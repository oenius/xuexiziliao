//
//  IDDaYanView.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/24.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDDaYanView.h"
#import "UIButton+LZCategory.h"
CGFloat const kDaYanViewHeight = 130;
CGFloat const kDefaultRadius = 25;

@interface IDDaYanView (){
    CGFloat ziDongSliderValue;
    CGFloat shouDongSliderValue;
}

@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;

@property (weak, nonatomic) IBOutlet UIButton *doneBnt;

@property (weak, nonatomic) IBOutlet UIButton *shoudongBtn;

@property (weak, nonatomic) IBOutlet UIButton *zidongBtn;

@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (copy,nonatomic) DaYanViewActionBlock block;

@property (assign,nonatomic) DaYanViewActionType currentType;

@end


@implementation IDDaYanView


-(instancetype)initWithAction:(DaYanViewActionBlock)block{
    IDDaYanView * view = [[NSBundle mainBundle] loadNibNamed:@"IDDaYanView" owner:nil options:nil].firstObject;
    if (view) {
        self = view;
        self.block = block;
        self.currentType = DaYanViewActionTypeZiDongValueChanged;
        ziDongSliderValue = 0;
        shouDongSliderValue = kDefaultRadius;
        self.slider.maximumValue = 1;
        self.slider.minimumValue = -1;
        self.slider.value = 0;
    }
    return self;
}


-(void)awakeFromNib{
    [super awakeFromNib];
    [self.zidongBtn setTitleColor:[UIColor colorWithHexString:@"#5C6064"] forState:(UIControlStateNormal)];
    [self.zidongBtn setTitle:[IDConst instance].Automatic forState:(UIControlStateNormal)];
    [self.zidongBtn setTitleColor:[UIColor colorWithHexString:@"#5A92FC"] forState:(UIControlStateSelected)];
    [self.shoudongBtn setTitleColor:[UIColor colorWithHexString:@"#5C6064"] forState:(UIControlStateNormal)];
    [self.shoudongBtn setTitle:[IDConst instance].Manual forState:(UIControlStateNormal)];
    [self.shoudongBtn setTitleColor:[UIColor colorWithHexString:@"#5A92FC"] forState:(UIControlStateSelected)];
    [self.zidongBtn LZSetbuttonType:(LZCategoryTypeBottom)];
    [self.shoudongBtn LZSetbuttonType:(LZCategoryTypeBottom)];
    [self.slider defaultUI];
}
-(void)setIsCanZiDong:(BOOL)isCanZiDong{
    _isCanZiDong = isCanZiDong;
    [self canZiDong:_isCanZiDong];
}

-(void)canZiDong:(BOOL)isCan{
    if (isCan == YES) {
        self.zidongBtn.selected = YES;
        self.shoudongBtn.selected = NO;
        self.currentType =DaYanViewActionTypeZiDongValueChanged;
        [self zidongBtnClick:self.zidongBtn];
    }
    else{
        self.zidongBtn.selected = NO;
        self.zidongBtn.enabled = NO;
        self.shoudongBtn.selected = YES;
        self.currentType =DaYanViewActionTypeShouDongValueChanged;
        [self sliderTouchDown];
        [self shoudongBtnClick:self.shoudongBtn];
        [self sliderTouchCancel];
    }
}

- (IBAction)doneBtnClick:(id)sender {
    if (self.block) {
        self.block(DaYanViewActionTypeDone,_slider.value);
    }
}

- (IBAction)shoudongBtnClick:(id)sender {
    
    [self setShouDongSliderAndButton];
    self.currentType = DaYanViewActionTypeShouDongValueChanged;
    if (self.block) {
        self.block(DaYanViewActionTypeShouDongValueChanged,_slider.value);
    }
}

- (IBAction)cancleBtnClick:(id)sender {
    if (self.block) {
        self.block(DaYanViewActionTypeCancel,_slider.value);
    }
}

- (IBAction)zidongBtnClick:(id)sender {
    
    [self setZiDongSliderAndButton];
    self.currentType = DaYanViewActionTypeZiDongValueChanged;
    if (self.block) {
        self.block(DaYanViewActionTypeZiDongValueChanged,_slider.value);
    }
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    if (self.block) {
        self.block(_currentType,sender.value);
    }
    if (_currentType == DaYanViewActionTypeZiDongValueChanged) {
        ziDongSliderValue = sender.value;
    }else{
        shouDongSliderValue = sender.value;
    }
}

-(IBAction)sliderTouchDown{
    if (self.block) {
        self.block(DaYanViewActionTypeTouchDown,shouDongSliderValue);
    }
}

-(IBAction)sliderTouchCancel{
    if (self.block) {
        self.block(DaYanViewActionTypeTouchCancel,shouDongSliderValue);
    }
}


-(void)setZiDongSliderAndButton{
    self.slider.maximumValue = 1;
    self.slider.minimumValue = -1;
    self.slider.value = ziDongSliderValue;
    self.shoudongBtn.selected = NO;
    self.zidongBtn.selected = YES;
}
-(void)setShouDongSliderAndButton{
    self.slider.maximumValue = 50;
    self.slider.minimumValue = 10;
    self.slider.value = shouDongSliderValue;
    self.shoudongBtn.selected = YES;
    self.zidongBtn.selected = NO;
}



@end
