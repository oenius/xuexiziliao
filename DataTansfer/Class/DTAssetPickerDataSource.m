//
//  DTAssetPickerDataSource.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/22.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTAssetPickerDataSource.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+x.h"
#import "DTPhotoViewModel.h"
#import "DTVideoViewModel.h"
@interface DTAssetPickerDataSource ()

@property (nonatomic,strong) NSMutableArray<MWPhoto *> * photos;

@property (nonatomic,strong) NSMutableArray<MWPhoto *> * thumbs;

@end


@implementation DTAssetPickerDataSource
-(NSMutableArray<MWPhoto *> *)photos{
    if (nil == _photos) {
        _photos = [NSMutableArray array];
    }
    return _photos;
}

-(NSMutableArray<MWPhoto *> *)thumbs{
    if (nil == _thumbs) {
        _thumbs = [NSMutableArray array];
    }
    return _thumbs;
}

-(NSMutableArray<NSNumber *> *)selecteds{
    if (nil == _selecteds) {
        _selecteds = [NSMutableArray array];
        
    }
    return _selecteds;
}



-(instancetype)initWithDataSource:(NSArray * )dataSource{
    self = [super init];
    if (self) {
        [self enumDatgaSources:dataSource];
    }
    return self;
}

-(void)setMWPhotosWithDataSource:(NSArray *)dataSource{
    [self enumDatgaSources:dataSource];
}

-(void)enumDatgaSources:(NSArray *)dataSource{
    [self.photos removeAllObjects];
    [self.thumbs removeAllObjects];
    if (dataSource.count <= 0) {
        return;
    }
    for (DTAssetModel * model in dataSource) {
        MWPhoto *photo = [MWPhoto photoWithAsset:model.asset targetSize:CGSizeMake(1500, 1500)];
        [self.photos addObject:photo];
        MWPhoto *thumb = [MWPhoto photoWithAsset:model.asset targetSize:CGSizeMake(200, 200)];
        [self.thumbs addObject:thumb];
        photo.isVideo = model.mediaType == PHAssetMediaTypeVideo ? YES : NO;
        thumb.isVideo = model.mediaType == PHAssetMediaTypeVideo ? YES : NO;
    }
 
}

#pragma mark - MWPhotoBrowserDelegate

-(void)removeSelectedAllPhotos{
    [self.selecteds removeAllObjects];
}

-(void)selectedAllPhotos{
    [self.selecteds removeAllObjects];
    for (NSUInteger i = 0; i < _photos.count; i ++) {
        [self.selecteds addObject:[NSNumber numberWithUnsignedInteger:i]];
    }
    
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    
    if (self.selecteds.count == _photos.count) {
        return YES;
    }
    else if (self.selecteds.count == 0) {
        return NO;
    }
    else{
        NSNumber * indexNum = [NSNumber numberWithUnsignedInteger:index];
        if ([self.selecteds containsObject:indexNum]) {
            return YES;
        }else{
            return NO;
        }
    }
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    NSNumber * indexNum = [NSNumber numberWithUnsignedInteger:index];
    if ([self.selecteds containsObject:indexNum]) {
        [self.selecteds removeObject:indexNum];
    }else{
        [self.selecteds addObject:indexNum];
    }
}

@end
