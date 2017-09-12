//
//  SNStyleSectionModel.m
//  MindMap
//
//  Created by 何少博 on 2017/8/23.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNStyleSectionModel.h"
#import "SNStyleModel.h"
@implementation SNStyleSectionModel



-(instancetype)initWithDic:(NSDictionary *)dic{
    self = [super initWithDic:dic];
    if (self) {
        NSString * nameKey = dic[@"name"];
        NSArray * tips = dic[@"styles"];
        self.childs = [NSMutableArray array];
        for (NSDictionary * tipDic in tips) {
            SNStyleModel * model = [[SNStyleModel alloc]initWithNSDictionary:tipDic];
            [self.childs addObject:model];
        }
        self.name = NSLocalizedString(nameKey, @"");
    }
    return self;
}


@end
