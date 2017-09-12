//
//  SNMapStyle.m
//  MindMap
//
//  Created by 何少博 on 2017/8/23.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNMapStyle.h"

static NSString * const kDepth           = @"kDepth";
static NSString * const kOpenImage       = @"kOpenImage";
static NSString * const kCloseImage      = @"kCloseImage";
static NSString * const kLineColor       = @"kLineColor";
static NSString * const kStartColor      = @"kStartColor";
static NSString * const kEndColor        = @"kEndColor";
static NSString * const kBorderColor     = @"kBorderColor";
static NSString * const kTextColor       = @"kTextColor";
static NSString * const kNodeBgColor     = @"kNodeBgColor";


@implementation SNMapStyle



-(instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)setDepth:(NSInteger)depth{
    _depth = depth;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.openImage = [aDecoder decodeObjectForKey:kOpenImage];
        self.closeImage = [aDecoder decodeObjectForKey:kCloseImage];
        self.lineColor = [aDecoder decodeObjectForKey:kLineColor];
        self.startColor = [aDecoder decodeObjectForKey:kStartColor];
        self.endColor = [aDecoder decodeObjectForKey:kEndColor];
        self.borderColor = [aDecoder decodeObjectForKey:kBorderColor];
        self.textColor = [aDecoder decodeObjectForKey:kTextColor];
        self.nodeBgColor = [aDecoder decodeObjectForKey:kNodeBgColor];
        self.depth = [aDecoder decodeIntegerForKey:kDepth];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.openImage forKey:kOpenImage];
    [aCoder encodeObject:self.closeImage forKey:kCloseImage];
    [aCoder encodeObject:self.lineColor forKey:kLineColor];
    [aCoder encodeObject:self.startColor forKey:kStartColor];
    [aCoder encodeObject:self.endColor forKey:kEndColor];
    [aCoder encodeObject:self.borderColor forKey:kBorderColor];
    [aCoder encodeObject:self.textColor forKey:kTextColor];
    [aCoder encodeObject:self.nodeBgColor forKey:kNodeBgColor];
    [aCoder encodeInteger:self.depth forKey:kDepth];
}


@end
