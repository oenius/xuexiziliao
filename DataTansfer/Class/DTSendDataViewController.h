//
//  DTSendDataViewController.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/26.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "BaseViewController.h"

@interface DTSendDataViewController : BaseViewController

@property (nonatomic,strong) UIImage  * QRImage;

-(instancetype)initWithQRImage:(UIImage *)image;

@end
