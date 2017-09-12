//
//  UISlider+x.m
//  IDPhoto
//
//  Created by 何少博 on 17/5/6.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "UISlider+x.h"

@implementation UISlider (x)

-(void)defaultUI{
    self.minimumTrackTintColor = [UIColor colorWithHexString:@"#b8b8b8"];
    self.maximumTrackTintColor = [UIColor colorWithHexString:@"#b8b8b8"];
    UIImage * image = [UIImage imageNamed:@"time"];
    [self setThumbImage:image forState:(UIControlStateNormal)];
    [self setThumbImage:image forState:(UIControlStateHighlighted)];
}

@end
