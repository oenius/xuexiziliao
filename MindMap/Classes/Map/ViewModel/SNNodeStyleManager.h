//
//  SNNodeStyleManager.h
//  MindMap
//
//  Created by 何少博 on 2017/8/23.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SNContainerView;
@class SNBaseStyle;
@class SNNodeView;
@interface SNNodeStyleManager : NSObject


@property (strong, nonatomic) SNBaseStyle *style;
@property (weak, nonatomic) SNNodeView *node;

-(instancetype)initWithNode:(SNNodeView *)nodeView;

@end
