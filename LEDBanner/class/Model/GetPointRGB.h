//
//  GetPointRGB.h
//  获取RGB测试
//
//  Created by Mac_H on 16/6/25.
//  Copyright © 2016年 何少博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef struct {
    Byte A;
    Byte R;
    Byte G;
    Byte B;
}Color;


@interface GetPointRGB : NSObject
-(Byte*)getImageData:(UIImage*)Image;
-(Color)GetImageColorAtPointX:(int)X
                       PointY:(int)Y
                    FromImage:(Byte*)ImageData
                  OfImageSize:(CGSize)ImageSize;

@end
