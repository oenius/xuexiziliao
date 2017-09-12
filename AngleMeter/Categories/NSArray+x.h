//
//  NSArray+x.h
//  TestArchive
//
//  Created by mayuan on 13-3-10.
//  Copyright (c) 2013年 mayuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (x)

-(BOOL) writeToFile:(NSString *)path forKey:(NSString*)key;

-(BOOL) isEmpty;

-(id) firstObject;

-(BOOL) containsObjectWithBlock:(BOOL (^)(id))block;

-(NSArray*) subarrayWithBlock:(BOOL (^)(id))block;

-(NSArray*) arrayGenWithBlock:(id (^)(id))block;

@end

@interface NSMutableArray (x)

-(void) removeObjectsWithCondition:(BOOL (^)(id))condition;

-(void) removeFirstObject;

+(id) arrayWithContentsOfFile:(NSString *)path forKey:(NSString*)key;


@end
