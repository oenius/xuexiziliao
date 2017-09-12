//
//  MEMusic.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/4.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "MEMusic.h"

@interface MEMusic ()

@end

@implementation MEMusic


+(NSString *)entityName{
    
    return @"MEMusic";
}

+ (NSFetchRequest<MEMusic *> *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:@"MEMusic"];
}


@dynamic describe;
@dynamic image;
@dynamic iPodUrl;
@dynamic isFavorite;
@dynamic isiPod;
@dynamic localUrl;
@dynamic music_id;
@dynamic name;
@dynamic order;
@dynamic singer;
@dynamic isEditState;
@dynamic duration;
@dynamic list;

@end
