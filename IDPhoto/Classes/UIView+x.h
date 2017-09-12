//
//  UIView+x.h
//  IDPhoto
//
//  Created by 何少博 on 17/5/2.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (x)
-(void)setViewLayoutAnimation;
-(void)setViewLayoutAnimationCompletion:(void(^)(BOOL finish))completion;
-(void)addGrayShadow;
@end
