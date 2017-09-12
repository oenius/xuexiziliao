//
//  SNLavenderStyle.m
//  MindMap
//
//  Created by 何少博 on 2017/8/24.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNLavenderStyle.h"

@implementation SNLavenderStyle
-(instancetype)init{
    self = [super init];
    if (self) {
        [self setupDefault];
    }
    return self;
}
-(void)setupDefault{
    self.openImage = [UIImage imageNamed:@"jia7"];
    self.closeImage = [UIImage imageNamed:@"jian7"];
    self.lineColor = [UIColor colorWithHexString:@"#cbcbcb"];
    self.startColor = [UIColor clearColor];
    self.endColor = [UIColor clearColor];
    self.borderColor = [UIColor clearColor];
    self.textColor = [UIColor blackColor];
    self.nodeBgColor = [UIColor clearColor];
}


-(UIImage *)KnobImage{
    return [UIImage imageNamed:@"yuan7"];
}

-(UIColor *)mapBgColor{
    return [UIColor colorWithHexString:@"#FBFBFB"];
}

-(void)setDepth:(NSInteger)depth{
    [super setDepth:depth];
    if (depth == 0) {
        self.startColor = [UIColor colorWithHexString:@"#b1d8fd"];
        self.endColor  = [UIColor colorWithHexString:@"#87c3fe"];
    }else if (depth == 1){
        self.startColor = [UIColor colorWithHexString:@"#e8cdff"];
        self.endColor  = [UIColor colorWithHexString:@"#d6a3ff"];
    }
}
@end
