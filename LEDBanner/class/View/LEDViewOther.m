//
//  LEDViewOther.m
//  LEDBanner
//
//  Created by Mac_H on 16/7/14.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "LEDViewOther.h"

@implementation LEDViewOther


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
-(void)setDotArray:(NSArray *)dotArray{
    _dotArray = dotArray;
    self.backgroundColor = [UIColor clearColor];
    [self setNeedsDisplay];
}
-(void)setShowModel:(NSShowModel)showModel{
    _showModel = showModel;
    _columns = showModel;
}
-(void)setColumns:(int)columns{
    _columns = columns;
    _showModel = columns;
}
-(void)setIsBackGroundView:(BOOL)isBackGroundView{
    _isBackGroundView = isBackGroundView;
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect {
    CGFloat lieshu = _columns;
    CGFloat space = 2;
    CGFloat radus = (rect.size.width-(lieshu-1)*space)/lieshu/2;
    CGFloat hangshu = _rows;
    if (self.isBackGroundView) {
        for (int i =0 ; i <hangshu; i++) {
            for (int j =0 ; j<lieshu ;j++ ) {
                @autoreleasepool {
                    CGPoint center ;
                    center.x = j*(2*radus+space) + radus;
                    center.y = i*(2*radus+space) + radus;
                    UIColor * color = self.offColor;
                    [self drawEllips:center WithColor:color WithRadus:radus];
                }
            }
        }
    }
    if (self.dotArray == nil || self.dotArray.count == 0) return;
    for (int i =0 ; i <hangshu; i++) {
        for (int j =0 ; j<lieshu ;j++ ) {
            @autoreleasepool {
                CGPoint center ;
                center.x = j*(2*radus+space) + radus;
                center.y = i*(2*radus+space) + radus;
                UIColor * color ;
                NSArray * rowDotArray = self.dotArray[_showModel-j-1];
                NSNumber * numberBool ;
                if (rowDotArray.count<i+3) {
                    numberBool = [NSNumber numberWithBool:NO];
                }else{
                    numberBool = [rowDotArray objectAtIndex:i+2];
                }
                
                    if (numberBool.boolValue) {
                        color = self.fontColor;
                    }else{
                        color = [UIColor darkGrayColor];
                    }
//                [self drawRectangle:center WithColor:color WithRadus:radus];
                [self drawEllips:center WithColor:color WithRadus:radus];
            }
        }
    }
}
-(void)drawEllips:(CGPoint)center WithColor:(UIColor*)color WithRadus:(CGFloat)radus{
    CGContextRef ctf = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctf, [color CGColor]);
    CGContextFillEllipseInRect(ctf, CGRectMake(center.x-radus, center.y-radus, 2*radus, 2*radus));
}
-(void)drawRectangle:(CGPoint)center WithColor:(UIColor*)color WithRadus:(CGFloat)radus{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);//填充颜色
    //    CGContextSetLineWidth(context,1);
    [color setStroke];
    //    CGContextSetAllowsAntialiasing(context,NO);
    CGContextAddRect(context,CGRectMake(center.x-radus, center.y-radus, 2*radus, 2*radus));//画方框
    //    CGContextStrokePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    
}
@end
