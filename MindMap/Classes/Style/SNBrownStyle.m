//
//  SNBrownStyle.m
//  MindMap
//
//  Created by 何少博 on 2017/8/24.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNBrownStyle.h"

@implementation SNBrownStyle
-(instancetype)init{
    self = [super init];
    if (self) {
        [self setupDefault];
    }
    return self;
}
-(void)setupDefault{
    self.openImage = [UIImage imageNamed:@"jia6"];
    self.closeImage = [UIImage imageNamed:@"jian6"];
    self.lineColor = [UIColor colorWithHexString:@"#b98d6d"];
    self.startColor = [UIColor clearColor];
    self.endColor = [UIColor clearColor];
    self.borderColor = [UIColor clearColor];
    self.textColor = [UIColor blackColor];
    self.nodeBgColor = [UIColor clearColor];
}


-(UIImage *)KnobImage{
    return [UIImage imageNamed:@"yuan6"];
}

-(UIColor *)mapBgColor{
    return [UIColor colorWithHexString:@"#FBFBFB"];
}

-(void)setDepth:(NSInteger)depth{
    [super setDepth:depth];
    if (depth == 0) {
        self.startColor = [UIColor colorWithHexString:@"#b98d6d"];
        self.endColor  = [UIColor colorWithHexString:@"#b98d6d"];
        self.textColor = [UIColor whiteColor];
    }else if (depth == 1){
        self.startColor = [UIColor colorWithHexString:@"#f6f2ee"];
        self.endColor = [UIColor colorWithHexString:@"#f6f2ee"];
        self.textColor = [UIColor blackColor];
        self.borderColor = [UIColor colorWithHexString:@"#b98d6d"];
    }
}
@end
