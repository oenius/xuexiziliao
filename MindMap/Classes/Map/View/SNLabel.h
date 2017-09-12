//
//  SNLabel.h
//  MindMap
//
//  Created by 何少博 on 2017/8/8.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface SNLabel : UILabel

@property (nonatomic,assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic,assign) IBInspectable CGFloat borderWidth;
@property (nonatomic,assign) IBInspectable UIColor *borderColor;

@end
