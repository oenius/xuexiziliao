//
//  ColorPickerView.m
//  LEDBanner
//
//  Created by 何少博 on 16/6/29.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "ColorPickerView.h"

#import "HRColorPickerView.h"
#import "HRColorMapView.h"
#import "HRBrightnessSlider.h"
#import "UIColor+x.h"
@interface ColorPickerView ()


@property (nonatomic,strong) HRColorPickerView * colorPickerView;

@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *colorView;

@end

@implementation ColorPickerView
{
    id <ColorPickerViewDelegate> __weak delegate;
    HRColorPickerView *colorPickerView;
    UIColor *_color;
    BOOL _fullColor;
}

@synthesize delegate;

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
-(void)awakeFromNib{
    self.colorView.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 15;
    self.contentView.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    colorPickerView.frame = (CGRect) {.origin = CGPointZero, .size = self.colorView.frame.size};
    [self.doneBtn setTitle:NSLocalizedString(@"common.Done", @"Done") forState:UIControlStateNormal];
    [self.cancelBtn setTitle:NSLocalizedString(@"common.Cancel", @"Cancel") forState:UIControlStateNormal];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    colorPickerView = [[HRColorPickerView alloc] init];
    _color = self.defaultColor;
    colorPickerView.color = _color;
    
    HRColorMapView *colorMapView = [[HRColorMapView alloc] init];
    colorMapView.saturationUpperLimit = @1;
    colorMapView.tileSize = @1;
    [colorPickerView addSubview:colorMapView];
    colorPickerView.colorMapView = colorMapView;
    
    HRBrightnessSlider *slider = [[HRBrightnessSlider alloc] init];
    slider.brightnessLowerLimit = @0;
    [colorPickerView addSubview:slider];
    colorPickerView.brightnessSlider = slider;
    [self.colorView addSubview:colorPickerView];
    colorPickerView.frame = (CGRect) {.origin = CGPointZero, .size = self.colorView.frame.size};
    [colorPickerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
}

- (IBAction)onChooseColorBtnClick:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate setSelectedColor:colorPickerView.color];
    }
    [self removeFromSuperview];
}
- (IBAction)onCancelBtnClick:(UIButton *)sender {
    [self removeFromSuperview];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
