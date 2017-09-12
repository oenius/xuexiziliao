//
//  LEDShowViewController.h
//  LED_MySelf
//
//  Created by Mac_H on 16/6/22.
//  Copyright © 2016年 何少博. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEDView.h"
#import "LEDViewSecond.h"
#import "HSScanStr.h"


@interface LEDShowViewController : UIViewController
@property (nonatomic,copy)   NSString * showString;
@property (nonatomic,assign) NSShowModel  showModel;
@property (nonatomic,assign) NSDotModel dotModel;
@property (nonatomic,strong) UIFont * font;
@property (nonatomic,strong) UIColor * offColor;
@property (nonatomic,strong) UIColor * onColor;
@property (nonatomic,assign) BOOL isMulticolour;
@property (nonatomic,assign) CGFloat ledSpeed;
@property (nonatomic,assign) CGFloat ledFrequency;
@property (nonatomic,assign) BOOL ledIsFilcker;
@property (nonatomic,assign) BOOL ledDirection;//right->YES,left->NO

@end
