//
//  VoiceNoticViewController.h
//  VoiceRemind
//
//  Created by 何少博 on 16/8/30.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "BaseViewController.h"

@interface VoiceNoticViewController : BaseViewController

@property (strong,nonatomic) NSString * someDayKey;
@property (strong,nonatomic) NSString * fileKey;
@property (strong,nonatomic) NSDate * noticDate;

@end
