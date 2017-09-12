//
//  DTResponseManager.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/22.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTResponseManager.h"
#import "DTContactViewModel.h"
#import "DTPhotoViewModel.h"
#import "DTVideoViewModel.h"
//#import "DTMusicViewModel.h"
@implementation DTResponseManager

///获取设备名称
-(void)getServeriPhoneNameWithRequest:(GCDWebServerRequest *)request completed:(void (^)(GCDWebServerDataResponse *))completed{
    NSString * reuqestiPhoneName = [self getIDFRWithRequest:request];
    
    /* TODO: 发通知接收到设备名称 */
    [[NSNotificationCenter defaultCenter] postNotificationName:kClientiPhoneNameNotition object:reuqestiPhoneName];
    GCDWebServerDataResponse * response = [self loadDeviceNameWithIDFR:reuqestiPhoneName];
    completed(response);
}
///获取任务列表
-(void)getTaskListWithRequest:(GCDWebServerRequest *)request completed:(void (^)(GCDWebServerDataResponse *))completed{
     
    NSString * idfr = [self getIDFRWithRequest:request];
    GCDWebServerDataResponse * response = [self loadTaskListWithIDFR:idfr];
    completed(response);
}

///获取联系人

-(void)getContactDataResponseWithRequest:(GCDWebServerRequest *)request completed:(void (^)(GCDWebServerDataResponse *))completed{
    
    NSString * idfr = [self getIDFRWithRequest:request];
    [self loadDataType:DTFileTypeContact IDFR:idfr completed:^(GCDWebServerDataResponse *response) {
        completed(response);
    }];
}

///获取照片

-(void)getPhotoDataResponseWithRequest:(GCDWebServerRequest *)request completed:(void (^)(GCDWebServerDataResponse *))completed{
    
    NSString * idfr = [self getIDFRWithRequest:request];
    [self loadDataType:DTFileTypePhtoto IDFR:idfr completed:^(GCDWebServerDataResponse *response) {
        completed(response);
    }];
}

///获取视频

-(void)getVideoDataResponseWithRequest:(GCDWebServerRequest *)request completed:(void (^)(GCDWebServerDataResponse *))completed{
    
    NSString * idfr = [self getIDFRWithRequest:request];
    [self loadDataType:DTFileTypeVideo IDFR:idfr completed:^(GCDWebServerDataResponse *response) {
        completed(response);
    }];
}

///获取音乐
-(void)getMusicDataResponseWithRequest:(GCDWebServerRequest *)request
                             completed:(void(^)(GCDWebServerDataResponse * response))completed{
    
    NSString * idfr = [self getIDFRWithRequest:request];
    
    [self loadDataType:DTFileTypeMusic IDFR:idfr completed:^(GCDWebServerDataResponse *response) {
        completed(response);
    }];
}
///获取沙盒文件
-(void)getFileDataResponseWithRequest:(GCDWebServerRequest *)request
                            completed:(void(^)(GCDWebServerFileResponse* response))completed{
    NSString * idfr = [self getIDFRWithRequest:request];
    
    [self loadFileDataWithIDFR:idfr completed:^(GCDWebServerFileResponse *response) {
        completed(response);
    }];
}

-(void)getDidFinishRequest:(GCDWebServerRequest *)request
                            completed:(void(^)(GCDWebServerDataResponse* response))completed{
    NSString * idfr = [self getIDFRWithRequest:request];GCDWebServerDataResponse * reponse = [GCDWebServerDataResponse responseWithHTML:@"<html><body><p>yishoudao,zhidaoliao ！！！</p></body></html>"];
    completed(reponse);
    NSString * filePath = [NSTemporaryDirectory() stringByAppendingString:idfr];
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath] ) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}


