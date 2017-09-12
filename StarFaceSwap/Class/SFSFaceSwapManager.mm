//
//  SFSFaceSwapManager.m
//  StarFaceSwap
//
//  Created by 何少博 on 17/3/7.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//


#import <dlib/image_processing/frontal_face_detector.h>
#import <dlib/image_processing/render_face_detections.h>
#import <dlib/image_processing.h>
#import <dlib/gui_widgets.h>
#import <dlib/image_io.h>
#import <iostream>
#import <dlib/opencv.h>
#import <dlib/opencv/cv_image_abstract.h>
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/imgproc.hpp>
#import <opencv2/highgui/highgui.hpp>
#import <vector>
#import <opencv2/photo.hpp>
#import "SFSFaceSwapManager.h"
#ifndef ISPRO
#import "StarFaceSwap-Swift.h"
#else
#import "StarFaceSwapPro-Swift.h"
#endif
using namespace cv;
using namespace std;
using namespace dlib;



struct correspondens{
    std::vector<int> index;
};

@interface SFSFaceSwapManager ()

@property (nonatomic,assign) BOOL isPrepareOK;

@property (nonatomic,copy) faceDetectorBlock block1;
@property (nonatomic,copy) swapFaceCompleted block2;

@end

@implementation SFSFaceSwapManager
{
    shape_predictor sp;
}

Singleton_M(Manager);

-(void)prepareDetectioin{
    if (_isPrepareOK == YES) { return;}
    cout<< "准备合成" << endl;
    NSString *modelFileName = [[NSBundle mainBundle] pathForResource:@"shape_predictor_68_face_landmarks" ofType:@"dat"];
    string modelFileNameCString = [modelFileName UTF8String];
    
    dlib::deserialize(modelFileNameCString) >> sp;
    
    _isPrepareOK = YES;
}

-(void)faceDetector:(NSString *)imagePath completed:(faceDetectorBlock)block
{
    
    
    if(self.isPrepareOK == NO)
    {
        [self prepareDetectioin];
    }
    
    self.block1 = block;
    
    std::string fileName = [imagePath UTF8String];
    
    frontal_face_detector detector = get_frontal_face_detector();
    
    dlib:: array2d<dlib:: rgb_pixel> img;
    load_image(img,fileName);
    
    std::vector<dlib:: rectangle> dets = detector(img);
    int faceCount = (int)dets.size();
    NSLog(@"人脸个数 %d",faceCount);//检测到人脸的数量
    //判断检测到人脸的个数
    
    if (faceCount <= 0) {
        if (self.block1) {
            self.block1(0,nil);
        }
    }
    else if (faceCount > 1) {
        if (self.block1) {
            self.block1(faceCount,nil);
        }
    }else{
        full_object_detection shape = sp(img, dets[0]);
        
        NSMutableArray * facePoint = [NSMutableArray array];
        for (int i = 0; i < shape.num_parts(); ++i)
        {
            SFSFacePoint * point = [[SFSFacePoint alloc]init];
            point.x = shape.part(i).x();
            point.y = shape.part(i).y();
            [facePoint addObject:point];
        }
        if (self.block1) {
            self.block1(1,facePoint);
        }
    }
    
    
}

-(std::vector<Point2f>)getFaceLandmark:(NSArray *)markArray{
    
    std:: vector<Point2f> landmark;
    
    for (SFSFacePoint * facePoint in markArray) {
        cv::Point2f point(facePoint.x,facePoint.y);
        landmark.push_back(point);
    }
    
    return landmark;
}

