//
//  HSScanStr.m
//  GetImageDataTest
//
//  Created by Mac_H on 16/6/18.
//  Copyright © 2016年 何少博. All rights reserved.
//

#import "HSScanStr.h"
//#import "GetPointRGB.h"
//#import "ColorModel.h"
//#import "UIColor+ext.h"
typedef struct {
    Byte A;
    Byte R;
    Byte G;
    Byte B;
}Color;

@interface HSScanStr ()

//@property (nonatomic,strong) GetPointRGB * RGB;
@property (nonatomic,strong) NSMutableString * shortLengtStringTemp;
@end

@implementation HSScanStr

//-(GetPointRGB *)RGB{
//    if (!_RGB) {
//        _RGB = [[GetPointRGB alloc]init];
//    }
//    return _RGB;
//}

//-(NSArray *)getStingDotMatrix:(NSString *)showString{
//    NSInteger lengh = showString.length;
//    if (lengh) {
//        //点阵数组的结构：里面存放了H个子数组每个子数组里存放了W个colorModel
//        NSMutableArray * DotMatrix = [NSMutableArray array];
//        
//        for (int strLen = 0; strLen < lengh ; strLen ++) {
//            @autoreleasepool {
//                NSRange range;
//                //根据语言滚动方式进字符串截取
//                if (self.ledDirection) {
//                    NSInteger loction = lengh - strLen -1;
//                    range = NSMakeRange(loction, 1);
//                }else{
//                   range = NSMakeRange(strLen, 1);
//                }
//                NSString * showChar = [showString substringWithRange:range];
//                
//                UILabel * textLabel = [[UILabel alloc]initWithFrame:CGRectZero];
//                textLabel.backgroundColor = [UIColor blackColor];//self.offColor;
//                textLabel.text =showChar;
//                textLabel.textColor = [UIColor whiteColor];//self.fontColor;
//                textLabel.numberOfLines =1;
//                UIFont * tfont;
//                if (self.font==nil) {
//                    tfont = [UIFont systemFontOfSize:FONTTEXTLABELHIGHT-10];
//                }else{
//                    tfont = [self.font fontWithSize:FONTTEXTLABELHIGHT-10];
//                }
//                //[UIFont systemFontOfSize:FONTSIZE];//[UIFont fontWithName:@"MarkerFelt-Thin" size:_showModel];
//                textLabel.font = tfont;
////                textLabel.lineBreakMode =NSLineBreakByTruncatingTail ;
//                textLabel.textAlignment = NSTextAlignmentCenter;
//                //高度估计文本大概要显示几行，宽度根据需求自己定义。 MAXFLOAT 可以算出具体要多高
//                CGSize size =CGSizeMake(MAXFLOAT,FONTTEXTLABELHIGHT);
//                //获取当前文本的属性
//                NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
//                //获取文本需要的size，限制宽度
//                CGSize  actualsize =[showChar boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
//                textLabel.frame =CGRectMake(0,0, actualsize.width, actualsize.height);
//                textLabel.adjustsFontSizeToFitWidth = YES;
//                [textLabel layoutIfNeeded];
////                [textLabel sizeToFit];
//                UIImage * imageLabel = [self imageWithUIView:textLabel];
//                UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,imageLabel.size.width,FONTTEXTLABELHIGHT)];
//                imageView.backgroundColor = [UIColor blackColor];//self.offColor;
//                imageView.image =imageLabel;
//                imageView.contentMode = UIViewContentModeScaleAspectFit;
//                UIImage* image = [self imageWithUIView:imageView];
//                int W = image.size.width;
//                int H = image.size.height;
//                
//                int dX = (H)/_showModel;
//                if (DotMatrix.count==0) {
//                    for (int i = 0; i<H; i+=dX) {
//                        NSMutableArray * horizontalDot = [NSMutableArray array];
//                        [DotMatrix addObject:horizontalDot];
//                    }
//                }
//                int dotMatrixCount = (int)DotMatrix.count;
//                NSArray * dotRGBArray = [self getDianZhenForm_RGB_Image:image];
//                int index = 0;
//                //判断语言滚动方式进项相应的调整
//                if (self.ledDirection) {
//                    for (int i = H-1; i>=0; i-=dX) {
//                        NSMutableArray * horizontalDot = [DotMatrix objectAtIndex:dotMatrixCount - index-1];
//                        for (int j =W-1; j>=0; j-=dX) {
//                            NSNumber * model = [dotRGBArray objectAtIndex:(i*W +j)];
//                            [horizontalDot addObject:model];
//                        }
//                        index ++;
//                    }
//                }else{
//                    for (int i = 0; i<H; i+=dX) {
//                        NSMutableArray * horizontalDot = [DotMatrix objectAtIndex:index];
//                        for (int j =0; j<W; j+=dX) {
//                            NSNumber * model = [dotRGBArray objectAtIndex:(i*W +j)];
//                            [horizontalDot addObject:model];
//                        }
//                        index ++;
//                    }
//
//                }
//                
//            };
//        }
//        return DotMatrix;
//    }else{
//        return nil;
//    }
//}
-(NSArray *)getStingDotMatrix:(NSString *)showString{
    NSInteger lengh = showString.length;
    if (lengh) {
        //点阵数组的结构：里面存放了H个子数组每个子数组里存放了W个colorModel
        NSMutableArray * DotMatrix = [NSMutableArray array];
        
        for (int strLen = 0; strLen < lengh ; strLen ++) {
            @autoreleasepool {
                //根据语言滚动方式进字符串截取
                NSRange range;
                //根据语言滚动方式进字符串截取
                if (self.ledDirection) {
                    NSInteger loction = lengh - strLen -1;
                    range = NSMakeRange(loction, 1);
                }else{
                    range = NSMakeRange(strLen, 1);
                }

                NSString * showChar = [showString substringWithRange:range];
                
                UILabel * textLabel = [[UILabel alloc]initWithFrame:CGRectZero];
                textLabel.backgroundColor = [UIColor blackColor];//self.offColor;
                textLabel.text =showChar;
                textLabel.textColor = [UIColor whiteColor];//self.fontColor;
                textLabel.numberOfLines =1;
                UIFont * tfont;
                if (self.font==nil) {
                    tfont = [UIFont systemFontOfSize:FONTTEXTLABELHIGHT-10];
                }else{
                    tfont = [self.font fontWithSize:FONTTEXTLABELHIGHT-10];
                }
                //[UIFont systemFontOfSize:FONTSIZE];//[UIFont fontWithName:@"MarkerFelt-Thin" size:_showModel];
                textLabel.font = tfont;
                //                textLabel.lineBreakMode =NSLineBreakByTruncatingTail ;
                textLabel.textAlignment = NSTextAlignmentCenter;
                //高度估计文本大概要显示几行，宽度根据需求自己定义。 MAXFLOAT 可以算出具体要多高
                CGSize size =CGSizeMake(MAXFLOAT,FONTTEXTLABELHIGHT);
                //获取当前文本的属性
                NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
                //获取文本需要的size，限制宽度
                CGSize  actualsize =[showChar boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
                textLabel.frame =CGRectMake(0,0, actualsize.width, actualsize.height);
                textLabel.adjustsFontSizeToFitWidth = YES;
                [textLabel layoutIfNeeded];
                //                [textLabel sizeToFit];
                UIImage * imageLabel = [self imageWithUIView:textLabel];
                UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,imageLabel.size.width,FONTTEXTLABELHIGHT)];
                imageView.backgroundColor = [UIColor blackColor];//self.offColor;
                imageView.image =imageLabel;
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                UIImage* image = [self imageWithUIView:imageView];
                if (DotMatrix.count==0) {
                    for (int i = 0; i<_showModel; i++) {
                        NSMutableArray * horizontalDot = [NSMutableArray array];
                        [DotMatrix addObject:horizontalDot];
                    }
                }
                NSArray * dotRGBArray = [self getDianZhenForm_RGB_Image:image withModel:_showModel];
                int rrows = dotRGBArray.count;
                int drows = DotMatrix.count;
                int rows = rrows <= drows ? rrows : drows;
                //判断语言滚动方式进项相应的调整
                if (self.ledDirection) {
                    int index = 0;
                    for (int i = rows-1; i>=0; i--) {
                        NSMutableArray * horizontalDot = [DotMatrix objectAtIndex:rows-index-1];
                        NSArray * rowDotArray = [dotRGBArray objectAtIndex:rows-index-1];
                        rowDotArray = [[rowDotArray reverseObjectEnumerator] allObjects];
                        NSIndexSet * indexs = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, rowDotArray.count)];
                        [horizontalDot insertObjects:rowDotArray atIndexes:indexs];

                        index ++;
                    }

                }else{
                    for (int i = 0; i<rows; i++) {
                        NSMutableArray * horizontalDot = [DotMatrix objectAtIndex:i];
                        NSArray * dots = [dotRGBArray objectAtIndex:i];
                        [horizontalDot addObjectsFromArray:dots];
                    }
                }
                
            };
        }
        if (DotMatrix.count != _showModel) {
            return nil;
        }
        return DotMatrix;
    }else{
        return nil;
    }
}
//获取image每个像素点的RGB根据RGB判断是否显示字体颜色即前景色并将信息保存在数组里面
-(NSArray <NSArray*>*)getDianZhenForm_RGB_Image:(UIImage*)image withModel:(NSShowModel) showModel{
    NSMutableArray * dotRGBArray = [NSMutableArray array];
    CGImageRef imageRef= [image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    int width =  (int)CGImageGetWidth(imageRef);
    int height = (int)CGImageGetHeight(imageRef);
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel*width;
    int bitsPerComponent = 8;
    //准备用来存储数据的数组
    unsigned char *data = (unsigned char*) calloc(height * width * bitsPerComponent, sizeof(unsigned char));
    CGContextRef cgContexRef = CGBitmapContextCreate(data,
                                                     width,
                                                     height,
                                                     bitsPerComponent,
                                                     bytesPerRow,
                                                     colorSpace,
                                                     kCGImageAlphaPremultipliedFirst);
    CGRect theRect = CGRectMake(0,0, width, height);
    CGContextDrawImage(cgContexRef, theRect, imageRef);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(cgContexRef);
    
    
    CGFloat A;
    CGFloat R;
    CGFloat G;
    CGFloat B;
    int delatX = height/showModel;
    int index = 0;
    for (int i = 0; i < height; i += delatX) {
        NSMutableArray * rowsDotArray = [NSMutableArray array];
        for (int j = 0; j < width; j +=delatX) {
            index =bytesPerPixel*j+bytesPerPixel*i*width;
            A=data[index]/255.0 ;
            R=data[index+1]/255.0 ;
            G=data[index+2]/255.0 ;
            B=data[index+3]/255.0 ;
            BOOL showColor = [self isEqualToWhiteColorWithRed:R Green:G  Blue:B alpha:A];
            [rowsDotArray addObject:[NSNumber numberWithBool:showColor]];
        }
        [dotRGBArray addObject:rowsDotArray];
    }
    free(data);
    return dotRGBArray;
}

-(NSArray *)getDianZhenForm_RGB_Image:(UIImage*)image{
    NSMutableArray * dotRGBArray = [NSMutableArray array];
    Byte * data = [self getImageRGBDataFormImage:image];
    int W = image.size.width;
    int H = image.size.height;
    
    CGFloat A;
    CGFloat R;
    CGFloat G;
    CGFloat B;
    
    int index = 0;
    for (int i = 0; i < H; i ++) {
        for (int j = 0; j < W; j ++) {
            @autoreleasepool {
                index =4*j+4*i*W;
                A=data[index]/255.0 ;
                R=data[index+1]/255.0 ;
                G=data[index+2]/255.0 ;
                B=data[index+3]/255.0 ;
                BOOL showColor = [self isEqualToWhiteColorWithRed:R Green:G  Blue:B alpha:A];
                [dotRGBArray addObject:[NSNumber numberWithBool:showColor]];
            }
        }
    }
    free(data);
    return dotRGBArray;
}
/**
 *  将view转化为UIImage对象
 */
- (UIImage*) imageWithUIView:(UIView*) view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ctx];
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tImage;
}
//根据RGB判断是否显示前景色（字体颜色）默认是白色的
-(BOOL)isEqualToWhiteColorWithRed:(CGFloat)colorR  Green:(CGFloat)colorG Blue:(CGFloat)colorB alpha:(CGFloat)colorA{
    CGFloat R_ChaZhi = fabs(colorR - 1);
    CGFloat G_ChaZhi = fabs(colorG - 1);
    CGFloat B_ChaZhi = fabs(colorB - 1);
    CGFloat A_ChaZhi = fabs(colorA - 1);
    if ((A_ChaZhi<=0.32)&&(B_ChaZhi<=0.32)&&(G_ChaZhi<=0.32)&&(R_ChaZhi<=0.32)) {
        return YES;
    }else{
        return NO;
    }
}

