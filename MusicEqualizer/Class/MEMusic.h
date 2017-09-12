//
//  MEMusic.h
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/4.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "MEList.h"

@interface MEMusic : NSManagedObject

+(nullable NSString*)entityName;

+ (nonnull NSFetchRequest<MEMusic *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *describe;
@property (nullable, nonatomic, retain) NSData *image;
@property (nullable, nonatomic, copy) NSString *iPodUrl;
@property (nonatomic) BOOL isFavorite;
@property (nonatomic) BOOL isiPod;
@property (nullable, nonatomic, copy) NSString *localUrl;
@property (nonatomic) int64_t music_id;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) double order;
@property (nullable, nonatomic, copy) NSString *singer;
@property (nonatomic) BOOL isEditState;
@property (nonatomic) float duration;
@property (nullable, nonatomic, retain) MEList *list;

@end
