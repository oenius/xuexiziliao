//
//  RemindCellModel.m
//  VoiceRemind
//
//  Created by 何少博 on 16/8/25.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "RemindCellModel.h"

@implementation RemindCellModel

-(instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        _fileName = [dic objectForKey:kFileName];
        _remindTime = [dic objectForKey:kRemindTime];
        _titleName = [dic objectForKey:kTitleName];
        _timeLength = [dic objectForKey:kTimeLength];
        _imageType = [dic objectForKey:kImageType];
        _noticeDate = [dic objectForKey:kNoticeDate];
        _openRemind = [dic objectForKey:kOpenRemind];
        _remindBody = [dic objectForKey:kRemindBody];
        _repeatType = [dic objectForKey:kRepeatType];
        _remindMusic = [dic objectForKey:kRemindMusic];
    }
    return self;
}
+(instancetype)modelWithDic:(NSDictionary*)dic{
    return [[self alloc]initWithDic:dic];
}

@end