-(void)swapFaceFirstImage:(NSString *)firstImagePath
          firstPointArray:(NSArray *)firstPointArray
              secondImage:(NSString *)secondImagePath
         secondPointArray:(NSArray *)secondPointArray
                completed:(swapFaceCompleted)block
{
    if(_isPrepareOK == NO){
        [self prepareDetectioin];
    }
    self.block2 = block;
    std:: string orimageFilePath = [firstImagePath UTF8String];
    std:: string swapImageFilePath = [secondImagePath UTF8String];
    
    cout<< "开始合成" << endl;
    
    //加载 cv 图片
    cv:: Mat orimg_cv = imread(orimageFilePath);
    cv:: Mat swapimg_cv = imread(swapImageFilePath);
    
    //加载dlib图片 获取脸部特征点
    dlib:: array2d<dlib:: rgb_pixel> orimg_dlib;
    load_image(orimg_dlib, orimageFilePath);
    std:: vector<Point2f> orimgLandmark = [self getFaceLandmark:firstPointArray];
    
    dlib:: array2d<dlib:: rgb_pixel> swapimg_dlib;
    load_image(swapimg_dlib, swapImageFilePath);
    std:: vector<Point2f> swapimgLandmark = [self getFaceLandmark:secondPointArray];
    
    //凸包
    Mat orimg_cv_Warped = swapimg_cv.clone();
    orimg_cv.convertTo(orimg_cv, CV_32F);
    orimg_cv_Warped.convertTo(orimg_cv_Warped, CV_32F);
    
    std::vector<Point2f> orimgHull;
    std::vector<Point2f> swapimgHull;
    std::vector<int> hullIndex;//保存组成凸包的关键点的下标索引。
    
    cv::convexHull(swapimgLandmark, hullIndex, false, false);//计算凸包
    
    //保存组成凸包的关键点。
    for(int i = 0; i < hullIndex.size(); i++)
    {
        orimgHull.push_back(orimgLandmark[hullIndex[i]]);
        swapimgHull.push_back(swapimgLandmark[hullIndex[i]]);
    }
    
    //Delaunay 三角剖份 和 仿射变换
    std::vector<correspondens> delaunayTri;
    //    cv:: Rect rect(0, 0, orimg_cv_Warped.cols, orimg_cv_Warped.rows);
    cv:: Rect rect(0, 0, orimg_cv_Warped.cols, orimg_cv_Warped.rows);
    cout << "rect" << rect << endl;
    int result =  delaunayTriangulation(swapimgHull,delaunayTri,rect);
    
    if (result == -1) {
        if (self.block2) {
            self.block2(nil,nil,NO);
            return;
        }
    }
    
    for(size_t i=0;i<delaunayTri.size();++i)
    {
        std::vector<Point2f> t1,t2;
        correspondens corpd=delaunayTri[i];
        for(size_t j=0;j<3;++j)
        {
            t1.push_back(orimgHull[corpd.index[j]]);
            t2.push_back(swapimgHull[corpd.index[j]]);
        }
        
        warpTriangle(orimg_cv,orimg_cv_Warped,t1,t2);
    }
    //-------------------------------------------
    //计算遮罩
    std::vector<cv::Point> hull8U;
    
    for(int i=0; i< swapimgHull.size();++i)
    {
        cv::Point pt(swapimgHull[i].x,swapimgHull[i].y);
        hull8U.push_back(pt);
    }
    
    
    Mat mask = Mat::zeros(swapimg_cv.rows,swapimg_cv.cols,swapimg_cv.depth());
    fillConvexPoly(mask, &hull8U[0], hull8U.size(), Scalar(255,255,255));
    
#pragma mark - -----待修正r
    cv::Rect r = boundingRect(swapimgHull);

    cv::Point center = (r.tl() +r.br()) / 2;
    
    Mat output;
    orimg_cv_Warped.convertTo(orimg_cv_Warped, CV_8UC3);
    //    NORMAL_CLONE = 1,
    //    MIXED_CLONE  = 2,
    //    MONOCHROME_TRANSFER = 3
    seamlessClone(orimg_cv_Warped,swapimg_cv,mask,center,output,NORMAL_CLONE);
    //-------------------------------------------
    NSString *tmpPath = NSTemporaryDirectory();
    NSString * name = [[[NSUUID UUID]UUIDString] stringByAppendingString:@".png"];
    tmpPath = [tmpPath stringByAppendingPathComponent:name];
    cv::String savePath = [tmpPath UTF8String];
    
    imwrite(savePath, output);
    //    UIImage * finalImage = creatImageFromCVMat(output);
    UIImage * finalImage = [UIImage imageWithContentsOfFile:tmpPath];
//    NSDictionary * dic = [NSDictionary dictionaryWithObject:finalImage forKey:documentsPath];
    //    UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil);
//    [[NSFileManager defaultManager] removeItemAtPath:documentsPath error:nil];
    cout<< "合成完毕" <<endl;
    if(self.block2){
        self.block2(tmpPath,finalImage,YES);
    }
}


/*
 //perform Delaunay Triangulation on the keypoints of the convex hull.
 */

