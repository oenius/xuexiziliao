//
//  SNAssetViewModel.h
//  MindMap
//
//  Created by 何少博 on 2017/8/29.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SNAssetModel;
@interface SNAssetViewModel : NSObject

@property (assign, nonatomic) NSInteger assetCount;
+(void)requestThumbImageWithAsset:(SNAssetModel *)model thumb:(BOOL)thumb completed:(void(^)(UIImage *thumbImage))completed;
-(NSInteger)numberOfSectionsInCollectionView;
-(NSInteger)numberOfItemsInSection:(NSInteger)section;
-(SNAssetModel *)modelAtIndexPath:(NSIndexPath *)indexPath;
+ (void)getPhotoWithAsset:(id)asset photoWidth:(CGFloat)photoWidth completion:(void (^)(UIImage *photo,NSDictionary *info,BOOL isDegraded))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler networkAccessAllowed:(BOOL)networkAccessAllowed;
@end
