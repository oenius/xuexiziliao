//
//  ThemeContentView.h
//  InstaMessage
//
//  Created by 何少博 on 16/7/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustonCollectionViewCell.h"

@protocol ThemeContentViewDelegate ;

@interface ThemeContentView : UIView

@property (strong,nonatomic) UICollectionView * editThemeCollectionView;
@property(nonatomic,weak) id<ThemeContentViewDelegate> delegate;

@end

@protocol ThemeContentViewDelegate  <NSObject>

-(void)themeContentView:(ThemeContentView*)themeContentView ChooseTheme:(ThemeItemModel*)model;
-(void)themeContentView:(ThemeContentView *)themeContentView SliderValueChange:(CGFloat)value;
@end