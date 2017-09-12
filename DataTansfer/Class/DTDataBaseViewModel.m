//
//  DTDataBaseViewModel.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/18.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTDataBaseViewModel.h"

@implementation DTDataBaseViewModel


-(NSMutableArray *)selectedArray{
    if (_selectedArray == nil) {
        _selectedArray = [NSMutableArray array];
    }
    return _selectedArray;
}

-(NSMutableArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

-(void)loadDatas{
    
}

-(void)authorizationStatus:(DTAuthorizationResultBlock)block{
    
}
+(void)archivedModel:(id)model completed:(void(^)(NSData * data)) completed{
    completed(nil);
}
@end
