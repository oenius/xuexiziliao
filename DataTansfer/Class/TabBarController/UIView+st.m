//
//  UIView+st.m
//  Common
//
//  Created by 何少博 on 17/3/27.
//  Copyright © 2017年 camory. All rights reserved.
//

#import "UIView+st.h"

@implementation UIView (st)

-(NSLayoutConstraint *)addConstraintEqualLeftToSupview:(UIView *)view{
    if (self.translatesAutoresizingMaskIntoConstraints == YES)
        self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:self attribute:(NSLayoutAttributeLeft) relatedBy:(NSLayoutRelationEqual) toItem:view attribute:(NSLayoutAttributeLeft) multiplier:1.0 constant:0.0];
    [view addConstraint:constraint];
    return constraint;
}

-(NSLayoutConstraint *)addConstraintEqualRightToSupview:(UIView *)view{
    if (self.translatesAutoresizingMaskIntoConstraints == YES)
        self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:self attribute:(NSLayoutAttributeRight) relatedBy:(NSLayoutRelationEqual) toItem:view attribute:(NSLayoutAttributeRight) multiplier:1.0 constant:0.0];
    [view addConstraint:constraint];
    return constraint;
}

-(NSLayoutConstraint *)addConstraintEqualTopToSupview:(UIView *)view{
    if (self.translatesAutoresizingMaskIntoConstraints == YES)
        self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:self attribute:(NSLayoutAttributeTop) relatedBy:(NSLayoutRelationEqual) toItem:view attribute:(NSLayoutAttributeTop) multiplier:1.0 constant:0.0];
    [view addConstraint:constraint];
    return constraint;
}

-(NSLayoutConstraint *)addConstraintEqualBottomToSupview:(UIView *)view{
    return [self addConstraintEqualBottomToSupview:view spacing:0.0];
}

-(NSLayoutConstraint *)addConstraintEqualBottomToSupview:(UIView *)view spacing:(CGFloat )spacing{
    if (self.translatesAutoresizingMaskIntoConstraints == YES)
        self.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:self attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:view attribute:(NSLayoutAttributeBottom) multiplier:1.0 constant:-spacing];
    [view addConstraint:constraint];
    return constraint;
}

-(NSLayoutConstraint *)addConstraintEqualHeight:(CGFloat )height{
    if (self.translatesAutoresizingMaskIntoConstraints == YES)
        self.translatesAutoresizingMaskIntoConstraints = NO;
    
     NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:self attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:height];
    [self addConstraint:constraint];
    return constraint;
}

-(NSLayoutConstraint *)addConstraintEqualWidth:(CGFloat )width{
    if (self.translatesAutoresizingMaskIntoConstraints == YES)
        self.translatesAutoresizingMaskIntoConstraints = NO;
    
     NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:self attribute:(NSLayoutAttributeHeight) relatedBy:(NSLayoutRelationEqual) toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:width];
    [self addConstraint:constraint];
    return constraint;
}


@end
