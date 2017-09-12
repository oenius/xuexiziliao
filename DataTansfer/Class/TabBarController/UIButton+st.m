//
//  UIButton+st.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/17.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "UIButton+st.h"

@implementation UIButton (st)
- (void)setTitlePosition:(TitlePosition)position {
    
    CGSize titleSize = self.titleLabel.bounds.size;
    CGSize imageSize = self.imageView.bounds.size;
    CGFloat interval = 1.0;
    
    if (position == TitlePositionLeft) {
        
        [self setImageEdgeInsets:UIEdgeInsetsMake(0,titleSize.width + interval, 0, -(titleSize.width + interval))];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -(imageSize.width + interval), 0, imageSize.width + interval)];
        
    } else if(position == TitlePositionBottom) {
        
        [self setImageEdgeInsets:UIEdgeInsetsMake(0,0, titleSize.height + interval, -(titleSize.width))];
        [self setTitleEdgeInsets:UIEdgeInsetsMake(imageSize.height + interval, -(imageSize.width), 0, 0)];
    }
}
@end
