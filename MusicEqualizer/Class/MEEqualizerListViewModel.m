//
//  MEEqualizerListViewModel.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/5.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "MEEqualizerListViewModel.h"
#import "MECoreDataManager.h"
#import "MEEqualizer.h"
@interface MEEqualizerListViewModel ()

@property (strong,nonatomic)NSMutableArray * eqModelArray;

@end

@implementation MEEqualizerListViewModel

-(NSMutableArray *)eqModelArray{
    if (nil == _eqModelArray) {
        NSArray * array = [[MECoreDataManager defaultManager] getAllEQArray];
        _eqModelArray = [NSMutableArray arrayWithArray:array];
    }
    return _eqModelArray;
}

-(NSInteger)numberOfSectionsInCollectionView{
    return 1;
}

-(NSInteger)numberOfItemsInSection:(NSInteger)section{
    return self.eqModelArray.count;
}


-(MEEqualizer *)getEQModelAtIndexPath:(NSIndexPath *)indxpath{
    return self.eqModelArray[indxpath.row];
}

-(NSInteger)getDefaultEQCount{
    return [[MECoreDataManager defaultManager] getDefaultEQCount];
}

-(void)deleteEqualizerAtIndexPath:(NSIndexPath *)indexpath{
    if (indexpath.row>self.eqModelArray.count-1) {
        return;
    }
    MEEqualizer * eq = [self.eqModelArray objectAtIndex:indexpath.row];
    [self.eqModelArray removeObjectAtIndex:indexpath.row];
    [[MECoreDataManager defaultManager] deleteObject:eq];
    [[MECoreDataManager defaultManager] save];
    
}






@end
