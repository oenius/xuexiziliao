//
//  IDTopToolView.h
//  IDPhoto
//
//  Created by 何少博 on 17/4/27.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IDTopToolView : UIView

-(void)setUndoBtnEnable:(BOOL)enable;

-(void)setRedoBtnEnable:(BOOL)enable;

-(void)backButtonAddTarget:(id)target action:(SEL)action;

-(void)undoButtonAddTarget:(id)target action:(SEL)action;

-(void)resetButtonAddTarget:(id)target action:(SEL)action;

-(void)redoButtonAddTarget:(id)target action:(SEL)action;

-(void)nextStepButtonAddTarget:(id)target action:(SEL)action;

@end
