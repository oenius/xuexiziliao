//
//  DTDwonTask.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/27.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTDataBaseViewModel.h"

typedef enum : NSUInteger {
    DTDwonTaskStatusNotStart,
    DTDwonTaskStatusLoading,
    DTDwonTaskStatusDownloading,
    DTDwonTaskStatusPause,
    DTDwonTaskStatusCancle,
    DTDwonTaskStatusSuccessed,
    DTDwonTaskStatusFailed,
    DTDwonTaskStatusSaveSuccesse,
    DTDwonTaskStatusSaveFailed,
    DTDwonTaskStatusTimeOut,
    DTDwonTaskStatusNotContectServer,
    //....
} DTDwonTaskStatus;

//typedef enum : NSUInteger {
//    DTFTPErrorTypeNotContectServer,
//    DTFTPErrorTypeRequestToLong,
//    DTFTPErrorTypeStorageSpaces,
//    DTFTPErrorTypeUnknown,
//    //....
//} DTFTPErrorType;

@protocol DTDwonTaskDeletage;

@interface DTDwonTask : NSObject

-(instancetype)initWithBaseUlr:(NSString *)baseUrl andIDFR:(NSString *)idfr;

+(instancetype)taskWithBaseUlr:(NSString *)baseUrl andIDFR:(NSString *)idfr;

@property (nonatomic, weak) id<DTDwonTaskDeletage> delegate;

@property (nonatomic,assign) DTFileType downType;

@property (nonatomic,copy) NSString * name;

@property (nonatomic,strong) NSURL * downloadFilePath;

///任务状态
@property (nonatomic,assign) DTDwonTaskStatus status;

@property (nonatomic,assign,readonly) CGFloat progress;
//
//@property (nonatomic,assign,readonly) CGFloat fileSize;

@property (nonatomic,strong,readonly) NSString * taskID;

@property (nonatomic,strong,readonly) NSString * baseUrl;

///开启
-(void)resume;
///暂停
-(void)pause;
/// 取消
-(void)cancel;
/// 重试
-(void)retry;

@end

@protocol DTDwonTaskDeletage <NSObject>

-(void)downTaskBeginDownload:(DTDwonTask *)task;

-(void)downTask:(DTDwonTask *)task statusChanged:(DTDwonTaskStatus) status;

-(void)downTask:(DTDwonTask *)task didError:(NSError *)error;

-(void)downTask:(DTDwonTask *)task didSuccessPath:(NSURL *)filePath dataModel:(id) dataModel;

-(void)downTask:(DTDwonTask *)task progress:(CGFloat)progress;

@end


