//
//  DTFileChoiceViewModel.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/18.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DTDataBaseViewModel.h"
@class DTFileChoiceModel;




@interface DTFileChoiceViewModel : NSObject

- (NSInteger)numberOfSections;

- (NSInteger)numberOfRowsInSection:(NSInteger)section;

-(DTFileChoiceModel *)modelAtIndexPath:(NSIndexPath *)indexPath;

-(void)syncSelectsToDataResponse;
-(NSUInteger)checkSelectedCount;

@end

@interface DTFileChoiceModel : NSObject

@property (nonatomic,assign) DTFileType modelType;

@property (nonatomic,strong) DTDataBaseViewModel * viewModel;

@property (nonatomic,copy) NSString * headImageName;

@property (nonatomic,copy) NSString * title;

@end
