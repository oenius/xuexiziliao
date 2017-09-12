//
//  IDCutBGViewModel.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/27.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDCutBGViewModel.h"

static inline double radians (double degrees) {return degrees * M_PI/180;}

///决定处理效率和处理速度 300
const static int MAX_IMAGE_LENGTH = 300;

@implementation IDCutBGViewModel

-(UIImage *)getProperResizedImage:(UIImage*)original{
    float ratio = original.size.width/original.size.height;
    
    if(original.size.width > original.size.height){
        if(original.size.width > MAX_IMAGE_LENGTH){
            return [self resizeWithRotation:original size:CGSizeMake(MAX_IMAGE_LENGTH, MAX_IMAGE_LENGTH/ratio)];
        }
    }else{
        if(original.size.height > MAX_IMAGE_LENGTH){
            return [self resizeWithRotation:original size:CGSizeMake(MAX_IMAGE_LENGTH*ratio, MAX_IMAGE_LENGTH)];
        }
    }
    return original;
}


-(UIImage*)resizeWithRotation:(UIImage *) sourceImage size:(CGSize)targetSize
{
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }
    
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage;
}
-(UIImage*)resizeImage:(UIImage*)image size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, size.width, size.height), [image CGImage]);
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}


-(UIImage *)UIImageAlphaFromImage:(UIImage *)image
{
    
    CGImageRef oldImageRef = [image CGImage];
    
    NSData *data = UIImagePNGRepresentation(image);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(CGImageGetWidth(oldImageRef),                                 //width
                                        CGImageGetHeight(oldImageRef),                                 //height
                                        CGImageGetBitsPerComponent(oldImageRef),                                          //bits per component
                                        CGImageGetBitsPerPixel(oldImageRef),                       //bits per pixel
                                        CGImageGetBytesPerRow(oldImageRef),                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}
- (UIImage *)alphaImage:(UIImage *)image
{
    CGImageRef cgimage = image.CGImage;
    size_t width = CGImageGetWidth(cgimage); // 图片宽度
    
    size_t height = CGImageGetHeight(cgimage); // 图片高度
    
    unsigned char *data = (unsigned char*) calloc(width * height * 4, sizeof(unsigned char)); // 取图片首地址
    
    size_t bitsPerComponent = 8; // r g b a 每个component bits数目
    
    size_t bytesPerRow = width * 4; // 一张图片每行字节数目 (每个像素点包含r g b a 四个字节)
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB(); // 创建rgb颜色空间
    
    CGContextRef context =
    
    CGBitmapContextCreate(data,
                          width,
                          height,
                          bitsPerComponent,
                          bytesPerRow,
                          space,
                          kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgimage);
    
    for (size_t i = 0; i < height; i++)
    {
        for (size_t j = 0; j < width; j++)
        {
            size_t pixelIndex = i * width * 4 + j * 4;
            unsigned char red = data[pixelIndex];
            
            unsigned char green = data[pixelIndex + 1];
            
            unsigned char blue = data[pixelIndex + 2];
            
            unsigned char alpha = data[pixelIndex + 3];
            // 修改颜色
            if (alpha == 0) {
                red = 0;
                green = 0;
                blue = 0;
                alpha = 0;
            }else{
                red = 255;
                green = 255;
                blue = 255;
                alpha = 255;
            }
        }
        
    }
    
    cgimage = CGBitmapContextCreateImage(context);
    
    return [UIImage imageWithCGImage:cgimage];
    
}

-(UIImage *)masking:(UIImage*)sourceImage mask:(UIImage*) maskImage useTest:(BOOL)use{
    //Mask Image
    UIImage * testMaskImage = [self createImageWithColor:[UIColor clearColor] size:maskImage.size];
    CGImageRef maskRef =  use ? testMaskImage.CGImage : maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([sourceImage CGImage], mask);
    CGImageRelease(mask);
    
    UIImage *maskedImage = [UIImage imageWithCGImage:masked];
    
    NSData * imageData = UIImagePNGRepresentation(maskedImage);
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:imageData], nil, nil, nil);
    
    CGImageRelease(masked);
    
    return maskedImage;
}

- (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f,0.0f,1.0f,1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *myImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return myImage;
}

