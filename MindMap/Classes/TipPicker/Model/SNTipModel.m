//
//  SNTipModel.m
//  MindMap
//
//  Created by 何少博 on 2017/8/17.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNTipModel.h"

@implementation SNTipModel
-(instancetype)initWithNSDictionary:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.name = dic[@"tipName"];
    }
    return self;
}
@end
