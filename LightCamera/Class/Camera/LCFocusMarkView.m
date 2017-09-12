//
//  LCFocusMarkView.m
//  LightCamera
//
//  Created by 何少博 on 16/12/14.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "LCFocusMarkView.h"

@interface LCFocusMarkView ()

@property (nonatomic,strong)UIImageView * imageView;

@end


@implementation LCFocusMarkView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setViews];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setViews];
    }
    return self;
}

-(void)setViews{
    self.imageView = [[UIImageView alloc]init];
    self.imageView.image = [UIImage imageNamed:@"focus"];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.imageView];
}

-(void)layoutSubviews{
//    self.layer.borderWidth = 1.0;
//    self.layer.borderColor =[UIColor orangeColor].CGColor;
//    self.layer.cornerRadius = 5;
//    self.layer.masksToBounds = YES;
    self.imageView.frame = self.bounds;
    self.backgroundColor = [UIColor clearColor];
}

// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextSetRGBStrokeColor(ctx, 0xff/255.0, 0xcc/255.0, 0x66/255.0, 1);
//    CGContextMoveToPoint(ctx, self.point.x - 50, self.point.y - 50);
//    CGContextAddLineToPoint(ctx, self.point.x - 50, self.point.y + 50);
//    CGContextAddLineToPoint(ctx, self.point.x + 50, self.point.y + 50);
//    CGContextAddLineToPoint(ctx, self.point.x + 50, self.point.y - 50);
//    CGContextAddLineToPoint(ctx, self.point.x - 50, self.point.y - 50);
//    CGContextStrokePath(ctx);
//}


@end
