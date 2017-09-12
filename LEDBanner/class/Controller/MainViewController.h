//
//  MainViewController.h
//  LEDBanner
//
//  Created by 何少博 on 16/6/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "BaseViewController.h"
#import "LEDShowViewController.h"
#import "NPCommonConfig.h"
@interface MainViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic,strong) UIFont * font;
@property (nonatomic,assign) NSShowModel  showModel;
@property (nonatomic,assign) NSDotModel dotModel;
@property (assign,nonatomic) BOOL isMulticolour;
@property (strong,nonatomic) UIColor * onColor;
@property (strong,nonatomic) UIColor * offColor;
@end
