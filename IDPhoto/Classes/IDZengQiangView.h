//
//  IDZengQiangView.h
//  IDPhoto
//
//  Created by 何少博 on 17/4/24.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
UIKIT_EXTERN CGFloat const kZengQiangViewHeight;

typedef enum : NSUInteger {
    ZengQiangActionTypeCancel,
    ZengQiangActionTypeDone,
    ZengQiangActionTypeBaoHeDu,
    ZengQiangActionTypeLiangDu,
    ZengQiangActionTypeDuiBiDu,
    ZengQiangActionTypeBaoGuangDu,
} ZengQiangActionType;

typedef void(^ZengQiangActionBlock)(ZengQiangActionType const actionType ,CGFloat value);


@interface IDZengQiangView : UIView

-(instancetype)initWithAction:(ZengQiangActionBlock) block ;

@end
