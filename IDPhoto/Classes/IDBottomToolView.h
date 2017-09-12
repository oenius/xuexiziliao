//
//  IDBottomToolView.h
//  IDPhoto
//
//  Created by 何少博 on 17/4/28.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum : NSUInteger {
    BottomToolActionKouTu,
    BottomToolActionEraser
} BottomToolAction;

typedef void(^BottomToolBlock)(BottomToolAction action ,CGFloat value);

UIKIT_EXTERN CGFloat const kBottomToolViewHeight;


@interface IDBottomToolView : UIView

-(instancetype)initWithAction:(BottomToolBlock) block;

@end
