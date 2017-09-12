//
//  DTResponseManager.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/22.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GCDWebServer.h>
#import <GCDWebServerDataResponse.h>
#import <GCDWebServerFileResponse.h>
#import "DTSingleton.h"

@interface DTResponseManager : NSObject

@property (nonatomic,strong) NSArray * contactSelects;
@property (nonatomic,strong) NSArray * photoSelects;
@property (nonatomic,strong) NSArray * videoSelects;
@property (nonatomic,strong) NSArray * musicSelects;

//-(GCDWebServerDataResponse *)getServeriPhoneNameWithRequest:(GCDWebServerRequest *)request;
//-(GCDWebServerDataResponse *)getTaskListWithRequest:(GCDWebServerRequest *)request;
//-(GCDWebServerDataResponse *)getContactDataResponseWithRequest:(GCDWebServerRequest *)request;
//-(GCDWebServerDataResponse *)getPhotoDataResponseWithRequest:(GCDWebServerRequest *)request;
//-(GCDWebServerDataResponse *)getVideoDataResponseWithRequest:(GCDWebServerRequest *)request;
//-(GCDWebServerDataResponse *)getMusicDataResponseWithRequest:(GCDWebServerRequest *)request;

-(void)getServeriPhoneNameWithRequest:(GCDWebServerRequest *)request
                            completed:(void(^)(GCDWebServerDataResponse * response))completed;

-(void)getTaskListWithRequest:(GCDWebServerRequest *)request
                    completed:(void(^)(GCDWebServerDataResponse * response))completed;

-(void)getContactDataResponseWithRequest:(GCDWebServerRequest *)request
                               completed:(void(^)(GCDWebServerDataResponse * response))completed;

-(void)getPhotoDataResponseWithRequest:(GCDWebServerRequest *)request
                             completed:(void(^)(GCDWebServerDataResponse * response))completed;

-(void)getVideoDataResponseWithRequest:(GCDWebServerRequest *)request
                             completed:(void(^)(GCDWebServerDataResponse * response))completed;

-(void)getMusicDataResponseWithRequest:(GCDWebServerRequest *)request
                             completed:(void(^)(GCDWebServerDataResponse * response))completed;

-(void)getFileDataResponseWithRequest:(GCDWebServerRequest *)request
                             completed:(void(^)(GCDWebServerFileResponse * response))completed;

-(void)getDidFinishRequest:(GCDWebServerRequest *)request
                 completed:(void(^)(GCDWebServerDataResponse* response))completed;
Singleton_H(Instance);
@end

