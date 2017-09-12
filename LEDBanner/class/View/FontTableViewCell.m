//
//  FontTableViewCell.m
//  LEDBanner
//
//  Created by 何少博 on 16/6/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "FontTableViewCell.h"
//#import "FontViewViewController.h"
#import "UIView+x.h"
#import "ColorPickerView.h"
#import "FontPickerView.h"
#import "UIColor+x.h"
@interface FontTableViewCell ()<ColorPickerViewDelegate,FontPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *redBtn;
@property (weak, nonatomic) IBOutlet UIButton *purpleBtn;
@property (weak, nonatomic) IBOutlet UIButton *blueBtn;
@property (weak, nonatomic) IBOutlet UIButton *multicolourBtn;
@property (weak, nonatomic) IBOutlet UIButton *customBtn;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@property (assign,nonatomic) BOOL isMuliticolour;
  
@property (weak, nonatomic) IBOutlet UIButton *fontBtn;


@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *zitiLabel;
@property (weak, nonatomic) IBOutlet UILabel *yanseLabel;
@property (weak, nonatomic) IBOutlet UILabel *zidingyiLable;



@end

@implementation FontTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:kSaveColorData];
    NSMutableDictionary * saveColorDic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    UIColor * customBtnBackColor = [saveColorDic objectForKey:kCustomBtnFontColor];

    self.nameLabel.textColor = color_ffffff;
    self.zitiLabel.textColor = color_666666;
    self.yanseLabel.textColor  = color_666666;
    self.zidingyiLable.textColor  = color_666666;
    [self.fontBtn setTitleColor:color_40d0d9 forState:UIControlStateNormal];
    self.lineView.backgroundColor = color_40d0d9;
    self.backgroundColor = color_131a20;
    self.customBtn.backgroundColor = customBtnBackColor;
    NSString * title = [[NSUserDefaults standardUserDefaults]objectForKey:kTextFontName];
    [self.fontBtn setTitle:title forState:UIControlStateNormal];
    
    NSString * namelabeltext = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Font", @"Font"),NSLocalizedString(@"Settings", @"Settings")];
    self.nameLabel.text = namelabeltext;
    self.zitiLabel.text = NSLocalizedString(@"Font", @"Font");
    self.yanseLabel.text = NSLocalizedString(@"Color", @"Color");
    self.zidingyiLable.text = NSLocalizedString(@"Customize", @"Customize");

    NSNotificationCenter * noticenter = [NSNotificationCenter defaultCenter];
    [noticenter addObserver:self selector:@selector(setSelecedBtn) name:kSelecedBtnFont object:nil];
    
    [self setBtnCornerRadius:_multicolourBtn];
    [self setBtnCornerRadius:_redBtn];
    [self setBtnCornerRadius:_purpleBtn];
    [self setBtnCornerRadius:_blueBtn];
    [self setBtnCornerRadius:_customBtn];

    
}
-(void)setBtnCornerRadius:(UIButton*)sender{
    sender.layer.cornerRadius = 5;
    sender.layer.masksToBounds = YES;
}
-(void)setSelecedBtn{
    NSSelecdBtn selecedBtn = [[NSUserDefaults standardUserDefaults]integerForKey:kSelecedBtnFont];
    switch (selecedBtn) {
        case NSSelecdNone:
            [self setColorButtonImageWithRedBtn:NO andGreenBtn:NO andBlueBtn:NO andMulticourBtn:NO andCustomBtn:NO];
            break;
        case NSSelecdRedBtn:
            [self setColorButtonImageWithRedBtn:YES andGreenBtn:NO andBlueBtn:NO andMulticourBtn:NO andCustomBtn:NO];
            break;
        case NSSelecdPurpleBtn:
            [self setColorButtonImageWithRedBtn:NO andGreenBtn:YES andBlueBtn:NO andMulticourBtn:NO andCustomBtn:NO];
            break;
        case NSSelecdBlueBtn:
            [self setColorButtonImageWithRedBtn:NO andGreenBtn:NO andBlueBtn:YES andMulticourBtn:NO andCustomBtn:NO];
            break;
        case NSSelecdCustomBtn:
            [self setColorButtonImageWithRedBtn:NO andGreenBtn:NO andBlueBtn:NO andMulticourBtn:NO andCustomBtn:YES];
            break;
        case NSSelecdMulticolourBtn:
            [self setColorButtonImageWithRedBtn:NO andGreenBtn:NO andBlueBtn:NO andMulticourBtn:YES andCustomBtn:NO];
            break;
        default:
            [self setColorButtonImageWithRedBtn:NO andGreenBtn:NO andBlueBtn:NO andMulticourBtn:NO andCustomBtn:NO];
            break;
    }
}
-(void)layoutSubviews{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self.redBtn setImage:kongImage forState:UIControlStateNormal];
        CGFloat rimgW = self.redBtn.imageView.bounds.size.width;
        self.redBtn.imageEdgeInsets = UIEdgeInsetsMake(
                                                       self.redBtn.bounds.size.height,
                                                       self.redBtn.bounds.size.width,
                                                       rimgW,
                                                       rimgW);
        [self.purpleBtn setImage:kongImage forState:UIControlStateNormal];
        CGFloat gimgW = self.purpleBtn.imageView.bounds.size.width;
        self.purpleBtn.imageEdgeInsets = UIEdgeInsetsMake(
                                                         self.purpleBtn.bounds.size.height,
                                                         self.purpleBtn.bounds.size.width,
                                                         gimgW,
                                                         gimgW);
        [self.blueBtn setImage:kongImage forState:UIControlStateNormal];
        CGFloat bimgW = self.blueBtn.imageView.bounds.size.width;
        self.blueBtn.imageEdgeInsets = UIEdgeInsetsMake(
                                                        self.blueBtn.bounds.size.height,
                                                        self.blueBtn.bounds.size.width,
                                                        bimgW,
                                                        bimgW);
        [self.multicolourBtn setImage:kongImage forState:UIControlStateNormal];
        CGFloat mimgW = self.multicolourBtn.imageView.bounds.size.width;
        self.multicolourBtn.imageEdgeInsets = UIEdgeInsetsMake(
                                                               self.multicolourBtn.bounds.size.height,
                                                               self.multicolourBtn.bounds.size.width,
                                                               mimgW,
                                                               mimgW);
        [self.customBtn setImage:kongImage forState:UIControlStateNormal];
        CGFloat cimgW = self.customBtn.imageView.bounds.size.width;
        self.customBtn.imageEdgeInsets = UIEdgeInsetsMake(
                                                          self.customBtn.bounds.size.height,
                                                          self.customBtn.bounds.size.width,
                                                          cimgW,
                                                          cimgW);
    });
}
- (void)bounceTargetView:(UIView *)targetView {
    targetView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.3
          initialSpringVelocity:5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         targetView.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];
}

