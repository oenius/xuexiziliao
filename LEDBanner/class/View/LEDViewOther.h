//
//  LEDViewOther.h
//  LEDBanner
//
//  Created by Mac_H on 16/7/14.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSScanStr.h"


@interface LEDViewOther : UIView
@property (nonatomic,strong)NSArray * dotArray;
@property (nonatomic,assign)NSDotModel dotModel;
@property (nonatomic,assign)BOOL isBackGroundView;
@property (nonatomic,assign)NSShowModel showModel;
@property (nonatomic,assign)int columns;
@property (nonatomic,assign)int rows;
@property (nonatomic,strong)UIColor * offColor;
@property (nonatomic,strong)UIColor * fontColor;
@end
