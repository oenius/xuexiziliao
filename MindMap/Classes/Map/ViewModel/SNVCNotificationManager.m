//
//  SNVCNotificationManager.m
//  MindMap
//
//  Created by 何少博 on 2017/8/8.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNVCNotificationManager.h"
#import "SNMindMapViewController.h"
#import "SNPathView.h"
#import "SNNodeView.h"
#import "SNContainerView.h"
#import "SNNodeTextView.h"
#import "SNNodeFrameMananger.h"
@implementation SNVCNotificationManager

-(void)registerNotification{
    
    NSNotificationCenter * notiCenter = [NSNotificationCenter defaultCenter];
    [notiCenter addObserver:self selector:@selector(nodeDidSet:)
                       name:kSNNodeViewDidMoveToSuperView object:nil];
    [notiCenter addObserver:self selector:@selector(nodeBeenRemove:)
                       name:kSNNodeViewDidRemoveFromSuperView object:nil];
    [notiCenter addObserver:self selector:@selector(nodeDidBeenRefresh:)
                       name:kSNNodeViewBeenRefreshNotification object:nil];
    [notiCenter addObserver:self selector:@selector(keyBoardDidShow:)
                       name:UIKeyboardDidShowNotification object:nil];
    [notiCenter addObserver:self selector:@selector(keyBoardWillHidden:)
                       name:UIKeyboardWillHideNotification object:nil];
    [notiCenter addObserver:self selector:@selector(textChange:)
                       name:UITextViewTextDidChangeNotification object:nil];
    [notiCenter addObserver:self selector:@selector(nodeStatusChanged:)
                       name:kSNNodeViewStatusChangedNotification object:nil];
    [notiCenter addObserver:self selector:@selector(keyBoardWillShow:)
                       name:UIKeyboardWillShowNotification object:nil];
    [notiCenter addObserver:self selector:@selector(nodeCloseButtonChanged:)
                       name:kSNNodeViewCloseChangedNotification object:nil];
    
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - noti actions

-(void)nodeCloseButtonChanged:(NSNotification *)noti{
    if (![self.host isKindOfClass:[SNMindMapViewController class]]) {
        return;
    }
    if (![noti.object isKindOfClass:[SNNodeView class]]) {
        return;
    }
    SNMindMapViewController * vc = (SNMindMapViewController *)self.host;
    vc.canCheckScorllviewExtend = NO;
    [vc.textEditor deattach];
    [vc hiddenAllKnob];
}

-(void)nodeDidSet:(NSNotification *)noti{
    if (![self.host isKindOfClass:[SNMindMapViewController class]]) {
        return;
    }
    if (![noti.object isKindOfClass:[SNNodeView class]]) {
        return;
    }
    SNNodeView * noteView = (SNNodeView *)noti.object;
    SNPathView * pathView = noteView.associatePathView;
    if (pathView == nil) {
        return;
    }
    SNMindMapViewController * vc = (SNMindMapViewController *)self.host;
    [vc.pathContainer addSubview:pathView];
//    vc.textEditor.text = @"";
    [vc.textEditor attach:noteView];
    [noteView.frameManager updateNodeFrame];
    [vc.textEditor deattach];
}

-(void)nodeBeenRemove:(NSNotification *)noti{
    if (![noti.object isKindOfClass:[SNNodeView class]]) {
        return;
    }
    SNNodeView * note = (SNNodeView *)noti.object;
    [note.associatePathView removeFromSuperview];
}

-(void)nodeDidBeenRefresh:(NSNotification *)noti{
    if (![self.host isKindOfClass:[SNMindMapViewController class]]) {
        return;
    }
    SNMindMapViewController * vc = (SNMindMapViewController *)self.host;
    if (vc.canCheckScorllviewExtend) {
        [vc extendScrollViewIfNeed];
    }else{
        vc.canCheckScorllviewExtend = YES;
    }
}

-(void)keyBoardDidShow:(NSNotification *)noti{
    NSLog(@"keyBoardDidShow");
    if (![self.host isKindOfClass:[SNMindMapViewController class]]) {
        return;
    }
    SNMindMapViewController * vc = (SNMindMapViewController *)self.host;
    NSValue *rectValue = noti.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect f = rectValue.CGRectValue;
    if (vc.canChangeScrollViewBottomByKeyBoardflag) {
        vc.scrollViewBottomSuggestHeight = f.size.height;
    }
    vc.canChangeScrollViewBottomByKeyBoardflag = YES;
}

-(void)keyBoardWillHidden:(NSNotification *)noti{
    NSLog(@"keyBoardWillHidden");
    if (![self.host isKindOfClass:[SNMindMapViewController class]]) {
        return;
    }
    
    SNMindMapViewController * vc = (SNMindMapViewController *)self.host;
//    BOOL isPortrait = [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait;
//    BOOL isPhone = [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad;
    vc.scrollViewBottomSuggestHeight = 0;
}

-(void)textChange:(NSNotification *)noti{
    if (![self.host isKindOfClass:[SNMindMapViewController class]]) {
        return;
    }
    SNMindMapViewController * vc = (SNMindMapViewController *)self.host;
    if (![noti.object isKindOfClass:[SNNodeTextView class]]) {
        return;
    }
    CGRect frame = ((SNNodeTextView *)noti.object).frame;
    [vc.scrollview scrollRectToVisible:frame animated:YES];
    [vc updateKnobPosition];
}

-(void)nodeStatusChanged:(NSNotification *)noti{
    if (![self.host isKindOfClass:[SNMindMapViewController class]]) {
        return;
    }
    SNMindMapViewController * vc = (SNMindMapViewController *)self.host;
    [vc updateNodeStatus];
}
-(void)keyBoardWillShow:(NSNotification *)noti{
//    if (![self.host isKindOfClass:[SNMindMapViewController class]]) {
//        return;
//    }
//    SNMindMapViewController * vc = (SNMindMapViewController *)self.host;
    
}

@end

























