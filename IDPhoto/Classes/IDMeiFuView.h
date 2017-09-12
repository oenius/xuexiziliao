//
//  IDMeiFuView.h
//  IDPhoto
//
//  Created by 何少博 on 17/4/25.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN CGFloat const kMeiFuViewHeight;

typedef enum : NSUInteger {
    MeiFuActionTypeValueChanged,
    MeiFuActionTypeCancel,
    MeiFuActionTypeDone,
} MeiFuActionType;

typedef void(^MeiFuActionBlock)(MeiFuActionType const type,CGFloat value);

@interface IDMeiFuView : UIView

-(instancetype)initWithAction:(MeiFuActionBlock)block;

-(void)setDefaultValue:(CGFloat) value;

@end
