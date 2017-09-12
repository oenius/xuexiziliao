//
//  MEEqualizerListViewController.h
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/5.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "BaseViewController.h"
@class MEEqualizer;

typedef void(^EQSelectBlock)(MEEqualizer * equalizer);

@interface MEEqualizerListViewController : BaseViewController

-(void)EQSelectedCallBack:(EQSelectBlock)block;

@end
