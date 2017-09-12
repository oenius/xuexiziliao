//
//  SNAssetViewModel.m
//  MindMap
//
//  Created by 何少博 on 2017/8/29.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNAssetViewModel.h"
#import <Photos/Photos.h>
#import "SNAssetModel.h"
#import "UIImage+SN.h"
@interface SNAssetViewModel ()


@property (strong ,nonatomic) NSArray * dataSource;

@end




@implementation SNAssetViewModel

-(NSArray *)dataSource{
    if (_dataSource == nil) {
        _dataSource = [self getAssetModels];
    }
    return _dataSource;
}


-(NSInteger)assetCount{
    return self.dataSource.count;
}

-(NSInteger)numberOfSectionsInCollectionView{
    return 1;
}

-(NSInteger)numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(SNAssetModel *)modelAtIndexPath:(NSIndexPath *)indexPath{
    return self.dataSource[indexPath.row];
}

-(NSArray *)getAssetModels{
    NSMutableArray * dataSourceArray = [NSMutableArray array];
    SNAssetModel * fisrtModel = [[SNAssetModel alloc]init];
    fisrtModel.isNone = YES;
    [dataSourceArray addObject:fisrtModel];
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult * result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PHAsset class]]) {
            PHAsset * asset = (PHAsset *)obj;
            SNAssetModel * model = [[SNAssetModel alloc]init];
            model.asset = asset;
            model.assetID = asset.localIdentifier;
            [dataSourceArray addObject:model];
        }
    }];
    return dataSourceArray;
}


+(void)requestThumbImageWithAsset:(SNAssetModel *)model thumb:(BOOL)thumb completed:(void(^)(UIImage *thumbImage))completed{
    if (model.isNone) {
        if (completed) {
            completed(nil);
        }
        return;
    }
    CGSize targetSize = CGSizeMake(200, 200);
    if (!thumb) {
        targetSize = CGSizeMake(300, 300);
    }
    PHImageRequestOptions * op = [[PHImageRequestOptions alloc]init];
    op.synchronous = YES;
    [[PHImageManager defaultManager] requestImageForAsset:model.asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:op resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        if (result) {
            UIImage * image = result;
            if (thumb) {
                image = [image getProperResized:200];
            }
            if (completed) {
                completed(image);
            }
            NSData * data = UIImageJPEGRepresentation(image, 1);
            BOOL success = [data writeToFile:model.thumPath atomically:NO];
            NSLog(@"path:%@",model.thumPath);
            if (success) {
                NSLog(@"保存成功");
            }else{
                NSLog(@"保存失败");
            }
        }
        
        
        
    }];
}

@end
