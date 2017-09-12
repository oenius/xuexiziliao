//
//  IDMagnifier.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/27.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDMagnifier.h"

@interface IDMagnifier ()

@property (strong, nonatomic) CALayer *contentLayer;

@end

@implementation IDMagnifier

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, 120, 120);
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.cornerRadius = 60;
        self.layer.masksToBounds = YES;
        self.windowLevel = UIWindowLevelAlert;
        
        self.contentLayer = [CALayer layer];
        self.contentLayer.frame = self.bounds;
        self.contentLayer.delegate = self;
        self.contentLayer.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:self.contentLayer];
    }
    
    return self;
}

-(void)setViewToMagnify:(UIView *)viewToMagnify{
    _viewToMagnify = viewToMagnify;
    [self makeKeyAndVisible];
}

- (void)setPointToMagnify:(CGPoint)pointToMagnify
{
    _pointToMagnify = pointToMagnify;
    
    CGPoint center = CGPointMake(pointToMagnify.x, self.center.y);
    if (pointToMagnify.y > CGRectGetHeight(self.bounds) * 0.5) {
        center.y = pointToMagnify.y -  CGRectGetHeight(self.bounds) / 2;
    }
    center.y -= 30;
    self.center = center;
    [self.contentLayer setNeedsDisplay];
}


- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGContextTranslateCTM(ctx, self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    CGContextScaleCTM(ctx, 1.2, 1.2);
    CGContextTranslateCTM(ctx, -1 * self.pointToMagnify.x, -1 * self.pointToMagnify.y);
    [self.viewToMagnify.layer renderInContext:ctx];
}

@end
