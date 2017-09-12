//
//  DTServerManager.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/22.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTServerManager.h"
#import <GCDWebServer.h>
#import <GCDWebServerDataResponse.h>
#import "DTResponseManager.h"


@interface DTServerManager ()<NSNetServiceBrowserDelegate,NSNetServiceDelegate>

@property (nonatomic,strong) GCDWebServer * webServer;

//@property (nonatomic,strong) NSMutableArray * servers;

@property (nonatomic,strong) NSNetService * service;

@property (nonatomic,strong) NSNetServiceBrowser * serviceBrowser;

@property (nonatomic,copy) DidSearchBlock searchBlock;

@end

@implementation DTServerManager

-(GCDWebServer *)webServer{
    if (_webServer == nil) {
        _webServer = [[GCDWebServer alloc]init];
        
    }
    return _webServer;
}

//-(NSMutableArray *)servers{
//    if (nil == _servers) {
//        _servers = [NSMutableArray array];
//    }
//    return _servers;
//}

-(NSNetServiceBrowser *)serviceBrowser{
    if (nil == _serviceBrowser) {
        _serviceBrowser = [[NSNetServiceBrowser alloc]init];
        _serviceBrowser.delegate = self;
        
    }
    return _serviceBrowser;
}

-(BOOL)isRunning{
    return self.webServer.isRunning;
}

#pragma mark - 开启服务器
-(void)openServer:(void(^)(NSString * baseUrl))block{
    
//    WEAKSELF_DT
    ///默认响应
    [self.webServer addDefaultHandlerForMethod:@"GET"
                              requestClass:[GCDWebServerRequest class]
                              processBlock:^GCDWebServerResponse *(__kindof GCDWebServerRequest *request) {
                                  return [GCDWebServerDataResponse responseWithHTML:@"<html><body><p>Hello！！！</p></body></html>"];
                              }];
    ///请求设备名响应
    [self.webServer addHandlerForMethod:@"GET" pathRegex:kRequestDeviceNamePathRegex requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(__kindof GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
        [[DTResponseManager shareInstance] getServeriPhoneNameWithRequest:request
                                                                completed:^(GCDWebServerDataResponse *response) {
            completionBlock(response);
        }];
        
        
    }];
    ///请求任务清单响应
    [self.webServer addHandlerForMethod:@"GET" pathRegex:kRequestTaskListPathRegex requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(__kindof GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
        [[DTResponseManager shareInstance] getTaskListWithRequest:request
                                                        completed:^(GCDWebServerDataResponse *response) {
            completionBlock(response);
        }];
        
        
    }];
    
    ///请求联系人响应
    [self.webServer addHandlerForMethod:@"GET" pathRegex:kRequestContactsPathRegex requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(__kindof GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
        [[DTResponseManager shareInstance] getContactDataResponseWithRequest:request
                                                                   completed:^(GCDWebServerDataResponse *response) {
            completionBlock(response);
        }];
    }];
    
    ///请求照片响应
    [self.webServer addHandlerForMethod:@"GET" pathRegex:kRequestPhotosPathRegex requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(__kindof GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
        [[DTResponseManager shareInstance] getPhotoDataResponseWithRequest:request
                                                                 completed:^(GCDWebServerDataResponse *response) {
           completionBlock(response);
        }];
        
    }];
    ///请求视频响应
    [self.webServer addHandlerForMethod:@"GET" pathRegex:kRequestVideosPathRegex requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(__kindof GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
        [[DTResponseManager shareInstance] getVideoDataResponseWithRequest:request
                                                                 completed:^(GCDWebServerDataResponse *response) {
             completionBlock(response);
        }];
    }];
    ///请求音乐响应
    [self.webServer addHandlerForMethod:@"GET" pathRegex:kRequestMusicsPathRegex requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(__kindof GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
        [[DTResponseManager shareInstance]getMusicDataResponseWithRequest:request
                                                                completed:^(GCDWebServerDataResponse *response) {
            completionBlock(response);
        }];
        
    }];
    ///请求沙河文件
    [self.webServer addHandlerForMethod:@"GET" pathRegex:kRequestFileDataPathRegex requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(__kindof GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
        [[DTResponseManager shareInstance]getFileDataResponseWithRequest:request
                                                                completed:^(GCDWebServerFileResponse *response) {
                                                                    completionBlock(response);
                                                                }];
        
    }];
    ///客户端告知完成
    [self.webServer addHandlerForMethod:@"GET" pathRegex:kReponseDidFinishPathRegex requestClass:[GCDWebServerRequest class] asyncProcessBlock:^(__kindof GCDWebServerRequest *request, GCDWebServerCompletionBlock completionBlock) {
        
         [[DTResponseManager shareInstance] getDidFinishRequest:request completed:^(GCDWebServerDataResponse *response) {
             completionBlock(response);
         }];
    }];
    NSUInteger initialPort = 8080 ;
    while ([self.webServer startWithPort:initialPort bonjourName:@""] == NO) {
        initialPort ++ ;
    }
    self.baseUrl = self.webServer.serverURL.absoluteString;
    if (block) {
        block(self.baseUrl);
    }
}

#pragma mark - 关闭服务器
-(void)closeServer{
    if (self.webServer.isRunning) {
        [self.webServer stop];
        [self.webServer removeAllHandlers];
    }
}

#pragma mark - 查找服务器
-(void)searchServer:(DidSearchBlock)block{
    self.searchBlock = block;
    
    [self.serviceBrowser searchForServicesOfType:@"_http._tcp" inDomain:@"local."];
}
-(void)connectToService:(NSNetService *)service {
    _service = service;
    service.delegate = self;
    //解析服务
    [service resolveWithTimeout:5];
}
#pragma mark - NSNetServiceBrowserDelegate
-(void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser{
    
}
//搜索发生错误
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *, NSNumber *> *)errorDict{
    if (self.searchBlock) {
        self.searchBlock(NO,nil);
    }
    [self.serviceBrowser stop];
    LOG(@"%s",__func__);
}
///搜索到服务器
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing{
    [self connectToService:service];
}

#pragma mark - NSNetServiceBrowserDelegate
///完成解析
-(void)netServiceDidResolveAddress:(NSNetService *)sender{
    if (sender.addresses.count > 0) {
        NSString * baseurl = [NSString stringWithFormat:@"http://%@:%zd",sender.hostName,sender.port];
        self.baseUrl = baseurl;
        if (self.searchBlock) {
            self.searchBlock(YES,baseurl);
        }
        [self.serviceBrowser stop];
    }
}
///解析失败
-(void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *,NSNumber *> *)errorDict{
    if (self.searchBlock) {
        self.searchBlock(NO,nil);
    }
    [self.serviceBrowser stop];
}

Singleton_M(Instance)
@end
