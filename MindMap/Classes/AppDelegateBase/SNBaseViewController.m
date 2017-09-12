//
//  SNBaseViewController.m
//  MindMap
//
//  Created by 何少博 on 2017/8/7.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNBaseViewController.h"

@interface SNBaseViewController ()

@end

@implementation SNBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if ([self userBGImage]) {
        UIImage * image = [UIImage imageNamed:@"bg"];
        self.view.layer.contents = (__bridge id _Nullable)(image.CGImage);
    }
}

-(BOOL)userBGImage{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GCD

- (void)runAsyncOnMainThread:(void(^)(void))block{
    dispatch_async(dispatch_get_main_queue(), block);
}

- (void)runSyncOnMainThread:(void(^)(void))block{
    dispatch_sync(dispatch_get_main_queue(), block);
}

- (void)runAsynchronous:(void(^)(void))block{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}

- (void)performOnMainThread:(void(^)(void))block wait:(BOOL)shouldWait {
    if (shouldWait) {
        // Synchronous
        dispatch_sync(dispatch_get_main_queue(), block);
    }
    else {
        // Asynchronous
        dispatch_async(dispatch_get_main_queue(), block);
    }
}



- (void)performAsynchronous:(void(^)(void))block {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, block);
}



- (void)performAfter:(NSTimeInterval)seconds block:(void(^)(void))block {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_current_queue(), block);
}

@end
