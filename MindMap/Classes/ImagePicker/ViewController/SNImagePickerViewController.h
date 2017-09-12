//
//  SNImagePickerViewController.h
//  MindMap
//
//  Created by 何少博 on 2017/8/29.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNBaseViewController.h"

@protocol SNImagePickerDelegate ;


@interface SNImagePickerViewController : SNBaseViewController


@property (nonatomic,weak) id<SNImagePickerDelegate> delegate;

@end


@protocol SNImagePickerDelegate <NSObject>

-(void)imagePickerCancel:(SNImagePickerViewController *)imagePicker;
-(void)imagePicker:(SNImagePickerViewController *)imagePicker didSeleceted:(UIImage *)image;

@end
