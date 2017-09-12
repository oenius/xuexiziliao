//
//  DTFileTransferViewModel.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/31.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DTDwonTask;
@interface DTFileTransferViewModel : NSObject

- (NSInteger)numberOfSectionsInTableView;

- (NSInteger)numberOfRowsInSection:(NSInteger)section;

-(DTDwonTask *)modelWithIndexPath:(NSIndexPath *)indexPath;

-(NSIndexPath *)indexPathWithModel:(DTDwonTask *)model;

-(NSArray *)getAllTasks;

-(void)generateTaskWithTaskList:(NSArray *)taskList andBaseUrl:(NSString *)baseUrl;


@end


