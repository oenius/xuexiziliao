//
//  TextContentView.h
//  InstaMessage
//
//  Created by 何少博 on 16/7/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "He_enum.h"

@protocol TextContentViewDelegate ;

@interface TextContentView : UIView

@property (nonatomic,weak) id<TextContentViewDelegate> delegate;

-(BOOL)isHiddenBannerView;
@end

@protocol TextContentViewDelegate <NSObject>

-(void)textContentView:(TextContentView *)textContentView fontSettingCellClick:(TextActionTag)tag;
-(void)textContentView:(TextContentView *)textContentView lineSpaceValueChange:(CGFloat)value;
-(void)textContentView:(TextContentView *)textContentView fontSizeValueChange:(CGFloat)value;
-(void)textContentView:(TextContentView *)textContentView textAlphaValueChange:(CGFloat)value;
-(void)textContentView:(TextContentView *)textContentView charSpaceValueChange:(CGFloat)value;



@end