//将UIimage中的数据放入Byte数组中，顺序为ARGB.
-(Byte*)getImageRGBDataFormImage:(UIImage*)Image{
    CGImageRef imageRef= [Image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    int width =  (int)CGImageGetWidth(imageRef);
    int height = (int)CGImageGetHeight(imageRef);
    int bytesPerPixel = 4;
    int bytesPerRow=bytesPerPixel*width;
    int bitsPerComponent = 8;
    //准备用来存储数据的数组
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
-(NSArray*)getDianZhenForm_Gray_Image:(UIImage*)image{
    NSMutableArray * dotRGBArray = [NSMutableArray array];
    CGImageRef imageRef = [image CGImage];
    CGFloat width = CGImageGetWidth(imageRef);
    CGFloat height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    unsigned char * heightData = (unsigned char*)calloc(width * height, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 1;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(heightData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaNone);
    CGRect theRect = CGRectMake(0,0, width, height);
    CGContextDrawImage(context, theRect, imageRef);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);

    int index;
    for (int i = 0; i < height; i ++) {
        for (int j = 0; j < width; j ++) {
            @autoreleasepool {
                index =j+i*width;
                uint8_t grayValue = heightData[index] ;
//                NSLog(@"%d",grayValue);
                BOOL showColor;
                if (grayValue>=180) {
                    showColor = YES;
                }else{
                    showColor = NO;
                }
                [dotRGBArray addObject:[NSNumber numberWithBool:showColor]];
            }
        }
    }
//    free(heightData);
    heightData = nil;
    return dotRGBArray;
}
-(void)dealloc{
    LOG(@"%s", __func__);
//    LOG(@"%@%@",[self class],@"被释放");
    
}
@end
