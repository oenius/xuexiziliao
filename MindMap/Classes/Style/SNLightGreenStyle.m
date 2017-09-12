//
//  SNLightGreenStyle.m
//  MindMap
//
//  Created by 何少博 on 2017/8/31.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNLightGreenStyle.h"

@implementation SNLightGreenStyle
-(instancetype)init{
    self = [super init];
    if (self) {
        [self setupDefault];
    }
    return self;
}
-(void)setupDefault{
    self.openImage = [UIImage imageNamed:@"jia5"];
    self.closeImage = [UIImage imageNamed:@"jian5"];
    self.lineColor = [UIColor colorWithHexString:@"#5eb861"];
    self.startColor = [UIColor clearColor];
    self.endColor = [UIColor clearColor];
    self.borderColor = [UIColor clearColor];
    self.textColor = [UIColor blackColor];
    self.nodeBgColor = [UIColor clearColor];
}


-(UIImage *)KnobImage{
    return [UIImage imageNamed:@"yuan5"];
}

-(UIColor *)mapBgColor{
    return [UIColor colorWithHexString:@"#FBFBFB"];
}

-(void)setDepth:(NSInteger)depth{
    [super setDepth:depth];
    if (depth == 0) {
        self.startColor = [UIColor colorWithHexString:@"#5eb861"];
        self.endColor  = [UIColor colorWithHexString:@"#5eb861"];
        self.textColor = [UIColor whiteColor];
    }else if (depth == 1){
        self.startColor = [UIColor colorWithHexString:@"#eef6ee"];
        self.endColor = [UIColor colorWithHexString:@"#eef6ee"];
        self.textColor = [UIColor blackColor];
        self.borderColor = [UIColor colorWithHexString:@"#5eb861"];
    }
}
@end
