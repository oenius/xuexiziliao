//
//  PreviewViewController.h
//  InstaMessage
//
//  Created by 何少博 on 16/8/12.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "BaseViewController.h"
#import "EditViewController.h"
typedef NS_ENUM(NSInteger, PreviewSaveAction) {
    SAVE,
    COMMENT,
    GOPRO,
};

@interface PreviewViewController : BaseViewController

@property (strong,nonatomic)UIImage * image;
@property (assign,nonatomic)PreviewSaveAction saveAction;
@property (weak,nonatomic) EditViewController * editVC;
@end