//设置字体
- (IBAction)onFontSetClick:(UIButton *)sender {

    FontPickerView * fontView = [FontPickerView viewWithNib:@"FontPickerView" owner:nil];
    fontView.delegate = self;
    fontView.preViewString = [NSString stringWithFormat:@"%@",@"abcABC123"];
    fontView.frame = [UIScreen mainScreen].bounds;
    UIViewController * vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [vc.view addSubview:fontView];
}
//默认提供颜色的设置
- (IBAction)onDefaultChooseColorClick:(UIButton *)sender {
    //tag = 1000 --红 tag= 2000 紫色 tag = 3000 蓝
    UIColor * color;
    switch (sender.tag) {
        case 1000:{
            color = [UIColor redColor];
            [self setColorButtonImageWithRedBtn:YES andGreenBtn:NO andBlueBtn:NO andMulticourBtn:NO andCustomBtn:NO];
        }
            break;
        case 2000:{
            color = [UIColor purpleColor];
            [self setColorButtonImageWithRedBtn:NO andGreenBtn:YES andBlueBtn:NO andMulticourBtn:NO andCustomBtn:NO];
        }
            break;
        case 3000:{
            color = [UIColor blueColor];
            [self setColorButtonImageWithRedBtn:NO andGreenBtn:NO andBlueBtn:YES andMulticourBtn:NO andCustomBtn:NO];
        }
            break;
        default:
            break;
    }
    if ([self.delegate respondsToSelector:@selector(setFontDefaultChooseColorClick:)]) {
        [self.delegate setFontDefaultChooseColorClick:color];
    }
    [self bounceTargetView:sender];
}
//多彩颜色的设置
- (IBAction)onMulticolourClick:(UIButton *)sender {
    [self setColorButtonImageWithRedBtn:NO andGreenBtn:NO andBlueBtn:NO andMulticourBtn:YES andCustomBtn:NO];
    [self bounceTargetView:sender];
}

