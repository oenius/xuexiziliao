//
//  NSDictionary+x.m
//  TestArchive
//
//  Created by mayuan on 13-3-9.
//  Copyright (c) 2013年 mayuan. All rights reserved.
//

#import "NSDictionary+x.h"

@implementation NSDictionary (x)

- (int)intForKey:(id)key {
    return [[self objectForKey:key] intValue];
}

- (int)floatForKey:(id)key {
    return [[self objectForKey:key] floatValue];
}

- (int)boolForKey:(id)key {
    return [[self objectForKey:key] boolValue];
}

- (id)objectForKey:(id)key defaults:(id)defValue {
    id obj = [self objectForKey:key];
    return obj ? obj : defValue;
}

- (int)intForKey:(id)key defaults:(int)defValue {
    id obj = [self objectForKey:key];
    return obj ? [obj intValue] : defValue;
}

- (float)floatForKey:(id)key defaults:(float)defValue {
    id obj = [self objectForKey:key];
    return obj ? [obj floatValue] : defValue;
}

- (BOOL)boolForKey:(id)key defaults:(BOOL)defValue {
    id obj = [self objectForKey:key];
    return obj ? [obj boolValue] : defValue;
}

- (BOOL)containsKey:(id)key {
    return [self.allKeys containsObject:key];
}

@end

//
@implementation NSMutableDictionary (NSMutableDictionaryx)

- (void)setInt:(int)value forKey:(id)aKey {
    [self setObject:[NSNumber numberWithInt:value] forKey:aKey];
}

- (void)setFloat:(float)value forKey:(id)aKey {
    [self setObject:[NSNumber numberWithFloat:value] forKey:aKey];
}

- (void)setBool:(BOOL)value forKey:(id)aKey {
    [self setObject:[NSNumber numberWithBool:value] forKey:aKey];
}



@end
