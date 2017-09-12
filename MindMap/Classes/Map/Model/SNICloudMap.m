//
//  SNICloudMap.m
//  MindMap
//
//  Created by 何少博 on 2017/9/5.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNICloudMap.h"


static NSString * const kAssetDataKey   = @"adfjhaihfao";
static NSString * const kMapDataKey     = @"aefgihoaihoi";

@implementation SNICloudMap

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        _assetData = [aDecoder decodeObjectForKey:kAssetDataKey];
        _mapData = [aDecoder decodeObjectForKey:kMapDataKey];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.assetData forKey:kAssetDataKey];
    [aCoder encodeObject:self.mapData forKey:kMapDataKey];
}


@end
