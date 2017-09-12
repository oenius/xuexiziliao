//
//  GetPointRGB.m
//  获取RGB测试
//
//  Created by Mac_H on 16/6/25.
//  Copyright © 2016年 何少博. All rights reserved.
//

#import "GetPointRGB.h"

@implementation GetPointRGB
//将UIimage中的数据放入Byte数组中，顺序为ARGB.
-(Byte*)getImageData:(UIImage*)Image{
    CGImageRef imageRef= [Image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    int width =  (int)CGImageGetWidth(imageRef);
    int height = (int)CGImageGetHeight(imageRef);
    int bytesPerPixel = 4;
    int bytesPerRow=bytesPerPixel*width;
    int bitsPerComponent = 8;
    
//    void* imageData ;//准备用来存储数据的数组
    unsigned char *rawData = (unsigned char*) calloc(height * width * 8, sizeof(unsigned char));
    CGContextRef cgContexRef = CGBitmapContextCreate(rawData,
                                                     width,
                                                     height,
                                                     bitsPerComponent,
                                                     bytesPerRow,
                                                     colorSpace,
                                                     kCGImageAlphaPremultipliedFirst);
    CGRect theRect = CGRectMake(0,0, width, height);
    CGContextDrawImage(cgContexRef, theRect, imageRef);
    
    //Byte* tempData=(Byte*)CGBitmapContextGetData(cgContexRef);
    CGColorSpaceRelease(colorSpace);

    CGContextRelease(cgContexRef);
    
    
//    return (Byte*)imageData;
    return (Byte*)rawData;
}

-(Color)GetImageColorAtPointX:(int)X
                       PointY:(int)Y
                    FromImage:(Byte*)ImageData
                  OfImageSize:(CGSize)ImageSize{
    int index =4*X+4*Y*ImageSize.width;
    Color c;
    c.A=ImageData [index];
    c.R=ImageData[index+1];
    c.G=ImageData[index+2];
    c.B=ImageData[index+3];
    return c;
}

@end
