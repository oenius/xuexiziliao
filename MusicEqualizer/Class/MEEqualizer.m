//
//  MEEqualizer.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/4.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "MEEqualizer.h"

@interface MEEqualizer ()

@end

@implementation MEEqualizer

+(NSString *)entityName{
    return @"MEEqualizer";
}

+ (NSFetchRequest<MEEqualizer *> *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:@"MEEqualizer"];
}

@dynamic eq_1k;
@dynamic eq_2k;
@dynamic eq_4k;
@dynamic eq_8k;
@dynamic eq_16k;
@dynamic eq_31;
@dynamic eq_62;
@dynamic eq_125;
@dynamic eq_250;
@dynamic eq_500;
@dynamic eq_id;
@dynamic name;
@dynamic order;

@end
