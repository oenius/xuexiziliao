//
//  BannerTableViewCell.m
//  LEDBanner
//
//  Created by 何少博 on 16/6/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "BannerTableViewCell.h"
#import "UIView+x.h"
#import "ColorPickerView.h"
#import "UIColor+x.h"
#import "NPCommonConfig.h"

@interface BannerTableViewCell ()<ColorPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *redBtn;
@property (weak, nonatomic) IBOutlet UIButton *purpleBtn;
@property (weak, nonatomic) IBOutlet UIButton *blueBtn;
@property (weak, nonatomic) IBOutlet UIButton *customBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *xingzhuangSeg;

@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *qingxiduSeg;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *yanseLabel;
@property (weak, nonatomic) IBOutlet UILabel *zidingyiLabel;
@property (weak, nonatomic) IBOutlet UILabel *qingxiduLabel;
@property (weak, nonatomic) IBOutlet UILabel *xiangzhuangLabel;
@end

@implementation BannerTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = color_131a20;
    
    NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:kSaveColorData];
    NSMutableDictionary * saveColorDic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    UIColor * customBtnBackGroundColor = [saveColorDic objectForKey:kCustomBtnBannColor];

    self.nameLabel.textColor  = color_ffffff;
    self.yanseLabel.textColor  = color_666666;
    self.zidingyiLabel.textColor  = color_666666;
    self.qingxiduLabel.textColor = color_666666;
    self.xiangzhuangLabel.textColor = color_666666;
    self.customBtn.backgroundColor = customBtnBackGroundColor;
    self.lineView.backgroundColor = color_40d0d9;
    self.xingzhuangSeg.tintColor = color_40d0d9;
    self.qingxiduSeg.tintColor = color_40d0d9;
    UIImage *fangImage = [[UIImage imageNamed:@"fang"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *yuanIamge = [[UIImage imageNamed:@"yuan"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.xingzhuangSeg setImage:fangImage forSegmentAtIndex:0];
    [self.xingzhuangSeg setImage:yuanIamge forSegmentAtIndex:1];
    NSDotModel dotModel = [[NSUserDefaults standardUserDefaults]integerForKey:kDotModel];
    if (dotModel == NSDotModelSquare) {
        self.xingzhuangSeg.selectedSegmentIndex = 0;
    }else{
        self.xingzhuangSeg.selectedSegmentIndex = 1;
    }
    [self.qingxiduSeg setTitle:NSLocalizedString(@"Standard", @"Standard") forSegmentAtIndex:0];
    [self.qingxiduSeg setTitle:NSLocalizedString(@"High", @"High") forSegmentAtIndex:1];
    NSShowModel showModel = [[NSUserDefaults standardUserDefaults]integerForKey:kShowModel];
    if (showModel == NSShowModel32) {
        self.qingxiduSeg.selectedSegmentIndex = 0;
    }else{
        self.qingxiduSeg.selectedSegmentIndex = 1;
    }
    NSDictionary * attributes = @{
                                  UITextAttributeTextColor:color_ffffff,
                                  UITextAttributeFont:[UIFont systemFontOfSize:17]
                                  };
    [self.qingxiduSeg setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    NSString * namelabeltext = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"background", @"Background"),NSLocalizedString(@"Settings", @"Settings")];
    self.nameLabel.text = namelabeltext;
    self.yanseLabel.text = NSLocalizedString(@"Color", @"Color");
    self.zidingyiLabel.text = NSLocalizedString(@"Customize", @"Customize");
    self.xiangzhuangLabel.text = NSLocalizedString(@"Style", @"Style");
    self.qingxiduLabel.text = NSLocalizedString(@"Definition", @"Definition");

    NSNotificationCenter * noticenter = [NSNotificationCenter defaultCenter];
    [noticenter addObserver:self selector:@selector(setSelecedBtn) name:kSelecedBtnBanner object:nil];
    
    [self setBtnCornerRadius:_redBtn];
    [self setBtnCornerRadius:_purpleBtn];
    [self setBtnCornerRadius:_blueBtn];
    [self setBtnCornerRadius:_customBtn];

    
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

-(void)setBtnCornerRadius:(UIButton*)sender{
    sender.layer.cornerRadius = 5;
    sender.layer.masksToBounds = YES;
}
-(void)setSelecedBtn{
    NSSelecdBtn selecedBtn = [[NSUserDefaults standardUserDefaults]integerForKey:kSelecedBtnBanner];
    switch (selecedBtn) {
        case NSSelecdNone:
            [self setColorButtonImageWithRedBtn:NO andGreenBtn:NO andBlueBtn:NO andCustomBtn:NO ];
            break;
        case NSSelecdRedBtn:
            [self setColorButtonImageWithRedBtn:YES andGreenBtn:NO andBlueBtn:NO andCustomBtn:NO ];
            break;
        case NSSelecdPurpleBtn:
            [self setColorButtonImageWithRedBtn:NO andGreenBtn:YES andBlueBtn:NO andCustomBtn:NO ];
            break;
        case NSSelecdBlueBtn:
            [self setColorButtonImageWithRedBtn:NO andGreenBtn:NO andBlueBtn:YES andCustomBtn:NO ];
            break;
        case NSSelecdCustomBtn:
            [self setColorButtonImageWithRedBtn:NO andGreenBtn:NO andBlueBtn:NO andCustomBtn:YES];
            break;
        default:
            [self setColorButtonImageWithRedBtn:NO andGreenBtn:NO andBlueBtn:NO andCustomBtn:NO ];
            break;
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
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
        [self.customBtn setImage:kongImage forState:UIControlStateNormal];
        CGFloat cimgW = self.customBtn.imageView.bounds.size.width;
        self.customBtn.imageEdgeInsets = UIEdgeInsetsMake(
                                                          self.customBtn.bounds.size.height,
                                                          self.customBtn.bounds.size.width,
                                                          cimgW,
                                                          cimgW);
    });
    

     [self setSelecedBtn];
}

-(void)prepareForReuse{
    [super prepareForReuse];
}

//默认提供颜色的设置
- (IBAction)onDefaultChooseColorClick:(UIButton *)sender {
    //tag = 1000 --红 tag= 2000 绿 tag = 3000 蓝
    UIColor * color;
    switch (sender.tag) {
        case 1000:{
            color = [UIColor redColor];
            [self setColorButtonImageWithRedBtn:YES andGreenBtn:NO andBlueBtn:NO andCustomBtn:NO ];
        }
            break;
        case 2000:{
            color = [UIColor purpleColor];
            [self setColorButtonImageWithRedBtn:NO andGreenBtn:YES andBlueBtn:NO andCustomBtn:NO ];
        }
            break;
        case 3000:{
            color = [UIColor blueColor];
            [self setColorButtonImageWithRedBtn:NO andGreenBtn:NO andBlueBtn:YES andCustomBtn:NO ];
        }
            break;
        default:
            break;
    }
    if ([self.delegate respondsToSelector:@selector(setDefaultChooseColorClick:)]) {
        [self.delegate setDefaultChooseColorClick:color]; 
    }
    [self bounceTargetView:sender];
}
//形状选择
- (IBAction)xingzhuangChange:(UISegmentedControl *)sender {
    NSDotModel dotModel;
    switch (sender.selectedSegmentIndex) {
        case 0: dotModel = NSDotModelSquare; break;
        case 1: dotModel = NSDotModelCircle; break;
        default: dotModel = NSDotModelSquare; break;
    }
    if ([self.delegate respondsToSelector:@selector(setXingzhuangChange:)]) {
        [self.delegate setXingzhuangChange:dotModel];
    }
}
//清晰度选择
- (IBAction)qingxiduChange:(UISegmentedControl *)sender {
    NSShowModel showModel;
    switch (sender.selectedSegmentIndex) {
        case 0: showModel = NSShowModel32; break;
        case 1: showModel = NSShowModel64; break;
        default: showModel = NSShowModel32; break;
    }
    if ([self.delegate respondsToSelector:@selector(setQingxiduChange:)]) {
        [self.delegate setQingxiduChange:showModel];
    }
}
//-(BOOL)aboutPinglunJieSuo{
//    BOOL jiasuo = NO;
//    if (![NPCommonConfig shareInstance].isLiteApp) {
//        return NO;
//    }
//    BOOL pinglunCurr = [[NPCommonConfig shareInstance] isThisVersionRated];
//    BOOL pinglunHist = [[NPCommonConfig shareInstance] isAnyVersionRated];
//    if ((pinglunCurr == NO) && (pinglunHist == NO) ) {
//        BOOL isOnline = [[NPCommonConfig shareInstance] isCurrentVersionOnline];
//        if (isOnline) {
//            return YES;
//        }
//    }
//    return jiasuo;
//}

- (IBAction)onCustomColorClick:(UIButton *)sender {
    
        ColorPickerView * colorPicker = [ColorPickerView viewWithNib:@"ColorPickerView" owner:nil];
        colorPicker.delegate = self;
        colorPicker.defaultColor = self.customBtn.backgroundColor;
        colorPicker.frame = [UIScreen mainScreen].bounds;
        UIViewController * vc = [UIApplication sharedApplication].keyWindow.rootViewController;
        [vc.view addSubview:colorPicker];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (IBAction)adsBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(ADSBttonClick)]) {
        [self.delegate ADSBttonClick];
    }
}

