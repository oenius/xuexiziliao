//
//  SNDefaultStyle.m
//  MindMap
//
//  Created by 何少博 on 2017/8/23.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNDefaultStyle.h"

@implementation SNDefaultStyle



-(instancetype)init{
    self = [super init];
    if (self) {
        [self setupDefault];
    }
    return self;
}
-(void)setupDefault{
    self.openImage = [UIImage imageNamed:@"jia8"];
    self.closeImage = [UIImage imageNamed:@"jian8"];
    self.lineColor = [UIColor colorWithHexString:@"#abadfe"];
    self.startColor = [UIColor clearColor];
    self.endColor = [UIColor clearColor];
    self.borderColor = [UIColor clearColor];
    self.textColor = [UIColor blackColor];
    self.nodeBgColor = [UIColor clearColor];
}


-(UIImage *)KnobImage{
    return [UIImage imageNamed:@"yuan8"];
}

-(UIColor *)mapBgColor{
    return [UIColor colorWithHexString:@"#FBFBFB"];
}

-(void)setDepth:(NSInteger)depth{
    [super setDepth:depth];
    if (depth <= 1) {
        self.startColor = [UIColor colorWithHexString:@"#7db2fe"];
        self.endColor  = [UIColor colorWithHexString:@"#7d80ff"];
        self.textColor = [UIColor whiteColor];
    }else{
        self.startColor = [UIColor clearColor];
        self.endColor  = [UIColor clearColor];
        self.textColor = [UIColor blackColor];
    }
}
@end
