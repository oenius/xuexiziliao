//
//  MEList.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/4.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "MEList.h"

@interface MEList ()

@end

@implementation MEList

+(NSString *)entityName{
    return @"MEList";
}

+ (NSFetchRequest<MEList *> *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:@"MEList"];
}

@dynamic count;
@dynamic image;
@dynamic list_id;
@dynamic name;
@dynamic order;
@dynamic musics;


@end
