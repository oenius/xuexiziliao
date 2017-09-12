//
//  DTProgressButton.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/31.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DTProgressStatuNone,
    DTProgressStatuLoading,
    DTProgressStatuDowning,
    DTProgressStatuSuccess,
    DTProgressStatuFailed,
} DTProgressStatu;


@interface DTProgressButton : UIButton

@property (nonatomic,assign) CGFloat progress;

@property (nonatomic,assign) DTProgressStatu statu;

-(void)addFailedAction:(SEL)action  target:(id) target;

@end
