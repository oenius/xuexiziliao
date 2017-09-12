//
//  NSObject+x.m
//  common
//
//  Created by czh0766 on 12-8-7.
//
//
#import <UIKit/UIKit.h>
#import "NSObject+x.h"

@implementation NSObject (x)

-(void)asyncTask:(dispatch_block_t)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

-(void)syncTask:(dispatch_block_t)block {
    dispatch_async(dispatch_get_current_queue(), block);
}

-(void)syncTaskOnMain:(dispatch_block_t)block {
    dispatch_async(dispatch_get_main_queue(), block);
}

-(void) asyncTask:(dispatch_block_t)block after:(NSTimeInterval)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC),
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

-(void) syncTask:(dispatch_block_t)block after:(NSTimeInterval)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC),
                   dispatch_get_current_queue(), block);
}

-(void) syncTaskOnMain:(dispatch_block_t)block after:(NSTimeInterval)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC),
                   dispatch_get_main_queue(), block);
}

-(void)asyncTask:(dispatch_block_t)block returnOnMain:(dispatch_block_t)block2 {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        block();
        dispatch_async(dispatch_get_main_queue(), block2);
    });

}

-(void) execOnceOnKey:(NSString*)key block:(dispatch_block_t)block {
    NSUserDefaults* udef = [NSUserDefaults standardUserDefaults];
    BOOL processed = [udef boolForKey:key];
    if (!processed) {
        block();
        [udef setBool:YES forKey:key];
        [udef synchronize];
    }
}


-(BOOL)isIPad
{
    BOOL isIPad = NO;
    if (isIPad == NO) {
        if ([[UIDevice currentDevice] userInterfaceIdiom]
            == UIUserInterfaceIdiomPad) {
            isIPad = YES;
        }
        else
        {
            isIPad = NO;
        }
    }
    return isIPad;
}

@end
