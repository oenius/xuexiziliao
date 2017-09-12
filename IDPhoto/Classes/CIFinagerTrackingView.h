//
//  CIFinagerTrackingView.h
//  CutoutImage
//
//  Created by 何少博 on 17/2/7.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CIPositionStateOne,
    CIPositionStateTwo
} CIPositionState;

@interface CIFinagerTrackingView : UIView

@property(nonatomic,assign) CGFloat zoom;

@property (nonatomic, assign) CIPositionState positionState;

-(void)beganTrackingView:(UIView*)trackingView;

-(void)trackingPoint:(CGPoint)point;

-(void)endTracking;

@end
