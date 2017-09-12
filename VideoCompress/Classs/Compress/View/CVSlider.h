//
//  CVSlider.h
//  VideoCompress
//
//  Created by 何少博 on 17/4/13.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CVSlider : UIControl

@property (nonatomic,assign) CGFloat sliderMaxValue;//default 1.0

@property (nonatomic,assign) CGFloat sliderMinValue;//default 0.0

@property (nonatomic,assign) CGFloat maxValue;

@property (nonatomic,assign) CGFloat minValue;

@property (nonatomic,strong) UIImage * image;

@end
