//
//  TextUnderLineStyleView.h
//  InstaMessage
//
//  Created by 何少博 on 16/8/3.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextUnderLineStyleViewDelegate;

@interface TextUnderLineStyleView : UIView

@property (nonatomic,weak) id<TextUnderLineStyleViewDelegate> delegate;

@end

@protocol TextUnderLineStyleViewDelegate <NSObject>

-(void)textUnderLineStyleView:(TextUnderLineStyleView*)textUnderLineStyleView chooseUnderlineStyle:(NSUnderlineStyle)underlineStyle;
-(void)textUnderLineStyleViewCancelButtonClick:(TextUnderLineStyleView*)textUnderLineStyleView;

@end