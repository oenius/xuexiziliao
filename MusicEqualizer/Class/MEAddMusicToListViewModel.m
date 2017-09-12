//
//  MEAddMusicToListViewModel.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/6.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "MEAddMusicToListViewModel.h"
#import "MECoreDataManager.h"
#import "MEList.h"
@interface MEAddMusicToListViewModel ()

@property (strong,nonatomic)NSMutableArray * listModelArray;

@end

@implementation MEAddMusicToListViewModel


-(NSMutableArray *)listModelArray{
    if (nil == _listModelArray || _listModelArray.count == 0) {
        NSArray * listarray = [[MECoreDataManager defaultManager]getAllMusicList];
        _listModelArray = [NSMutableArray arrayWithArray:listarray];
        
    }
    return _listModelArray;
}

-(MEList *)getMusicListModelAtIndexPath:(NSIndexPath *)indexPath{
    return [self.listModelArray objectAtIndex:indexPath.row];
}

-(NSInteger)numberOfRowsInSection:(NSInteger)sectoin{
    return self.listModelArray.count;
}

-(NSInteger)numberOfSectionsInTableView{
    return 1;
}

@end