-(CGRect)getTouchedRectWithImageSize:(CGSize) size atView:(UIView *)atView andRect:(CGRect)rect{
    CGFloat widthScale = size.width/atView.frame.size.width;
    CGFloat heightScale = size.height/atView.frame.size.height;
    CGFloat x = rect.origin.x * widthScale;
    CGFloat y = rect.origin.y * heightScale;
    CGFloat w = rect.size.width * widthScale;
    CGFloat h = rect.size.height * heightScale;
    
    return CGRectMake(x, y, w, h);
}

-(CGRect)getTouchedRect:(CGPoint)startPoint endPoint:(CGPoint)endPoint{
    return [self getTouchedRect:startPoint endPoint:endPoint widthScale:1.0 heightScale:1.0];
}

-(CGRect)getTouchedRect:(CGPoint)startPoint endPoint:(CGPoint)endPoint widthScale:(CGFloat)widthScale heightScale:(CGFloat)heightScale{
    CGFloat minX = startPoint.x > endPoint.x ? endPoint.x*widthScale : startPoint.x*widthScale;
    CGFloat maxX = startPoint.x < endPoint.x ? endPoint.x*widthScale : startPoint.x*widthScale;
    CGFloat minY = startPoint.y > endPoint.y ? endPoint.y*heightScale : startPoint.y*heightScale;
    CGFloat maxY = startPoint.y < endPoint.y ? endPoint.y*heightScale : startPoint.y*heightScale;
    
    return CGRectMake(minX, minY, maxX - minX, maxY - minY);
}


-(CGSize)getProperImageViewSize:(CGSize)imageSize maxWidth:(CGFloat)maxWidth maxHeight:(CGFloat)maxHeight{
    CGFloat scale = imageSize.width/imageSize.height;
    CGFloat imageViewWidth ,imageViewHeight;
    if (scale <= 1) {
        imageViewHeight = maxHeight;
        imageViewWidth = imageViewHeight * scale;
        if (imageViewWidth > maxWidth) {
            imageViewWidth = maxWidth;
            imageViewHeight = imageViewWidth / scale;
        }
    }else{
        imageViewWidth = maxWidth;
        imageViewHeight = imageViewWidth / scale;
        if (imageViewHeight > maxHeight) {
            imageViewHeight = maxHeight;
            imageViewWidth = imageViewHeight * scale;
        }
    }
    return CGSizeMake(imageViewWidth, imageViewHeight);
}

-(CGRect)covertRect:(CGRect)rect fromView:(UIView*)fromView toView:(UIView *)toView{
    
    CGRect newRect = [fromView convertRect:rect toView:toView];
    
    
    
    //区域选择错误
    if (CGRectGetMaxX(newRect) < 0 || CGRectGetMinX(newRect) > CGRectGetWidth(toView.frame)) {
        return CGRectMake(0, 0, 0, 0);
    }
    if (CGRectGetMaxY(newRect) < 0 || CGRectGetMinY(newRect) > CGRectGetHeight(toView.frame)) {
        return CGRectMake(0, 0, 0, 0);
    }
    
    //区域修正
    // x方向
    CGFloat newX = 0, newWidth = 0;
    if (newRect.origin.x <= 0) {
        newX = 0;
        newWidth = newRect.size.width - ABS(newRect.origin.x);
        if (newWidth >= toView.bounds.size.width) {
            newWidth = toView.bounds.size.width;
        }
    }
    if (newRect.origin.x > 0) {
        newX = newRect.origin.x;
        CGFloat tempWidth = toView.frame.size.width - newX;
        CGFloat flag = newX + newRect.size.width;
        if (flag > toView.frame.size.width) {
            newWidth = tempWidth;
        }else{
            newWidth = newRect.size.width;
        }
    }
    newRect.origin.x = newX;
    newRect.size.width = newWidth;
    
    //y方向
    CGFloat newY=0,newHeight=0;
    if (newRect.origin.y <= 0) {
        newY = 0;
        newHeight = newRect.size.height - ABS(newRect.origin.y);
        if (newHeight >= toView.frame.size.height) {
            newHeight = toView.bounds.size.height;
        }
    }
    if (newRect.origin.y > 0) {
        newY = newRect.origin.y;
        CGFloat tempHeight = toView.frame.size.height - newY;
        CGFloat flag = newY + newRect.size.height;
        if (flag > toView.frame.size.height) {
            newHeight = tempHeight;
        }else{
            newHeight = newRect.size.height;
        }
    }
    
    newRect.origin.y = newY;
    newRect.size.height = newHeight;
    
    //修正
    if ((newRect.origin.x == 0) &&
        (newRect.origin.y == 0) &&
        (newRect.size.width == toView.bounds.size.width) &&
        (newRect.size.height == toView.bounds.size.height)) {
        newRect.origin.y = 10;
    }
    
    
    return newRect;
}


