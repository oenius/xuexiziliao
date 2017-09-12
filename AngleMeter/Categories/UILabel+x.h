//
//  UILabelx.h
//  iWeibo
//
//  Created by czh0766 on 12-2-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (x)

-(void) adjustsWidthToFitText;

-(void) adjustsWidthToFitText:(float)maxWidth;

-(void) adjustsSizeToFitText:(float)maxWidth;

- (void)adjustsHeightToFitText;

@end
