//
//  SNImagePickerCollectionViewCell.h
//  MindMap
//
//  Created by 何少博 on 2017/8/29.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNAssetModel;

@interface SNImagePickerCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) SNAssetModel *model;
@property (strong, nonatomic) UIImageView *imageView;

@end
