//
//  SNGreenStyle.m
//  MindMap
//
//  Created by 何少博 on 2017/8/24.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNGreenStyle.h"

@implementation SNGreenStyle


-(instancetype)init{
    self = [super init];
    if (self) {
        [self setupDefault];
    }
    return self;
}
-(void)setupDefault{
    self.openImage = [UIImage imageNamed:@"jia3"];
    self.closeImage = [UIImage imageNamed:@"jian3"];
    self.lineColor = [UIColor colorWithHexString:@"#01d482"];
    self.startColor = [UIColor clearColor];
    self.endColor = [UIColor clearColor];
    self.borderColor = [UIColor clearColor];
    self.textColor = [UIColor colorWithHexString:@"#01d482"];
    self.nodeBgColor = [UIColor clearColor];
}


-(UIImage *)KnobImage{
    return [UIImage imageNamed:@"yuan3"];
}

-(UIColor *)mapBgColor{
    return [UIColor colorWithHexString:@"#000000"];
}

-(void)setDepth:(NSInteger)depth{
    [super setDepth:depth];
    
}

@end
