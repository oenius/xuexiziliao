//
//  CustomTextView.h
//  InstaMessage
//
//  Created by 何少博 on 16/8/5.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "YYTextView.h"

#define deleteButtomTag 100
#define doneButtomTag 200
#define changeFrameButtomTag 300

@protocol CustomTextViewDelegate ;

@interface CustomTextView : YYTextView
/**
 *  是否被旋转或缩放
 */
@property (assign,nonatomic) BOOL beiScaAndRot;
@property (assign,nonatomic) BOOL isCanMove;
@property (weak,nonatomic) UIButton * delelBtn;
@property (weak,nonatomic) UIButton * doneBtn;
@property (weak,nonatomic) UIButton * frameBtn;
@property (weak,nonatomic) CAShapeLayer * border;

@property (weak,nonatomic) id<CustomTextViewDelegate> customDelegate;


@end

@protocol CustomTextViewDelegate <NSObject>

-(void)returnCurrentCustomTextView:(CustomTextView *)customTextView;

@end