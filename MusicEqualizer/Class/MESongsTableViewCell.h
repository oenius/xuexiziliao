//
//  MESongsTableViewCell.h
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/27.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEMusic.h"


#define   cellDefaultHeight   65
#define   cellActiveHeight    110

typedef enum : NSUInteger {
    MESongsCellActionTypeDetail,
    MESongsCellActionTypeFavorite,
    MESongsCellActionTypeAddToList,
    MESongsCellActionTypeNextPlay,
    MESongsCellActionTypeDelete
} MESongsCellActionType;

typedef void(^ActionsCallBack)(MESongsCellActionType actionType,UITableViewCell * cell);

@interface MESongsTableViewCell : UITableViewCell

@property (strong,nonatomic)MEMusic * musicModel;

-(void)setIsFavorive:(BOOL)isfavorite;

+(NSString *)className;

-(void)cellActionsCallBackBlock:(ActionsCallBack)block;

@end
