//
//  SNStyleModel.m
//  MindMap
//
//  Created by 何少博 on 2017/8/23.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNStyleModel.h"

@implementation SNStyleModel
-(instancetype)initWithNSDictionary:(NSDictionary *)dic{
    self = [super initWithNSDictionary:dic];
    if (self) {
        self.name = dic[@"styleName"];
        self.imageName = dic[@"imageName"];
    }
    return self;
}
@end
