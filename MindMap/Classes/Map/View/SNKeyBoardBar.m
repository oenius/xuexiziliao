//
//  SNKeyBoardBar.m
//  MindMap
//
//  Created by 何少博 on 2017/8/8.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNKeyBoardBar.h"
#import "SNMindMapViewController.h"
#import "SNNodeTextView.h"
#import "SNNodeView.h"

typedef enum : NSUInteger {
    BTNActionTypeBrother = 0,
    BTNActionTypeChild,
    BTNActionTypeImage,
    BTNActionTypeTip,
    BTNActionTypeStyle,
    BTNActionTypeDelete,
} BTNActionType;

@interface SNKeyBoardBar ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *buttonsArray;


@end

static CGFloat kButtonHeight = 35;
static CGFloat kButtonWidth = 50;

@implementation SNKeyBoardBar

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}
-(void)awakeFromNib{
    [super awakeFromNib];
    [self setupSubViews];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width =  CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat buttonMarign = 10;
    NSInteger count = self.buttonsArray.count;
//    CGFloat sideSpace = buttonMarign / 2;
    CGFloat needWidth = count * (buttonMarign + kButtonWidth);
    if (needWidth > width) {
        self.scrollView.contentSize = CGSizeMake(needWidth, height);
    }else{
        buttonMarign = (width - kButtonWidth * count) / count;
        self.scrollView.contentSize = CGSizeMake(width, height);
    }
    CGFloat leftSpace = buttonMarign / 2;
    CGFloat Y = (height - kButtonHeight) / 2;
    for (int i = 0; i < count; i ++) {
        CGRect frame = CGRectMake(leftSpace + (kButtonWidth + buttonMarign) * i,
                                  Y,
                                  kButtonWidth,
                                  kButtonHeight);
        UIButton * button = self.buttonsArray[i];
        button.frame = frame;
    }
}

-(NSArray *)buttonImages{
    return @[
             [UIImage imageNamed:@"1"],
             [UIImage imageNamed:@"2"],
             [UIImage imageNamed:@"3"],
             [UIImage imageNamed:@"5"],
             [UIImage imageNamed:@"6"],
             [UIImage imageNamed:@"4"],
             ];
}


-(void)setupSubViews{
    NSArray * images = [self buttonImages];
    self.buttonsArray  = [NSMutableArray array];
    for (int i = 0 ; i < images.count; i ++) {
        UIImage * image = images[i];
        UIButton * button = [[UIButton alloc]init];
        [button setImage:image forState:(UIControlStateNormal)];
        [button addTarget:self action:@selector(buttonsClick:) forControlEvents:(UIControlEventTouchUpInside)];
        button.tag = i;
        [self.scrollView addSubview:button];
        [self.buttonsArray addObject:button];
    }
    
}

-(void)buttonsClick:(UIButton *)sender{
    
    switch (sender.tag) {
        case BTNActionTypeBrother:
            [self.host activeNodeBrother];
            break;
        case BTNActionTypeChild:
            [self.host activeNodeChild];
            break;
        case BTNActionTypeImage:
            [self.host activeAddImage];
            break;
        case BTNActionTypeDelete:
            [self.host activeNodeDelete];
            break;
        case BTNActionTypeTip:
            [self.host activeNodeTip];
            break;
        case BTNActionTypeStyle:
            [self.host mindMapStyleAction];
            break;
        default:
            break;
    }
    sender.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
}



@end
