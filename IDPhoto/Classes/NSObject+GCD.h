//
//  NSObject+GCD.h
//


#import <Foundation/Foundation.h>
@interface NSObject (GCD)


- (void)runAsyncOnMainThread:(void(^)(void))block;

- (void)runSyncOnMainThread:(void(^)(void))block;

- (void)runAsynchronous:(void(^)(void))block;

- (void)performOnMainThread:(void(^)(void))block wait:(BOOL)wait;

- (void)performAsynchronous:(void(^)(void))block;

- (void)performAfter:(NSTimeInterval)seconds block:(void(^)(void))block;



@end
