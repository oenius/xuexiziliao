//
//  DTPhotoViewModel.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/18.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTPhotoViewModel.h"


@interface DTPhotoViewModel ()


@end

@implementation DTPhotoViewModel

+(void)archivedModel:(DTAssetModel *)model completed:(void (^)(NSData *))completed{
    [[PHImageManager defaultManager] requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        model.assetData = imageData;
        NSData * modelData = [NSData archivedData:model];
        completed(modelData);
        model.assetData = nil;
    }];
}

@end


