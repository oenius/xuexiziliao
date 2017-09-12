//
//  DTFileChoiceViewModel.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/18.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTFileChoiceViewModel.h"

#import "DTPhotoViewModel.h"
#import "DTVideoViewModel.h"
#import "DTContactViewModel.h"
//#import "DTMusicViewModel.h"
#import "DTResponseManager.h"
@interface DTFileChoiceViewModel()
@property (nonatomic,strong) DTContactViewModel * contactViewModel;
@property (nonatomic,strong) DTPhotoViewModel * photoViewModel;
@property (nonatomic,strong) DTVideoViewModel * videoViewModel;
//@property (nonatomic,strong) DTMusicViewModel * musicViewModel;
@property (nonatomic,strong) NSMutableArray * dataSource;
@end

@implementation DTFileChoiceViewModel

-(instancetype)init{
    self = [super init];
    if (self) {
        [self loadDataSource];
    }
    return self;
}

-(NSMutableArray *)dataSource{
    if (_dataSource == nil) {
        _dataSource  = [NSMutableArray array];
    }
    return _dataSource;
}


-(void)loadDataSource{
    [self.dataSource removeAllObjects];
    DTFileChoiceModel * addressBookModel = [self getAddressBookModel];
    [self.dataSource addObject:addressBookModel];
    DTFileChoiceModel * photoViewModel = [self getPhotoModel];
    [self.dataSource addObject:photoViewModel];
    DTFileChoiceModel * videoViewModel = [self getVideoModel];
    [self.dataSource addObject:videoViewModel];
//    DTFileChoiceModel * musicViewModel = [self getMusicModel];
//    [self.dataSource addObject:musicViewModel];
}

-(NSUInteger)checkSelectedCount{
    return  (self.contactViewModel.selectedArray.count
            +self.photoViewModel.selectedArray.count
            +self.videoViewModel.selectedArray.count
//            +self.musicViewModel.selectedArray.count
             );
}

-(void)syncSelectsToDataResponse{
    
    for (int i = 0; i < self.photoViewModel.selectedArray.count; i ++) {
        DTAssetModel * model = self.photoViewModel.selectedArray[i];
        model.name = [NSString stringWithFormat:@"PHOTO%04d",i];
    }
    for (int i = 0; i < self.videoViewModel.selectedArray.count; i ++) {
        DTAssetModel * model = self.videoViewModel.selectedArray[i];
        model.name = [NSString stringWithFormat:@"VIDEO%04d",i];
    }
    [DTResponseManager shareInstance].contactSelects = self.contactViewModel.selectedArray;
    [DTResponseManager shareInstance].photoSelects = self.photoViewModel.selectedArray;
    [DTResponseManager shareInstance].videoSelects = self.videoViewModel.selectedArray;
//    [DTResponseManager shareInstance].musicSelects = self.musicViewModel.selectedArray;
}

- (NSInteger)numberOfSections{
    return 1;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(DTFileChoiceModel *)modelAtIndexPath:(NSIndexPath *)indexPath{
    return [self.dataSource objectAtIndex:indexPath.row];
}


#pragma mark - 加载数据
-(DTFileChoiceModel *)getAddressBookModel{
    self.contactViewModel = [[DTContactViewModel alloc]init];
    [self.contactViewModel loadDatas];
    DTFileChoiceModel * model = [[DTFileChoiceModel alloc]init];
    model.modelType = DTFileTypeContact;
    model.viewModel = self.contactViewModel;
    model.headImageName = @"tongxunlu";
    model.title = [DTConstAndLocal tongxunlu];
    return model;
}

-(DTFileChoiceModel *)getPhotoModel{
    self.photoViewModel = [[DTPhotoViewModel alloc]init];
    [self.photoViewModel loadDatasWithType:PHAssetMediaTypeImage];
    DTFileChoiceModel * model = [[DTFileChoiceModel alloc]init];
    model.modelType = DTFileTypePhtoto;
    model.viewModel = self.photoViewModel;
    model.headImageName = @"xiangce";
    model.title = [DTConstAndLocal tupian];
    return model;
}

-(DTFileChoiceModel *)getVideoModel{
    self.videoViewModel = [[DTVideoViewModel alloc]init];
    [self.videoViewModel loadDatasWithType:PHAssetMediaTypeVideo];
    DTFileChoiceModel * model = [[DTFileChoiceModel alloc]init];
    model.modelType = DTFileTypeVideo;
    model.viewModel = self.videoViewModel;
    model.headImageName = @"shiping";
    model.title = [DTConstAndLocal shipin];
    return model;
}

//-(DTFileChoiceModel *)getMusicModel{
//    self.musicViewModel = [[DTMusicViewModel alloc]init];
//    [self.musicViewModel loadDatas];
//    DTFileChoiceModel * model = [[DTFileChoiceModel alloc]init];
//    model.modelType = DTFileTypeMusic;
//    model.viewModel = self.musicViewModel;
//    model.headImageName = @"yinyue";
//    model.title = [DTConstAndLocal yinyue];
//    return model;
//}

@end

@implementation DTFileChoiceModel

@end
