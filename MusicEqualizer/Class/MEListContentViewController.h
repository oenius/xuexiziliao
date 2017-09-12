//
//  MEListContentViewController.h
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/3.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "BaseViewController.h"
@class MEList;

@interface MEListContentViewController : BaseViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andmusicList:(MEList *)list;

@end
