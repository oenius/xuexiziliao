//
//  IDMeiFuView.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/25.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDMeiFuView.h"

CGFloat const kMeiFuViewHeight = 130;


CGFloat const kMeiFuMaxValue = 2;
CGFloat const kMeiFuMinValue = -1;

@interface IDMeiFuView ()
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;

@property (copy, nonatomic) MeiFuActionBlock block;

@end



@implementation IDMeiFuView



-(instancetype)initWithAction:(MeiFuActionBlock)block;{
    
    IDMeiFuView * view = [[NSBundle mainBundle] loadNibNamed:@"IDMeiFuView" owner:nil options:nil].firstObject;
    if (view) {
        self = view;
        self.userInteractionEnabled = YES;
        self.block =  block;
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
}

-(void)didMoveToSuperview{
    [super didMoveToSuperview];
    self.slider.value = 0.5;
    [self sliderValueChange:self.slider];
}


-(void)setDefaultValue:(CGFloat)value{
    self.slider.value = value;
}
-(void)awakeFromNib{
    [super awakeFromNib];
    self.slider.maximumValue = kMeiFuMaxValue;
    self.slider.minimumValue = kMeiFuMinValue;
    [self.slider defaultUI];
}

- (IBAction)doneBtnClick:(id)sender {
    
    if (self.block) {
        self.block(MeiFuActionTypeDone,MAXFLOAT);
    }
}


- (IBAction)sliderValueChange:(UISlider *)sender {
    if (self.block) {
        self.block(MeiFuActionTypeValueChanged,sender.value);
    }
}


- (IBAction)cancelBtnClick:(id)sender {
    if (self.block) {
        self.block(MeiFuActionTypeCancel,MAXFLOAT);
    }
}



@end
