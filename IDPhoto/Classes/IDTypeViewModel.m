//
//  IDTypeViewModel.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/21.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDTypeViewModel.h"


@interface IDTypeViewModel ()

@property (nonatomic,strong) NSMutableArray * dataSurce;

@end


@implementation IDTypeViewModel


-(NSMutableArray *)dataSurce{
    if (_dataSurce == nil) {
        _dataSurce = [NSMutableArray array];
        
        NSString * dataArrayPath = [[NSBundle mainBundle]pathForResource:@"IDTypeList" ofType:@"plist"];
        NSArray * dataArray = [NSArray arrayWithContentsOfFile:dataArrayPath];
        NSString * currentLanguage = [[[NSLocale preferredLanguages] firstObject] substringToIndex:2];
        
        if (![currentLanguage containsString:@"zh"]) {
            NSArray * data1 = [dataArray subarrayWithRange:NSMakeRange(0, 7)];
            NSArray * data2 = [dataArray subarrayWithRange:NSMakeRange(7, dataArray.count-7)];
            data2 = [data2 arrayByAddingObjectsFromArray:data1];
            dataArray = data2;
        }

        if (dataArray) {
            for (NSDictionary * dic in dataArray) {
                IDTypeModel * model = [IDTypeModel new];
                NSString * imageNmae = dic[@"ImageName"];
                model.imageName = imageNmae;
                model.image = [UIImage imageNamed:model.imageName];
                NSString * titleKey = dic[@"TitleKey"];
                model.IPType = titleKey;
                model.title = NSLocalizedString(titleKey, @"");
                [_dataSurce addObject:model];
            }
        }
    }
    return _dataSurce;
}

-(NSInteger)numberOfSectionsInCollectionView{
    return 1;
}

-(NSInteger) numberOfItemsInSection:(NSInteger)section{
    return self.dataSurce.count;
}

-(IDTypeModel *)cellModelAtIndexPath:(NSIndexPath *)indexPath{
    return self.dataSurce[indexPath.row];
}


@end

@implementation IDTypeModel



@end