- (UIImage *)imageFromView:(UIView *)view rect:(CGRect)rect
{
    
    UIGraphicsBeginImageContext(view.bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    UIRectClip(rect);
    
    [view.layer renderInContext:context];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    
    image = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    return  image;
    
}

-(UIImage*)createCircleImageWithColor:(UIColor*) color size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    //    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // CGContextMoveToPoint(context, 0, 0);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextAddArc(context, size.width/2, size.height/2, size.width/2, 0, M_PI*2, 0);
    CGContextFillPath(context);
    //CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

-(BOOL)isUnderMinimumRect:(CGRect)rect{
    if(rect.size.width <20.0 || rect.size.height < 20.0){
        return YES;
    }
    return NO;
}

- (UIImage *)getMaskImageFromImageAlpha:(UIImage *)souceImage
{
    CGImageRef cgimage = souceImage.CGImage;
    //get dimensions
    NSInteger width = CGImageGetWidth(cgimage);
    NSInteger height = CGImageGetHeight(cgimage);
    
    //create alpha image
    NSInteger bytesPerRow = ((width + 3) / 4) * 4;
    void *data = calloc(bytesPerRow * height, sizeof(unsigned char *));
    CGContextRef context = CGBitmapContextCreate(data, width, height, 8, bytesPerRow, NULL, kCGImageAlphaOnly);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), cgimage);
   
    
    //invert alpha pixels
    for (int y = 0; y < height; y++)
    {
        for (int x = 0; x < width; x++)
        {
            NSInteger index = y * bytesPerRow + x;
            ((unsigned char *)data)[index] = 255 - ((unsigned char *)data)[index];
        }
    }
    
    //create mask image
    CGImageRef maskRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    UIImage *mask = [UIImage imageWithCGImage:maskRef];
    CGImageRelease(maskRef);
    free(data);
    //return image
    return mask;
}

