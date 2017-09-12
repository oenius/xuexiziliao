//
//  IDShouLianView.h
//  IDPhoto
//
//  Created by 何少博 on 17/4/24.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
UIKIT_EXTERN CGFloat const kShouLianViewHeight;

typedef enum : NSUInteger {
    ShouLianViewActionTypeZiDongValueChanged,
    ShouLianViewActionTypeShouDongValueChanged,
    ShouLianViewActionTypeDone,
    ShouLianViewActionTypeCancel,
} ShouLianViewActionType;

typedef void(^ShouLianViewActionBlock)(ShouLianViewActionType const actionType,CGFloat value);

@interface IDShouLianView : UIView

-(instancetype)initWithAction:(ShouLianViewActionBlock)block;

@end
