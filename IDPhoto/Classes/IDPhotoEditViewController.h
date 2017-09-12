//
//  IDPhotoEditViewController.h
//  IDPhoto
//
//  Created by 何少博 on 17/4/24.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "BaseViewController.h"

@interface IDPhotoEditViewController : BaseViewController


@property (nonatomic,strong) UIImage * editImage;

-(instancetype)initWithChiCunType:(NSString *)idType
                           BGType:(IDPhotoBGType) bgType
                        editImage:(UIImage *)image;

@end
