//
//  SNTipViewController.h
//  MindMap
//
//  Created by 何少博 on 2017/8/17.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNBaseViewController.h"


@interface SNTipViewController : SNBaseViewController

@property (copy, nonatomic) void(^tipImageCallBack)(UIImage * tipImage) ;

@end
