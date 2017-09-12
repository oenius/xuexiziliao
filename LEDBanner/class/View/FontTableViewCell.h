//
//  FontTableViewCell.h
//  LEDBanner
//
//  Created by 何少博 on 16/6/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MainViewController.h"
@protocol FontTableViewCellDelegate <NSObject>

- (void)setFontDefaultChooseColorClick:(UIColor *)color;
- (void)setMulticolourClick:(BOOL)isMulticolour;
- (void)setFontCustomColorBtnClick:(UIColor *)color;
- (void)fontAdsBtnClick;
- (void)setFontChoose:(NSString *)fontName;
@end
@interface FontTableViewCell : UITableViewCell
@property (weak, nonatomic) id<FontTableViewCellDelegate> delegate;
@end
