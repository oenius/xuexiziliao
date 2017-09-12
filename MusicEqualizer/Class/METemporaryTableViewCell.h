//
//  METemporaryTableViewCell.h
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/4.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MEMusic.h"

typedef void(^DeleteBtnBlock)(MEMusic * musicModel);

@interface METemporaryTableViewCell : UITableViewCell

-(void)deleteBtnCallBack:(DeleteBtnBlock)block;

@property(nonatomic,strong) MEMusic * musicModel;

@end
