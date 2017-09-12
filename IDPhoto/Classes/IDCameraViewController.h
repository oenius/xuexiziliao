//
//  IDCameraViewController.h
//  IDPhoto
//
//  Created by 何少博 on 17/4/24.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IDCameraViewControllerDelegate;

@interface IDCameraViewController : UIViewController


@property(nonatomic,weak) id<IDCameraViewControllerDelegate>delegate;

@end



@protocol IDCameraViewControllerDelegate <NSObject>

-(void)cameraTakePhoto:(IDCameraViewController *) cameraController didFinish:(UIImage *)image;

-(void)cameraDidCancel:(IDCameraViewController *) cameraController;

@end
