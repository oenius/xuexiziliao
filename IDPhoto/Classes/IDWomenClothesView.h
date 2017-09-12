//
//  IDWomenClothesView.h
//  IDPhoto
//
//  Created by 何少博 on 17/4/28.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDClothesChooseView.h"

@interface IDWomenClothesView : IDClothesChooseView

-(instancetype)initWithSelected:(ClothesBlock)block;
-(void)clotheSelectBlock:(ClothesBlock)block;
@end
