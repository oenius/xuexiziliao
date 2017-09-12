//
//  UIViewx.h
//  MemoLite
//
//  Created by czh0766 on 11-10-3.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (x)

+(id) viewWithNib:(NSString*)nib owner:(id)owner;

-(void) offset:(CGPoint)point;

-(void) setPosition:(CGPoint)position;

-(void) setSize:(CGSize)size;

-(CGPoint) postion;

-(CGSize) size;

-(CGPoint) boundsCenter;

-(float) left;

-(float) top;

-(float) right;

-(float) bottom;

-(float) width;

-(float) height;

-(void) setWidth:(float)width;

-(void) setHeight:(float)height;

-(void) setLeft:(float)lef;

-(void) setRight:(float)right;

-(void) setTop:(float)top;

-(void) setBottom:(float)bottom;

-(void) clearSubviews;

-(void) replaceView:(UIView*)view atIndex:(int)index;

-(UIView*) viewAtIndex:(int)index;

-(void) removeViewAtIndex:(int)index;

-(void) transitionToAddSubview:(UIView*)view duration:(NSTimeInterval)duration;

-(void) transitionToRemoveFromSuperview:(NSTimeInterval)duration;

-(BOOL) pointInsideFrame:(CGPoint)location;

-(int) indexOfView:(UIView*)view;

-(UITapGestureRecognizer*) addTapGestureRecognizer:(id)target forAction:(SEL)action;

-(UILongPressGestureRecognizer*) addLongPressGestureRecognizer:(id)target forAction:(SEL)action;

- (NSString *)recursiveDescription;

-(void) layoutSubviewsInCenter;

@end
