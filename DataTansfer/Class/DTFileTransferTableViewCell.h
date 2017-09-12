//
//  DTFileTransferTableViewCell.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/31.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTDwonTask;

@interface DTFileTransferTableViewCell : UITableViewCell

@property (nonatomic,strong) DTDwonTask * model;

@property (nonatomic,copy) void(^retryBlock)(DTDwonTask * model);


@end
