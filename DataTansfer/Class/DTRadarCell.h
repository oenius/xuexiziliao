//
//  DTRadarCell.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/24.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DTRadarCellDelegate ;

@interface DTRadarCell : UIView


@property(nullable, nonatomic,weak) id <DTRadarCellDelegate> delegate;
@end
@protocol DTRadarCellDelegate <NSObject>

@optional
- (void)didSelectItemRadarPointView:(nonnull DTRadarCell *)radarPointView;   // 点击事件

@end
