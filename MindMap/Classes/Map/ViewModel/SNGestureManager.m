//
//  SNGestureManager.m
//  MindMap
//
//  Created by 何少博 on 2017/8/8.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNGestureManager.h"
#import "SNMindMapViewController.h"
#import "SNNodeView.h"
#import "SNContainerView.h"
#import "SNNodeFrameMananger.h"
#import "SNPathView.h"
#import "SNNodeTextView.h"


@interface SNGestureManager ()

@property (assign, nonatomic) BOOL shouldShowMenu;
@property (nonatomic,assign) CGPoint lastTapPoint;
@property (nonatomic,assign) CGFloat direction;
@property (nonatomic,strong) SNNodeView *currentNode;

@end


@implementation SNGestureManager

-(instancetype)initWithMindMapViewControlelr:(SNMindMapViewController *)controller{
    self = [super init];
    if (self) {
        _mindMapViewController = controller;
        _shouldShowMenu = YES;
        [self prepareGesture];
        
    }
    return self;
}

-(void)prepareGesture{
    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.mindMapViewController.view addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.mindMapViewController.view addGestureRecognizer:singleTap];
    
    NSArray <UIGestureRecognizer *>* scrollviewGes = self.mindMapViewController.scrollview.gestureRecognizers;
    for (UIGestureRecognizer * ges in scrollviewGes) {
        [ges requireGestureRecognizerToFail:singleTap];
    }
    
//    UIPanGestureRecognizer * panKnob = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panOnKnob:)];
//    [self.mindMapViewController.knobContainer addGestureRecognizer:panKnob];
    
//    UIPanGestureRecognizer * panNode = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panOnNode:)];
//    [self.mindMapViewController.nodeContainer addGestureRecognizer:panNode];
    
//    scrollviewGes = self.mindMapViewController.scrollview.gestureRecognizers;
//    for (UIGestureRecognizer * ges in scrollviewGes) {
//        if ([ges isKindOfClass:[UIPanGestureRecognizer class]]) {
//            [ges requireGestureRecognizerToFail:panKnob];
//            [ges requireGestureRecognizerToFail:panNode];
//        }
//    }
}

#pragma mark - 单击手势
-(void)singleTap:(UITapGestureRecognizer *)sender{
    [self.mindMapViewController endEdit];
    CGPoint loc = [sender locationInView:self.mindMapViewController.view];
    self.lastTapPoint = loc;
    UIView * hitView = [self.mindMapViewController.view hitTest:_lastTapPoint withEvent:nil];
    if ([hitView isKindOfClass:[UIScrollView class]]) {
        [self tapOnScrollview];
    }
    else if ([hitView isKindOfClass:[SNNodeView class]]) {
        self.mindMapViewController.activeNode = (SNNodeView *)hitView;
        [self tapOnNode];
    }
}

-(void)tapOnScrollview{
    
}
-(void)tapOnNode{

    [self editNodeAction:nil];
    
}

#pragma mark - 双击手势

-(void)doubleTap:(UITapGestureRecognizer *)sender{
    CGPoint loc = [sender locationInView:self.mindMapViewController.view];
    UIView * hitView = [self.mindMapViewController.view hitTest:loc withEvent:nil];
    if ([hitView isKindOfClass:[UIButton class]]) {
        return;
    }
    if ([hitView isKindOfClass:[SNNodeView class]]) {
        self.mindMapViewController.activeNode = (SNNodeView *)hitView;
        [self.mindMapViewController beginEdit];
    }else{
        CGFloat scale1 = 1.0;
        CGFloat scale2 = 1.5;
        CGFloat scrollviewScale = self.mindMapViewController.scrollview.zoomScale;
        if ( scrollviewScale != scale1) {
            [self.mindMapViewController.scrollview setZoomScale:scale1 animated:YES];
        }else{
            [self.mindMapViewController.scrollview setZoomScale:scale2 animated:YES];
        }
            
    }
}


-(void)panOnKnob:(UIPanGestureRecognizer *)sender{
    SNNodeView * activeNote = self.mindMapViewController.activeNode;
    if (!activeNote) { return;}
    CGPoint loc = [sender locationInView:sender.view];
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self.mindMapViewController beginUpdateActivite];
            if (!activeNote.frameManager.resized) {
                activeNote.frameManager.resized = YES;
            }
            if (loc.x < activeNote.center.x) {
                self.direction = 1;
            }else{
                self.direction = 0;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
            [self.mindMapViewController commitUpdateActivite];
            break;
        default:
            break;
    }
    
    CGFloat delta = [sender translationInView:self.mindMapViewController.knobContainer].x;
    CGRect frame = activeNote.frame;
    activeNote.frameManager.resized = YES;
    CGFloat width = frame.size.width + (1 - 2 * self.direction) * delta;
    NSLog(@"width:%g",width);
    switch (activeNote.status) {
        case SNNodeStatusHightLight:
            activeNote.frame = CGRectMake(
                                          frame.origin.x + self.direction * delta,
                                          frame.origin.y,
                                          MAX(42, width),
                                          frame.size.height);
            break;
            
        default:
            break;
    }
    
    [sender setTranslation:CGPointZero inView:self.mindMapViewController.knobContainer];
    if (activeNote.frameManager.imageMode != SNNodeImageModeFreedom) {
        activeNote.frameManager.imageMode = SNNodeImageModeFreedom;
    }
    CGFloat A = activeNote.frameManager.imageWidthOnFreedomMode + (1 - 2 * self.direction) * delta * 2;
    activeNote.frameManager.imageWidthOnFreedomMode = MAX(A, 42);
    [activeNote.frameManager updateNodeFrame];
    [activeNote refresh];
    [self.mindMapViewController updateKnobPosition];
}

-(void)panOnNode:(UIPanGestureRecognizer *)sender{
    UIView * locView = sender.view;
    if (!locView) {
        return;
    }
    CGPoint offset = [sender translationInView:locView];
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.currentNode = (SNNodeView *)[locView hitTest:[sender locationInView:locView] withEvent:nil];
            if (!self.currentNode) { return; }
            [self.currentNode.superview bringSubviewToFront:self.currentNode];
            [self.currentNode.associatePathView.superview bringSubviewToFront:self.currentNode.associatePathView];
            [self.mindMapViewController hiddenAllKnob];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            self.currentNode.frame = CGRectOffset(self.currentNode.frame, offset.x, offset.y);
            if (self.mindMapViewController.textEditor.associatedNode == self.currentNode) {
                self.mindMapViewController.textEditor.frame = CGRectOffset(self.mindMapViewController.textEditor.frame, offset.x, offset.y);
            }
            [sender setTranslation:CGPointZero inView:locView];
            [self.currentNode refreshChild];
            
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        {
            [SNPathView animateWithDuration:0.3 animations:^{
                [self.currentNode refresh];
            }];
        }
          break;
        default:
            break;
    }
}


-(void)editNodeAction:(id)sender{
    [self.mindMapViewController beginEdit];
    NSLog(@"%s",__func__);
}



@end


















