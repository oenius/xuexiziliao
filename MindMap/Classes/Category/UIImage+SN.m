//
//  UIImage+SN.m
//  MindMap
//
//  Created by 何少博 on 2017/8/9.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "UIImage+SN.h"

static inline double radians (double degrees) {return degrees * M_PI/180;}

@implementation UIImage (SN)

+(UIImage *)coreBlurImage:(UIImage *)image withBlurNumber:(CGFloat)blur
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage= [CIImage imageWithCGImage:image.CGImage];
    //设置filter
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey]; [filter setValue:@(blur) forKey: @"inputRadius"];
    //模糊图片
    CIImage *result=[filter valueForKey:kCIOutputImageKey];
    CGImageRef outImage=[context createCGImage:result fromRect:[result extent]];
    UIImage *blurImage=[UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return blurImage;
}

-(UIImage *)fit{
    NSData * data = UIImageJPEGRepresentation(self, [self preQuality]);
    if (data) {
        return [UIImage imageWithData:data];
    }
    return nil;
}
-(CGFloat)preQuality{
    CGFloat size = self.size.width * self.size.height;
    CGFloat x = MAX(0, size - 40000)/10000;
    CGFloat high = 0.5;
    CGFloat low = 0.1;
    return (high - low) * exp(-x) + low;
}
- (UIImage *)imageWithCornerRadius:(CGFloat)radius
{
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //clip image
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0.0f, radius);
    CGContextAddLineToPoint(context, 0.0f, self.size.height - radius);
    CGContextAddArc(context, radius, self.size.height - radius, radius, M_PI, M_PI / 2.0f, 1);
    CGContextAddLineToPoint(context, self.size.width - radius, self.size.height);
    CGContextAddArc(context, self.size.width - radius, self.size.height - radius, radius, M_PI / 2.0f, 0.0f, 1);
    CGContextAddLineToPoint(context, self.size.width, radius);
    CGContextAddArc(context, self.size.width - radius, radius, radius, 0.0f, -M_PI / 2.0f, 1);
    CGContextAddLineToPoint(context, radius, 0.0f);
    CGContextAddArc(context, radius, radius, radius, -M_PI / 2.0f, M_PI, 1);
    CGContextClip(context);
    
    //draw image
    [self drawAtPoint:CGPointZero];
    
    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return image
    return image;
}

+ (UIImage *)jk_imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


+(UIImage *)groupIcon:(NSArray *)images{
    NSInteger count = images.count;
    switch (count) {
        case 0:
            return nil;
            break;
        case 1:
            return [self groupIcon1:images];
            break;
        case 2:
            return [self groupIcon2:images];
            break;
        case 3:
            return [self groupIcon3:images];
            break;
        case 4:
            return [self groupIcon4:images];
            break;
        case 5:
            return [self groupIcon5:images];
            break;
        case 6:
            return [self groupIcon6:images];
            break;
        case 7:
            return [self groupIcon7:images];
            break;
        case 8:
            return [self groupIcon8:images];
            break;
        case 9:
            return [self groupIcon9:images];
            break;
            
        default:
            break;
    }
    return nil;
}

