//
//  MEEqualizer.h
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/4.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface MEEqualizer : NSManagedObject

+(nullable NSString *)entityName;

+ (nonnull NSFetchRequest<MEEqualizer *> *)fetchRequest;

@property (nonatomic) float eq_1k;
@property (nonatomic) float eq_2k;
@property (nonatomic) float eq_4k;
@property (nonatomic) float eq_8k;
@property (nonatomic) float eq_16k;
@property (nonatomic) float eq_31;
@property (nonatomic) float eq_62;
@property (nonatomic) float eq_125;
@property (nonatomic) float eq_250;
@property (nonatomic) float eq_500;
@property (nullable, nonatomic, copy) NSString *eq_id;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) double order;

@end
