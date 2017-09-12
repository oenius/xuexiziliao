//
//  SNDocument.m
//  MindMap
//
//  Created by 何少博 on 2017/9/4.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNDocument.h"
#import "SNICloudMap.h"
@interface SNDocument ()

@property (nonatomic, strong) NSFileWrapper *assetFileWrapper;
@property (nonatomic, strong) NSFileWrapper *mapFileWrapper;

@end



static NSString * const kAssetFileName  = @"mindMap.asset";
static NSString * const kMapFileName    = @"mindMap.map";

@implementation SNDocument

-(instancetype)initWithFileURL:(NSURL *)url{
    self = [super initWithFileURL:url];
    if (self) {
        _map = [[SNICloudMap alloc]init];
    }
    return self;
}

// read contents
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError
{
//    NSFileWrapper *fileWrapper = (NSFileWrapper *)contents;
//    
//    self.assetFileWrapper = fileWrapper.fileWrappers[kAssetFileName];
//    NSData *assetData = (self.assetFileWrapper).regularFileContents;
//    self.assetData = assetData;
//    
//    self.mapFileWrapper = fileWrapper.fileWrappers[kMapFileName];
//    NSData *mapData = (self.mapFileWrapper).regularFileContents;
//    self.mapData = mapData;
   
    NSKeyedUnarchiver * unarchive = [[NSKeyedUnarchiver alloc]initForReadingWithData:contents];
    self.map = [unarchive decodeObject];
    return YES;
}

// save contents
- (id)contentsForType:(NSString *)typeName error:(NSError **)outError
{
//    NSFileWrapper *contentsFileWrapper =
//    [[NSFileWrapper alloc] initDirectoryWithFileWrappers:@{}];
//
//    self.assetFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:self.assetData];
//    (self.assetFileWrapper).preferredFilename = kAssetFileName;
//    [contentsFileWrapper addFileWrapper:self.assetFileWrapper];
//    
//    self.mapFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:self.mapData];
//    (self.mapFileWrapper).preferredFilename = kMapFileName;
//    [contentsFileWrapper addFileWrapper:self.mapFileWrapper];
    NSMutableData * data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.map];
    [archiver finishEncoding];
    return data;
}



@end
