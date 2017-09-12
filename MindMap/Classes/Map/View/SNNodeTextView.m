//
//  SNNodeTextView.m
//  MindMap
//
//  Created by 何少博 on 2017/8/15.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNNodeTextView.h"
#import "SNNodeView.h"
#import "SNNodeFrameMananger.h"
#import "SNMapStyle.h"
@interface SNNodeTextView ()

@property (assign, nonatomic) BOOL askForTextChanged;

@end


@implementation SNNodeTextView

-(instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(instancetype)initWithNode:(SNNodeView *)node{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.associatedNode = node;
    }
    return self;
}


-(void)attach:(SNNodeView *)noteView{
    self.backgroundColor = [UIColor clearColor];
    self.textColor = noteView.style.textColor;
    self.layer.borderColor = noteView.style.textColor.CGColor;
    if (noteView.depth == 0) {
        self.font = [UIFont systemFontOfSize:21];
    }else if (noteView.depth == 1){
        self.font = [UIFont systemFontOfSize:18];
    }else{
        self.font = [UIFont systemFontOfSize:16];
    }
    [self deattach];
    self.autoGrowingWidth = YES;
    SNNodeFrameMananger * fm = noteView.frameManager;
    if (fm) {
        NSAttributedString * att = fm.attributeText;
        if (att) {
            self.text = att.string;
        }else{
            self.text = @"";
        }
    }
   
    self.associatedNode = noteView;
    if (noteView != nil &&(noteView.frameManager.image != nil)) {
        self.autoGrowingWidth = NO;
        CGRect frame = self.frame;
        frame.size  = CGSizeMake(noteView.frameManager.innerWidth, 0);
        self.frame = frame;
        [self textChanged:nil];
    }
    [self updateAssociatedNode];
    [self textChanged:nil];
    
}

-(BOOL)becomeFirstResponder{
    self.askForTextChanged = NO;
    BOOL r = [super becomeFirstResponder];
    self.askForTextChanged = YES;
    return r;
}

-(void)textChanged:(NSNotification *)noti{
    [super textChanged:noti];
    if (self.askForTextChanged == NO) {
        return;
    }
    [self updateAssociatedNode];
    [self.associatedNode refresh];
    [self.associatedNode setNeedsDisplay];
}

-(void)deattach{
    if ([self.text isEqualToString:@""]) {
        self.associatedNode.frameManager.attributeText = nil;
    }
    self.associatedNode.frameManager.recommendContainerBounds = CGRectZero;
    [self.associatedNode.frameManager updateNodeFrame];
    self.associatedNode = nil;
    [self resignFirstResponder];
    self.hidden = YES;
}

-(void)updateAssociatedNode{
    
    self.associatedNode.frameManager.attributeText = self.attributedText;
    self.associatedNode.frameManager.recommendContainerBounds = self.bounds;
    self.associatedNode.frameManager.textContainerInset = self.textContainerInset;
    [self.associatedNode.frameManager updateNodeFrame];
    CGRect frame = self.associatedNode.frameManager.textFrame;
    if (!CGRectEqualToRect(frame, CGRectZero) &&
        self.associatedNode != nil &&
        self.associatedNode.superview != nil) {
        CGRect f = [self.associatedNode convertRect:frame toView:self.associatedNode.superview];
        self.frame = f;
        self.hidden = NO ;
    }
}


@end
