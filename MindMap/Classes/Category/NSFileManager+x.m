//
//  NSFileManager+NSFileManagerx.m
//  MemoLite
//
//  Created by czh0766 on 12-1-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSFileManager+x.h"

@implementation NSFileManager (x)

+(NSString *)documentPath {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path0 = [paths objectAtIndex:0];
    return path0;
}

+(NSString*) pathInDocuments:(NSString*)path {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path0 = [paths objectAtIndex:0];
    return path ? [path0 stringByAppendingPathComponent:path] : path0;  
}

+(NSString *)pathInLibrary:(NSString *)path {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* path0 = [paths objectAtIndex:0];
    return path ? [path0 stringByAppendingPathComponent:path] : path0;  
}

+(NSString *)pathInLibraryCaches:(NSString *)path {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* path0 = [paths objectAtIndex:0];
    return path ? [path0 stringByAppendingPathComponent:path] : path0;
}

-(NSArray *)subpathsInDocuments:(NSString *)directory {
    NSArray* subfiles = [self subpathsAtPath:[NSFileManager pathInDocuments:directory]];
    NSMutableArray* subpaths = [NSMutableArray array];
    for (NSString* file in subfiles) {
        if (directory) {
            [subpaths addObject:[NSFileManager pathInDocuments:
                                 [NSString stringWithFormat:@"%@/%@", directory, file]]];
        } else {
            [subpaths addObject:[NSFileManager pathInDocuments:file]];
        }
        
    }
    return subpaths;
}
-(NSArray *)contentsFullPathOfDirectoryAtPath:(NSString *)directory{
    NSArray *contentArray = [self contentsOfDirectoryAtPath:directory error:nil];
    NSMutableArray *contentPaths = [NSMutableArray array];
    for (NSString *content in contentArray) {
        [contentPaths addObject:[NSString stringWithFormat:@"%@/%@",directory,content]];
    }
    return contentPaths;
    
}

-(BOOL)isDirectory:(NSString *)path{
    BOOL isDir;
   BOOL isExist = [self fileExistsAtPath:path isDirectory:&isDir];
    if (isExist && isDir) {
        return YES;
    }
    return NO;
}

-(NSArray *)subpathsInLibrary:(NSString *)directory {
    NSArray* subfiles = [self subpathsAtPath:[NSFileManager pathInLibrary:directory]];
    NSMutableArray* subpaths = [NSMutableArray array];
    for (NSString* file in subfiles) {
        if (directory) {
            [subpaths addObject:[NSFileManager pathInLibrary:
                                 [NSString stringWithFormat:@"%@/%@", directory, file]]];
        } else {
            [subpaths addObject:[NSFileManager pathInLibrary:file]];
        }
    }
    return subpaths;
}

-(BOOL) deleteFileAtPath:(NSString*)path {
    return [self removeItemAtPath:path error:nil];
}

@end
