//
//  SNStyleViewModel.m
//  MindMap
//
//  Created by 何少博 on 2017/8/23.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNStyleViewModel.h"
#import "SNStyleSectionModel.h"
#import "SNStyleModel.h"
@interface SNStyleViewModel ()

@property (strong, nonatomic)NSMutableArray <SNStyleSectionModel *>* dataSource;
@end

@implementation SNStyleViewModel


-(NSMutableArray<SNStyleSectionModel *> *)dataSource{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
        NSString * tipsPath = [[NSBundle mainBundle]pathForResource:@"Styles" ofType:@"plist"];
        NSArray * datas = [NSArray arrayWithContentsOfFile:tipsPath];
        for (NSDictionary * dic in datas) {
            SNStyleSectionModel * model = [[SNStyleSectionModel alloc]initWithDic:dic];
            [_dataSource addObject:model];
        }
    }
    return _dataSource;
}

-(NSInteger)numberOfSectionsInCollectionView{
    return self.dataSource.count;
}
-(NSInteger)numberOfItemsInSection:(NSInteger)section{
    return self.dataSource[section].childs.count;
}
-(SNStyleModel *)modelAtIndexPath:(NSIndexPath *)indexPath{
    return self.dataSource[indexPath.section].childs[indexPath.row];
}
-(SNStyleSectionModel *)sectionModelAtIndexPath:(NSIndexPath *)indexPath{
    return self.dataSource[indexPath.section];
}

-(Class)getSelectedStyleClassAtIndexPath:(NSIndexPath *)indexPath{
    SNStyleModel * model = [self modelAtIndexPath:indexPath];
    return NSClassFromString(model.name);
}



@end
