//
//  SNNodeStyleManager.m
//  MindMap
//
//  Created by 何少博 on 2017/8/23.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNNodeStyleManager.h"
#import "SNNodeView.h"

@interface SNNodeStyleManager ()


@end

@implementation SNNodeStyleManager


-(instancetype)initWithNode:(SNNodeView *)nodeView{
    self = [super init];
    if (self) {
        self.node = nodeView;
    }
    return self;
}


-(void)setStyle:(SNBaseStyle *)style{
    _style = style;
}





@end
