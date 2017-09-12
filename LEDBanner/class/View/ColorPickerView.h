//
//  ColorPickerView.h
//  LEDBanner
//
//  Created by 何少博 on 16/6/29.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ColorPickerViewDelegate
- (void)setSelectedColor:(UIColor *)color;
@end

@interface ColorPickerView : UIView

@property (nonatomic,weak) id <ColorPickerViewDelegate> delegate;
@property (nonatomic,strong)UIColor * defaultColor;
@end
