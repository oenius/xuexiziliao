//
//  DTMusicViewModel.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/19.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTDataBaseViewModel.h"

//@class DTMusicModel;

@interface DTMusicViewModel : DTDataBaseViewModel
//-(NSInteger)numberOfSectionsInTableView;
//-(NSInteger)numberOfRowsInSection:(NSInteger)section;
//-(DTMusicModel *)modelAtIndexPath:(NSIndexPath *)indexPath;
//-(void)setSelectedArrayWithIndexPaths:(NSArray <NSIndexPath *>*)seletctIndexPaths;
//-(void)getSelectIndexPathsFromModels:(NSMutableArray *) selectedIndexPaths;
@end

@interface DTMusicModel : NSObject<NSCopying,NSCoding>

//@property (nonatomic, assign) BOOL isSelected;
//@property (nonatomic, copy) NSString * IDFR;
//@property (nonatomic, copy) NSString * name;
//@property (nonatomic, copy) NSURL * iPodUrl;
//@property (nonatomic, copy) NSData * imageData;
//@property (nonatomic, copy) NSString *singer;
//@property (nonatomic, copy) NSData *musicData;
//@property (nonatomic, copy) NSString * fileUrlPath;
//
//+(instancetype)modelWithMeidaItem:(MPMediaItem *)item;
@end
