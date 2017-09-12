//
//  IDClothesViewController.h
//  IDPhoto
//
//  Created by 何少博 on 17/4/28.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "BaseViewController.h"

@interface IDClothesViewController : BaseViewController

-(instancetype)initWithImage:(UIImage *)imnage
                      idType:(NSString *)idType
                      bgType:(IDPhotoBGType) bgTye;

@end
