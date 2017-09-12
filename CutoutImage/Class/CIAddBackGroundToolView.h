//
//  CIAddBackGroundToolView.h
//  CutoutImage
//
//  Created by 何少博 on 17/2/14.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  CIAddBackGroundToolViewDeleagte;

@interface CIAddBackGroundToolView : UIView

@property (nonatomic,weak) id<CIAddBackGroundToolViewDeleagte> delegate;

@end


@protocol CIAddBackGroundToolViewDeleagte <NSObject>

-(void)imageDidChoosed:(UIImage *)image;

-(void)alphaValueChanged:(CGFloat)value;

@end
