//
//  IDBottomToolView.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/28.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDBottomToolView.h"
#import "UIButton+LZCategory.h"
CGFloat const kBottomToolViewHeight = 130;

@interface IDBottomToolView ()

@property (weak, nonatomic) IBOutlet UIView *circleView;

@property (weak, nonatomic) IBOutlet UIButton *kouTuBtn;
@property (weak, nonatomic) IBOutlet UIButton *eraserBtn;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *circleHeight;

@property (assign, nonatomic) CGFloat kouTuValue;
@property (assign, nonatomic) CGFloat eraserValue;

@property (assign,nonatomic) BottomToolAction currentAction;

@property (copy, nonatomic) BottomToolBlock block;

@end




@implementation IDBottomToolView

-(instancetype)initWithAction:(BottomToolBlock)block{
    IDBottomToolView * view = [[NSBundle mainBundle]loadNibNamed:@"IDBottomToolView" owner:nil options:nil].firstObject;
    if (view) {
        self = view;
        self.slider.maximumValue = 30;
        self.slider.minimumValue = 10;
        self.slider.value = 10;
        self.kouTuValue = 10;
        self.eraserValue = 5;
        self.currentAction = BottomToolActionKouTu;
        self.circleView.layer.masksToBounds = YES;
        self.circleHeight.constant = self.slider.value;
        self.circleView.layer.cornerRadius = self.slider.value/2;
        self.circleView.backgroundColor = [UIColor colorWithRed:255/255.0 green:240/255.0 blue:53/255.0 alpha:1.00];
        self.circleView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        self.circleView.layer.shadowOffset = CGSizeMake(0, 0);
        self.circleView.layer.shadowOpacity = 0.8;
        self.circleView.layer.shadowRadius = 3;
        
        self.block = block;
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self.slider defaultUI];
    self.kouTuBtn.selected = YES;
    
//    [self.kouTuBtn LZSetbuttonType:(LZCategoryTypeBottom)];
//    [self.kouTuBtn setTitle:[IDConst instance].Cutout forState:(UIControlStateNormal)];
//    self.kouTuBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
//    [self.kouTuBtn setTitleColor:[UIColor colorWithHexString:@"#fe709a"] forState:(UIControlStateNormal)];
//    [self.kouTuBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected)];
//    
//    [self.eraserBtn LZSetbuttonType:(LZCategoryTypeLeft)];
//    [self.eraserBtn setTitle:[IDConst instance].Eraser forState:(UIControlStateNormal)];
//    self.eraserBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
//    [self.eraserBtn setTitleColor:[UIColor colorWithHexString:@"#fe709a"] forState:(UIControlStateNormal)];
//    [self.eraserBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected)];
}

-(void)layoutSubviews{
    [super layoutSubviews];
}

- (IBAction)kouTuBtnclick:(id)sender {
    self.currentAction = BottomToolActionKouTu;
    self.kouTuBtn.selected = YES;
    self.eraserBtn.selected = NO;
    self.slider.maximumValue = 30;
    self.slider.minimumValue = 8;
    self.slider.value = self.kouTuValue;
    self.circleHeight.constant = self.kouTuValue;
    self.circleView.backgroundColor = [UIColor colorWithRed:255/255.0 green:240/255.0 blue:53/255.0 alpha:1.00];
    self.circleView.layer.cornerRadius = self.kouTuValue/2;
    if (self.block) {
        self.block(BottomToolActionKouTu,self.kouTuValue);
    }
    
}


- (IBAction)eraserBtn:(id)sender {
    self.eraserBtn.selected = YES;
    self.kouTuBtn.selected = NO;
    self.currentAction = BottomToolActionEraser;
    self.slider.maximumValue = 30;
    self.slider.minimumValue = 5;
    self.slider.value = self.eraserValue;
    
    self.circleView.backgroundColor = [UIColor blackColor];
    self.circleHeight.constant = self.eraserValue;
    self.circleView.layer.cornerRadius = self.eraserValue/2;
    if (self.block) {
        self.block(BottomToolActionEraser,self.eraserValue);
    }
    
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    if (_currentAction == BottomToolActionKouTu) {
        self.kouTuValue = sender.value;
    }
    else if(_currentAction == BottomToolActionEraser){
        self.eraserValue = sender.value;
    }
    if (self.block) {
        self.block(_currentAction,sender.value);
    }
    
    self.circleHeight.constant = sender.value;
    self.circleView.layer.cornerRadius = sender.value/2;
}


@end
