//
//  DTTaskManager.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/27.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTSingleton.h"
#import "DTDwonTask.h"
@protocol DTTaskManagerDelegate ;


/**
 下载任务管理
 */
@interface DTTaskManager : NSObject
Singleton_H(Managaer)


@property (nonatomic,weak) id<DTTaskManagerDelegate> delegate;

///最大同时下载个数 默认1 最大10
@property (nonatomic,assign) NSUInteger maxTaskCount;
///失败的任务
@property (nonatomic,strong,readonly) NSMutableArray <DTDwonTask *>* failedTaskList;
///正在下载的任务
@property (nonatomic,strong,readonly) NSMutableArray <DTDwonTask *>* runingTaskList;
///正在等待的任务
@property (nonatomic,strong,readonly) NSMutableArray <DTDwonTask *>* waitingTaskList;


/**
 创建相册

 @param error NSError

 @return xaingce
 */
-(PHAssetCollection *)getAssetCollection:(NSError **)error;
/**
 添加任务

 @param tasks 包含所有下载任务的数组
 */
-(void)addTasks:(NSArray <DTDwonTask *>*)tasks;

/**
 删除任务

 @param task 要删除的任务
 */
//-(void)deleteTask:(DTDwonTask *)task;

/**
 暂停某个任务

 @param task 要被暂停的任务
 */
//-(void)pauseTask:(DTDwonTask *)task;

/**
 重新开始某个任务

 @param task 要重新开始的任务
 */
-(void)retryTask:(DTDwonTask *)task;

/**
 开启所有任务
 */
-(void)startDownLoad;

/**
 暂停所有任务
 */
//-(void)pauseDownLoad;

/**
 重新开始被暂停的任务
 */
//-(void)resumeDownload;

/**
 取消所有任务
 */
-(void)cancelDownLoad;


@end


/**
 任务管理代理
 */
@protocol DTTaskManagerDelegate <NSObject>

-(void)allTaskDidDownload:(DTTaskManager *)manager;

-(void)currentTaskBeginDwonload:(DTDwonTask *)task;

-(void)currentTask:(DTDwonTask *)task didError:(NSError *)error;

-(void)currentTask:(DTDwonTask *)task progress:(CGFloat)progress;

-(void)currentTask:(DTDwonTask *)task statusChanged:(DTDwonTaskStatus) status;


@end
