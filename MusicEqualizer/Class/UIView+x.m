//
//  UIViewx.m
//  MemoLite
//
//  Created by czh0766 on 11-10-3.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "UIView+x.h"

@implementation UIView (UIViewx)

+(id) viewWithNib:(NSString*)nib owner:(id)owner {
    NSArray* array =[[NSBundle mainBundle] loadNibNamed:nib owner:owner options:nil];
    return [array objectAtIndex:0];
}

-(void) offset:(CGPoint)point {
    CGRect frame = self.frame;
    frame.origin.x += point.x;
    frame.origin.y += point.y;
    self.frame = frame;
}

-(void) setPosition:(CGPoint)position {
    CGRect frame = self.frame;
    frame.origin.x = position.x;
    frame.origin.y = position.y; 
    self.frame = frame;
}

-(void) setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

-(CGPoint)postion {
    return self.frame.origin;
}

-(CGSize)size {
    return self.frame.size;
}

-(CGPoint)boundsCenter {
    CGSize size = self.bounds.size;
    return CGPointMake(size.width/2, size.height/2);
}

-(float) left {
    return self.frame.origin.x;
}

-(float) top {
    return self.frame.origin.y;
}

-(float) right {
    return [self left] + [self width];
}

-(float) bottom {
    return [self top] + [self height];
}

-(float) width {
    return self.frame.size.width;
}

-(float) height {
    return self.frame.size.height;
}

-(void) setLeft:(float)left {
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame; 
}

-(void) setRight:(float)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

-(void) setTop:(float)top {
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}

-(void) setBottom:(float)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

-(void) setWidth:(float)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame; 
}

-(void) setHeight:(float)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;   
}    

-(void) clearSubviews {
    id subviews = self.subviews;
    int count = [subviews count];
    for (int i = 0; i < count; i++) {
        [[subviews objectAtIndex:i] removeFromSuperview];
    }
}

-(void) replaceView:(UIView*)view atIndex:(int)index {
    UIView* view0 = [self viewAtIndex:index];
    view.frame = view0.frame;
    [view0 removeFromSuperview];
    [self insertSubview:view atIndex:index];
}

-(UIView*) viewAtIndex:(int)index {
    return [self.subviews objectAtIndex:index];
}

-(void) removeViewAtIndex:(int)index {
    UIView* view = [self viewAtIndex:index];
    [view removeFromSuperview];
}

-(void) transitionToAddSubview:(UIView*)view duration:(NSTimeInterval)duration {
    [self addSubview:view];
    view.alpha = 0;
    [UIView animateWithDuration:duration animations:^{
        view.alpha = 1;
    }];
}

-(void) transitionToRemoveFromSuperview:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.alpha = 1;
        [self removeFromSuperview];
    }];
}

-(BOOL) pointInsideFrame:(CGPoint)location {
    location.x -= [self left];
    location.y -= [self top];
    return [self pointInside:location withEvent:nil];
}

-(int) indexOfView:(UIView*)view {
    return [self.subviews indexOfObject:view];
}

-(UITapGestureRecognizer*)addTapGestureRecognizer:(id)target forAction:(SEL)action {
    UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:recognizer];
    return recognizer;
}

-(UILongPressGestureRecognizer*)addLongPressGestureRecognizer:(id)target forAction:(SEL)action {
    UILongPressGestureRecognizer* recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:recognizer];
    return recognizer;
}

- (NSString *)recursiveDescription:(NSString *)tab
{
    NSString *viewDescription = [NSString stringWithFormat:@"%@%@\n", tab, [self description]];
    NSString *subViewDescription = @"";
    NSString *subTab = [NSString stringWithFormat:@"%@  |", tab];
    for (UIView *subView in self.subviews) {
        subViewDescription = [NSString stringWithFormat:@"%@%@", subViewDescription, [subView recursiveDescription:subTab]];
    }
    return [NSString stringWithFormat:@"%@%@", viewDescription, subViewDescription];
}

- (NSString *)recursiveDescription
{
    return [self recursiveDescription:@""];
}

-(void) layoutSubviewsInCenter {
    float width = 0;
    for (UIView* view in self.subviews) {
        if (!view.hidden) {
            width += [view width];
        }
    }
    float offx = ([self width] - width) / 2;
    float offy = [self height] / 2;
    for (UIView* view in self.subviews) {
        if (!view.hidden) {
            float w = [view width];
            view.center = CGPointMake(offx + w / 2, offy);
            offx += w;
        }
    }
}

@end
