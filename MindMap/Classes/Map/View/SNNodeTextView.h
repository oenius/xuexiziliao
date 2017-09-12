//
//  SNNodeTextView.h
//  MindMap
//
//  Created by 何少博 on 2017/8/15.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNGrowingTextView.h"
@class SNNodeView;
@interface SNNodeTextView : SNGrowingTextView

@property (nonatomic,weak) SNNodeView *associatedNode;

-(instancetype)initwithNode:(SNNodeView *)node;

-(void)attach:(SNNodeView *)nodeView;
-(void)deattach;
@end
