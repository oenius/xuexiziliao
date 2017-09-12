//
//  SNTipViewModel.m
//  MindMap
//
//  Created by 何少博 on 2017/8/17.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNTipViewModel.h"
#import "SNTipModel.h"
#import "SNTipSectionModel.h"
@interface SNTipViewModel ()
@property (strong, nonatomic)NSMutableArray <SNTipSectionModel *>* dataSource;
@end

@implementation SNTipViewModel


-(NSMutableArray<SNTipSectionModel *> *)dataSource{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
        NSString * tipsPath = [[NSBundle mainBundle]pathForResource:@"Tips" ofType:@"plist"];
        NSArray * datas = [NSArray arrayWithContentsOfFile:tipsPath];
        for (NSDictionary * dic in datas) {
            SNTipSectionModel * model = [[SNTipSectionModel alloc]initWithDic:dic];
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
-(SNTipModel *)modelAtIndexPath:(NSIndexPath *)indexPath{
    return self.dataSource[indexPath.section].childs[indexPath.row];
}
-(SNTipSectionModel *)sectionModelAtIndexPath:(NSIndexPath *)indexPath{
    return self.dataSource[indexPath.section];
}
-(UIImage *)getTipImageAtIndexPath:(NSIndexPath *)indexPath{
    SNTipModel * model = [self modelAtIndexPath:indexPath];
    return [UIImage imageNamed:model.name];
}
@end
