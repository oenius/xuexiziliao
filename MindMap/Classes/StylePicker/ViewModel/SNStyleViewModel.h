//
//  SNStyleViewModel.h
//  MindMap
//
//  Created by 何少博 on 2017/8/23.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SNStyleModel;
@class SNStyleSectionModel;
@interface SNStyleViewModel : NSObject
-(NSInteger)numberOfSectionsInCollectionView;
-(NSInteger)numberOfItemsInSection:(NSInteger)section;
-(SNStyleModel *)modelAtIndexPath:(NSIndexPath *)indexPath;
-(SNStyleSectionModel *)sectionModelAtIndexPath:(NSIndexPath *)indexPath;
-(Class)getSelectedStyleClassAtIndexPath:(NSIndexPath *)indexPath;
@end
