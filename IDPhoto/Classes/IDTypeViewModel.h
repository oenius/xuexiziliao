//
//  IDTypeViewModel.h
//  IDPhoto
//
//  Created by 何少博 on 17/4/21.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IDTypeModel : NSObject

@property (nonatomic,strong) UIImage * image;

@property (nonatomic,copy) NSString *imageName;

@property (nonatomic,copy) NSString * title;

@property (nonatomic,copy) NSString * IPType;

@end

@interface IDTypeViewModel : NSObject

-(NSInteger)numberOfSectionsInCollectionView;

-(NSInteger) numberOfItemsInSection:(NSInteger)section;

-(IDTypeModel *)cellModelAtIndexPath:(NSIndexPath *)indexPath;

@end


