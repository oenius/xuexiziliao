//
//  SNICloudMap.h
//  MindMap
//
//  Created by 何少博 on 2017/9/5.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNICloudMap : NSObject<NSCoding>
@property (strong, nonatomic) NSData *assetData;
@property (strong, nonatomic) NSData *mapData;
@end