-(UIImage*)maskimageSourceImage:(UIImage *)sourceImage maskImage:(UIImage *)maskImage{
    
    UIImageView * cutImageView = [[UIImageView alloc]initWithImage:sourceImage];
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = cutImageView.bounds;
    maskLayer.contents = (__bridge id)maskImage.CGImage;
//    maskLayer.shadowOpacity = 5;
//    maskLayer.shadowColor = [[UIColor blackColor] CGColor];
//    maskLayer.shadowOffset = CGSizeMake(0,0);
//    maskLayer.shadowRadius = 5;
    cutImageView.layer.mask = maskLayer;
    UIGraphicsBeginImageContextWithOptions(cutImageView.bounds.size,NO,1.0);
    [cutImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}
-(UIImage *) masking:(UIImage*)sourceImage mask:(UIImage*) maskImage{
    //Mask Image
    CGImageRef maskRef = maskImage.CGImage;

    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([sourceImage CGImage], mask);
    CGImageRelease(mask);
    
    UIImage *maskedImage = [UIImage imageWithCGImage:masked];
    
    CGImageRelease(masked);
    
    return maskedImage;
//
//    UIImage *image = [sourceImage jk_imageWithAlpha];
//    
//    CGRect newRect = CGRectMake(0, 0, image.size.width, image.size.height);
//    
//    // Build a context that's the same dimensions as the new size
//    CGContextRef bitmap = CGBitmapContextCreate(NULL,
//                                                newRect.size.width,
//                                                newRect.size.height,
//                                                CGImageGetBitsPerComponent(sourceImage.CGImage),
//                                                0,
//                                                CGImageGetColorSpace(sourceImage.CGImage),
//                                                CGImageGetBitmapInfo(sourceImage.CGImage));
//    
//
//    CGContextDrawImage(bitmap, newRect, sourceImage.CGImage);
//    CGImageRef borderImageRef = CGBitmapContextCreateImage(bitmap);
//     maskImage = [maskImage jk_imageWithAlpha];
//    CGImageRef maskRef = maskImage.CGImage;
//    
//    CGImageRef maskImageRef = CGImageMaskCreate(CGImageGetWidth(maskRef),
//                                        CGImageGetHeight(maskRef),
//                                        CGImageGetBitsPerComponent(maskRef),
//                                        CGImageGetBitsPerPixel(maskRef),
//                                        CGImageGetBytesPerRow(maskRef),
//                                        CGImageGetDataProvider(maskRef), NULL, false);
//
//    CGImageRef transparentBorderImageRef = CGImageCreateWithMask(borderImageRef, maskImageRef);
//    UIImage *transparentBorderImage = [UIImage imageWithCGImage:transparentBorderImageRef];
//    
//    // Clean up
//    CGContextRelease(bitmap);
//    CGImageRelease(borderImageRef);
//    CGImageRelease(maskImageRef);
//    CGImageRelease(transparentBorderImageRef);
//    return transparentBorderImage;
    
}
- (UIImage *)masked:(UIImage *)image_ WithMask:(UIImage *)maskImage
{

    CGImageRef maskImageRef = maskImage.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskImageRef),
                                        CGImageGetHeight(maskImageRef),
                                        CGImageGetBitsPerComponent(maskImageRef),
                                        CGImageGetBitsPerPixel(maskImageRef),
                                        CGImageGetBytesPerRow(maskImageRef),
                                        CGImageGetDataProvider(maskImageRef), NULL, false);

    
    CGImageRef sourceImage = image_.CGImage;
    CGImageRef maskedImage;
    
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(sourceImage);
    
    if (alpha != kCGImageAlphaFirst && alpha != kCGImageAlphaLast && alpha != kCGImageAlphaPremultipliedFirst && alpha != kCGImageAlphaPremultipliedLast) {
        size_t width = CGImageGetWidth(sourceImage);
        size_t height = CGImageGetHeight(sourceImage);
        
        CGContextRef offscreenContext = CGBitmapContextCreate(NULL, width, height,
                                                              8, 0, CGImageGetColorSpace(sourceImage),
                                                              kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
        
        CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), sourceImage);
        
        CGImageRef imageRefWithAlpha = CGBitmapContextCreateImage(offscreenContext);
        maskedImage = CGImageCreateWithMask(imageRefWithAlpha, mask);
        CGImageRelease(imageRefWithAlpha);
        
        CGContextRelease(offscreenContext);
    } else {
        maskedImage = CGImageCreateWithMask(sourceImage, mask);
    }
    
    UIImage *returnImage = [UIImage imageWithCGImage:maskedImage];
    
    CGImageRelease(maskedImage);
    CGImageRelease(mask);
    
    return returnImage;
}
- (UIImage *)trimmedBetterSize:(UIImage *)image {
    if (image == nil) {
        return nil;
    }
    CGImageRef inImage = image.CGImage;
    CFDataRef m_DataRef;
    m_DataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    
    UInt8 * m_PixelBuf = (UInt8 *) CFDataGetBytePtr(m_DataRef);
    
    CGFloat width = CGImageGetWidth(inImage);
    CGFloat height = CGImageGetHeight(inImage);
    CGPoint top,left,right,bottom;
    
    BOOL breakOut = NO;
    for (int x = 0;breakOut==NO && x < width; x++) {
        for (int y = 0; y < height; y++) {
            int loc = x + (y * width);
            loc *= 4;
            if (m_PixelBuf[loc + 3] != 0) {
                left = CGPointMake(x, y);
                breakOut = YES;
                break;
            }
        }
    }
    
    breakOut = NO;
    for (int y = 0;breakOut==NO && y < height; y++) {
        
        for (int x = 0; x < width; x++) {
            
            int loc = x + (y * width);
            loc *= 4;
            if (m_PixelBuf[loc + 3] != 0) {
                top = CGPointMake(x, y);
                breakOut = YES;
                break;
            }
        }
    }
    
    breakOut = NO;
    for (int y = height-1;breakOut==NO && y >= 0; y--) {
        
        for (int x = width-1; x >= 0; x--) {
            
            int loc = x + (y * width);
            loc *= 4;
            if (m_PixelBuf[loc + 3] != 0) {
                bottom = CGPointMake(x, y);
                breakOut = YES;
                break;
            }
            
        }
    }
    
    breakOut = NO;
    for (int x = width-1;breakOut==NO && x >= 0; x--) {
        
        for (int y = height-1; y >= 0; y--) {
            
            int loc = x + (y * width);
            loc *= 4;
            if (m_PixelBuf[loc + 3] != 0) {
                right = CGPointMake(x, y);
                breakOut = YES;
                break;
            }
            
        }
    }
    

    CGFloat scale = image.scale;
    
    CGRect cropRect = CGRectMake(left.x / scale, top.y/scale, (right.x - left.x)/scale, (bottom.y - top.y) / scale);
    UIGraphicsBeginImageContextWithOptions( cropRect.size,
                                           NO,
                                           scale);
    [image drawAtPoint:CGPointMake(-cropRect.origin.x, -cropRect.origin.y)
             blendMode:kCGBlendModeCopy
                 alpha:1.];
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CFRelease(m_DataRef);
    return croppedImage;
}
-(UIImage *)drawImage:(UIImage *) drawImage atImage:(UIImage *)sourceImage{
    CGSize size = sourceImage.size;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
//    UIGraphicsBeginImageContext(size);
//    [sourceImage drawAtPoint:CGPointMake(0, 0)];
//    [drawImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
//    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    return [self drawImage:drawImage atImage:sourceImage withRect:rect];
}


