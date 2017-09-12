//
//  Ruler.h
//  numberChoose
//
//  Created by 何少博 on 16/9/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RulerScrollView.h"
@protocol RulerDelegate <NSObject>

- (void)rulerDidDrag:(CGFloat)rulerValue;

@end


@interface Ruler : UIView<UIScrollViewDelegate>

@property (nonatomic,weak) id<RulerDelegate>delegate;

@property (nonatomic,strong) NSArray *numberArray;

-(void)showInView:(UIView*)view;

-(void)nextItem;

@end
