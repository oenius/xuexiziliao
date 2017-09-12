//
//  SNNodeAsset.m
//  MindMap
//
//  Created by 何少博 on 2017/8/10.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNNodeAsset.h"

#import "SNNodeView.h"
static NSString *const KeyNameDisplayName = @"displayName";
static NSString *const KeyNameThumb = @"thumb";
static NSString *const KeyNameBgColor = @"bgColor";
static NSString *const KeyNameModifiedDate = @"modifiedDate";
static NSString *const KeyNameCreatDate = @"creatDate";

@implementation SNNodeAsset

-(instancetype)init{
    self = [self initWithAssetPath:nil];
    return self;
}

-(instancetype)initWithAssetPath:(NSString *)path{
    self = [super init];
    if (self) {
        [self setupWithPath:path];
        self.creatDate = [NSDate date];
        self.modifiedDate = [NSDate date];
    }
    return self;
}

-(void)setupWithPath:(NSString *)path{
    self.assetPath = [path copy];
    self.mapPath = [path stringByReplacingOccurrencesOfString:kAssetSuffix withString:kMapSuffix];
    self.displayName = [[path lastPathComponent] stringByDeletingPathExtension];
}


-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.displayName forKey:KeyNameDisplayName];
    [aCoder encodeObject:UIImageJPEGRepresentation(self.thumb, 1) forKey:KeyNameThumb];
    [aCoder encodeObject:self.modifiedDate forKey:KeyNameModifiedDate];
    [aCoder encodeObject:self.creatDate forKey:KeyNameCreatDate];
    [aCoder encodeObject:self.bgColor forKey:KeyNameBgColor];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        _displayName = [aDecoder decodeObjectForKey:KeyNameDisplayName];
        NSData * data = [aDecoder decodeObjectForKey:KeyNameThumb];
        _thumb = [UIImage imageWithData:data];
        _creatDate = [aDecoder decodeObjectForKey:KeyNameCreatDate];
        _modifiedDate = [aDecoder decodeObjectForKey:KeyNameModifiedDate];
        _bgColor = [aDecoder decodeObjectForKey:KeyNameBgColor];
    }
    return self;
}


-(NSArray *)load{
    NSURL * fileUrl = [NSURL fileURLWithPath:self.mapPath];
    NSData * data = [NSData dataWithContentsOfURL:fileUrl];
    if (data == nil) {
        return nil;
    }
    NSKeyedUnarchiver * unarchive = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    NSArray * result = [unarchive decodeObject];
    return result;
}

-(NSData *)save:(NSArray<SNNodeView *> *)nodes autoReName:(BOOL) autoReName{
    if (autoReName) {
        while ([[NSFileManager defaultManager] fileExistsAtPath:self.assetPath]) {
            self.assetPath = [self.assetPath stringByReplacingOccurrencesOfString:@"." withString:@"_1."];
        }
        self.mapPath = [self.assetPath stringByReplacingOccurrencesOfString:kAssetSuffix withString:kMapSuffix];
    }
    NSMutableData * data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:nodes];
    [archiver finishEncoding];
    BOOL success = [data writeToFile:self.mapPath atomically:YES];
    if (success) {
        NSLog(@"保存成功");
        return data;
    }else{
        NSLog(@"保存失败");
        return nil;
    }
    return nil;
}

-(NSData *)saveSelf{
    NSMutableData * data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self];
    [archiver finishEncoding];
    BOOL success = [data writeToFile:self.assetPath atomically:YES];
    if (success) {
        NSLog(@"保存成功");
        return data;
    }else{
        NSLog(@"保存失败");
        return nil;
    }
    return nil;
}

-(void)resetAssetPathWithName:(NSString *)name{
    self.displayName = name;
    NSString * parentPath = [[self assetPath] stringByDeletingLastPathComponent];
    self.assetPath = [parentPath stringByAppendingFormat:@"/%@%@",name,kAssetSuffix];
    self.mapPath = [self.assetPath stringByReplacingOccurrencesOfString:kAssetSuffix withString:kMapSuffix];
}


@end


































