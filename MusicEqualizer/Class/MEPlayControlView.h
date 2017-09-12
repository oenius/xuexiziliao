//
//  MEPlayControlView.h
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/9.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LeftContenViewTapBlock)(BOOL isTap);

@interface MEPlayControlView : UIView

-(void)viewTapCallBack:(LeftContenViewTapBlock) block;

-(void)reset;

@end