- (IBAction)customColorBtnClick:(UIButton *)sender {
    
    ColorPickerView * colorPicker = [ColorPickerView viewWithNib:@"ColorPickerView" owner:nil];
    colorPicker.delegate = self;
    colorPicker.defaultColor = self.customBtn.backgroundColor;
    colorPicker.frame = [UIScreen mainScreen].bounds;
    UIViewController * vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [vc.view addSubview:colorPicker];
    
}

-(void)setColorButtonImageWithRedBtn:(BOOL)RedBtn andGreenBtn:(BOOL)GreenBtn andBlueBtn:(BOOL)BlueBtn andMulticourBtn:(BOOL)MulticourBtn andCustomBtn:(BOOL)CustomBtn{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    self.isMuliticolour = NO;
    if (RedBtn) {
        [self.redBtn setImage:checkImage forState:UIControlStateNormal];
        [userDefault setInteger:NSSelecdRedBtn forKey:kSelecedBtnFont];
    }else{
        [self.redBtn setImage:kongImage forState:UIControlStateNormal];
    }
    if (GreenBtn) {
        [self.purpleBtn setImage:checkImage forState:UIControlStateNormal];
        [userDefault setInteger:NSSelecdPurpleBtn forKey:kSelecedBtnFont];
    }else{
        [self.purpleBtn setImage:kongImage forState:UIControlStateNormal];
    }
    if (BlueBtn) {
        [self.blueBtn setImage:checkImage forState:UIControlStateNormal];
        [userDefault setInteger:NSSelecdBlueBtn forKey:kSelecedBtnFont];
    }else{
        [self.blueBtn setImage:kongImage forState:UIControlStateNormal];
    }
    if (MulticourBtn) {
        self.isMuliticolour = YES;
        [self.multicolourBtn setImage:checkImage forState:UIControlStateNormal];
        [userDefault setInteger:NSSelecdMulticolourBtn forKey:kSelecedBtnFont];
    }else{;
        [self.multicolourBtn setImage:kongImage forState:UIControlStateNormal];
    }
    if (CustomBtn) {
        [self.customBtn setImage:checkImage forState:UIControlStateNormal];
        [userDefault setInteger:NSSelecdCustomBtn forKey:kSelecedBtnFont];
    }else{
        [self.customBtn setImage:kongImage forState:UIControlStateNormal];
    }
    if ([self.delegate respondsToSelector:@selector(setMulticolourClick:)]) {
        [self.delegate setMulticolourClick:self.isMuliticolour];
    }
    [userDefault synchronize];
}

- (IBAction)adsBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(fontAdsBtnClick)]) {
        [self.delegate fontAdsBtnClick];
    }
}

//colorPicker 代理方法
- (void)setSelectedColor:(UIColor *)color {
    self.customBtn.backgroundColor = color;
    [self setColorButtonImageWithRedBtn:NO andGreenBtn:NO andBlueBtn:NO andMulticourBtn:NO andCustomBtn:YES];
    if ([self.delegate respondsToSelector:@selector(setFontCustomColorBtnClick:)]) {
        [self.delegate setFontCustomColorBtnClick:color];
    }
    [self bounceTargetView:self.customBtn];
}
//fontPicker代理
-(void)setSelectFontName:(NSString *)fontName{
    [self.fontBtn setTitle:fontName forState:UIControlStateNormal];
    if ([self.delegate respondsToSelector:@selector(setFontChoose:)]) {
        [self.delegate setFontChoose:fontName];
    }
    [self bounceTargetView:self.fontBtn];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
