//
//  MEMusicListViewModel.h
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/3.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class MEList;

@interface MEMusicListViewModel : NSObject

-(NSInteger)numberOfRowsInSection:(NSInteger)sectoin;

-(NSInteger)numberOfSectionsInTableView;

-(MEList *)getMusicListModelAtIndexPath:(NSIndexPath *)indexPath;

-(BOOL)canEditRowAtIndexPath:(NSIndexPath *)indexPath;

-(void)insertMusicListWithName:(NSString*)name;

-(void)renameMusicListName:(NSString *)name atIndexPath:(NSIndexPath *)indexPath;

-(void)deleteMusicListAtIndexPath:(NSIndexPath *)indexPath;

@end
