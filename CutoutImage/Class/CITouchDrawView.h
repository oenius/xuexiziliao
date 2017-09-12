//
//  CITouchDrawView.h
//  CutoutImage
//
//  Created by 何少博 on 17/2/6.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CITouchStateRect,
    CITouchStatePlus,
    CITouchStateMinus,
    CITouchStateEarse
} CITouchState;


@interface CITouchDrawView : UIView

@property (nonatomic, assign) CGFloat eraseSize;

@property (nonatomic, assign) CITouchState currentState;


-(void)earseWithImage:(UIImage *)image;

- (void)touchStarted:(CGPoint)point;
- (void)touchMoved:(CGPoint)point;
- (void)touchEnded:(CGPoint)point;
- (void)drawRectangle:(CGRect)rect;
- (void)clear;

- (UIImage *)maskImageWithPainting;
- (UIImage *)maskImagePaintingAtRect:(CGRect)rect;
@end