+(UIImage *)groupIcon1:(NSArray *)images{
    CGFloat marign = 8;
    CGSize size = CGSizeMake( 200, 200);
    UIGraphicsBeginImageContext(size);
    
    UIImage * image = images.firstObject;
    CGRect rect = CGRectMake(marign,
                             marign,
                             size.width - marign * 2,
                             size.width - marign * 2);
    [image drawInRect:rect];
    image = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
    return image;
}
+(UIImage *)groupIcon2:(NSArray *)images{
    CGFloat marign = 8;
    CGSize size = CGSizeMake( 200, 200);
    UIGraphicsBeginImageContext(size);
    
    CGFloat width = (size.width - 3 * marign) / 2;
    CGFloat Y = (size.height - width)/2;
    for (int i = 0; i < images.count; i ++) {
        CGFloat X = marign + (width + marign) * i;
        CGRect rect = CGRectMake(X, Y, width, width);
        UIImage * image = images[i];
        [image drawInRect:rect];
    }
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
    return image;
}
+(UIImage *)groupIcon3:(NSArray *)images{
    CGFloat marign = 8;
    CGSize size = CGSizeMake( 200, 200);
    UIGraphicsBeginImageContext(size);
    
    CGFloat width = (size.width - 3 * marign) / 2;
    for (int i = 0; i < images.count; i ++) {
        CGFloat X = 0;
        CGFloat Y = 0;
        if (i == 0) {
            X = (size.height - width)/2;
            Y = marign ;
        }else{
            X = marign + (width + marign) * (i-1);
            Y = marign + width + marign;
        }
        CGRect rect = CGRectMake(X, Y, width, width);
        UIImage * image = images[i];
        [image drawInRect:rect];
    }
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
    return image;
}
+(UIImage *)groupIcon4:(NSArray *)images{
    CGFloat marign = 8;
    CGSize size = CGSizeMake( 200, 200);
    UIGraphicsBeginImageContext(size);
    
    CGFloat width = (size.width - 3 * marign) / 2;
    for (int i = 0; i < 2; i ++) {
        for (int j = 0; j < 2; j ++) {
            CGFloat X = marign + (width + marign) * j;
            CGFloat Y = marign + (width + marign) * i;
            CGRect rect = CGRectMake(X, Y, width, width);
            UIImage * image = images[i*2 + j];
            [image drawInRect:rect];
        }
    }
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
+(UIImage *)groupIcon5:(NSArray *)images{
    CGFloat marign = 8;
    CGSize size = CGSizeMake( 200, 200);
    UIGraphicsBeginImageContext(size);
    
    CGFloat width = (size.width - 4 * marign) / 3;
    CGFloat topM = (size.height - (width * 2 + marign)) / 2;
    for (int i = 0; i < 5; i ++) {
        CGFloat X,Y;
        if (i < 2) {
            X = topM + (marign + width) * i;
            Y = topM;
        }else{
            X = marign + (marign + width) * (i - 2);
            Y = topM + marign + width;
        }
        CGRect rect = CGRectMake(X, Y, width, width);
        UIImage * image = images[i];
        [image drawInRect:rect];
    }
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
    return image;
}
+(UIImage *)groupIcon6:(NSArray *)images{
    CGFloat marign = 8;
    CGSize size = CGSizeMake( 200, 200);
    UIGraphicsBeginImageContext(size);
    
    CGFloat width = (size.width - 4 * marign) / 3;
    CGFloat topM = (size.height - (width * 2 + marign)) / 2;
    for (int i = 0; i < 6; i ++) {
        CGFloat X,Y;
        X = marign + (marign + width) * (i%3);
        Y = topM + (i < 3 ? 0 : (marign + width));
        CGRect rect = CGRectMake(X, Y, width, width);
        UIImage * image = images[i];
        [image drawInRect:rect];
    }
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
    return image;
}
+(UIImage *)groupIcon7:(NSArray *)images{
    CGFloat marign = 8;
    CGSize size = CGSizeMake( 200, 200);
    UIGraphicsBeginImageContext(size);
    
    CGFloat width = (size.width - 4 * marign) / 3;
    for (int i = 0; i < 7; i ++) {
        CGFloat X,Y;
        if (i < 1) {
            CGFloat left = (size.width - width  - marign) / 2;
            X = left + marign/2;
            Y = marign;
        }else{
            int index = i - 1;
            if (index >= 3) {
                index = index - 3;
            }
            X = marign + (marign + width) * (index%3);
            Y = marign + (i >= 4 ? (marign + width) * 2 : (marign + width));
        }
        CGRect rect = CGRectMake(X, Y, width, width);
        UIImage * image = images[i];
        [image drawInRect:rect];
    }
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
    return image;
}
+(UIImage *)groupIcon8:(NSArray *)images{
    CGFloat marign = 8;
    CGSize size = CGSizeMake( 200, 200);
    UIGraphicsBeginImageContext(size);
    
    
    CGFloat width = (size.width - 4 * marign) / 3;
    for (int i = 0; i < 8; i ++) {
        CGFloat X,Y;
        if (i < 2) {
            CGFloat left = (size.width - width * 2 - marign) / 2;
            X = left + (marign + width) * i;
            Y = marign;
        }else{
            int index = i - 2;
            if (index >= 3) {
                index = index - 3;
            }
            X = marign + (marign + width) * (index%3);
            Y = marign + (i >= 5 ? (marign + width) * 2 : (marign + width));
        }
        CGRect rect = CGRectMake(X, Y, width, width);
        UIImage * image = images[i];
        [image drawInRect:rect];
    }
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
    return image;
}
+(UIImage *)groupIcon9:(NSArray *)images{
    CGFloat marign = 8;
    CGSize size = CGSizeMake( 200, 200);
    UIGraphicsBeginImageContext(size);
    
    CGFloat width = (size.width - 4 * marign) / 3;
    for (int i = 0; i < 3; i ++) {
        for (int j = 0; j < 3; j ++) {
            CGFloat X = marign + (width + marign) * j;
            CGFloat Y = marign + (width + marign) * i;
            CGRect rect = CGRectMake(X, Y, width, width);
            UIImage * image = images[i*3 + j];
            [image drawInRect:rect];
        }
    }
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIImage *)imageToSquare:(CGFloat)square bgColor:(UIColor *)bgColor{
    CGSize size = CGSizeMake(square, square);
    UIGraphicsBeginImageContext(size);
    CGFloat x = 0,y = 0,w,h;
    CGFloat marign = 10;
    CGFloat scale = self.size.width / self.size.height;
    if (self.size.height > self.size.width) {
        h = square - marign * 2;
        w = h * scale;
        x = (square - w) / 2 + marign;
    }else{
        w = square - marign * 2;
        h = w / scale;
        y = (square - h) / 2 + marign;
    }
    CGRect rect = CGRectMake(0, 0, square, square);
    UIBezierPath * rectPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:0];
    [bgColor setFill];
    [rectPath fill];
    
//    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:marign];
//    [bgColor setFill];
//    [path fill];
    CGRect imageRect = CGRectMake(x, y, w, h);
    [self drawInRect:imageRect];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (image) {
        return image;
    }
    return [self getProperResized:square];
}

-(UIImage *)getProperResized:(CGFloat) resize{
    float ratio = self.size.width/self.size.height;
    
    if(self.size.width > self.size.height){
        if(self.size.width > resize){
            return [self resizeWithRotationSize:CGSizeMake(resize, resize/ratio)];
        }
    }else{
        if(self.size.height > resize){
            return [self resizeWithRotationSize:CGSizeMake(resize*ratio, resize)];
        }
    }
    return self;
}


-(UIImage*)resizeWithRotationSize:(CGSize)targetSize
{
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGImageRef imageRef = [self CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (self.imageOrientation == UIImageOrientationUp || self.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }
    
    if (self.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (self.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (self.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (self.imageOrientation == UIImageOrientationDown) {
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


+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    if (image.size.width > size.width) {
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    } else {
        return image;
    }
}

+ (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}




















@end
