//
//  CameraView.h
//  AngleMeter
//
//  Created by 何少博 on 16/9/18.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraView : UIView
/**
 *  聚焦
 *
 *  @param point 焦点
 */
- (void)focusAtPoint:(CGPoint)point;
/**
 *  切换相机
 */
- (void)changeCamera;
@end