-(UIImage *)drawImage:(UIImage *) drawImage atImage:(UIImage *)sourceImage withRect:(CGRect) rect{
    CGSize size = sourceImage.size;
    UIGraphicsBeginImageContext(size);
    [sourceImage drawAtPoint:CGPointMake(0, 0)];
    [drawImage drawInRect:rect];
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

-(UIImage *)getImageAtView:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size,NO,0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

//** 颜色变化 */
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}
- (UIImage*)getNewMaskFrom:(UIImage*)oldMask{
    const int imageWidth = oldMask.size.width;
    const int imageHeight = oldMask.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), oldMask.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            uint8_t red     = ptr[3];
            uint8_t green   = ptr[2];
            uint8_t blue    = ptr[1];
//            uint8_t alpha   = ptr[0];
            if ((red>=6 && red<=8)&& (green>=37 && green<=39) && (blue>=189 && blue<=191)) {//7,38,190
//            if (alpha != 0) {
                ptr[1] = 0;
                ptr[2] = 0;
                ptr[3] = 0;
            }else{
                ptr[1] = 255;
                ptr[2] = 255;
                ptr[3] = 255;
            }
            ptr[0] = 255;
//        if ((*pCurPtr & 0xFFFFFF00) < 0x82828200)    // 将像素值进行判断
//        {
//            // 改成下面的代码，会将图片转成想要的颜色
//            uint8_t* ptr = (uint8_t*)pCurPtr;
//        
//            uint8_t red     = ptr[3];
//            uint8_t green   = ptr[2];
//            uint8_t blue    = ptr[1];
//            if (red == 0 && green ==0 && blue == 0 ) {
//                ptr[0] = 0;
//            }
//        }
//        else
//        {
//            uint8_t* ptr = (uint8_t*)pCurPtr;
//            ptr[0] = 0;
//        }
        
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

-(UIImage *)image:(UIImage *)orimage addBGColor:(UIColor *)color{
    CGSize size = orimage.size;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    [orimage drawAtPoint:CGPointMake(0, 0)];
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

#pragma mark - Marge two Images

//- (UIImage *)addImageToImage:(UIImage *)img withImage2:(UIImage *)img2 andRect:(CGRect)cropRect{
//    
//    CGSize size = CGSizeMake(imageView.image.size.width, imageView.image.size.height);
//    UIGraphicsBeginImageContext(size);
//    
//    CGPoint pointImg1 = CGPointMake(0,0);
//    [img drawAtPoint:pointImg1];
//    
//    CGPoint pointImg2 = cropRect.origin;
//    [img2 drawAtPoint: pointImg2];
//    
//    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return result;
//}
@end
