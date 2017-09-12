//
//  NSNumber+x.m
//  iWeibo
//
//  Created by czh0766 on 12-4-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSNumber+x.h"

static NSString* HEX_TABLE[] = {@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",
    @"A",@"B",@"C",@"D",@"E",@"F"};

@implementation NSNumber (NSNumberx)

+(NSNumber *)numberWithHex:(NSString*)hexValue {
    hexValue = [hexValue lowercaseString];
    if ([hexValue hasPrefix:@"0x"]) {
        hexValue = [hexValue substringFromIndex:2];
    }
    int ret = 0;
    const char* ch = [hexValue UTF8String];
    int length = hexValue.length;
    for (int i = length - 1; i >= 0; i--) {
        if (ch[i] >= '0' && ch[i] <= '9') { 
            ret += (ch[i] - '0') * powf(16, (length - 1 - i));
        } else if(ch[i] >= 'a' && ch[i] <= 'f') {
            ret += (ch[i] - 'a' + 10) * powf(16, (length - 1 - i));
        }
    }
    return [NSNumber numberWithInt:ret];
}

-(NSString*) hexStringValue {
    NSMutableString* value = [NSMutableString stringWithCapacity:5];
    int src = [self intValue];

    while (src >= 16) {
    int b = src % 16;
    [value insertString:HEX_TABLE[b] atIndex:0];
        src /= 16;
    } 

    [value insertString:HEX_TABLE[src] atIndex:0];
    return value;
}

@end
