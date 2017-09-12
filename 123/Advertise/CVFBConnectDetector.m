//
//  CVFBConnectDetector.m
//  Common
//
//  Created by mayuan on 2017/6/9.
//  Copyright © 2017年 camory. All rights reserved.
//

#import "CVFBConnectDetector.h"
#import "Macros.h"

@implementation CVFBConnectDetector

static CVFBConnectDetector *detector = nil;

+ (CVFBConnectDetector *)shareInstance{
    if(detector != nil){
        return detector;
    }
    detector = [[CVFBConnectDetector alloc] init];
    return detector;
}

- (id)init{
    self = [super init];
    if (!self) {
        self.isFacebookReachable = YES;
        self.haveDetectNetwork = NO;
    }
    return self;
}

- (void) detectFacebookAdReachability {
    
//     https://graph.facebook.com/network_ads_common/
//     https://graph.facebook.com
    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com"];
    //2.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:3];
 
    //3.发送请求
    /*
     发送异步请求
     
     request              : 请求对象
     queue                : 回调方法在哪个线程中执行，如果是主队列则block在主线程中执行，非主队列则在子线程中执行
     completionHandler    : 接受到响应的时候执行该block中的代码
     response：响应头信息
     data：响应体
     connectionError：错误信息，如果请求失败，那么该参数有值
     **/
    //TODO:call back twice
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
         LOG(@"%s, response:%@, data: %@, connectionError: %@",__func__, response, data, connectionError);
        self.haveDetectNetwork = YES;
        if (response == nil) {
            NSLog(@"没有网络");
            self.isFacebookReachable = NO;
        }
        else{
            self.isFacebookReachable = YES;
            NSLog(@"网络是通的");
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:keyFacebookReachabilityNotification object:@(_isFacebookReachable)];
        
    }];
    
    
}



@end
