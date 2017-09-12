//
//  CIBottomToolView.h
//  CutoutImage
//
//  Created by 何少博 on 17/2/5.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CIBottomToolViewHightStateInteli,
    CIBottomToolViewHightStateEraser
} CIBottomToolViewHightState;

@interface CIBottomToolView : UIView

-(void)intelligentButtonAddTarget:(id)target action:(SEL)action;

-(void)eraserButtonButtonAddTarget:(id)target action:(SEL)action;

-(void)setLightState:(CIBottomToolViewHightState)state;

@end
