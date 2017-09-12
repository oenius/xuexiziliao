//
//  EditViewController.h
//  VoiceRemind
//
//  Created by 何少博 on 16/8/25.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "BaseViewController.h"
#import "VoiceRemindENUM.h"
#import "RemindCellModel.h"

@interface EditViewController : BaseViewController
@property (nonatomic,strong)NSString *voiceFileName;
@property (nonatomic,strong)NSString *timeLength;
@property (strong,nonatomic) RemindCellModel * model;
@property (nonatomic,assign) BOOL isEditNotFromRecord;
@property (nonatomic,strong) NSString * someDayKey;
@property (nonatomic,strong) NSString * fileKey;
@end
