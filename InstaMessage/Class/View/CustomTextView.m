//
//  CustomTextView.m
//  InstaMessage
//
//  Created by 何少博 on 16/8/5.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextView.h"

#define kButton_W_H 20
#define kButton_X_Y 0

@interface CustomTextView ()



@end

@implementation CustomTextView


-(instancetype)initWithFrame:(CGRect)frame{
    CGFloat  W = frame.size.width;
    CGFloat H = frame.size.height;
    frame.size.width = W>60 ? W : 60;
    frame.size.height = H>60 ? H : 60;
    self = [super initWithFrame:frame];
    
    if (self) {
        self.isCanMove = YES;
        CAShapeLayer *border = [CAShapeLayer layer];
        border.strokeColor = [UIColor redColor].CGColor;
        self.border = border;
        [self.layer addSublayer:border];
        
        
        UIButton * deleBtn = [[UIButton alloc]initWithFrame:CGRectMake(kButton_X_Y,kButton_X_Y, kButton_W_H, kButton_W_H)];
        [deleBtn addTarget:self action:@selector(shanchu) forControlEvents:UIControlEventTouchUpInside];
        deleBtn.tag = deleteButtomTag;
        [deleBtn setImage:[UIImage imageNamed:@"delete-icon"] forState:UIControlStateNormal];
        self.delelBtn = deleBtn;
        [self addSubview:deleBtn];
        
        UIButton * doneBtn = [[UIButton alloc]initWithFrame:CGRectMake(W-kButton_W_H, kButton_X_Y, kButton_W_H, kButton_W_H)];
        doneBtn.tag = doneButtomTag;
        [doneBtn setImage:[UIImage imageNamed:@"sure-icon"] forState:UIControlStateNormal];
        [doneBtn addTarget:self action:@selector(wancheng) forControlEvents:UIControlEventTouchUpInside];
        self.doneBtn = doneBtn;
        [self addSubview:doneBtn];
        
        
        UIButton * frameBtn = [[UIButton alloc]initWithFrame:CGRectMake(W-kButton_W_H, H-kButton_W_H, kButton_W_H, kButton_W_H)];
        [frameBtn addTarget:self action:@selector(framechange) forControlEvents:UIControlEventTouchUpInside];
        frameBtn.tag = changeFrameButtomTag;
        [frameBtn setImage:[UIImage imageNamed:@"zoom"] forState:UIControlStateNormal];
        self.frameBtn = frameBtn;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(Move:)];
        [frameBtn addGestureRecognizer:pan];
        [self addSubview:frameBtn];
        
        UIPanGestureRecognizer * moveself = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveSelf:)];
        [self addGestureRecognizer:moveself];
        //        UIPinchGestureRecognizer *scaler = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(Scaler:)];
        //        [self addGestureRecognizer:scaler];
        //        UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
        //        [self addGestureRecognizer:rotation];
        self.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20);
        self.allowsCopyAttributedString = YES;
        self.allowsPasteAttributedString = YES;
        self.allowsPasteImage = YES;
        
        
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect frame = self.frame;
    CGFloat  W = frame.size.width;
    CGFloat H = frame.size.height;
    self.delelBtn.frame = CGRectMake(kButton_X_Y, kButton_X_Y, kButton_W_H, kButton_W_H);
    self.doneBtn.frame = CGRectMake(W-kButton_W_H, kButton_X_Y, kButton_W_H, kButton_W_H);
    self.frameBtn.frame = CGRectMake(W-kButton_W_H, H-kButton_W_H, kButton_W_H, kButton_W_H);
    
    self.border.fillColor = nil;
    CGRect rect = self.bounds;
    rect.origin.x += 5;
    rect.origin.y += 5;
    rect.size.width -=20;
    rect.size.height -=20;
    self.border.path = [UIBezierPath bezierPathWithRect:rect].CGPath;
    self.border.frame = rect;
    self.border.lineWidth = 1.f;
    self.border.lineCap = @"square";
    self.border.lineDashPattern = @[@5, @5];
}


-(void)shanchu{
    [self removeFromSuperview];
}
-(void)wancheng{
    self.delelBtn.hidden = YES;
    self.doneBtn.hidden = YES;
    self.frameBtn.hidden = YES;
    self.border.hidden = YES;
    [self resignFirstResponder];
}
-(void)framechange{
    
}
- (void)Scaler:(UIPinchGestureRecognizer *)scler{
    [self resignFirstResponder];
    UIView *view = scler.view;
    
    view.transform = CGAffineTransformScale(view.transform, scler.scale, scler.scale);
    scler.scale = 1;
    
}
- (void)rotate:(UIRotationGestureRecognizer *)rotate{
    [self resignFirstResponder];
    UIView *view = rotate.view;
    
    if (rotate.state == UIGestureRecognizerStateBegan || rotate.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformRotate(view.transform, rotate.rotation);
        [rotate setRotation:0];
    }
    
}
-(void)Move:(UIPanGestureRecognizer*)pan{
    CGPoint p = [pan locationInView:self];
    CGFloat W = self.bounds.size.width;
    CGFloat H = self.bounds.size.height;
    
    CGRect frame = self.frame;
    frame.size.width = p.x;
    frame.size.height = p.y;
    self.frame = frame;
    self.delelBtn.frame = CGRectMake(kButton_X_Y, kButton_X_Y, kButton_W_H, kButton_W_H);
    self.doneBtn.frame = CGRectMake(W-kButton_W_H, kButton_X_Y, kButton_W_H, kButton_W_H);
    self.frameBtn.frame = CGRectMake(W-kButton_W_H, H-kButton_W_H, kButton_W_H, kButton_W_H);
}

-(void)moveSelf:(UIPanGestureRecognizer*)move{
    if (self.isCanMove == NO) return;
    if (self.border.hidden == YES) {
        if ([self.customDelegate respondsToSelector:@selector(returnCurrentCustomTextView:)]) {
            [self.customDelegate returnCurrentCustomTextView:self];
        }
    }
    UIView * view = move.view;
    if (move.state == UIGestureRecognizerStateBegan || move.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [move translationInView:view.superview];
        
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [move setTranslation:CGPointZero inView:view.superview];
    }
}


-(void)setBeiScaAndRot:(BOOL)beiScaAndRot{
    _beiScaAndRot = beiScaAndRot;
    if (beiScaAndRot == YES) {
        self.doneBtn.hidden = YES;
        self.delelBtn.hidden = YES;
        self.frameBtn.hidden = YES;
        self.border.hidden = YES;
    }
}
-(void)dealloc{
    LOG(@"%s",__func__);
}

@end
