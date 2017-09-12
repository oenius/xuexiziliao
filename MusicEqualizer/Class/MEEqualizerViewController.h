//
//  MEEqualizerViewController.h
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "BaseViewController.h"

@class MEAudioPlayer;

@interface MEEqualizerViewController : BaseViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil player:(MEAudioPlayer*)player;
-(instancetype)initWithPlayer:(MEAudioPlayer*)player;



@end
