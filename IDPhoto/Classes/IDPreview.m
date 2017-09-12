//
//  IDPreview.m
//  IDPhoto
//
//  Created by 何少博 on 17/5/4.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDPreview.h"

@implementation IDPreview

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.imageView = [[UIImageView alloc]init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];
        self.activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectZero];
        self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [self addSubview:self.activityView];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    self.activityView.frame = CGRectMake(0, 0, 30, 30);
    self.activityView.center = self.center;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
