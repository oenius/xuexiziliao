//
//  MEMusicListViewModel.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/3.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "MEMusicListViewModel.h"
#import "MECoreDataManager.h"
#import "MEList.h"

@interface MEMusicListViewModel ()

@property (strong,nonatomic)NSMutableArray * listModelArray;

@end


@implementation MEMusicListViewModel

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

-(BOOL)canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    BOOL isCanEdit = NO;
    if (indexPath.row != 0) {
        isCanEdit = YES;
    }
    return isCanEdit;
}

-(void)insertMusicListWithName:(NSString*)name{
    MEList * list = [[MECoreDataManager defaultManager]insertMusicList];
    
    NSString *newName = name;
    while (1) {
        NSArray * listArray = [[MECoreDataManager defaultManager] searchMusicListWithName:newName];
        if (listArray!= nil && listArray.count >= 1) {
            newName = [newName stringByAppendingString:@"_1"];
        }else{
            break;
        }
    }
    list.name = newName;
    list.order = [[NSDate date] timeIntervalSince1970];
    [[MECoreDataManager defaultManager] save];
    [self.listModelArray addObject:list];
}

-(void)deleteMusicListAtIndexPath:(NSIndexPath *)indexPath{
    MEList * list = [self.listModelArray objectAtIndex:indexPath.row];
    [self.listModelArray removeObject:list];
    [[MECoreDataManager defaultManager] deleteObject:list];
}

-(void)renameMusicListName:(NSString *)name atIndexPath:(NSIndexPath *)indexPath{
    MEList * list = [self.listModelArray objectAtIndex:indexPath.row];
    
    LOG(@"list: %@",list);
    NSArray * listArray = [[MECoreDataManager defaultManager] searchMusicListWithName:list.name];
    if (listArray!= nil && listArray.count > 1) {
        list.name = [name stringByAppendingString:@"_1"];
    }else{
        list.name = name;
    }
    [[MECoreDataManager defaultManager] save];
}

@end
