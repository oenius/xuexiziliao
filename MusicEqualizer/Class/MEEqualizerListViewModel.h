//
//  MEEqualizerListViewModel.h
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/5.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MEEqualizer;

@interface MEEqualizerListViewModel : NSObject

-(NSInteger)numberOfSectionsInCollectionView;

-(NSInteger)numberOfItemsInSection:(NSInteger)section;

-(MEEqualizer *)getEQModelAtIndexPath:(NSIndexPath *)indxpath;

-(NSInteger)getDefaultEQCount;

-(void)deleteEqualizerAtIndexPath:(NSIndexPath *)indexpath;

@end
