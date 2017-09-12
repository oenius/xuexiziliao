//
//  UIViewController+x.m
//  common
//
//  Created by czh0766 on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+x.h"
#import "UIView+x.h"

@implementation UIViewController (x)

-(void) reloadViewForNib:(NSString*)nib {
   
    UIView* view = [UIView viewWithNib:nib owner:self];
    
    if ([self isViewLoaded]) {
        UIView* view0 = self.view;
        view.center = view0.center;
        UIView* superview = view0.superview;
        if (superview) {
            int index = [superview indexOfView:view0];
            [view0 removeFromSuperview];
            [superview insertSubview:view atIndex:index];
        }
    } 
    
    self.view = view;
}

-(BOOL) isViewAttachToSuperview {
    return [self isViewLoaded] && self.view.superview;
}

-(BOOL) isViewAttachToWindow {
    return [self isViewLoaded] && self.view.window;
}

-(UIViewController *)parentViewController_x {
    if ([self respondsToSelector:@selector(presentingViewController)]) {
        return [self presentingViewController];
    } else {
        return [self parentViewController];
    }
}

@end
