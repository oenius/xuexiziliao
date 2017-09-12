//
//  IDDaYanView.h
//  IDPhoto
//
//  Created by 何少博 on 17/4/24.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN CGFloat const kDaYanViewHeight;
UIKIT_EXTERN CGFloat const kDefaultRadius;
typedef enum : NSUInteger {
    DaYanViewActionTypeZiDongValueChanged,
    DaYanViewActionTypeShouDongValueChanged,
    DaYanViewActionTypeDone,
    DaYanViewActionTypeCancel,
    DaYanViewActionTypeTouchCancel,
    DaYanViewActionTypeTouchDown,
} DaYanViewActionType;

typedef void(^DaYanViewActionBlock)(DaYanViewActionType const actionType,CGFloat value);

@interface IDDaYanView : UIView

@property (nonatomic,assign) BOOL isCanZiDong;

-(instancetype)initWithAction:(DaYanViewActionBlock)block;


@end
