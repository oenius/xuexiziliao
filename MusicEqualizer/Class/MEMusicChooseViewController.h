//
//  MEMusicChooseViewController.h
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/3.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "BaseViewController.h"
#import "MEList.h"
typedef void(^ChooseMusicBlock)(NSArray *array);

@interface MEMusicChooseViewController : BaseViewController
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andmusicList:(MEList *)list;
-(void)musicChooseCallBack:(ChooseMusicBlock)block;

@end
