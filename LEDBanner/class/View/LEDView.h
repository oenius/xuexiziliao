//
//  HSLedView.h
//  LED_MySelf
//
//  Created by Mac_H on 16/6/22.
//  Copyright © 2016年 何少博. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "HSScanStr.h"


@interface LEDView : UIView


@property (nonatomic,assign)NSShowModel showModel;
@property (nonatomic,assign)NSDotModel dotModel;
@property (nonatomic,strong)UIColor * offColor;
@property (nonatomic,strong)UIColor * fontColor;

/**
 *  将子控件分组返回
 */
-(NSMutableArray*)getLEDViewSubViews;
@end
