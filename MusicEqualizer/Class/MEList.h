//
//  MEList.h
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/4.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MEMusic;

@interface MEList : NSManagedObject

+(nullable NSString *)entityName;

+ (nonnull NSFetchRequest<MEList *> *)fetchRequest;

@property (nonatomic) int16_t count;
@property (nullable, nonatomic, retain) NSData *image;
@property (nullable, nonatomic, copy) NSString *list_id;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) double order;
@property (nullable, nonatomic, retain) NSSet<MEMusic *> *musics;

- (void)addMusicsObject:(nonnull MEMusic *)value;
- (void)removeMusicsObject:(nonnull MEMusic *)value;
- (void)addMusics:(nonnull NSSet<MEMusic *> *)values;
- (void)removeMusics:(nonnull NSSet<MEMusic *> *)values;

@end
