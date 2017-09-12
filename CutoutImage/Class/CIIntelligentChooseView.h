//
//  CIIntelligentChooseView.h
//  CutoutImage
//
//  Created by 何少博 on 17/2/6.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CITouchDrawView.h"

@interface CIIntelligentChooseView : UIView


@property(nonatomic,assign)CITouchState touchState;

-(void)setRectButtonEnable:(BOOL)enable;
-(void)setPlusButtonEnable:(BOOL)enable;
-(void)setMinusButtonEnable:(BOOL)enable;

-(void)rectButtonAddTarget:(id)target action:(SEL)action;
-(void)plusButtonAddTarget:(id)target action:(SEL)actio;
-(void)minusButtonAddTarget:(id)target action:(SEL)action;


@end
