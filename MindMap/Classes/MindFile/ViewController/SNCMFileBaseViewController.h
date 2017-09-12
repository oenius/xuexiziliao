//
//  SNCMFileBaseViewController.h
//  MindMap
//
//  Created by 何少博 on 2017/8/19.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNBaseViewController.h"

/**
 copy or move baseViewController
 */
@interface SNCMFileBaseViewController : SNBaseViewController

@property (nonatomic ,strong) NSString *toDir;
@property (nonatomic, strong) NSArray *fileArray;
@property (copy, nonatomic) void(^finishCallBack)(NSString * message);
-(void)configItemAction;
-(void)alertMessage:(NSString *)message;
@end
