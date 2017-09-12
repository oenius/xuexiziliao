//
//  ScrSettingCell.h
//  LEDBanner
//
//  Created by 何少博 on 16/6/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScrsettingDelegate <NSObject>

-(void)setDirectionChange:(BOOL)direction;
-(void)setSpeedChange:(CGFloat)speed;
-(void)setFlickerChange:(BOOL)flicker;
-(void)setFrequencyChange:(CGFloat)frequency;

@end
  


@interface ScrSettingCell : UITableViewCell

@property (nonatomic,weak)id <ScrsettingDelegate> delegate;

@end
