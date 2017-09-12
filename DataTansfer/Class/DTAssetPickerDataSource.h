//
//  DTAssetPickerDataSource.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/22.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MWPhotoBrowser.h>

@interface DTAssetPickerDataSource : NSObject<MWPhotoBrowserDelegate>

@property (nonatomic, strong) NSMutableArray<NSNumber*> *selecteds;

-(void)removeSelectedAllPhotos;

-(void)selectedAllPhotos;

-(instancetype)initWithDataSource:(NSArray * )dataSource;

-(void)setMWPhotosWithDataSource:(NSArray *)dataSource;

@end
