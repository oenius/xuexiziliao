//
//  UIAlertView+x.h
//  TestArchive
//
//  Created by mayuan on 13-3-10.
//  Copyright (c) 2013年 mayuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (x)


+(id)messageBox:(NSString*)msg buttonTitle:(NSString*)title;

+(id)messageBox:(NSString*)msg buttonTitles:(NSArray*)titles delegate:(id)delegate;

@end
