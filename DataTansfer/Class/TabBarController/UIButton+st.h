//
//  UIButton+st.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/17.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,TitlePosition) {
    TitlePositionLeft = 0,
    TitlePositionBottom,
};

@interface UIButton (st)
- (void)setTitlePosition:(TitlePosition)position;
@end
