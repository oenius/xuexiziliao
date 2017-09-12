//
//  TextViewModel.m
//  InstaMessage
//
//  Created by 何少博 on 16/8/1.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "TextViewModel.h"

@implementation TextViewModel

-(instancetype)initWithDictionary:(NSDictionary*)dictionary{
    self = [super init];
    if (self) {
        self.imageName = [dictionary objectForKey:@"imageName"];
        self.acrionTag = [dictionary objectForKey:@"actionTag"];
    }
    return self;
}

+(instancetype)textViewModelWithDictionary:(NSDictionary *)dictionary{
    return  [[self alloc]initWithDictionary:dictionary];
}

@end
