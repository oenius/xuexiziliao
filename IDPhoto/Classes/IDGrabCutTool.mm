//
//  IDGrabCutTool.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/27.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDGrabCutTool.h"

@implementation IDGrabCutTool

-(cv::Mat)getMask{
    cv:: Mat newMask ;
    mask.copyTo(mask);
    return newMask;
}

-(void)setMask:(cv::Mat)newMask{
    newMask.copyTo(mask);
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
//            [UIColor colorWithRed:1.00 green:0.94 240 blue:0.21 53 alpha:1.00]
            if(red == 255 && green == 240 && blue == 53 && alpha == 255){
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
    
    NSLog(@"Count %d %d %d sum : %d width*height : %d", countFGD, countBGD, countRem, countFGD+countBGD + countRem, int(width*height));
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
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

-(Mat3b)maskImageToMatrix:(CGSize)imageSize{
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
    
    NSLog(@"fgd : %d bgd : %d pfgd : %d pbgd : %d total : %d width*height : %d", fgd,bgd,pfgd,pbgd, fgd+bgd+pfgd+pbgd, cols*rows);
    
    return cvMat;
}

-(Mat4b)resultMaskToMatrix:(CGSize)imageSize{
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
    //    }[UIColor colorWithRed:0.03 green:0.15 blue:0.75 alpha:1.00]
    for(int y = 0; y < rows; y++){
        for( int x = 0; x < cols; x++){
            int index = cols*y+x;
            if(data[index] == GC_FGD){
                cvMat.at<Vec4b>(cv::Point(x,y)) = Vec4b(7,38,190,255);
                fgd++;
            }else if(data[index] == GC_BGD){
                cvMat.at<Vec4b>(cv::Point(x,y)) = Vec4b(255,255,255,0);
                bgd++;
            }else if(data[index] == GC_PR_FGD){
                cvMat.at<Vec4b>(cv::Point(x,y)) = Vec4b(7,38,190,255);
                pfgd++;
            }else if(data[index] == GC_PR_BGD){
                cvMat.at<Vec4b>(cv::Point(x,y)) = Vec4b(255,255,255,0);
                pbgd++;
            }
        }
    }
    NSLog(@"fgd : %d bgd : %d pfgd : %d pbgd : %d total : %d width*height : %d", fgd,bgd,pfgd,pbgd, fgd+bgd+pfgd+pbgd, cols*rows);
    
    return cvMat;
}


-(void) resetManager{
    mask.setTo(cv::GC_PR_BGD);
    bgModel.setTo(0);
    fgModel.setTo(0);
}


-(void)prepareGrabCut:(UIImage *)sourceImage iterationCount:(int)iterCount{
    [self doGrabCut:sourceImage foregroundBound:CGRectMake(1, 1, sourceImage.size.width-2, sourceImage.size.height-2) iterationCount:iterCount];
}

-(UIImage*)doGrabCut:(UIImage*)sourceImage foregroundBound:(CGRect)rect iterationCount:(int) iterCount{
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
    
    return resultImage;
}

-(UIImage*)doGrabCutWithMask:(UIImage*)sourceImage maskImage:(UIImage*)maskImage iterationCount:(int) iterCount{
    
    if (maskImage == nil || sourceImage == nil) {return nil;}
    
    if (mask.data == nil) {
        [self prepareGrabCut:sourceImage iterationCount:iterCount];
    }
    
    cv::Mat img=[self cvMatFromUIImage:sourceImage];
    cv::cvtColor(img , img , CV_RGBA2RGB);
    
    cv::Mat1b markers=[self cvMatMaskerFromUIImage:maskImage];
    cv::Rect rectangle(0,0,0,0);
    
    cv::grabCut(img, markers, rectangle, bgModel, fgModel, iterCount, cv::GC_INIT_WITH_MASK);
    
    UIImage* resultImage = [self UIImageFromCVMat:[self resultMaskToMatrix:sourceImage.size]];
    
    return resultImage;
}
-(UIImage *)bianYuanQuJuChi:(UIImage *)maskImage{
    
    Mat vesselImage = [self cvMatFromUIImage:maskImage];
//    NSString * path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"ceshi3.jpg"];
//    
//    Mat vesselImage = imread([path UTF8String]);
    
    cv::threshold(vesselImage, vesselImage, 125, 255, THRESH_BINARY);
    
    cv::Mat blurredImage; //output of the algorithm
    
    cv::pyrUp(vesselImage, blurredImage);
    
    for (int i = 0; i < 15; i++)
        
    cv::medianBlur(blurredImage, blurredImage, 7);
    
    cv::pyrDown(blurredImage, blurredImage);
    
    cv::threshold(blurredImage, blurredImage, 200, 255, THRESH_BINARY);
    
    return  [self UIImageFromCVMat:blurredImage];
    
}
-(UIImage*)bianYuanXuHua:(UIImage *)sourceImage;
{
   
    IplImage * image = [[self class] IplImageFromUIImage:sourceImage];
//    IplImage* newimage = cvCreateImage(
//                                  cvGetSize(image),   //获得输入图片的大小，并进行创建，也可以使用cvSize（）
//                                  IPL_DEPTH_8U,
//                                  3
//                                  );
    IplImage * newimage = [[self class] IplImageFromUIImage:sourceImage];
    cvSmooth(image,newimage,CV_BLUR,2,2);
//    cvSmooth(image,newimage,CV_BLUR,11,11);
    UIImage *resultImage = [[self class] UIImageFromIplImage:newimage];
    return resultImage;

//    Mat img= [self cvMatFromUIImage:sourceImage];
//    Mat whole_image=[self cvMatFromUIImage:sourceImage];
//    whole_image.convertTo(whole_image,CV_32FC3,1.0/255.0);
//    cv::resize(whole_image,whole_image,img.size());
//    img.convertTo(img,CV_32FC3,1.0/255.0);
//    
//    Mat bg=Mat(img.size(),CV_32FC3);
//    bg=Scalar(1.0,1.0,1.0);
//    
//    // Prepare mask
//    Mat mask;
//    Mat img_gray;
//    cv::cvtColor(img,img_gray,cv::COLOR_BGR2GRAY);
//    img_gray.convertTo(mask,CV_32FC1);
//    threshold(1.0-mask,mask,0.9,1.0,cv::THRESH_BINARY_INV);
//    
//    cv::GaussianBlur(mask,mask,cv::Size(21,21),11.0);

    
    
    // Reget the image fragment with smoothed mask
//    Mat res;
//    
//    std::vector<Mat> ch_img(3);
//    std::vector<Mat> ch_bg(3);
//    cv::split(whole_image,ch_img);
//    cv::split(bg,ch_bg);
//    ch_img[0]=ch_img[0].mul(mask)+ch_bg[0].mul(1.0-mask);
//    ch_img[1]=ch_img[1].mul(mask)+ch_bg[1].mul(1.0-mask);
//    ch_img[2]=ch_img[2].mul(mask)+ch_bg[2].mul(1.0-mask);
//    cv::merge(ch_img,res);
//    cv::merge(ch_bg,bg);
    
//    UIImage *resultImage = [self UIImageFromCVMat:mask];
//    return resultImage;
}
//对image进行平滑处理
void example2_4( IplImage* image )
{
    IplImage* out = cvCreateImage(
                                  cvGetSize(image),   //获得输入图片的大小，并进行创建，也可以使用cvSize（）
                                  IPL_DEPTH_8U,
                                  3
                                  );
    //可以在此选择一种，作为自己的滤波方法
    cvSmooth( image, out, CV_GAUSSIAN, 5,5 );  //高斯平滑  调节参数平滑程度不同
    //  cvSmooth( image, out, CV_BLUR  );  //对每个象素param1×param2邻域 求和并做尺度变换
    //  cvSmooth( image, out, CV_BLUR_NO_SCALE ,3,3,3,3 );  //简单不带尺度变换的模糊
    //  cvSmooth( image, out, CV_MEDIAN,5,5  );  //中值滤波
    //  cvSmooth( image, out, CV_BILATERAL ,10,10);  //双向滤波
    
    cvNamedWindow( "Example2_4-in", CV_WINDOW_AUTOSIZE );  //显示输入图片
    cvNamedWindow( "Example2_4-out", CV_WINDOW_AUTOSIZE ); //显示输出图片
    cvShowImage( "Example2_4-in", image );
    cvShowImage( "Example2_4-out", out );
    cvReleaseImage( &out );
    cvWaitKey( 0 );   
    cvDestroyWindow("Example2_4-in" );  
    cvDestroyWindow("Example2_4-out" );  
}
//1. cv::Mat -> IplImage
//cv::Mat matimg = cv::imread ("heels.jpg");
//IplImage* iplimg;
//*iplimg = IplImage(matimg);
//2. IplImage -> cv::Mat
//IplImage* iplimg = cvLoadImage("heels.jpg");
//cv::Mat matimg;
//matimg = cv::Mat(iplimg);
+ (IplImage*)IplImageFromUIImage:(UIImage*)image
{
    CGImageRef imageRef = image.CGImage;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    IplImage *iplimage = cvCreateImage(cvSize(image.size.width,image.size.height), IPL_DEPTH_8U, 4 );
    
    CGContextRef contextRef = CGBitmapContextCreate(
                                                    iplimage->imageData,
                                                    iplimage->width,
                                                    iplimage->height,
                                                    iplimage->depth,
                                                    iplimage->widthStep,
                                                    colorSpace,
                                                    kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef,
                       CGRectMake(0, 0, image.size.width, image.size.height),
                       imageRef);
    
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplimage, ret, CV_RGBA2BGR);
    cvReleaseImage(&iplimage);
    
    return ret;
}
+ (UIImage*)UIImageFromIplImage:(IplImage*)image
{
    CGColorSpaceRef colorSpace;
    if (image->nChannels == 1)
    {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        //BGRになっているのでRGBに変換
        cvCvtColor(image, image, CV_BGR2RGB);
    }
    NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(image->width,
                                        image->height,
                                        image->depth,
                                        image->depth * image->nChannels,
                                        image->widthStep,
                                        colorSpace,
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault
                                        );
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return ret;
}
@end
