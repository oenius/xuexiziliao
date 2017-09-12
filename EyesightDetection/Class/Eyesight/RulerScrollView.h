//
//  RulerScrollView.h
//  numberChoose
//
//  Created by 何少博 on 16/9/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DISTANCELEFTANDRIGHT 0.f // 标尺左右距离
#define DISTANCEVALUE self.rulerWidth/7//50.f // 每隔刻度实际长度8个点
#define DISTANCETOPANDBOTTOM 3.f // 标尺上下距离

@interface RulerScrollView : UIScrollView

@property (nonatomic,strong) NSArray *numberArray;

@property (nonatomic,strong) NSMutableArray *offsetArray;

@property (nonatomic,assign) NSUInteger rulerHeight;

@property (nonatomic,assign) NSUInteger rulerWidth;

@property (nonatomic,assign) CGFloat rulerValue;

@property (nonatomic,assign) CGFloat distanceValue;

- (void)drawRuler;

@end
