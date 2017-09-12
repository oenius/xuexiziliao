//
//  EditViewController+Theme.m
//  InstaMessage
//
//  Created by 何少博 on 16/8/1.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "EditViewController+Theme.h"
#import "NPCommonConfig.h"
@implementation EditViewController (Theme)
-(void)initThemeContentView{
    self.themeContentView = [[ThemeContentView alloc]initWithFrame:self.editOptionsBackGroundView.bounds];
    self.themeContentView.delegate = self;
    self.themeContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.editOptionsBackGroundView addSubview:self.themeContentView];
    
}

#pragma mark - ThemeContentViewDelegate

-(void)themeContentView:(ThemeContentView *)themeContentView ChooseTheme:(ThemeItemModel *)model{
    
    if ([model.thumbImageName isEqualToString:@"AD_147.png"]) {
        [self addQuanPingAD];
        return;
    }
    
    NSString * path = [[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"%@",model.imageName] ofType:nil];
    self.frontImageView.image = [UIImage imageWithContentsOfFile:path];
    self.currentThemeModel = model;
    if ([model.photoEnabled isEqualToString:@"YES"]) {
        self.photoEnabled = YES;
        if (!self.blackGroundImageViewTempImage) {
            NSString * path = [[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"%@",model.bottomImage] ofType:nil];
            self.blackgroundImageView.image = [UIImage imageWithContentsOfFile:path];
        }
    }
    else{
        self.photoEnabled = NO;
    }

    self.blackgroundImageView.transform = self.blackGroundImageViewOldTransform;
    self.blackgroundImageView.frame = self.blackGroundImageViewOldFrame;
}
-(void)themeContentView:(ThemeContentView *)themeContentView SliderValueChange:(CGFloat)value{
    self.frontImageView.alpha = value;
}

-(void)addQuanPingAD{
    if ([[NPCommonConfig shareInstance] shouldShowAdvertise]) {
        [[NPCommonConfig shareInstance] showFullScreenAdORNativeAdForController:self];
    }
}
@end
