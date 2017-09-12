//
//  IDClotehsEraseView.h
//  IDPhoto
//
//  Created by 何少博 on 17/5/2.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClothesEraseBlock)(CGFloat value);

@interface IDClotehsEraseView : UIView

@property (nonatomic,strong) UIButton * cancelBtn;

@property (nonatomic,strong) UIButton * okBtn;

@property (nonatomic,strong) UIColor * eraseColor;

-(void)valueChanged:(ClothesEraseBlock)block;

@end
