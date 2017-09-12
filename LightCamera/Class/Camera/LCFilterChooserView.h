//
//  LCFilterChooserView.h
//  LightCamera
//
//  Created by 何少博 on 16/12/13.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

typedef void(^callBackFilter)(GPUImageOutput<GPUImageInput> * filter);

@interface LCFilterChooserView : UIView

@property(nonatomic,copy) callBackFilter backback;

@end


#pragma mark - LCFilterChooseCell

@interface LCFilterChooseCell : UICollectionViewCell

@property(nonatomic,strong)UIImageView * iconImg;

@property(nonatomic,strong)UILabel * nameLab;

@property(nonatomic,assign) NSInteger index;

@end
