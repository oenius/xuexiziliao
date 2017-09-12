//
//  UIAlertView+x.m
//  TestArchive
//
//  Created by mayuan on 13-3-10.
//  Copyright (c) 2013年 mayuan. All rights reserved.
//

#import "UIAlertView+x.h"

@implementation UIAlertView (x)

+(id)messageBox:(NSString *)msg buttonTitle:(NSString *)title {
    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil
                                           cancelButtonTitle:title otherButtonTitles:nil];
    [dialog show];
    return dialog;
}

+(id)messageBox:(NSString*)msg buttonTitles:(NSArray*)titles delegate:(id)delegate {
    UIAlertView* dialog = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:delegate
                                           cancelButtonTitle:[titles firstObject] otherButtonTitles:nil];
    for (int i = 1; i < titles.count; i++) {
        [dialog addButtonWithTitle:[titles objectAtIndex:i]];
    }
    [dialog show];
    return dialog;
}


@end
