//
//  SNNotificationManager.m
//  MindMap
//
//  Created by 何少博 on 2017/8/8.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNNotificationManager.h"



@implementation SNNotificationManager

-(instancetype)initWithHost:(id)host{
    self = [super init];
    if (self) {
        self.host = host;
        [self registerNotification];
    }
    return self;
}



-(void)registerNotification{
    
}
-(void)removeNotification{
    
}

@end
