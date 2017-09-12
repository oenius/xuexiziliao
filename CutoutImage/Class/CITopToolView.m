 //
//  CITopToolView.m
//  CutoutImage
//
//  Created by 何少博 on 17/2/5.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "CITopToolView.h"


@interface CITopToolView ()

@property (nonatomic,strong)UIButton * backButton;

@property (nonatomic,strong)UIButton * undoButton;

@property (nonatomic,strong)UIButton * redoButton;

@property (nonatomic,strong)UIButton * resetButton;

@property (nonatomic,strong)UIButton * previewButton;


@end


@implementation CITopToolView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addButton];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addButton];
        
    }
    return self;
}

-(void)addButton{
    _backButton = [[UIButton alloc]init];
    [_backButton setImage:[UIImage imageNamed:@"goback"] forState:UIControlStateNormal];
    [self addSubview:_backButton];
    
    _undoButton = [[UIButton alloc]init];
    [_undoButton setImage:[UIImage imageNamed:@"undo"] forState:UIControlStateNormal];
    [self addSubview:_undoButton];
    
    _redoButton = [[UIButton alloc]init];
    [_redoButton setImage:[UIImage imageNamed:@"redo"]  forState:UIControlStateNormal];
    [self addSubview:_redoButton];
    
    _resetButton = [[UIButton alloc]init];
    [_resetButton setImage:[UIImage imageNamed:@"reset"] forState:UIControlStateNormal];
    [self addSubview:_resetButton];
    
    _previewButton = [[UIButton alloc]init];
    [_previewButton setImage:[UIImage imageNamed:@"preview"]  forState:UIControlStateNormal];
    [self addSubview:_previewButton];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(topViewTap)];
    [self addGestureRecognizer:tap];
    
}

-(void)topViewTap{
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width-40;
    CGFloat height = self.bounds.size.height;
    CGFloat buttonWidth = height-20;
    CGFloat buttonY = (height - buttonWidth) / 2;
    CGFloat spacing = (width - buttonWidth * 5) / 4;
    
    _backButton.frame = CGRectMake(20, buttonY, buttonWidth, buttonWidth);
    _undoButton.frame = CGRectMake(20+buttonWidth+spacing, buttonY, buttonWidth, buttonWidth);
    _resetButton.frame = CGRectMake(20+(buttonWidth+spacing)*2, buttonY, buttonWidth, buttonWidth);
    _redoButton.frame = CGRectMake(20+(buttonWidth+spacing)*3, buttonY, buttonWidth, buttonWidth);
    _previewButton.frame = CGRectMake(20+(buttonWidth+spacing)*4, buttonY, buttonWidth, buttonWidth);
    
}

-(void)setUndoBtnEnable:(BOOL)enable{
    self.undoButton.enabled = enable;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (enable) {
            self.undoButton.backgroundColor = [UIColor redColor];
        }else{
            self.undoButton.backgroundColor = [UIColor whiteColor];
        }
    });
   
}

-(void)setRedoBtnEnable:(BOOL)enable{
    self.redoButton.enabled  = enable;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (enable) {
            self.redoButton.backgroundColor = [UIColor redColor];
        }else{
            self.redoButton.backgroundColor = [UIColor whiteColor];
        }
    });
}


-(void)backButtonAddTarget:(id)target action:(SEL)action{
    [_backButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

-(void)undoButtonAddTarget:(id)target action:(SEL)action{
    [_undoButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

-(void)resetButtonAddTarget:(id)target action:(SEL)action{
    [_resetButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

-(void)redoButtonAddTarget:(id)target action:(SEL)action{
    [_redoButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

-(void)previewButtonAddTarget:(id)target action:(SEL)action{
    [_previewButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

@end
