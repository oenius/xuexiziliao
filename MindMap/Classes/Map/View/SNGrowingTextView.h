//
//  SNGrowingTextView.h
//  MindMap
//
//  Created by 何少博 on 2017/8/8.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SNGrowingTextViewDirectionDwon,
    SNGrowingTextViewDirectionUp,
} SNGrowingTextViewDirection;


@interface SNGrowingTextView : UITextView

@property (copy, nonatomic) NSString * placeholder;
@property (nonatomic,assign) SNGrowingTextViewDirection growingDirection;
@property (nonatomic,strong) UIColor *placeholderColor;
@property (nonatomic,assign) BOOL autoGrowingWidth;
@property (nonatomic,assign) CGFloat minWidth;
@property (nonatomic,assign) CGFloat maxWidth;
@property (nonatomic,assign) NSInteger maxLine;

-(instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer;
-(void)loadComponent;
-(void)textChanged:(NSNotification *)noti;
@end