-(void)setColorButtonImageWithRedBtn:(BOOL)RedBtn andGreenBtn:(BOOL)GreenBtn andBlueBtn:(BOOL)BlueBtn andCustomBtn:(BOOL)CustomBtn{
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    if (RedBtn) {
        [self.redBtn setImage:checkImage forState:UIControlStateNormal];
        [userDefault setInteger:NSSelecdRedBtn forKey:kSelecedBtnBanner];
    }else{
        [self.redBtn setImage:kongImage forState:UIControlStateNormal];
    }
    if (GreenBtn) {
        [self.purpleBtn setImage:checkImage forState:UIControlStateNormal];
        [userDefault setInteger:NSSelecdPurpleBtn forKey:kSelecedBtnBanner];
    }else{
        [self.purpleBtn setImage:kongImage forState:UIControlStateNormal];
    }
    if (BlueBtn) {
        [self.blueBtn setImage:checkImage forState:UIControlStateNormal];
        [userDefault setInteger:NSSelecdBlueBtn forKey:kSelecedBtnBanner];
    }else{
        [self.blueBtn setImage:kongImage forState:UIControlStateNormal];
    }
    if (CustomBtn) {
        [self.customBtn setImage:checkImage forState:UIControlStateNormal];
        [userDefault setInteger:NSSelecdCustomBtn forKey:kSelecedBtnBanner];
    }else{
        [self.customBtn setImage:kongImage forState:UIControlStateNormal];
    }
    [userDefault synchronize];
}
//颜色选择代理方法
- (void)setSelectedColor:(UIColor *)color {
    self.customBtn.backgroundColor = color;
    [self setColorButtonImageWithRedBtn:NO andGreenBtn:NO andBlueBtn:NO andCustomBtn:YES];
    if ([self.delegate respondsToSelector:@selector(setCustomColorClick:)]) {
        [self.delegate setCustomColorClick:color];
    }
    [self bounceTargetView:self.customBtn];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
