//
//  SNTipViewModel.h
//  MindMap
//
//  Created by 何少博 on 2017/8/17.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SNTipModel;
@class SNTipSectionModel;
@interface SNTipViewModel : NSObject
-(NSInteger)numberOfSectionsInCollectionView;
-(NSInteger)numberOfItemsInSection:(NSInteger)section;
-(SNTipModel *)modelAtIndexPath:(NSIndexPath *)indexPath;
-(SNTipSectionModel *)sectionModelAtIndexPath:(NSIndexPath *)indexPath;
-(UIImage *)getTipImageAtIndexPath:(NSIndexPath *)indexPath;
@end
