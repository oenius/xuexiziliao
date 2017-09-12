//
//  ColorPickerView.h
//  ColorPicker
//
//  Created by Mac_H on 16/8/1.
//  Copyright © 2016年 何少博. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ColorPickerViewDelegate;

@interface ColorPickerView : UIView

@property (nonatomic,weak) id<ColorPickerViewDelegate> delegate;

@end

@protocol ColorPickerViewDelegate <NSObject>

-(void)colorPickerView:(ColorPickerView*)colorPickerView colorChoose:(UIColor *)color;
-(void)colorPickerViewCancelButtonClick:(ColorPickerView*)colorPickerView;
-(void)colorPickerViewDoneButtonClick:(ColorPickerView *)colorPickerView;

@end