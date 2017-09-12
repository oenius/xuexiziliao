//
//  SucceedView.m
//  MemoryTurnCard
//
//  Created by 何少博 on 16/10/25.
//  Copyright © 2016年 shaobo.He. All rights reserved.


#define kNext      1111
#define kAgain     2222
#define kDismiss   3333

#import "SucceedView.h"
#import "ViewAnimation.h"
#import "NPCommonConfig.h"
@interface SucceedView ()

@property (copy,nonatomic) BtnClickBlock block;
@property (weak,nonatomic) UIView * adView;
@property (strong,nonatomic) UIView * contentView;
@property (strong,nonatomic) UIButton * againBtn;
@property (strong,nonatomic) UIButton * nextBtn;
@property (strong,nonatomic) UIButton * dismissBtn;
//@property (strong,nonatomic) UILabel* completeLabel;
@property (strong,nonatomic) UIImageView* Pad_AD_View;
@end

@implementation SucceedView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {

        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.userInteractionEnabled = YES;
        
        self.contentView = [[UIView alloc]init];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.cornerRadius = 8;
        self.contentView.layer.masksToBounds = YES;
        self.contentView.userInteractionEnabled = YES;
        [self addSubview:self.contentView];
        
        self.Pad_AD_View = [[UIImageView alloc]init];
        self.Pad_AD_View.backgroundColor = [UIColor clearColor];
        self.Pad_AD_View.userInteractionEnabled = YES;
        [self.contentView addSubview:self.Pad_AD_View];
        
        
        self.dismissBtn = [[UIButton alloc]init];
        self.dismissBtn.tag = kDismiss;
        [self.dismissBtn setImage:[UIImage imageNamed:@"deletenew"] forState:UIControlStateNormal];
        [self.dismissBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.dismissBtn];
        
        self.againBtn = [[UIButton alloc]init];
        self.againBtn.tag = kAgain;
        [self.againBtn setImage:[UIImage imageNamed:@"game_play_again"] forState:UIControlStateNormal];
        [self.againBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.againBtn];
        
        self.nextBtn = [[UIButton alloc]init];
        [self.nextBtn setImage:[UIImage imageNamed:@"nextnew"] forState:UIControlStateNormal];
        self.nextBtn.tag = kNext;
        
        [self.nextBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.nextBtn];
        
//        self.completeLabel = [[UILabel alloc]init];
//        self.completeLabel.backgroundColor = [UIColor clearColor];
//        self.completeLabel.text = @"very good!";
//        self.completeLabel.textAlignment = NSTextAlignmentCenter;
//        [self.contentView addSubview:self.completeLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(naviAdReload:) name:kNaviAdReload object:nil];
    }
    return self;
}

-(void)setADView:(UIView *)adView hardLevel:(int)hareLavel btnClickBlock:(BtnClickBlock)block{
    self.adView = adView;
    self.block = block;
    if ([[NPCommonConfig shareInstance]shouldShowAdvertise]) {
        [self.Pad_AD_View addSubview:self.adView];
    }else{
        self.Pad_AD_View.image = [UIImage imageNamed:@"congratulations-bg"];
    }
    if (hareLavel == 6)   self.nextBtn.enabled = NO;
}

-(void)naviAdReload:(NSNotification*)noti{
    [self.Pad_AD_View.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIView * navi = [noti.userInfo objectForKey:kNaviAdReload];
//    navi.frame = self.Pad_AD_View.bounds;
    navi.center = CGPointMake(self.Pad_AD_View.bounds.size.width/2, self.Pad_AD_View.bounds.size.height/2);
    [self.Pad_AD_View addSubview:navi];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGSize adSize ;
    if (self.adView != nil) {
        adSize  = self.adView.bounds.size;
    }
    else{
        if (!([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)) {
            CGFloat W = self.bounds.size.width/6*5;
            CGFloat H = self.bounds.size.height/3*2;
            //广告高度最小280x250
            W = W<280 ? 280 : W;
            //如果是Pro 没加载到广告，去广告要进行判断
            adSize = CGSizeMake(W-20, H/2 - 20);
            float adW = adSize.width;
            float adH = adSize.height;
            adSize.width = adW<280 ? 280 : adW;
            adSize.height = adH<250 ? 250 : adH;
        }else{
            adSize = CGSizeMake(640, 500);
        }
    }
    
    
    CGFloat W = adSize.width + 20;
    CGFloat H = adSize.height + adSize.height/3;
    CGRect contentViewFrame = CGRectMake(0, 0, W, H);
    self.contentView.frame = contentViewFrame;
    self.contentView.center = self.center;
    
    //如果是Pro 没加载到广告，去广告要进行判断
    CGRect Pad_AD_ViewFrame = CGRectMake(0, 10, adSize.width, adSize.height);
    float adW = Pad_AD_ViewFrame.size.width;
    float adH = Pad_AD_ViewFrame.size.height;
    Pad_AD_ViewFrame.size.width = adW<280 ? 280 : adW;
    Pad_AD_ViewFrame.size.height = adH<250 ? 250 : adH;
    self.Pad_AD_View.frame = Pad_AD_ViewFrame;
    
    self.Pad_AD_View.center = CGPointMake(W/2, self.Pad_AD_View.center.y);
    if ((self.adView!=nil) && [[NPCommonConfig shareInstance]shouldShowAdvertise]) {
        self.adView.center = CGPointMake(Pad_AD_ViewFrame.size.width/2, Pad_AD_ViewFrame.size.height/2);
        self.Pad_AD_View.image = nil;
    }else{
        self.Pad_AD_View.image = [UIImage imageNamed:@"congratulations-bg"];
    }
    
    CGRect againBtnFrame = CGRectMake(0, 0, H/8, H/8);
    self.dismissBtn.frame = againBtnFrame;
    self.dismissBtn.center = CGPointMake(W/2, H/8*7);
    
    CGRect nextBtnFrame = CGRectMake(0, 0, H/8, H/8);
    self.nextBtn.frame = nextBtnFrame;
    self.nextBtn.center = CGPointMake(W/4*3, H/8*7);
    
    CGRect dismissBtnFrame = CGRectMake(0, 0, H/8, H/8);
    self.againBtn.frame = dismissBtnFrame;
    self.againBtn.center = CGPointMake(W/4, H/8*7);
    
//    float label_y = Pad_AD_ViewFrame.origin.y + Pad_AD_ViewFrame.size.height;
//    float label_h = H/8*7 - H/8/2  - label_y;
//    CGRect imageViewFrame = CGRectMake(0, label_y, W, label_h);
//    self.completeLabel.frame = imageViewFrame;
//    self.completeLabel.font = [UIFont fontWithName:@"Chalkduster" size:18];
}

-(void)btnClick:(UIButton*)sender{
//    block(BOOL isAgain ,BOOL remove ,BOOL isNext)
    switch (sender.tag) {
        case kNext: self.block(NO,NO,YES); break;
        case kAgain: self.block(YES,NO,NO); break;
        case kDismiss: self.block(NO,YES,NO); break;
        default:  break;
    }
    __weak typeof(self) weakSelf = self;
    [ViewAnimation animationOfScaleSmall:self duration:0.4 completion:^(BOOL finish) {
        [weakSelf removeFromSuperview];
    }];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
