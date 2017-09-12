//
//  SNBaseViewController.h
//  MindMap
//
//  Created by 何少博 on 2017/8/7.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "BaseViewController.h"

@interface SNBaseViewController : BaseViewController

-(BOOL)userBGImage;



#pragma mark - GCD
- (void)runAsyncOnMainThread:(void(^)(void))block;

- (void)runSyncOnMainThread:(void(^)(void))block;

- (void)runAsynchronous:(void(^)(void))block;

- (void)performOnMainThread:(void(^)(void))block wait:(BOOL)wait;

- (void)performAsynchronous:(void(^)(void))block;

- (void)performAfter:(NSTimeInterval)seconds block:(void(^)(void))block;

@end
