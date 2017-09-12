//
//  SNBlackStyle.m
//  MindMap
//
//  Created by 何少博 on 2017/8/23.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNBlackStyle.h"

@implementation SNBlackStyle
-(instancetype)init{
    self = [super init];
    if (self) {
        [self setupDefault];
    }
    return self;
}
-(void)setupDefault{
    self.openImage = [UIImage imageNamed:@"jia1"];
    self.closeImage = [UIImage imageNamed:@"jian1"];
    self.lineColor = [UIColor colorWithHexString:@"#9c9c9c"];
    self.startColor = [UIColor clearColor];
    self.endColor = [UIColor clearColor];
    self.borderColor = [UIColor clearColor];
    self.textColor = [UIColor colorWithHexString:@"#a2a3a6"];
    self.nodeBgColor = [UIColor clearColor];
}


-(UIImage *)KnobImage{
    return [UIImage imageNamed:@"yuan1"];
}

-(UIColor *)mapBgColor{
    return [UIColor colorWithHexString:@"#000000"];
}

-(void)setDepth:(NSInteger)depth{
    [super setDepth:depth];

}

@end
