//
//  LCLightModelChooseView.h
//  LightCamera
//
//  Created by 何少博 on 16/12/15.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum LightModel{
    
    kLightModelAuto = 0,
    kLightModelOne = 1,
    kLightModelTwo = 2,
    
} LightModel;

typedef void(^lightModelBlock)(LightModel model);

@interface LCLightModelChooseView : UIView

-(instancetype)initWithFrame:(CGRect)frame chooseBlock:(lightModelBlock) block;

@end
