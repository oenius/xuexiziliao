//
//  DTFileTransferViewModel.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/31.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTFileTransferViewModel.h"
#import "DTDwonTask.h"

@interface DTFileTransferViewModel ()

@property (strong,nonatomic) NSMutableArray * tasks;

@end


@implementation DTFileTransferViewModel


-(NSMutableArray *)tasks{
    if (!_tasks) {
        _tasks = [NSMutableArray array];
    }
    return _tasks;
}

- (NSInteger)numberOfSectionsInTableView{
    return 1;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section{
    return self.tasks.count;
}

-(DTDwonTask *)modelWithIndexPath:(NSIndexPath *)indexPath{
    return self.tasks[indexPath.row];
}

-(NSIndexPath *)indexPathWithModel:(DTDwonTask *)model{
    NSUInteger index = [self.tasks indexOfObject:model];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    return indexPath;
}

-(NSArray *)getAllTasks{
    return self.tasks;
}

-(void)generateTaskWithTaskList:(NSArray *)taskList andBaseUrl:(NSString *)baseUrl{
    for (NSDictionary * dic in taskList) {
        NSString * idfr = dic[kDataIDKey];
        DTDwonTask * task = [DTDwonTask taskWithBaseUlr:baseUrl andIDFR:idfr];
        task.name = dic[kDataNameKey];
        NSString * type = dic[kDataTypeKey];
        task.downType = [self getFileType:type];
        [self.tasks addObject:task];
    }
}

-(DTFileType)getFileType:(NSString *)typestr{
    if ([typestr isEqualToString:kDataTypeContactKey]) {
        return DTFileTypeContact;
    }
    else if ([typestr isEqualToString:kDataTypePhotoKey]) {
        return DTFileTypePhtoto;
    }
    else if ([typestr isEqualToString:kDataTypeVideoKey]) {
        return DTFileTypeVideo;
    }
    else if ([typestr isEqualToString:kDataTypeMusicKey]) {
        return DTFileTypeMusic;
    }
    return -1;
}

@end
