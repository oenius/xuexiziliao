//
//  CIEraserSizeChooseView.h
//  CutoutImage
//
//  Created by 何少博 on 17/2/9.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CIEarseSizeChooseViewDelegate ;

@interface CIEraserSizeChooseView : UIView

@property (nonatomic,weak) id<CIEarseSizeChooseViewDelegate> delegate;

-(instancetype)initWithFrame:(CGRect)frame sliderMaxValue:(CGFloat)maxValue;

@end

@protocol CIEarseSizeChooseViewDelegate <NSObject>

-(void)sizeChanged:(CIEraserSizeChooseView*)sizeChooseView size:(CGFloat)size;

@end