///获取资源ID 或设备名称
-(NSString *)getIDFRWithRequest:(GCDWebServerRequest *)request{
    
    NSString * urlStr = request.URL.absoluteString;
    NSString * idfr = nil;
    NSRange  range;
    if ([urlStr containsString:kRequestDeviceNamePath]) {
        range= [urlStr rangeOfString:kRequestDeviceNamePath];
    }
    else if ([urlStr containsString:kRequestTaskListPath]) {
        range= [urlStr rangeOfString:kRequestTaskListPath];
    }
    else if ([urlStr containsString:kRequestContactsPath]) {
        range= [urlStr rangeOfString:kRequestContactsPath];
    }
    else if ([urlStr containsString:kRequestPhotosPath]){
        range = [urlStr rangeOfString:kRequestPhotosPath];
    }
    else if ([urlStr containsString:kRequestVideosPath]){
        range = [urlStr rangeOfString:kRequestVideosPath];
    }
    else if ([urlStr containsString:kRequestMusicsPath]){
        range = [urlStr rangeOfString:kRequestMusicsPath];
    }
    else if ([urlStr containsString:kRequestFileDataPath]){
        range = [urlStr rangeOfString:kRequestFileDataPath];
    }
    else if ([urlStr containsString:kReponseDidFinishPath]){
        range = [urlStr rangeOfString:kReponseDidFinishPath];
    }
    //urlStr: requestVideos?IDFR=6884DF28-6E04-4A30-A457-3215E872D0E0/L0/001
    idfr = [urlStr substringFromIndex:range.location + range.length+6];
    idfr = [idfr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return idfr;
}
#pragma mark - 加载资源
-(GCDWebServerDataResponse *)loadDeviceNameWithIDFR:(NSString *)idfr{
    NSString * deviveName = [DTConstAndLocal getDeviceName];
    GCDWebServerDataResponse * response = [GCDWebServerDataResponse responseWithJSONObject:@{kServeriPhoneNameKey:deviveName}];
    return response;
}

-(GCDWebServerDataResponse *)loadTaskListWithIDFR:(NSString *)idfr{
    
    NSArray * dataArray = [self getTaskListArray];
    GCDWebServerDataResponse * response  = [[GCDWebServerDataResponse alloc]initWithJSONObject:dataArray];
    return response;
}
///获取沙盒文件
-(void)loadFileDataWithIDFR:(NSString *)idfr completed:(void(^)(GCDWebServerFileResponse * response)) completed{
    NSString * filePath = [NSTemporaryDirectory() stringByAppendingString:idfr];
    GCDWebServerFileResponse * response = [GCDWebServerFileResponse responseWithFile:filePath isAttachment:YES];
    completed(response);
}

-(void)loadDataType:(DTFileType)type IDFR:(NSString *)idfr completed:(void(^)(GCDWebServerDataResponse * response)) completed{
    
//    NSPredicate *preTemplate = [NSPredicate predicateWithFormat:@"SELF.IDFR==$IDFR"];
//    NSDictionary *dic= @{@"IDFR":idfr};
//    NSPredicate *predicate = [preTemplate predicateWithSubstitutionVariables: dic];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF.IDFR = %@",idfr];
    
    [self getDataWithType:type predicate:predicate completed:^(NSData *data) {
        NSString * contentType = [self getContentType:type];
        GCDWebServerDataResponse * response = [[GCDWebServerDataResponse alloc]initWithData:data
                                                                                contentType:contentType];
        completed(response);
    }];
}

-(void)getDataWithType:(DTFileType)type predicate:(NSPredicate *)predicate completed:(void(^)(NSData * data)) completed{
    NSArray * array = nil;
    Class  viewModel = [DTDataBaseViewModel class];
    switch (type) {
        case DTFileTypeContact:
            array = [self.contactSelects filteredArrayUsingPredicate:predicate];
            viewModel = [DTContactViewModel class];
            break;
        case DTFileTypePhtoto:
            array = [self.photoSelects filteredArrayUsingPredicate:predicate];
            viewModel = [DTPhotoViewModel class];
            break;
        case DTFileTypeVideo:
            array = [self.videoSelects filteredArrayUsingPredicate:predicate];
            viewModel = [DTVideoViewModel class];
            break;
        case DTFileTypeMusic:
//            array = [self.musicSelects filteredArrayUsingPredicate:predicate];
//            viewModel = [DTMusicViewModel class];
            break;
        default:
            break;
    }
    if (array.count <= 0 || array == nil) {completed([@"error: NSData==nil" dataUsingEncoding:NSUTF8StringEncoding]);return; }
    id model = array.firstObject;
    [viewModel archivedModel:model completed:^(NSData *data) {
        if (data == nil) {
            completed([@"error: NSData==nil" dataUsingEncoding:NSUTF8StringEncoding]);
            return ;
        }else{
            completed(data);
        }
    }];
    
}
-(NSString *)getContentType:(DTFileType)type{
    return @"application/octet-stream";
//    switch (type) {
//        case DTFileChoiceTypeContact:
//            return @"dt/contact";
//            break;
//        case DTFileChoiceTypePhtoto:
//            return @"dt/photo";
//            break;
//        case DTFileChoiceTypeVideo:
//            return @"dt/video";
//            break;
//        case DTFileChoiceTypeMusic:
//            return @"dt/music";
//            break;
//        default:
//            return @"dt/unknown";
//            break;
//    }
}
#pragma mark - 获取任务列表

-(NSArray *)getTaskListArray{
    NSMutableArray * list = [NSMutableArray array];
    for (DTContactModel * model in self.contactSelects) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        dict[kDataTypeKey] = kDataTypeContactKey;
        dict[kDataIDKey] = model.IDFR;
        dict[kDataNameKey] = model.name;
        [list addObject:dict];
    }
    
    for (DTAssetModel * model in self.photoSelects) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        dict[kDataTypeKey] = kDataTypePhotoKey;
        dict[kDataIDKey] = model.IDFR;
        dict[kDataNameKey] = model.name;
        [list addObject:dict];
    }
    
    for (DTAssetModel * model in self.videoSelects) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        dict[kDataTypeKey] = kDataTypeVideoKey;
        dict[kDataIDKey] = [model.IDFR stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        dict[kDataNameKey] = model.name;
        [list addObject:dict];
    }
    
//    for (DTMusicModel * model in self.musicSelects) {
//        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
//        dict[kDataTypeKey] = kDataTypeMusicKey;
//        dict[kDataIDKey] = model.IDFR;
//        dict[kDataNameKey] = model.name;
//        [list addObject:dict];
//    }
    return list;
}




Singleton_M(Instance);
@end

