//
//  IDTouchDrawView.h
//  IDPhoto
//
//  Created by 何少博 on 17/4/27.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum : NSUInteger {
    TouchStateNone,
    TouchStateRect,
    TouchStatePlus,
    TouchStateMinus,
    TouchStateEarse,
} TouchState;


@interface IDTouchDrawView : UIView

@property (nonatomic, assign) CGFloat eraseSize;
@property (nonatomic,assign) CGFloat plusSize;
@property (nonatomic, assign) TouchState currentState;
@property (nonatomic,strong) UIColor * eraseColor;
@property (nonatomic,assign) BOOL shadowEnable;
@property (nonatomic,assign) BOOL showCircle;

- (void)touchStarted:(CGPoint)point;
- (void)touchMoved:(CGPoint)point;
- (void)touchEnded:(CGPoint)point;
- (void)drawRectangle:(CGRect)rect;
- (void)clear;

- (UIImage *)maskImageWithPainting;
- (UIImage *)maskImagePaintingAtRect:(CGRect)rect;
@end
