//
//  SNMindMapViewController.h
//  MindMap
//
//  Created by 何少博 on 2017/8/8.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNBaseViewController.h"
@class SNContainerView;
@class SNNodeView;
@class SNNodeTextView;
@class SNNodeAsset;
@class SNMindFileViewModel;
@interface SNMindMapViewController : SNBaseViewController
<UIScrollViewDelegate,
CAAnimationDelegate>

@property (strong, nonatomic) SNMindFileViewModel *fileViewModel;
@property (copy, nonatomic) NSString *assetFilePath;
@property (strong, nonatomic) SNNodeAsset *asset;
@property (assign, nonatomic) BOOL isNewMap;
@property (nonatomic,strong) NSMutableArray<SNNodeView *> *mainNodes;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet SNContainerView *nodeContainer;
@property (weak, nonatomic) IBOutlet SNContainerView *knobContainer;
@property (weak, nonatomic) IBOutlet SNContainerView *pathContainer;
@property (weak, nonatomic) IBOutlet SNNodeTextView *textEditor;
@property (nonatomic,strong) SNNodeView * activeNode;
@property (nonatomic,assign) BOOL canCheckScorllviewExtend;
@property (nonatomic,assign) BOOL canChangeScrollViewBottomByKeyBoardflag;
@property (nonatomic,assign) CGFloat scrollViewBottomSuggestHeight;


-(void)beginEdit;
-(void)endEdit;
-(void)beginUpdateActivite;
-(void)commitUpdateActivite;
-(void)updateKnobPosition;
-(void)hiddenAllKnob;
-(void)extendScrollViewIfNeed;
-(void)updateNodeStatus;
//bar action
-(void)activeNodeBrother;
-(void)activeNodeChild;
-(void)activeAddImage;
-(void)activeNodeDelete;
-(void)activeNodeTip;
-(void)mindMapStyleAction;

@end
