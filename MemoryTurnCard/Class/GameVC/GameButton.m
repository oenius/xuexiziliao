//
//  GameButton.m
//  MemoryTurnCard
//
//  Created by 何少博 on 16/10/24.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "GameButton.h"

@implementation GameButton


-(instancetype)initWithFrame:(CGRect)frame{
   self =  [super initWithFrame:frame];
    if (self) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

-(void)setIsOpen:(BOOL)isOpen{
    _isOpen = isOpen;
    if (isOpen == YES) {
        self.userInteractionEnabled = NO;
    }else{
        self.userInteractionEnabled = YES;
    }
}


@end
