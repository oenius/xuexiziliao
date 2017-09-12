//
//  LCMultipleStateButton.h
//  LightCamera
//
//  Created by 何少博 on 16/12/12.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCMultipleStateButton : UIButton

@property (nonatomic,assign) UIInterfaceOrientation orientation;

@property (nonatomic,assign) NSArray<NSString*> * stateLabels;

@property  (nonatomic,assign) NSInteger state_;

@property (nonatomic,strong) IBInspectable NSString *semicolonSeparatedStateLabels;

@property (nonatomic,assign) IBInspectable NSInteger selectedState;



@end
