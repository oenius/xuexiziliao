//
//  UIView+st.h
//  Common
//
//  Created by 何少博 on 17/3/27.
//  Copyright © 2017年 camory. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (st)

-(NSLayoutConstraint *)addConstraintEqualLeftToSupview:(UIView *)view;

-(NSLayoutConstraint *)addConstraintEqualRightToSupview:(UIView *)view;

-(NSLayoutConstraint *)addConstraintEqualTopToSupview:(UIView *)view;

-(NSLayoutConstraint *)addConstraintEqualBottomToSupview:(UIView *)view;

-(NSLayoutConstraint *)addConstraintEqualBottomToSupview:(UIView *)view spacing:(CGFloat )spacing;

-(NSLayoutConstraint *)addConstraintEqualHeight:(CGFloat )height;

-(NSLayoutConstraint *)addConstraintEqualWidth:(CGFloat )width;

@end
