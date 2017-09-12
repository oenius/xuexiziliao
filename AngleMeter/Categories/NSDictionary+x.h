//
//  NSDictionary+x.h
//  TestArchive
//
//  Created by mayuan on 13-3-9.
//  Copyright (c) 2013年 mayuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (x)

- (int)intForKey:(id)key;

- (int)floatForKey:(id)key;

- (int)boolForKey:(id)key;

- (id)objectForKey:(id)key defaults:(id)defValue;

- (int)intForKey:(id)key defaults:(int)defValue;

- (float)floatForKey:(id)key defaults:(float)defValue;

- (BOOL)boolForKey:(id)key defaults:(BOOL)defValue;

- (BOOL)containsKey:(id)key;

@end
///


@interface NSMutableDictionary (NSMutableDictionaryx)

- (void)setInt:(int)value forKey:(id)aKey;

- (void)setFloat:(float)value forKey:(id)aKey;

- (void)setBool:(BOOL)value forKey:(id)aKey;


@end
