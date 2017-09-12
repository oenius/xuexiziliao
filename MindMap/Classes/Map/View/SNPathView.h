//
//  SNPathView.h
//  MindMap
//
//  Created by 何少博 on 2017/8/8.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SNLineStyleLine,
    SNLineStyleDash4,
    SNLineStyleDash6,
    SNLineStyleDash4_1,
} SNLineStyle;

IB_DESIGNABLE
@interface SNPathView : UIView
@property (strong, nonatomic) UIColor *strokeColor;
@property (assign, nonatomic) IBInspectable CGPoint startPoint;
@property (assign, nonatomic) IBInspectable CGPoint midPoint;
@property (assign, nonatomic) IBInspectable CGPoint endPoint;
@property (assign, nonatomic) SNLineStyle style;

@end
