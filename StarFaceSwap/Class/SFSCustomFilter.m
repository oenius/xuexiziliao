//
//  SFSCustomFilter.m
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/9.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "SFSCustomFilter.h"

@implementation SFSCustomFilter

static CGContextRef CreateRGBABitmapContext (CGImageRef inImage)// 返回一个使用RGBA通道的位图上下文
{
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData; //内存空间的指针，该内存空间的大小等于图像使用RGB通道所占用的字节数。
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    size_t pixelsWide = CGImageGetWidth(inImage); //获取横向的像素点的个数
    size_t pixelsHigh = CGImageGetHeight(inImage); //纵向
    
    bitmapBytesPerRow	= (int)(pixelsWide * 4); //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit(0-255)的空间
    bitmapByteCount	= (int)(bitmapBytesPerRow * pixelsHigh); //计算整张图占用的字节数
    
    colorSpace = CGColorSpaceCreateDeviceRGB();//创建依赖于设备的RGB通道
    
    bitmapData = malloc(bitmapByteCount); //分配足够容纳图片字节数的内存空间
    
    context = CGBitmapContextCreate (bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    //创建CoreGraphic的图形上下文，该上下文描述了bitmaData指向的内存空间需要绘制的图像的一些绘制参数
    
    CGColorSpaceRelease( colorSpace );
    //Core Foundation中通过含有Create、Alloc的方法名字创建的指针，需要使用CFRelease()函数释放
    
    return context;
}

static unsigned char *RequestImagePixelData(UIImage *inImage)
// 返回一个指针，该指针指向一个数组，数组中的每四个元素都是图像上的一个像素点的RGBA的数值(0-255)，用无符号的char是因为它正好的取值范围就是0-255
{
    CGImageRef img = [inImage CGImage];
    CGSize size = [inImage size];
    
    CGContextRef cgctx = CreateRGBABitmapContext(img); //使用上面的函数创建上下文
    
    CGRect rect = {{0,0},{size.width, size.height}};
    
    CGContextDrawImage(cgctx, rect, img); //将目标图像绘制到指定的上下文，实际为上下文内的bitmapData。
    unsigned char *data = CGBitmapContextGetData (cgctx);
    
    CGContextRelease(cgctx);//释放上面的函数创建的上下文
    return data;
}

static void changeRGBA(int *red,int *green,int *blue,int *alpha, const float* f)//修改RGB的值
{
    int redV = *red;
    int greenV = *green;
    int blueV = *blue;
    int alphaV = *alpha;
    
    *red = f[0] * redV + f[1] * greenV + f[2] * blueV + f[3] * alphaV + f[4];
    *green = f[0+5] * redV + f[1+5] * greenV + f[2+5] * blueV + f[3+5] * alphaV + f[4+5];
    *blue = f[0+5*2] * redV + f[1+5*2] * greenV + f[2+5*2] * blueV + f[3+5*2] * alphaV + f[4+5*2];
    *alpha = f[0+5*3] * redV + f[1+5*3] * greenV + f[2+5*3] * blueV + f[3+5*3] * alphaV + f[4+5*3];
    
    if (*red > 255)
    {
        *red = 255;
    }
    if(*red < 0)
    {
        *red = 0;
    }
    if (*green > 255)
    {
        *green = 255;
    }
    if (*green < 0)
    {
        *green = 0;
    }
    if (*blue > 255)
    {
        *blue = 255;
    }
    if (*blue < 0)
    {
        *blue = 0;
    }
    if (*alpha > 255)
    {
        *alpha = 255;
    }
    if (*alpha < 0)
    {
        *alpha = 0;
    }
}

+(UIImage *)imageWithImage:(UIImage *)inImage withTypeString:(NSString *)type{
//    SFSCustomFilterLomo,
//    SFSCustomFilterRetro,
//    SFSCustomFilterGothic,
//    SFSCustomFilterSharpening,
//    SFSCustomFilterElegant,
//    SFSCustomFilterRedwine,
//    SFSCustomFilterFresh,
//    SFSCustomFilterRomantic,
//    SFSCustomFilterHalo,
//    SFSCustomFilterBlues,
//    SFSCustomFilterDream,
//    SFSCustomFilterNight
    UIImage * newImage = inImage;
    if ([type isEqualToString:@"SFSCustomFilterLomo"]) {
        newImage = [self imageWithImage:inImage withColorMatrix:colormatrix_lomo];
    }
    else if ([type isEqualToString:@"SFSCustomFilterRetro"]) {
        newImage = [self imageWithImage:inImage withColorMatrix:colormatrix_huajiu];
    }
    else if ([type isEqualToString:@"SFSCustomFilterGothic"]) {
        newImage = [self imageWithImage:inImage withColorMatrix:colormatrix_gete];
    }
    else if ([type isEqualToString:@"SFSCustomFilterSharpening"]) {
        newImage = [self imageWithImage:inImage withColorMatrix:colormatrix_ruise];
    }
    else if ([type isEqualToString:@"SFSCustomFilterRedwine"]) {
        newImage = [self imageWithImage:inImage withColorMatrix:colormatrix_jiuhong];
    }
    else if ([type isEqualToString:@"SFSCustomFilterFresh"]) {
        newImage = [self imageWithImage:inImage withColorMatrix:colormatrix_qingning];
    }
    else if ([type isEqualToString:@"SFSCustomFilterRomantic"]) {
        newImage = [self imageWithImage:inImage withColorMatrix:colormatrix_langman];
    }
    else if ([type isEqualToString:@"SFSCustomFilterHalo"]) {
        newImage = [self imageWithImage:inImage withColorMatrix:colormatrix_guangyun];
    }
    else if ([type isEqualToString:@"SFSCustomFilterBlues"]) {
        newImage = [self imageWithImage:inImage withColorMatrix:colormatrix_landiao];
    }
    else if ([type isEqualToString:@"SFSCustomFilterDream"]) {
        newImage = [self imageWithImage:inImage withColorMatrix:colormatrix_menghuan];
    }
    else if ([type isEqualToString:@"SFSCustomFilterNight"]) {
        newImage = [self imageWithImage:inImage withColorMatrix:colormatrix_yese];
    }
    else if ([type isEqualToString:@"SFSCustomFilterElegant"]) {
        newImage = [self imageWithImage:inImage withColorMatrix:colormatrix_danya];
    }
    return newImage;
}


+ (UIImage*)imageWithImage:(UIImage*)inImage withColorMatrix:(const float*) f
{
    unsigned char *imgPixel = RequestImagePixelData(inImage);
    CGImageRef inImageRef = [inImage CGImage];
    GLuint w = (GLuint)CGImageGetWidth(inImageRef);
    GLuint h = (GLuint)CGImageGetHeight(inImageRef);
    
    int wOff = 0;
    int pixOff = 0;
    
    
    for(GLuint y = 0;y< h;y++)//双层循环按照长宽的像素个数迭代每个像素点
    {
        pixOff = wOff;
        
        for (GLuint x = 0; x<w; x++)
        {
            int red = (unsigned char)imgPixel[pixOff];
            int green = (unsigned char)imgPixel[pixOff+1];
            int blue = (unsigned char)imgPixel[pixOff+2];
            int alpha = (unsigned char)imgPixel[pixOff+3];
            changeRGBA(&red, &green, &blue, &alpha, f);
            
            //回写数据
            imgPixel[pixOff] = red;
            imgPixel[pixOff+1] = green;
            imgPixel[pixOff+2] = blue;
            imgPixel[pixOff+3] = alpha;
            
            
            pixOff += 4; //将数组的索引指向下四个元素
        }
        
        wOff += w * 4;
    }
    
    NSInteger dataLength = w * h * 4;
    
    //下面的代码创建要输出的图像的相关参数
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
    
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * w;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    CGImageRef imageRef = CGImageCreate(w, h, bitsPerComponent, bitsPerPixel, bytesPerRow,colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);//创建要输出的图像
    
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    return myImage;
}

//LOMO
const float colormatrix_lomo[] = {
    1.7f,  0.1f, 0.1f, 0, -73.1f,
    0,  1.7f, 0.1f, 0, -73.1f,
    0,  0.1f, 1.6f, 0, -73.1f,
    0,  0, 0, 1.0f, 0 };

//黑白
const float colormatrix_heibai[] = {
    0.8f,  1.6f, 0.2f, 0, -163.9f,
    0.8f,  1.6f, 0.2f, 0, -163.9f,
    0.8f,  1.6f, 0.2f, 0, -163.9f,
    0,  0, 0, 1.0f, 0 };
//复古
const float colormatrix_huajiu[] = {
    0.2f,0.5f, 0.1f, 0, 40.8f,
    0.2f, 0.5f, 0.1f, 0, 40.8f,
    0.2f,0.5f, 0.1f, 0, 40.8f,
    0, 0, 0, 1, 0 };

//哥特
const float colormatrix_gete[] = {
    1.9f,-0.3f, -0.2f, 0,-87.0f,
    -0.2f, 1.7f, -0.1f, 0, -87.0f,
    -0.1f,-0.6f, 2.0f, 0, -87.0f,
    0, 0, 0, 1.0f, 0 };

//锐化
const float colormatrix_ruise[] = {
    4.8f,-1.0f, -0.1f, 0,-388.4f,
    -0.5f,4.4f, -0.1f, 0,-388.4f,
    -0.5f,-1.0f, 5.2f, 0,-388.4f,
    0, 0, 0, 1.0f, 0 };


//淡雅
const float colormatrix_danya[] = {
    0.6f,0.3f, 0.1f, 0,73.3f,
    0.2f,0.7f, 0.1f, 0,73.3f,
    0.2f,0.3f, 0.4f, 0,73.3f,
    0, 0, 0, 1.0f, 0 };

//酒红
const float colormatrix_jiuhong[] = {
    1.2f,0.0f, 0.0f, 0.0f,0.0f,
    0.0f,0.9f, 0.0f, 0.0f,0.0f,
    0.0f,0.0f, 0.8f, 0.0f,0.0f,
    0, 0, 0, 1.0f, 0 };

//清宁
const float colormatrix_qingning[] = {
    0.9f, 0, 0, 0, 0,
    0, 1.1f,0, 0, 0,
    0, 0, 0.9f, 0, 0,
    0, 0, 0, 1.0f, 0 };

//浪漫
const float colormatrix_langman[] = {
    0.9f, 0, 0, 0, 63.0f,
    0, 0.9f,0, 0, 63.0f,
    0, 0, 0.9f, 0, 63.0f,
    0, 0, 0, 1.0f, 0 };

//光晕
const float colormatrix_guangyun[] = {
    0.9f, 0, 0,  0, 64.9f,
    0, 0.9f,0,  0, 64.9f,
    0, 0, 0.9f,  0, 64.9f,
    0, 0, 0, 1.0f, 0 };

//蓝调
const float colormatrix_landiao[] = {
    2.1f, -1.4f, 0.6f, 0.0f, -31.0f,
    -0.3f, 2.0f, -0.3f, 0.0f, -31.0f,
    -1.1f, -0.2f, 2.6f, 0.0f, -31.0f,
    0.0f, 0.0f, 0.0f, 1.0f, 0.0f
};

//梦幻
const float colormatrix_menghuan[] = {
    0.8f, 0.3f, 0.1f, 0.0f, 46.5f,
    0.1f, 0.9f, 0.0f, 0.0f, 46.5f,
    0.1f, 0.3f, 0.7f, 0.0f, 46.5f,
    0.0f, 0.0f, 0.0f, 1.0f, 0.0f
};

//夜色
const float colormatrix_yese[] = {
    1.0f, 0.0f, 0.0f, 0.0f, -66.6f,
    0.0f, 1.1f, 0.0f, 0.0f, -66.6f,
    0.0f, 0.0f, 1.0f, 0.0f, -66.6f,
    0.0f, 0.0f, 0.0f, 1.0f, 0.0f
};



@end
