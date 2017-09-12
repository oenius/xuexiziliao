//
//  NSString+x.h
//  TestArchive
//
//  Created by mayuan on 13-3-9.
//  Copyright (c) 2013年 mayuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (x)

+ (NSString *) checkString:(NSString *)str  replaceIfNotValid: (NSString *)replace;

+(NSString*) stringWithFileSize:(UInt64)size;

+(NSString*) stringWithUTF8ORGBKString:(const char *)cstring;

-(NSString*) extension;
/**
 *  密码筛选
 */
+(BOOL) isAllowedThePassword:(NSString*)password;


@end
