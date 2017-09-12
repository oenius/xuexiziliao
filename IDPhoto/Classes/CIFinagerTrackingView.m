//
//  CIFinagerTrackingView.m
//  CutoutImage
//
//  Created by 何少博 on 17/2/7.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "CIFinagerTrackingView.h"
@interface CIFinagerTrackingView ()

@property (nonatomic,weak) UIView *trackingView;

@property (nonatomic,assign) CGPoint touchPoint;

@end

@implementation CIFinagerTrackingView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.borderWidth = 2;
        self.layer.cornerRadius = frame.size.height/2;
        self.layer.masksToBounds = YES;
        self.layer.shouldRasterize = YES;
        self.zoom = 2;
    }
    return self;
}

-(void)beganTrackingView:(UIView*)trackingView{
    self.trackingView = trackingView;
    [trackingView addSubview:self];
}

-(void)trackingPoint:(CGPoint)point{
    self.touchPoint = point;
    [self setNeedsDisplay];
}

-(void)endTracking{
    [self removeFromSuperview];;
}


- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldAntialias(context, true);
    CGContextTranslateCTM(context,1*(self.frame.size.width*0.5),1*(self.frame.size.height*0.5));
    CGContextScaleCTM(context, _zoom, _zoom);
    CGContextTranslateCTM(context,-1*(_touchPoint.x),-1*(_touchPoint.y));
    [self.trackingView.layer renderInContext:context];
}

@end
