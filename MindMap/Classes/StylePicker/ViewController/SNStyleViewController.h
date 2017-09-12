//
//  SNStyleViewController.h
//  MindMap
//
//  Created by 何少博 on 2017/8/22.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNBaseViewController.h"
@interface SNStyleViewController : SNBaseViewController

@property (copy, nonatomic) void(^styleCallBack)(Class styleClass);

@end
