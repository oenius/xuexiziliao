//
//  METextPopView.m
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "METextPopView.h"

@interface METextPopView ()

@property (strong,nonatomic) UIImageView * imageView;

@property (strong,nonatomic) UILabel * label;

@end

@implementation METextPopView

//设置默认值
-(UIColor *)textColor{
    if (_textColor == nil) {
        _textColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1];
    }
    return _textColor;
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
-(UIFont *)textFont{
    if (_textFont == nil) {
        _textFont = [UIFont systemFontOfSize:17];
    }
    return _textFont;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _text = @"hello";
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
}
-(void)setText:(NSString *)text{
    _text = text;
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect{
    
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
    
    self.textFont = [self.textFont fontWithSize:fh-14];
    NSDictionary* attrs =@{NSForegroundColorAttributeName:self.textColor,
                           NSFontAttributeName:self.textFont};
    CGSize textSize = [self.text boundingRectWithSize:self.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    [self.text drawAtPoint:CGPointMake((fw-textSize.width)/2, (fh-7-textSize.height)/2) withAttributes:attrs];
}

/*
 使用CGContextAddArcToPoint画弧线
 从（180，280-70）到（180，280）画一条线，然后再从（180，280）到（ 180-20, 280）画一条线，从这两条线（无限延伸的） 和半径10可以确定一条弧
 说的是下面前两行的意思  下面依次类推
 */
//    CGContextMoveToPoint(context, 180, 280-100);  // 开始坐标右边开始
//    CGContextAddArcToPoint(context, 180, 280, 180-20, 280, 10);  // 右下角角度
//    CGContextAddArcToPoint(context, 120, 280, 120, 280-10, 10); // 左下角角度
//    CGContextAddArcToPoint(context, 120, 200, 180-20, 200, 10); // 左上角
//    CGContextAddArcToPoint(context, 180, 200, 180, 280-70, 10); // 右上角

@end
