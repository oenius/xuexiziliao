/*
 Copyright (c) 2016 Jason Pan
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

//
//  GrabCutManager.mm
//  OpenCVTest
//
//  Created by EunchulJeon on 2015. 8. 29..
//  Copyright (c) 2015 Naver Corp.
//  @Author Eunchul Jeon, Jason Pan
//
//  Originally written by Eunchul Jeon, Naver Corp.
//  https://github.com/naver/grabcutios
//

#import "GrabCutManager.h"
#import <opencv2/opencv.hpp>

#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/highgui/highgui_c.h>
#import <opencv2/core/core_c.h>
using namespace cv;


@interface GrabCutManager ()

@property (nonatomic,strong) NSUndoManager *undoRedoMananer;

@property (nonatomic,strong) UIImage *oldSourceImage;

@property (nonatomic,strong) UIImage *oldMaskImage;

@property (nonatomic,assign) CGRect oldRect;

@end

@implementation GrabCutManager

cv::Mat mask; // segmentation (4 possible values)
cv::Mat bgModel,fgModel; // the models (internally used)

-(NSUndoManager *)undoRedoMananer{
    if (_undoRedoMananer == nil) {
        _undoRedoMananer = [[NSUndoManager alloc]init];
    }
    return _undoRedoMananer;
}


- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (cv::Mat1b)cvMatMaskerFromUIImage:(UIImage *) image{
    
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    //    cv::Mat1b markers((int)height, (int)width);
    //    markers.setTo(cv::GC_PR_BGD);
//    LOG(@"%p",&mask);
//    cv::Mat nnn = mask.clone();
//    LOG(@"%p",&nnn);
//    LOG(@"%d",mask.cols);
//    LOG(@"%d",nnn.cols);
    cv::Mat1b markers = mask;
    uchar* data =  markers.data;
    
    int countFGD=0, countBGD=0, countRem = 0;
    
    for(int x = 0; x < width; x++){
        for( int y = 0; y < height; y++){
            NSUInteger byteIndex = ((image.size.width  * y) + x ) * 4;
            UInt8 red   = rawData[byteIndex];
            UInt8 green = rawData[byteIndex + 1];
            UInt8 blue  = rawData[byteIndex + 2];
            UInt8 alpha = rawData[byteIndex + 3];
            
//            if (green > 240) {
////                red = green = blue = 0;
////                alpha = 255;
//                data[width*y + x] = cv::GC_BGD;
//                countBGD++;
//
//            }else if (green == blue == 0) {
//                countRem++;
//            }else {
//                data[width*y + x] = cv::GC_FGD;
//                countFGD++;
//            }
            
            if(red == 255 && green == 255 && blue == 255 && alpha == 255){
                data[width*y + x] = cv::GC_FGD;
                countFGD++;
            }else if(red == 0 && green == 0 && blue == 0 && alpha == 255){
                data[width*y + x] = cv::GC_BGD;
                countBGD++;
            }else{
                countRem++;
            }
        }
    }
    
    free(rawData);
    
    LOG(@"Count %d %d %d sum : %d width*height : %d", countFGD, countBGD, countRem, countFGD+countBGD + countRem, int(width*height));
    
    return markers;
}


-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaLast|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
//    LOG(@"%zu",cvMat.elemSize());
//    LOG(@"%zu",cvMat.step[0]);
//    LOG(@"%d",cvMat.cols * 4);
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

- (UIImage *)alphaImage:(CGImageRef )cgimage
{

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
            if (alpha == 255 && red == 255 && green == 255 && blue == 255) {
                red = 0;
                green = 0;
                blue = 0;
                alpha = 0;
            }
        }
        
    }
    
    cgimage = CGBitmapContextCreateImage(context);
    
    return [UIImage imageWithCGImage:cgimage];
    
}



-(Mat3b) maskImageToMatrix:(CGSize)imageSize{
    int cols = imageSize.width;
    int rows = imageSize.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC3); // 8 bits per component, 4 channels (color channels + alpha)
    cvMat.setTo(0);
    
    uchar* data = mask.data;
    
    int fgd,bgd,pfgd,pbgd;
    fgd = 0;
    bgd = 0;
    pfgd = 0;
    pbgd = 0;
    
    for(int y = 0; y < rows; y++){
        for( int x = 0; x < cols; x++){
            int index = cols*y+x;
            if(data[index] == GC_FGD){
                cvMat.at<Vec3b>(cv::Point(x,y)) = Vec3b(255,0,0);
                fgd++;
            }else if(data[index] == GC_BGD){
                cvMat.at<Vec3b>(cv::Point(x,y)) = Vec3b(0,255,0);
                bgd++;
            }else if(data[index] == GC_PR_FGD){
                cvMat.at<Vec3b>(cv::Point(x,y)) = Vec3b(0,0,255);
                pfgd++;
            }else if(data[index] == GC_PR_BGD){
                cvMat.at<Vec3b>(cv::Point(x,y)) = Vec3b(255,255,0);
                pbgd++;
            }
        }
    }
    
    LOG(@"fgd : %d bgd : %d pfgd : %d pbgd : %d total : %d width*height : %d", fgd,bgd,pfgd,pbgd, fgd+bgd+pfgd+pbgd, cols*rows);
    
    return cvMat;
}

-(Mat4b) resultMaskToMatrix:(CGSize)imageSize{
    int cols = imageSize.width;
    int rows = imageSize.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    cvMat.setTo(0);
    
    uchar* data = mask.data;
    
    int fgd,bgd,pfgd,pbgd;
    fgd = 0;
    bgd = 0;
    pfgd = 0;
    pbgd = 0;
    
//    for(int y = 0; y < rows; y++){
//        for( int x = 0; x < cols; x++){
//            int index = cols*y+x;
//            if(data[index] == GC_FGD){
//                cvMat.at<Vec4b>(cv::Point(x,y)) = Vec4b(0,0,0,255);
//                fgd++;
//            }else if(data[index] == GC_BGD){
//                cvMat.at<Vec4b>(cv::Point(x,y)) = Vec4b(255,255,255,255);
//                bgd++;
//            }else if(data[index] == GC_PR_FGD){
//                cvMat.at<Vec4b>(cv::Point(x,y)) = Vec4b(0,0,0,255);
//                pfgd++;
//            }else if(data[index] == GC_PR_BGD){
//                cvMat.at<Vec4b>(cv::Point(x,y)) = Vec4b(255,255,255,255);
//                pbgd++;
//            }
//        }
//    }
    for(int y = 0; y < rows; y++){
        for( int x = 0; x < cols; x++){
            int index = cols*y+x;
            if(data[index] == GC_FGD){
                cvMat.at<Vec4b>(cv::Point(x,y)) = Vec4b(255,0,0,255);
                fgd++;
            }else if(data[index] == GC_BGD){
                cvMat.at<Vec4b>(cv::Point(x,y)) = Vec4b(255,255,255,0);
                bgd++;
            }else if(data[index] == GC_PR_FGD){
                cvMat.at<Vec4b>(cv::Point(x,y)) = Vec4b(255,0,0,255);
                pfgd++;
            }else if(data[index] == GC_PR_BGD){
                cvMat.at<Vec4b>(cv::Point(x,y)) = Vec4b(255,255,255,0);
                pbgd++;
            }
        }
    }
    LOG(@"fgd : %d bgd : %d pfgd : %d pbgd : %d total : %d width*height : %d", fgd,bgd,pfgd,pbgd, fgd+bgd+pfgd+pbgd, cols*rows);
    
    return cvMat;
}


-(void) resetManager{
    mask.setTo(cv::GC_PR_BGD);
    bgModel.setTo(0);
    fgModel.setTo(0);
    self.undoRedoMananer = nil;
}

-(UIImage*)doGrabCut:(UIImage*)sourceImage foregroundBound:(CGRect)rect iterationCount:(int) iterCount{
    if (self.oldSourceImage != sourceImage) {
        [[self.undoRedoMananer prepareWithInvocationTarget:self] doGrabCut:self.oldSourceImage foregroundBound:self.oldRect iterationCount:iterCount];
        self.oldSourceImage = sourceImage;
        self.oldRect = rect;
    }
    
    if (sourceImage == nil ) {
        return nil;
    }
    cv::Mat img=[self cvMatFromUIImage:sourceImage];
    cv::cvtColor(img , img , CV_RGBA2RGB);
    cv::Rect rectangle(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
    // GrabCut segmentation
    cv::grabCut(img,    // input image
                mask,      // segmentation result
                rectangle,   // rectangle containing foreground
                bgModel,fgModel, // models
                iterCount,           // number of iterations
                cv::GC_INIT_WITH_RECT); // use rectangle
    // Get the pixels marked as likely foreground
    
    UIImage* resultImage = [self UIImageFromCVMat:[self resultMaskToMatrix:sourceImage.size]];
    
//    cv::Mat tempMask;
//    cv::compare(mask,cv::GC_PR_FGD,tempMask,cv::CMP_EQ);
//    // Generate output image
//    cv::Mat foreground(img.size(),CV_8UC3,
//                       cv::Scalar(255,255,255));
//    
//    tempMask=tempMask&1;
//    
//    UIImage* resultImage = [self UIImageFromCVMat:tempMask];
//    
//    img.copyTo(foreground, tempMask);
//    
//    UIImage* resultImage=[self UIImageFromCVMat:foreground];
    
    return resultImage;
}

-(UIImage*)doGrabCutWithMask:(UIImage*)sourceImage maskImage:(UIImage*)maskImage iterationCount:(int) iterCount{
    
    if (self.oldMaskImage != maskImage) {
        if (self.oldMaskImage == nil) {
            [[self.undoRedoMananer prepareWithInvocationTarget:self] doGrabCut:self.oldSourceImage foregroundBound:self.oldRect iterationCount:iterCount];
            
        }else{
            [[self.undoRedoMananer prepareWithInvocationTarget:self]doGrabCutWithMask:sourceImage maskImage:self.oldMaskImage iterationCount:iterCount];
        }
        self.oldMaskImage = maskImage;
    }
    if (maskImage == nil) {
        return nil;
    }
    
    if (mask.data == nil) {
        [self doGrabCut:sourceImage foregroundBound:CGRectMake(1, 1, sourceImage.size.width-2, sourceImage.size.height-2) iterationCount:iterCount];
    }
    
    cv::Mat img=[self cvMatFromUIImage:sourceImage];
    cv::cvtColor(img , img , CV_RGBA2RGB);
    
    cv::Mat1b markers=[self cvMatMaskerFromUIImage:maskImage];
    cv::Rect rectangle(0,0,0,0);

    cv::grabCut(img, markers, rectangle, bgModel, fgModel, iterCount, cv::GC_INIT_WITH_MASK);
    
    
    UIImage* resultImage = [self UIImageFromCVMat:[self resultMaskToMatrix:sourceImage.size]];
//    cv::Mat tempMask;
//    cv::compare(mask,cv::GC_PR_FGD|cv::GC_FGD,tempMask,cv::CMP_EQ);
////    // Generate output image
////    cv::Mat foreground(img.size(),CV_8UC3,
////                       cv::Scalar(255,255,255));
//    // Generate output image
////    cv::Mat foreground(img.size(),CV_8UC3, cv::Scalar(255,255,255));
////    cv::Mat foreground(img.size(),CV_8UC3, cv::Scalar(255,0,0));
//    cv::Mat foreground(img.size(),CV_8UC3, cv::Scalar(0,0,255));
//    
//    tempMask=tempMask&1;
//    img.copyTo(foreground, tempMask);
//    
//    UIImage* resultImage=[self UIImageFromCVMat:foreground];
    
//    //    UIImage* resultImage =[self UIImageFromCVMat:[self maskImageToMatrix:sourceImage.size]];
//    
//    
//    //    UIImage* resultImage=[self UIImageFromCVMat:[self maskImageToMatrix:sourceImage.size]];
//        cv::Mat1b mask_fgpf = ( markers == cv::GC_FGD) | ( markers == cv::GC_PR_FGD);
//        // and copy all the foreground-pixels to a temporary image
//        cv::Mat3b tmp = cv::Mat3b::zeros(img.rows, img.cols);
//        img.copyTo(tmp, mask_fgpf);
//    
//    
//        UIImage* resultImage=[self UIImageFromCVMat:tmp];
    
    return resultImage;
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature * methodSignature  = [[self class] instanceMethodSignatureForSelector:aSelector];
    
    if (!methodSignature) {
        methodSignature = [NSMethodSignature signatureWithObjCTypes:"v@:*"];
    }
    LOG(@"%s",__func__);
    return methodSignature;
}
-(void)undo{
    if (self.undoRedoMananer.isRedoing || self.undoRedoMananer.isUndoing) {
        return;
    }
    if ([self.undoRedoMananer canUndo]) {
        [self.undoRedoMananer undo];
    }
}
-(void)redo{
    if (self.undoRedoMananer.isRedoing || self.undoRedoMananer.isUndoing) {
        return;
    }
    if ([self.undoRedoMananer canRedo]) {
        [self.undoRedoMananer redo];
    }
}

@end
