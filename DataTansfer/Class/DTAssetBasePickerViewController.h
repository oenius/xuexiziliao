//
//  DTAssetBasePickerViewController.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/22.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "BaseViewController.h"
#import "DTAssetBaseViewModel.h"
@interface DTAssetBasePickerViewController : BaseViewController

@property (nonatomic,strong) DTAssetBaseViewModel * baseViewModel;
-(void)doneItemClick;
@end
