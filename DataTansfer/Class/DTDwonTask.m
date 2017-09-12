//
//  DTDwonTask.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/27.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTDwonTask.h"
#import <AFNetworking.h>
#import "DTContactViewModel.h"
#import "DTPhotoViewModel.h"
#import "DTVideoViewModel.h"
#import "DTMusicViewModel.h"
#import "NSData+DT.h"

@interface DTDwonTask ()

///任务状态

@property (nonatomic,assign,readwrite) CGFloat progress;

@property (nonatomic,assign,readwrite) CGFloat fileSize;

@property (nonatomic,strong,readwrite) NSString * taskID;

@property (nonatomic,strong,readwrite) NSString * baseUrl;

@property (nonatomic,strong) NSURLSessionDownloadTask * downLoadTask;

@property (nonatomic,strong) NSURLSessionDataTask * dataTask;

@property (nonatomic,strong) AFHTTPSessionManager * sessionManager;

@property (nonatomic,strong) NSString * musicModelsDir;
@end


@implementation DTDwonTask

-(NSString *)musicModelsDir{
    if (nil == _musicModelsDir) {
        _musicModelsDir = [DTConstAndLocal getMusicModelsDir];
    }
    return _musicModelsDir;
}


-(void)setStatus:(DTDwonTaskStatus)status{
    _status = status;
    if ([self.delegate respondsToSelector:@selector(downTask:statusChanged:)]) {
        [self.delegate downTask:self statusChanged:self.status];
    }
}

-(instancetype)initWithBaseUlr:(NSString *)baseUrl andIDFR:(NSString *)idfr {
    self = [super init];
    if (self) {
        self.baseUrl = baseUrl;
        self.taskID = idfr;
        self.status = DTDwonTaskStatusNotStart;
    }
    return self;
}

+(instancetype)taskWithBaseUlr:(NSString *)baseUrl andIDFR:(NSString *)idfr{
    return [[[self class] alloc]initWithBaseUlr:baseUrl andIDFR:idfr];
}
///初始化dataTask
-(void)initTask{
    WEAKSELF_DT
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        //设置请求超时为120秒钟
        config.timeoutIntervalForRequest = 2*60.0;
        self.sessionManager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:config];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/octet-stream",@"text/html",@"text/plain",@"application/json",nil];
        NSString * requestUrlStr = [self getRequestUrl];
        
        self.dataTask = [_sessionManager GET:requestUrlStr parameters:@{@"IDFR":[self.taskID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]} progress:^(NSProgress * _Nonnull downloadProgress) {
            if (self.downType == DTFileTypeContact || self.downType == DTFileTypePhtoto) {
                [self dealWithProgress:downloadProgress];
            }else{
                self.progress = 0;
            }
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            LOG(@"---responseObject:%p",responseObject);
            [weakSelf dealWithDwonload:responseObject];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            LOG(@"error%@",error);
            [weakSelf dealWithError:error];
        }];
    });
    
}
///根据文件名下载大文件
-(void)downBigFileWithModel:(id)model{

    NSString * filePath =[model fileUrlPath];
    if (filePath == nil){
        if ([self.delegate respondsToSelector:@selector(downTask:didError:)]) {
            [self.delegate downTask:self didError:[NSError new]];
        }
        self.status = DTDwonTaskStatusFailed;
        return;
    }
    self.progress = 0.0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * urlStr = kRequestFileDataPath;
        urlStr = [urlStr stringByAppendingFormat:@"?IDFR=%@",filePath];
        urlStr = [self.baseUrl stringByAppendingString:urlStr];
        urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL * url = [NSURL URLWithString:urlStr];
        NSURLRequest * request = [NSURLRequest requestWithURL:url];
        self.downLoadTask = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            [self dealWithProgress:downloadProgress];
            
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            
            NSURL *tmpDirectoryURL = [NSURL fileURLWithPath:NSTemporaryDirectory()];
            tmpDirectoryURL = [NSURL URLWithString:filePath relativeToURL:tmpDirectoryURL];
            return tmpDirectoryURL;
            
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePathUrl, NSError * _Nullable error) {
            if (error) {
                [self dealWithError:error];
            }else{
                NSURL * tmpDirectoryURL = [NSURL URLWithString:filePath relativeToURL:filePathUrl];
                self.downloadFilePath = tmpDirectoryURL;
                LOG(@"filePath:%@",tmpDirectoryURL);
                if ([self.delegate respondsToSelector:@selector(downTask:didSuccessPath:dataModel:)]) {
                    [self.delegate downTask:self didSuccessPath:tmpDirectoryURL dataModel:model];
                }
                self.status = DTDwonTaskStatusSuccessed;
            }
            [self completedDealWithFilePath:filePath];
        }];
        [self.downLoadTask resume];
        self.status = DTDwonTaskStatusDownloading;
    });
    
}


