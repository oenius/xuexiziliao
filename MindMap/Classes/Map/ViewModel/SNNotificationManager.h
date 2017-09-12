//
//  SNNotificationManager.h
//  MindMap
//
//  Created by 何少博 on 2017/8/8.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface SNNotificationManager : NSObject

@property (nonatomic,weak) id host;

-(instancetype)initWithHost:(id)host;
-(void)registerNotification;
-(void)removeNotification;

@end
