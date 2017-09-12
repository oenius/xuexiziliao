//
//  DTMusicPickerCell.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/19.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTMusicAndContactBaseCell.h"
@class DTMusicModel;
@interface DTMusicPickerCell : DTMusicAndContactBaseCell

@property (nonatomic,strong) DTMusicModel * model;

@property (nonatomic,copy) void(^shareBlock)(DTMusicModel * model);

@property (nonatomic,assign) BOOL showShare;

@end
