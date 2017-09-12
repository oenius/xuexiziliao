//
//  MEEqualizerAdjustSlider.h
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MEEqualizerAdjustSlider : UIControl

@property (assign,nonatomic)CGFloat maximumValue ;

@property (assign,nonatomic)CGFloat minimumValue;

@property (assign,nonatomic)CGFloat value;

@property (strong,nonatomic) UILabel * bottomLabel;

@end