int delaunayTriangulation(const std::vector<Point2f>& hull,std::vector<correspondens>& delaunayTri,cv:: Rect rect)
{
    
    cv::Subdiv2D subdiv(rect);
    for (int it = 0; it < hull.size(); it++){
        cv::Point point = hull[it];
        //超出rect 范围 暂时简单处理
        if (rect.x<point.x && point.x<rect.x+rect.width && rect.y<point.y && point.y<rect.y+rect.height) {
            //point在rect内部
            subdiv.insert(point);
        } else {
            //point在rect边上或外部
            return -1;
            
        }
#pragma mark - -----待修正rect
//        if (rect.x > point.x) {
//            point.x = rect.x;
//        }
//        if (point.x > rect.x + rect.width) {
//            point.x = rect.x + rect.width;
//        }
//        if(rect.y > point.y){
//            point.y = rect.y;
//        }
//        if (point.y > rect.y + rect.height) {
//            point.y = rect.y + rect.height;
//        }
//        subdiv.insert(point);
    }
    //cout<<"done subdiv add......"<<endl;
    std::vector<Vec6f> triangleList;
    subdiv.getTriangleList(triangleList);
    //cout<<"traingleList number is "<<triangleList.size()<<endl;
    
    
    
    //std::vector<Point2f> pt;
    //correspondens ind;
    for (size_t i = 0; i < triangleList.size(); ++i)
    {
        
        std::vector<Point2f> pt;
        correspondens ind;
        Vec6f t = triangleList[i];
        pt.push_back( Point2f(t[0], t[1]) );
        pt.push_back( Point2f(t[2], t[3]) );
        pt.push_back( Point2f(t[4], t[5]) );
        //cout<<"pt.size() is "<<pt.size()<<endl;
        
        if (rect.contains(pt[0]) && rect.contains(pt[1]) && rect.contains(pt[2]))
        {
            //cout<<t[0]<<" "<<t[1]<<" "<<t[2]<<" "<<t[3]<<" "<<t[4]<<" "<<t[5]<<endl;
            int count = 0;
            for (int j = 0; j < 3; ++j)
                for (size_t k = 0; k < hull.size(); k++)
                    if (abs(pt[j].x - hull[k].x) < 1.0   &&  abs(pt[j].y - hull[k].y) < 1.0)
                    {
                        ind.index.push_back(k);
                        count++;
                    }
            if (count == 3)
                //cout<<"index is "<<ind.index[0]<<" "<<ind.index[1]<<" "<<ind.index[2]<<endl;
                delaunayTri.push_back(ind);
        }
        //pt.resize(0);
        //cout<<"delaunayTri.size is "<<delaunayTri.size()<<endl;
    }
    
    return 1;
}




// Apply affine transform calculated using srcTri and dstTri to src
void applyAffineTransform(Mat &warpImage, Mat &src, std::vector<Point2f> &srcTri, std::vector<Point2f> &dstTri)
{
    // Given a pair of triangles, find the affine transform.
    Mat warpMat = getAffineTransform( srcTri, dstTri );
    if (src.cols<=0||src.rows<=0) {
        return;
    }
    // Apply the Affine Transform just found to the src image
    warpAffine( src, warpImage, warpMat, warpImage.size(), cv::INTER_LINEAR, BORDER_REFLECT_101);
}




/*
 //morp a triangle in the one image to another image.
 */


void warpTriangle(Mat &img1, Mat &img2, std::vector<Point2f> &t1, std::vector<Point2f> &t2)
{
    
    cv:: Rect r1 = boundingRect(t1);
    cv:: Rect r2 = boundingRect(t2);
    
    // Offset points by left top corner of the respective rectangles
    std::vector<cv:: Point2f> t1Rect, t2Rect;
    std::vector<cv:: Point> t2RectInt;
    for(int i = 0; i < 3; i++)
    {
        
        t1Rect.push_back( Point2f( t1[i].x - r1.x, t1[i].y -  r1.y) );
        t2Rect.push_back( Point2f( t2[i].x - r2.x, t2[i].y - r2.y) );
        t2RectInt.push_back(cv:: Point(t2[i].x - r2.x, t2[i].y - r2.y) ); // for fillConvexPoly
        
    }
    
    // Get mask by filling triangle
    Mat mask = Mat::zeros(r2.height, r2.width, CV_32FC3);
    fillConvexPoly(mask, t2RectInt, Scalar(1.0, 1.0, 1.0), 16, 0);
    
    // Apply warpImage to small rectangular patches
    Mat img1Rect;
    if (r1.x < 0) {
        r1.x = 0;
    }
    if (r1.x > img1.cols) {
        r1.x = img1.cols;
    }
    if (r1.y < 0){
        r1.y = 0;
    }
    if (r1.y > img1.rows) {
        r1.y = img1.rows;
    }
    if (r1.x+r1.width > img1.cols) {
        int width = img1.cols - r1.x;
        if (width < 0) { width = 0 ;}
        r1.width = width;
    }
    if (r1.y+r1.height > img1.rows) {
        int heigth = img1.rows - r1.y;
        if (heigth < 0) {  heigth = 0; }
        r1.height = heigth;
    }
    img1(r1).copyTo(img1Rect);
    
    Mat img2Rect = Mat::zeros(r2.height, r2.width, img1Rect.type());
    
    applyAffineTransform(img2Rect, img1Rect, t1Rect, t2Rect);
    
    multiply(img2Rect,mask, img2Rect);
    multiply(img2(r2), Scalar(1.0,1.0,1.0) - mask, img2(r2));
    img2(r2) = img2(r2) + img2Rect;    
    
}

@end
