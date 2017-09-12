//
//  NSString+x.m
//  TestArchive
//
//  Created by mayuan on 13-3-9.
//  Copyright (c) 2013年 mayuan. All rights reserved.
//

#import "NSString+x.h"
@implementation NSString (x)

+ (NSString *) checkString: (NSString *)str  replaceIfNotValid: (NSString *)replace
{
    if (str == nil) return replace;
    
    NSString *_str = [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([_str length] > 0) return str;
    else return replace;
}

+(NSString*) stringWithFileSize:(UInt64)size {
    if (size < 1000) {
        return [NSString stringWithFormat:@"%lluB", size];
    } else if(size < 1000 * 1024){
        return [NSString stringWithFormat:@"%.1fKB", size / 1024.0];
    } else if(size < 1000 * 1024 * 1024){
        return [NSString stringWithFormat:@"%.1fMB", size / (1024.0 * 1024)];
    } else {
        return [NSString stringWithFormat:@"%.1fGB", size / (1024.0 * 1024 * 1024)];
    }
}

+(NSString*) stringWithUTF8ORGBKString:(const char *)cstring {
    NSString* str = [NSString stringWithUTF8String:cstring];
    if (!str) {
        str = [[NSString alloc] initWithBytes:cstring length:strlen(cstring)
                                     encoding:NSUTF8StringEncoding];
    }
    return str;
}
-(NSString*) extension {
    return [self stringWithRegex:@".+\\.(.+)"];
}
-(NSString*) stringWithRegex:(NSString*)regex {
    return [self stringWithRegex:regex rangeIndex:1];
}
-(NSString*) stringWithRegex:(NSString*)regex rangeIndex:(int)index {
    NSRegularExpression* o_regex = [NSRegularExpression regularExpressionWithPattern:regex
                                                                             options:0 error:nil];
    NSTextCheckingResult* ret = [o_regex firstMatchInString:self options:0
                                                      range:NSMakeRange(0, self.length)];
    if (ret && ret.range.location != NSNotFound) {
        if (ret.numberOfRanges > 1) {
            return [self substringWithRange:[ret rangeAtIndex:index]];
        } else {
            return [self substringWithRange:ret.range];
        }
    }
    
    return nil;
}
- (NSComparisonResult)compareBigToSmail:(NSString *)string{
    double selfNum = self.doubleValue;
    double otherNum = string.doubleValue;
//    {NSOrderedAscending = -1L, NSOrderedSame, NSOrderedDescending
    if (selfNum>otherNum) {
        return NSOrderedAscending;
    }
    else if(selfNum == otherNum){
        return NSOrderedSame;
    }
    else{
        return NSOrderedDescending;
    }
}

@end
