//
//  SNNodeView.h
//  MindMap
//
//  Created by 何少博 on 2017/8/15.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SNNodeFrameMananger;
@class SNPathView;
@class SNMapStyle;
typedef enum : NSUInteger {
    SNNodeDirectionLeft,
    SNNodeDirectionRight,
    SNNodeDirectionNone,
} SNNodeDirection;


typedef enum : NSUInteger {
    SNNodeStatusNormal,
    SNNodeStatusHightLight,
    SNNodeStatusEditing,
} SNNodeStatus;

@interface SNNodeView : UIView

@property (nonatomic,strong) SNMapStyle *style;
@property (nonatomic,assign) SNNodeStatus status;
@property (assign, nonatomic) SNNodeDirection direction;
@property (nonatomic,strong) SNNodeFrameMananger *frameManager;
@property (nonatomic,strong) SNPathView *associatePathView;
@property (nonatomic,weak) SNNodeView * parent;
@property (nonatomic,strong) NSMutableArray <SNNodeView *>*childs;
@property (nonatomic,strong) NSMutableArray <SNNodeView *>*visibleChilds;
@property (nonatomic,assign) NSInteger depth;
@property (assign, nonatomic) BOOL visiable;
@property (assign, nonatomic) BOOL needRedraw;
@property (assign, nonatomic) BOOL childVisiable;
@property (strong, nonatomic) UIButton *closeButton;



-(SNNodeView *)root;
-(void)remove;
-(void)refreshChild;
-(void)refresh;
-(SNNodeView *)append;
-(BOOL)isRoot;
-(void)updateLinkedPathBetweenNode;
-(void)closeOrOpenChild;
@end
