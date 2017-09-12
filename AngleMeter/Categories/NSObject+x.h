//
//  NSObject+x.h
//  common
//
//  Created by czh0766 on 12-8-7.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (x)

-(void) asyncTask:(dispatch_block_t)block; 

-(void) syncTask:(dispatch_block_t)block;

-(void) syncTaskOnMain:(dispatch_block_t)block;

-(void) asyncTask:(dispatch_block_t)block after:(NSTimeInterval)delay;

-(void) syncTask:(dispatch_block_t)block after:(NSTimeInterval)delay;

-(void) syncTaskOnMain:(dispatch_block_t)block after:(NSTimeInterval)delay;

-(void) asyncTask:(dispatch_block_t)block returnOnMain:(dispatch_block_t)block2;

-(void) execOnceOnKey:(NSString*)key block:(dispatch_block_t)block;

-(BOOL)isIPad;
@end
