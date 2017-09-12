//
//  DTProgressButton.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/31.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTProgressButton.h"
#import <DALabeledCircularProgressView.h>
@interface DTProgressButton ()

@property (nonatomic,strong) DALabeledCircularProgressView * progressView;

@property (nonatomic,strong) UIActivityIndicatorView * activityIndicatorView;

@end

@implementation DTProgressButton

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addActivityIndicatorView];
        [self addProgressView];
        [self setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    }
    return self;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        
        [self addActivityIndicatorView];
        [self addProgressView];
        [self setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    }
    return self;
}

-(void)setProgress:(CGFloat)progress{
    _progress = progress;
    [self.progressView setProgress:_progress animated:NO];
    self.progressView.progressLabel.text = [NSString stringWithFormat:@"%.0f%%", _progress*100];
    
}

-(void)setStatu:(DTProgressStatu)statu{
    _statu = statu;
    
    if (_statu == DTProgressStatuNone) {
        [self setImage:[UIImage new] forState:(UIControlStateNormal)];
        self.progressView.hidden = YES;
        self.activityIndicatorView.hidden = YES;
    }
    else if (_statu == DTProgressStatuLoading)
    {
        [self setImage:[UIImage new] forState:(UIControlStateNormal)];
        self.progressView.hidden = YES;
        self.activityIndicatorView.hidden = NO;
        [self.activityIndicatorView startAnimating];
    }
    else if (_statu == DTProgressStatuDowning)
    {
        [self setImage:[UIImage new] forState:(UIControlStateNormal)];
        self.progressView.hidden = NO;
        self.activityIndicatorView.hidden = YES;
        [self.activityIndicatorView stopAnimating];
    }
    else if (_statu == DTProgressStatuFailed)
    {
        [self setImage:[UIImage imageNamed:@"shuaxin"] forState:(UIControlStateNormal)];
        self.progressView.hidden = YES;
        self.activityIndicatorView.hidden = YES;
    }
    else if (_statu == DTProgressStatuSuccess)
    {
        [self setImage:[UIImage imageNamed:@"wancheng"] forState:(UIControlStateNormal)];
        self.progressView.hidden = YES;
        self.activityIndicatorView.hidden = YES;
    }
    else{
        [self setImage:[UIImage new] forState:(UIControlStateNormal)];
        self.progressView.hidden = YES;
        self.activityIndicatorView.hidden = YES;
    }
}

-(void)addActivityIndicatorView{
    if (self.activityIndicatorView) {
        [self.activityIndicatorView removeFromSuperview];
        self.activityIndicatorView = nil;
    }
    self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.activityIndicatorView.color = [UIColor colorWithRed:0.99 green:0.56 blue:0.15 alpha:1.00];
    self.activityIndicatorView.hidesWhenStopped = YES;
    [self addSubview:self.activityIndicatorView];
}

-(void)addProgressView{
    if (self.progressView) {
        [self.progressView removeFromSuperview];
        self.progressView = nil;
    }
    self.progressView = [[DALabeledCircularProgressView alloc]initWithFrame:CGRectZero];
    self.progressView.progressLabel.adjustsFontSizeToFitWidth = YES;
    self.progressView.progressLabel.textColor = [UIColor colorWithHexString:@"333333"];
    self.progressView.progressLabel.font = [UIFont systemFontOfSize:8];
    self.progressView.progressTintColor = [UIColor colorWithRed:0.99 green:0.56 blue:0.15 alpha:1.00];
    self.progressView.roundedCorners = YES;
    [self.progressView setProgress:0.0 animated:NO];
    [self insertSubview:self.progressView atIndex:0];
    self.progressView.hidden = YES;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.progressView.frame = self.bounds;
    self.activityIndicatorView.frame = CGRectMake(0, 0, 30, 30);
    self.activityIndicatorView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}


-(void)addFailedAction:(SEL)action target:(id)target{
    [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

@end
