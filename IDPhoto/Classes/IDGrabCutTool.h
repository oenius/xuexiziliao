//
//  IDGrabCutTool.h
//  IDPhoto
//
//  Created by 何少博 on 17/4/27.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>

#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/highgui/highgui_c.h>
#import <opencv2/core/core_c.h>

using namespace cv;

@interface IDGrabCutTool : NSObject
{
    cv::Mat mask; // segmentation (4 possible values)
    cv::Mat bgModel,fgModel; // the models (internally used)
}

-(cv::Mat)getMask;

-(void)setMask:(cv::Mat)newMask;

-(UIImage *)bianYuanQuJuChi:(UIImage *)maskImage;

-(UIImage*)bianYuanXuHua:(UIImage *)sourceImage;

-(void)prepareGrabCut:(UIImage*)sourceImage iterationCount:(int)iterCount;

//-(UIImage*)doGrabCut:(UIImage*)sourceImage foregroundBound:(CGRect) rect iterationCount:(int)iterCount;

-(UIImage*)doGrabCutWithMask:(UIImage*)sourceImage maskImage:(UIImage*)maskImage iterationCount:(int) iterCount;

-(void) resetManager;

@end