/**
 告知服务器文件传输完毕
 */
-(void)completedDealWithFilePath:(NSString *)filePath{
    NSString * requestUrl = [NSString stringWithFormat:@"%@%@",self.baseUrl,kReponseDidFinishPath];
    requestUrl = [requestUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.sessionManager GET:requestUrl parameters:@{@"IDFR":[filePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]} progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       
    }];
}


-(void)dealWithProgress:(NSProgress *)downloadProgress{
    CGFloat newProgress = (downloadProgress.completedUnitCount*1.0)/(downloadProgress.totalUnitCount*1.0);
    CGFloat oldProgress = self.progress;
    if (oldProgress+0.03 <= newProgress || newProgress >= 0.99) {
        self.progress = newProgress;
        if ([self.delegate respondsToSelector:@selector(downTask:progress:)]) {
            [self.delegate downTask:self progress:self.progress];
        }
    }
}

-(void)dealWithError:(NSError *)error{
    
//    NSString * des = error.localizedDescription;
    if (error.code == -1001)
    {
        self.status = DTDwonTaskStatusTimeOut;
    }
    else if (error.code == -1009||error.code == -1004)
    {
        self.status = DTDwonTaskStatusNotContectServer;
    }
    else{
        self.status = DTDwonTaskStatusFailed;
    }
    if ([self.delegate respondsToSelector:@selector(downTask:didError:)]) {
        [self.delegate downTask:self didError:error];
        
    }
}

///处理第一次下载数据，如果是音乐和视频会进行二次下载大文件，如果下载的是图片和联系人则直接完成该任务
-(void)dealWithDwonload:(NSData *)data{
    id model = [data unarchiveObject];
    switch (self.downType) {
        case DTFileTypeContact:
        case DTFileTypePhtoto:{
            if ([self.delegate respondsToSelector:@selector(downTask:didSuccessPath:dataModel:)]) {
                [self.delegate downTask:self didSuccessPath:nil dataModel:model];
                
            }
            self.status = DTDwonTaskStatusSuccessed;
        }
            break;
        case DTFileTypeVideo:
            [self downBigFileWithModel:model];
            break;
        case DTFileTypeMusic:{
            NSString * path = [self.musicModelsDir stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
            [data writeToFile:path atomically:YES];
            [self downBigFileWithModel:model];
        }
            break;
            
        default:
            break;
    }
}


///开启
-(void)resume{
    if (self.dataTask == nil) {
        [self initTask];
    }
    if (self.downLoadTask) {
        [self.downLoadTask resume];
        self.status = DTDwonTaskStatusDownloading;
    }
    else{
        [self.dataTask resume];
        if (self.downType == DTFileTypeVideo || self.downType == DTFileTypeMusic) {
            self.status = DTDwonTaskStatusLoading;
        }
        else{
            self.status = DTDwonTaskStatusDownloading;
        }
    }
   
    

}
///暂停
-(void)pause{
    if (self.downLoadTask) {
        [self.downLoadTask suspend];
    }else{
        [self.dataTask suspend];
    }
    self.status = DTDwonTaskStatusPause;
    
}
/// 取消
-(void)cancel{
    if (self.downLoadTask) {
        [self.downLoadTask cancel];
    }else{
        [self.dataTask cancel];
    }
    self.status = DTDwonTaskStatusCancle;
}
/// 重试
-(void)retry{
    self.dataTask = nil;
    self.downLoadTask = nil;
    self.status = DTDwonTaskStatusNotStart;
}
-(NSString *)getRequestUrl{
    NSString * requesetPath = @"";
    switch (self.downType) {
        case DTFileTypeContact:
            requesetPath = kRequestContactsPath;
            break;
        case DTFileTypePhtoto:
            requesetPath = kRequestPhotosPath;
            break;
        case DTFileTypeVideo:
            requesetPath = kRequestVideosPath;
            break;
        case DTFileTypeMusic:
            requesetPath = kRequestMusicsPath;
            break;
        case DTFileTypeBigFileData:
            requesetPath = kRequestFileDataPath;
            break;
        default:
            break;
    }
    //    NSURL * baseUrl = [NSURL URLWithString:self.baseUrl];
    //    NSURL * requestUrl = [NSURL URLWithString:requesetPath relativeToURL:baseUrl];
    NSString * requestUrl = [NSString stringWithFormat:@"%@%@",self.baseUrl,requesetPath];
    requestUrl = [requestUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return requestUrl;
}


@end
