//
//  UITableView+x.m
//  common
//
//  Created by czh0766 on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UITableView+x.h"

@implementation UITableView (x)

-(void)reloadRowAtIndex:(int)row {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self reloadRowAtIndexPath:indexPath];
}

-(void) reloadRowAtSection:(int)section {
    NSIndexSet* set = [NSIndexSet indexSetWithIndex:section];
    [self reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
}

-(void) reloadRowAtIndexPath:(NSIndexPath*)indexPath {
    [self reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
}

-(void) reloadRowAtIndexPath:(NSIndexPath*)indexPath withRowAnimation:(UITableViewRowAnimation)animation{
    [self reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animation];
}

-(UITableViewCell*) cellForRowAtIndex:(int)row {
    return [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
}

@end
