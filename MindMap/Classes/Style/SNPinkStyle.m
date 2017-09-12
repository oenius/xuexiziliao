//
//  SNPinkStyle.m
//  MindMap
//
//  Created by 何少博 on 2017/8/24.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNPinkStyle.h"

@implementation SNPinkStyle
-(instancetype)init{
    self = [super init];
    if (self) {
        [self setupDefault];
    }
    return self;
}
-(void)setupDefault{
    self.openImage = [UIImage imageNamed:@"jia4"];
    self.closeImage = [UIImage imageNamed:@"jian4"];
    self.lineColor = [UIColor colorWithHexString:@"#be7394"];
    self.startColor = [UIColor clearColor];
    self.endColor = [UIColor clearColor];
    self.borderColor = [UIColor clearColor];
    self.textColor = [UIColor blackColor];
    self.nodeBgColor = [UIColor clearColor];
}


-(UIImage *)KnobImage{
    return [UIImage imageNamed:@"yuan4"];
}

-(UIColor *)mapBgColor{
    return [UIColor colorWithHexString:@"#FBFBFB"];
}

-(void)setDepth:(NSInteger)depth{
    [super setDepth:depth];
    if (depth == 0) {
        self.startColor = [UIColor colorWithHexString:@"#be7394"];
        self.endColor  = [UIColor colorWithHexString:@"#be7394"];
        self.textColor = [UIColor whiteColor];
    }else if (depth == 1){
        self.startColor = [UIColor colorWithHexString:@"#f7eef3"];
        self.endColor = [UIColor colorWithHexString:@"#f7eef3"];
        self.textColor = [UIColor blackColor];
        self.borderColor = [UIColor colorWithHexString:@"#be7394"];
    }
}
@end
