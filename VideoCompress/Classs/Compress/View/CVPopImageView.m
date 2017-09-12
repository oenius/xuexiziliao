//
//  CVPopImageView.m
//  VideoCompress
//
//  Created by 何少博 on 17/4/13.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "CVPopImageView.h"

@interface CVPopImageView ()


@property (strong,nonatomic) UIImageView * imageView;

@end


@implementation CVPopImageView
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
-(UIColor *)borderColor{
    if (_borderColor == nil) {
        _borderColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1];
    }
    return _borderColor;
}
-(UIColor *)fillColor{
    if (_fillColor == nil) {
        _fillColor = [UIColor clearColor];
    }
    return _fillColor;
}

-(void)setImage:(UIImage *)image{
    _image = image;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    
    float fw = rect.size.width;
    float fh = rect.size.height;
    CGFloat radus = 3.0;
    if (self.borderWidth == 0) {
        self.borderWidth = 1;
    }
    CGFloat spacing = self.borderWidth;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextMoveToPoint(context, radus, spacing);
    CGContextAddArcToPoint(context, fw-spacing, spacing, fw-spacing, radus, radus);
    CGContextAddLineToPoint(context, fw-spacing, fh-radus-6);
    CGContextAddArcToPoint(context, fw-spacing, fh-6, fw-radus, fh-6, radus);
    CGContextAddLineToPoint(context, fw/2+5, fh-6);
    CGContextAddLineToPoint(context, fw/2, fh);
    CGContextAddLineToPoint(context, fw/2-5, fh-6);
    CGContextAddLineToPoint(context, radus, fh-6);
    CGContextAddArcToPoint(context, spacing, fh-6, spacing, fh-radus-6, radus);
    CGContextAddLineToPoint(context, spacing, radus);
    CGContextAddArcToPoint(context, spacing, spacing, radus, spacing, radus);
    CGContextClosePath(context);
    CGContextSetLineWidth(context, self.borderWidth);
    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGRect imageRect = CGRectMake(radus, spacing, fw-radus*2, fh-6);
    [self.image drawInRect:imageRect];
}


@end
