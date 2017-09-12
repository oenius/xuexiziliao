//
//  SNAssetModel.h
//  MindMap
//
//  Created by 何少博 on 2017/8/29.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PHAsset;


@interface SNAssetModel : NSObject

@property (strong, nonatomic) PHAsset *asset;
@property (copy, nonatomic) NSString *assetID;
@property (copy, nonatomic) NSString *thumPath;
@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) BOOL isNone;

@end
