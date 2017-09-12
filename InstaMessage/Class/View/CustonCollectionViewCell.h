//
//  CustonCollectionViewCell.h
//  InstaMessage
//
//  Created by 何少博 on 16/7/27.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThemeItemModel.h"
#import "TextViewModel.h"

@interface CustonCollectionViewCell : UICollectionViewCell
@property (nonatomic,strong)ThemeItemModel * model;
@property (nonatomic,strong)TextViewModel * textModel;
@property (nonatomic,strong)UIImage * image;
@property (nonatomic,strong)NSString * textFont;
@end
