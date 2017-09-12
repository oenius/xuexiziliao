//
//  IDClothesChooseView.h
//  IDPhoto
//
//  Created by 何少博 on 17/5/2.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^ClothesBlock)(NSString * clothesName);

@interface IDClothesChooseView : UIView

-(instancetype)initDataSource:(NSArray <NSString *>* ) clothes didSelected:(ClothesBlock)block;
-(void)setDataSource:(NSArray <NSString *>*)dataSource selectBlock:(ClothesBlock)block;
@end

