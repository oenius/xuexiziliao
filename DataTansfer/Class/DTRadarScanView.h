//
//  DTRadarScanView.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/24.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTRadarCell;
@class DTRadarIndictorView;
@protocol DTRadarViewDelegate;
@protocol DTRadarViewDateSource;
@interface DTRadarScanView : UIView

@property (nonatomic,assign) BOOL reversedRadar;

@property (nonatomic,assign) NSInteger numberOfWaves;

@property (nullable,nonatomic,strong) UIColor * radarColor;

@property (nonatomic,assign) CGFloat innerRadius;

@property (nullable,nonatomic,strong) UIImage * iconImage;

@property (nonatomic,assign) CGSize iconSize;

@property (nonatomic,assign) CGFloat waveWidth;

@property (nonatomic,assign) CGFloat maxWaveAlpha;

@property(nullable, nonatomic,strong) DTRadarIndictorView *indicatorView;   // 扫描指针

@property(nullable, nonatomic,weak) id<DTRadarViewDateSource> dataSource;   // 数据源
@property(nullable, nonatomic,weak) id<DTRadarViewDelegate> delegate;   // 委托
@property (nonatomic, assign) CGFloat radius;   // 半径
@property(nullable, nonatomic,strong) UIColor *indicatorStartColor; // 开始颜色
@property(nullable, nonatomic,strong) UIColor *indicatorEndColor;   // 结束颜色
@property (nonatomic, assign) CGFloat indicatorAngle;   // 扇形角度
@property (nonatomic, assign) BOOL indicatorClockwise;  // 是否顺时针

-(void)startScan;
-(void)stopScan;

- (void)show;   // 显示目标
- (void)hide;   // 隐藏目标

@end

@protocol DTRadarViewDateSource <NSObject>  // 数据源

@optional
- (NSInteger)numberOfPointsInRadarView:(nullable DTRadarScanView *)radarView;
- (nonnull DTRadarCell *)radarView:(nullable DTRadarScanView *)radarView viewForIndex:(NSUInteger)index; //  自定义目标点视图
- (CGPoint)radarView:(nullable DTRadarScanView *)radarView positionForIndex:(NSUInteger)index;  // 目标点所在位置

@end

@protocol DTRadarViewDelegate <NSObject>

@optional

- (void)radarView:(nullable DTRadarScanView *)radarView didSelectItemAtIndex:(NSUInteger)index;  // 点击事件

@end


@interface DTRadarIndictorView : UIView

@property (nonatomic, assign) CGFloat radius;   // 半径
@property(nullable, nonatomic,strong) UIColor *startColor;  // 渐变开始颜色
@property(nullable, nonatomic,strong) UIColor *endColor;    // 渐变结束颜色
@property (nonatomic, assign) CGFloat angle;    // 扫描角度
@property (nonatomic, assign) BOOL clockwise;   // 是否顺时针

@end
