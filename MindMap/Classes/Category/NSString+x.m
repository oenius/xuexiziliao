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
        unsigned long NSGBKStringEncoding =  CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        str = [[NSString alloc] initWithBytes:cstring length:strlen(cstring)
                                     encoding:NSGBKStringEncoding];
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
/**
 *  密码筛选
 */
+(BOOL) isAllowedThePassword:(NSString*)password{
    NSInteger lengh = password.length;
    if (lengh>30||lengh<6) return NO;
    for (int i = 0; i < lengh; i++) {
        unichar ch = [password characterAtIndex:i];
        if ((ch < 33)||(ch > 126)) return NO;
    }
    return YES;
}
@end
