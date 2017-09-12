//
//  UIViewController+x.h
//  common
//
//  Created by czh0766 on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (x)

-(void) reloadViewForNib:(NSString*)nib;

-(BOOL) isViewAttachToSuperview;

-(BOOL) isViewAttachToWindow;

-(UIViewController*) parentViewController_x;

@end
