//
//  MEAddMusicToListViewModel.h
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/6.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class MEList;
@interface MEAddMusicToListViewModel : NSObject

-(NSInteger)numberOfRowsInSection:(NSInteger)sectoin;

-(NSInteger)numberOfSectionsInTableView;

-(MEList *)getMusicListModelAtIndexPath:(NSIndexPath *)indexPath;

@end
