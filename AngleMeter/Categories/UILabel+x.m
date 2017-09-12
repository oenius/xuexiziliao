//
//  UILabelx.m
//  iWeibo
//
//  Created by czh0766 on 12-2-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UILabel+x.h"

@implementation UILabel (UILabelx)

-(void) adjustsWidthToFitText {
    [self adjustsWidthToFitText:MAXFLOAT];
}

-(void) adjustsWidthToFitText:(float)maxWidth {
    CGSize size = [self.text sizeWithFont:self.font 
                        constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT)];
    CGRect frame = self.frame;
    frame.size.width = size.width;
    self.frame = frame;
}

-(void) adjustsSizeToFitText:(float)maxWidth {
    CGSize size = [self.text sizeWithFont:self.font 
                        constrainedToSize:CGSizeMake(maxWidth, MAXFLOAT)];
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)adjustsHeightToFitText{
    CGSize size = [self.text sizeWithFont:self.font
                        constrainedToSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    CGRect frame = self.frame;
    frame.size.height = size.height;
    self.frame = frame;
}

@end
