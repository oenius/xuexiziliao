//
//  LEDViewSecond.m
//  LEDBanner
//
//  Created by 何少博 on 16/7/15.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//
#define SINGLE_LINE_WIDTH           (1 / [UIScreen mainScreen].scale)
#define SINGLE_LINE_ADJUST_OFFSET   ((1 / [UIScreen mainScreen].scale))

#import "LEDViewSecond.h"
#import "UIColor+x.h"

@interface LEDViewSecond ()
//@property (nonatomic,strong)CAShapeLayer *contentShapelayer;
@property (nonatomic,strong)NSArray * rainRowColorArray;

@end


@implementation LEDViewSecond

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        //        CAShapeLayer * contentShapelayer= [[CAShapeLayer alloc]init];
        //        self.contentShapelayer = contentShapelayer;
        //        [self.layer addSublayer:contentShapelayer];
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    //    self.contentShapelayer.frame = self.layer.bounds;
}

-(NSArray *)rainRowColorArray{
    if (_rainRowColorArray == nil) {
        _rainRowColorArray = [UIColor getRainbowColor];
    }
    return _rainRowColorArray;
}

-(void)setDotArray:(NSArray *)dotArray{
    _dotArray = dotArray;
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
    //    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGFloat W = self.bounds.size.width;
    CGFloat H = self.bounds.size.height;
    CGFloat space = 2;
//    if (W>H) {
//        W = W + H;
//        H = W - H;
//        W = W - H;
//    }
    CGFloat dw = (W - space)/self.showModel - space;
    CGFloat dh = dw;
    int flag = -1;
    for (int i = 0; ; i++) {
        for (int j = 0 ;j <self.showModel;j++) {
            CGFloat y = i * (dh + space) + space;
            CGFloat x = j * (dw + space) + space;
            CGRect rect = CGRectMake(x+SINGLE_LINE_ADJUST_OFFSET, y+SINGLE_LINE_ADJUST_OFFSET, dw-1, dh-1);
            if (y >= H && (i)%6==0) {//对6取余是为了方便速度的调节
                flag = 0;
                break;
            }
            UIColor * color = self.offColor;
            if (self.dotModel == NSDotModelSquare) {
                [self drawRectangle:rect WithColor:color WithRadus:dw/2];
            }else{
                [self drawEllips:rect WithColor:color WithRadus:dw/2];
            }
        }
       if (flag == 0) break;
    }
}
//yuan
-(void)drawEllips:(CGRect)rect WithColor:(UIColor*)color WithRadus:(CGFloat)radus{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextSetLineWidth(context,1);
    
    [color setStroke];
    CGContextFillEllipseInRect(context, rect);
}
-(void)drawRectangle:(CGRect)rect WithColor:(UIColor*)color WithRadus:(CGFloat)radus{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);//填充颜色
//    CGContextSetLineWidth(context,1);
    [color setStroke];
//    CGContextSetAllowsAntialiasing(context,NO);
    CGContextAddRect(context,rect);//画方框
//    CGContextStrokePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    
}
////圆
//-(void)drawEllips:(CGPoint)center WithColor:(UIColor*)color WithRadus:(CGFloat)radius{
//    UIBezierPath*path=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(center.x-radius, center.y-radius, 2*radius, 2*radius) cornerRadius:radius];
//    self.contentShapelayer.fillColor = [color CGColor];
//    self.contentShapelayer.path=path.CGPath;
//}
////方
//-(void)drawRectangle:(CGPoint)center WithColor:(UIColor*)color WithRadus:(CGFloat)radius{
//    UIBezierPath*path=[UIBezierPath bezierPathWithRoundedRect:CGRectMake(center.x-radius, center.y-radius, 2*radius, 2*radius) cornerRadius:0];
//    self.contentShapelayer.fillColor = [color CGColor];
//    self.contentShapelayer.path=path.CGPath;
//}
-(void)dealloc{
     LOG(@"%s", __func__);
    
}
@end
