//
//  SNGoldenStyle.m
//  MindMap
//
//  Created by 何少博 on 2017/8/24.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNGoldenStyle.h"

@implementation SNGoldenStyle


-(instancetype)init{
    self = [super init];
    if (self) {
        [self setupDefault];
    }
    return self;
}
-(void)setupDefault{
    self.openImage = [UIImage imageNamed:@"jia2"];
    self.closeImage = [UIImage imageNamed:@"jian2"];
    self.lineColor = [UIColor colorWithHexString:@"#f0cc96"];
    self.startColor = [UIColor clearColor];
    self.endColor = [UIColor clearColor];
    self.borderColor = [UIColor clearColor];
    self.textColor = [UIColor colorWithHexString:@"#f0cc96"];
    self.nodeBgColor = [UIColor clearColor];
}


-(UIImage *)KnobImage{
    return [UIImage imageNamed:@"yuan2"];
}

-(UIColor *)mapBgColor{
    return [UIColor colorWithHexString:@"#000000"];
}

-(void)setDepth:(NSInteger)depth{
    [super setDepth:depth];
    
}


@end
