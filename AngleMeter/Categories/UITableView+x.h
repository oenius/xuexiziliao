//
//  UITableView+x.h
//  common
//
//  Created by czh0766 on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (x)

-(void) reloadRowAtIndex:(int)row;

-(void) reloadRowAtSection:(int)section;

-(void) reloadRowAtIndexPath:(NSIndexPath*)indexPath;

-(void) reloadRowAtIndexPath:(NSIndexPath*)indexPath withRowAnimation:(UITableViewRowAnimation)animation;

-(UITableViewCell*) cellForRowAtIndex:(int)row;

@end
