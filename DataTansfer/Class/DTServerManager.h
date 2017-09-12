//
//  DTServerManager.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/22.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTSingleton.h"

typedef void(^DidSearchBlock)(BOOL success, NSString * baseUrl);

@interface DTServerManager : NSObject

@property (nonatomic,copy) NSString * baseUrl;

@property (nonatomic,assign) BOOL serachSuccess;

-(BOOL)isRunning;

///开启
-(void)openServer:(void(^)(NSString * baseUrl))block;
///关闭
-(void)closeServer;
///查找
-(void)searchServer:(DidSearchBlock)block;

Singleton_H(Instance);

@end
