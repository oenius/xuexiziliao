//
//  DTScanQRView.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/26.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTScanQRView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+st.h"
@interface DTScanQRView (){
    CGFloat scanContent_X,scanContent_Y;
}

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) UIImageView *scanningline;


@property (nonatomic,strong) UIView * scanContentView;
@property (nonatomic,strong) UIView * topView;
@property (nonatomic,strong) UIView * leftView;
@property (nonatomic,strong) UIView * rightView;
@property (nonatomic,strong) UIView * bottomView;

@property (nonatomic,strong) UILabel * promptLabel;
@property (nonatomic,strong) UIButton * lightButton;

@property (nonatomic,assign) BOOL isStopAnimation;

@end

static CGFloat const scanninglineHeight = 12;
static CGFloat const scanBorderOutsideViewAlpha = 0.5;

@implementation DTScanQRView



-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    // 扫描内容的创建
    self.scanContentView = [[UIView alloc] init];
    self.scanContentView.layer.borderColor = [[UIColor greenColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha].CGColor;
    self.scanContentView.layer.borderWidth = 0.7;
    self.scanContentView.layer.backgroundColor = [UIColor clearColor].CGColor;
    [self addSubview:self.scanContentView];
    self.scanContentView.clipsToBounds = YES;
    
    
    
    // 顶部layer的创建
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha];
    [self addSubview:self.topView];
    
    // 左侧layer的创建
    self.leftView = [[UIView alloc] init];
    self.leftView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha];
    [self addSubview:self.leftView];
    
    // 右侧layer的创建
    self.rightView = [[UIView alloc] init];
    self.rightView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha];
    [self addSubview:self.rightView];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha];
    [self addSubview:self.bottomView];
    
    // 提示Label
    _promptLabel = [[UILabel alloc] init];
    _promptLabel.backgroundColor = [UIColor clearColor];
    _promptLabel.textAlignment = NSTextAlignmentCenter;
    _promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
    _promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    _promptLabel.text = [DTConstAndLocal pleaseSaomiao];
    _promptLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_promptLabel];
    
    // 添加闪光灯按钮
    _lightButton = [[UIButton alloc] init];
    [_lightButton setImage:[UIImage imageNamed:@"openLight"] forState:UIControlStateNormal];
    [_lightButton setImage:[UIImage imageNamed:@"closeLight"] forState:UIControlStateSelected];
    [_lightButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    _lightButton.titleLabel.font = [UIFont systemFontOfSize:17];
    
    [_lightButton addTarget:self action:@selector(light_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_lightButton];
    [self tianJiaYueShu];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat minValue = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat height = minValue*0.7;
    [self.scanContentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(height));
        make.height.equalTo(@(height));
    }];
}

-(void)tianJiaYueShu{
    [self.scanContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
        make.width.equalTo(@(300));
        make.height.equalTo(@(300));
    }];
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.scanContentView.mas_left);
        make.bottom.equalTo(self.mas_bottom);
    }];
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.scanContentView.mas_right);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
    }];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.leftView.mas_right);
        make.right.equalTo(self.rightView.mas_left);
        make.bottom.equalTo(self.scanContentView.mas_top);
    }];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scanContentView.mas_bottom);
        make.left.equalTo(self.leftView.mas_right);
        make.right.equalTo(self.rightView.mas_left);
        make.bottom.equalTo(self.mas_bottom);
    }];
    [self.promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.left.equalTo(self.leftView.mas_right);
        make.right.equalTo(self.rightView.mas_left);
        make.bottom.equalTo(self.scanContentView.mas_top);
    }];
    [self.lightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bottomView.mas_centerX);
        make.centerY.equalTo(self.bottomView.mas_centerY);
        make.width.equalTo(@(100));
        make.height.equalTo(@(60));
    }];
}


- (void)light_buttonAction:(UIButton *)button {
    if (button.selected == NO) { // 点击打开照明灯
        [self turnOnLight:YES];
        button.selected = YES;
    } else { // 点击关闭照明灯
        [self turnOnLight:NO];
        button.selected = NO;
    }
}
- (void)turnOnLight:(BOOL)on {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([_device hasTorch]) {
        [_device lockForConfiguration:nil];
        if (on) {
            [_device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [_device setTorchMode: AVCaptureTorchModeOff];
        }
        [_device unlockForConfiguration];
    }
}

- (UIImageView *)scanningline {
    if (!_scanningline) {
        _scanningline = [[UIImageView alloc] init];
        _scanningline.image = [UIImage imageNamed:@"QRCodeScanningLine"];
        _scanningline.frame = CGRectMake(0, -scanninglineHeight, self.scanContentView.bounds.size.width, scanninglineHeight);
        [self.scanContentView addSubview:_scanningline];
    }
    return _scanningline;
}

-(void)stopScanAnimation{
    self.isStopAnimation = YES;
    [self.scanningline removeFromSuperview];
    self.scanningline = nil;
    
}

-(void)startScanAnimation{
    CGRect frame = CGRectMake(0, -scanninglineHeight, self.scanContentView.bounds.size.width, scanninglineHeight);
    self.scanningline.frame = frame;
    frame.origin.y = self.scanContentView.bounds.size.height;
    [UIView animateWithDuration:3 animations:^{
        self.scanningline.frame = frame;
    } completion:^(BOOL finished) {
        if (self.isStopAnimation) {  return ; }
        [self startScanAnimation];
    }];
    
}

-(void)dealloc{
    LOG(@"%s",__func__);
}
@end
