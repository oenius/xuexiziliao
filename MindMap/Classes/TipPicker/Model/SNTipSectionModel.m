//
//  SNTipSectionModel.m
//  MindMap
//
//  Created by 何少博 on 2017/8/17.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNTipSectionModel.h"
#import "SNTipModel.h"

@interface SNTipSectionModel ()



@end

@implementation SNTipSectionModel

-(instancetype)initWithDic:(NSDictionary *)dic{
    self = [super initWithDic:dic];
    if (self) {
        NSString * titleKey = dic[@"title"];
        NSArray * tips = dic[@"tips"];
        self.childs = [NSMutableArray array];
        for (NSDictionary * tipDic in tips) {
            SNTipModel * model = [[SNTipModel alloc]initWithNSDictionary:tipDic];
            [self.childs addObject:model];
        }
        self.name = NSLocalizedString(titleKey, @"");
    }
    return self;
}

@end
