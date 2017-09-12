//
//  CustomTableViewCell.h
//  VoiceRemind
//
//  Created by 何少博 on 16/8/25.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RemindCellModel.h"

@interface CustomTableViewCell : UITableViewCell

@property (strong,nonatomic) RemindCellModel * model;
@end
