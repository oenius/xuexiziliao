//
//  GameViewController.m
//  MemoryTurnCard
//
//  Created by 何少博 on 16/10/21.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//
#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS

#define TOP 40
#import "GameViewController.h"
#import "Masonry.h"
#import "MemoryCardContentView.h"
#import "SucceedView.h"
#import "CustomAnimatedDelegate.h"
#import "ViewAnimation.h"
#import "NPCommonConfig.h"
//#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
@interface GameViewController ()
@property (nonatomic,strong) NSArray * imagePathArray;
@property (nonatomic,assign) GameImageType imageType;
@property (nonatomic,strong) AVAudioPlayer * audioPlay;
@property (nonatomic,strong) UIImageView * topImageView;
@property (nonatomic,strong) UIButton * raiseDifficultyBtn;
@property (nonatomic,strong) UIButton * reduceDifficultyBtn;
@property (nonatomic,strong) UIView * contentView;
@property (nonatomic,strong) UIView * bottomView;
@property (nonatomic,weak) UIView * nativeAdView_250;
@property (nonatomic,strong) MemoryCardContentView * memoryCardView;
@property (nonatomic,assign) NSInteger hardLevel;//0->(2x2),1->(2x3),2->(2x4),3->(3x4),4->(4x4),5->(4x5)，6(5x6)
@property (nonatomic,assign) BOOL isFirst;
@property (nonatomic,assign) UIDeviceOrientation deviceOrient;
@property (nonatomic,weak) UIButton * adsBtn;
@property (nonatomic,weak) UIButton * backBtn;

@end

bool isCanPlay = true;

@implementation GameViewController

-(instancetype)initWithGameImageType:(GameImageType)imageType{
    self = [super init];
    if (self) {
        self.imageType = imageType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hardLevel = 0;
    self.isFirst = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.alpha = 0;
    self.navigationController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[[UIView alloc]init]];
    [self chuShiHua_UI];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_isFirst) {
        [self setMemoryCardContentView];
        _isFirst = NO;
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
#pragma mark - 广告相关
- (BOOL)needLoadNative250HAdView {
    return YES;
}

- (BOOL)needLoadNative132HAdView{
    return NO;
}

- (BOOL)needLoadBannerAdView {
    return YES;
}
- (void)showNative250HAdView:(UIView *)nativeAdView {
    [super showNative250HAdView:nativeAdView];
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    nativeAdView.center = CGPointMake(screenBounds.size.width /2.0, 130);
    self.nativeAdView_250 = nativeAdView;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNaviAdReload object:nil userInfo:@{kNaviAdReload:nativeAdView}];
    
}
-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    CGFloat offset = contentInsets.bottom;
    [_bottomView updateConstraints:^(MASConstraintMaker *make) {
             make.bottom.equalTo(-offset);
    }];
    if (offset < 40) return;
    if (self.memoryCardView!=nil && self.memoryCardView.isAnimationing == YES) {
        [self setMemoryCardContentView];
    }
}
#pragma  mark - 布局控件

-(void)chuShiHua_UI{
    //添加backGroundImageView
    UIImageView * balckImageview = [[UIImageView alloc]init];
    [self.view addSubview:balckImageview];
    balckImageview.image = [UIImage imageNamed:@"BackGround"];
//    balckImageview.contentMode = UIViewContentModeScaleAspectFill;
    [balckImageview makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.top);
        make.left.equalTo(self.view.left);
        make.bottom.equalTo(self.view.bottom);
        make.right.equalTo(self.view.right);
    }];
    //添加顶部ImageView
    self.topImageView = [[UIImageView alloc]init];
    [self.view addSubview:_topImageView];
    _topImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_topImageView setImage:[UIImage imageNamed:@"title"]];
    [_topImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(40);
        make.width.equalTo(self.view.width).multipliedBy(1.0/2.0);
        make.height.equalTo(self.view.width).multipliedBy(1.0/14.0);
        make.centerX.equalTo(self.view.centerX);
//        make.height.equalTo(60);
//        make.width.equalTo(self.view.width).multipliedBy(1.0/2);
//        make.centerX .equalTo(self.view.centerX);
//        make.top.equalTo(self.view.top).offset(TOP-10);
    }];
    //增加难度的Btn
    self.raiseDifficultyBtn = [[UIButton alloc]init];
    [self.view addSubview:self.raiseDifficultyBtn];
    _raiseDifficultyBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_raiseDifficultyBtn setImage:[UIImage imageNamed:@"raiseHard"] forState:UIControlStateNormal];
    [_raiseDifficultyBtn addTarget:self action:@selector(raiseDifficultyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_raiseDifficultyBtn makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(40);
        make.left.equalTo(_topImageView.right);
        make.right.equalTo(self.view.right);
//        make.top.equalTo(self.view.top).offset(TOP);
        make.centerY.equalTo(self.topImageView.centerY);
    }];
    //减少难度的Btn
    self.reduceDifficultyBtn = [[UIButton alloc]init];
    [self.view addSubview:self.reduceDifficultyBtn];
    _reduceDifficultyBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_reduceDifficultyBtn addTarget:self action:@selector(reduceDifficultyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _reduceDifficultyBtn.enabled = NO;
    [_reduceDifficultyBtn setImage:[UIImage imageNamed:@"reduceHard"] forState:UIControlStateNormal];
    [_reduceDifficultyBtn makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(40);
        make.left.equalTo(self.view.left);
        make.right.equalTo(_topImageView.left);
//        make.top.equalTo(self.view.top).offset(TOP);
        make.centerY.equalTo(self.topImageView.centerY);
    }];
    //添加下部
    self.bottomView = [[UIView alloc]init];
    _bottomView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_bottomView];
    [_bottomView makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(50);
        make.leftMargin.equalTo(10);
        make.rightMargin.equalTo(-10);
        make.bottom.equalTo(-20);
    }];
    
   
    if ([[NPCommonConfig shareInstance] shouldShowAdvertise]) {
        UIButton * adsBtn = [[UIButton alloc]init];
        [self.bottomView addSubview:adsBtn];
        self.adsBtn = adsBtn;
//        adsBtn.hidden = YES;
        [adsBtn addTarget:self action:@selector(adsBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        //    [adsBtn setTitle:@"ADS" forState:UIControlStateNormal];
        [adsBtn setImage:[UIImage imageNamed:@"adIcon"]forState:UIControlStateNormal];
        //    adsBtn.imageView.contentMode = UIViewContentModeScaleToFill;
        [adsBtn makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self.bottomView.height);
            make.width.equalTo(self.bottomView.width).multipliedBy(1.0/2);
            make.rightMargin.equalTo(0);
            make.topMargin.equalTo(0);
        }];
    }
    UIButton * blackBtn = [[UIButton alloc]init];
    [self.bottomView addSubview:blackBtn];
    self.backBtn = blackBtn;
    [blackBtn addTarget:self action:@selector(blackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [blackBtn setImage:[UIImage imageNamed:@"previous"] forState:UIControlStateNormal];
    CGFloat backBtnMultiplied = 1.0;
    if ([[NPCommonConfig shareInstance] shouldShowAdvertise]) {
        backBtnMultiplied = 0.5;
    }
    [blackBtn makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.bottomView.height);
        make.width.equalTo(self.bottomView.width).multipliedBy(backBtnMultiplied);
        make.leftMargin.equalTo(0);
        make.topMargin.equalTo(0);
    }];
    //添加btnContentView
    self.contentView = [[UIView alloc]init];
    _contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_contentView];
    [_contentView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_raiseDifficultyBtn.bottom).offset(30);
        make.bottom.equalTo(_bottomView.top).offset(-20);
        make.leftMargin.equalTo(15);
        make.rightMargin.equalTo(-15);
    }];
}

#pragma mark - 布局所有btn
-(void)setMemoryCardContentView{
    __weak typeof(self) weakSelf = self;
//    [_contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (self.memoryCardView) {
        [self.memoryCardView removeSelfWithAnimation];
    }
    self.memoryCardView = [[MemoryCardContentView alloc]initWithHardLevel:self.hardLevel imageType:self.imageType succeedBlock:^(NSInteger step) {
        //完成翻牌后调用添加胜利视图
        //        playSoundEffect();
        [weakSelf playSoundEffect];
        
        
        SucceedView * succeed = [[SucceedView alloc]init];
        
        [succeed setADView:weakSelf.nativeAdView_250 hardLevel:(int)self.hardLevel  btnClickBlock:^(BOOL isAgain, BOOL remove, BOOL isNext) {
            //接受胜利视图点击事件
            if (isAgain)  [weakSelf setMemoryCardContentView];
            else if (isNext) [weakSelf raiseDifficultyBtnClick:weakSelf.raiseDifficultyBtn];
            else if (isNext){};
            [weakSelf stopSoundEffect];
 
        }];
//    WithFrame:weakSelf.view.bounds ADView:weakSelf.nativeAdView_250 hardLevel:self.hardLevel btnClickBlock:^(BOOL isAgain, BOOL remove, BOOL isNext) {
//            //接受胜利视图点击事件
//            if (isAgain)  [weakSelf setMemoryCardContentView];
//            else if (isNext) [weakSelf raiseDifficultyBtnClick:weakSelf.raiseDifficultyBtn];
//            else if (isNext){};
//            [weakSelf stopSoundEffect];
//        }];
        
        
        [weakSelf.view addSubview:succeed];
        [succeed makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.view.left);
            make.top.equalTo(weakSelf.view.top);
            make.right.equalTo(weakSelf.view.right);
            make.bottom.equalTo(weakSelf.view.bottom);
        }];
        [ViewAnimation animationOfScaleBig:succeed duration:0.4 completion:^(BOOL finish) {}];
        
    }];
    
    [_contentView addSubview:self.memoryCardView];
    [self.memoryCardView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_contentView);
        make.top.equalTo(_contentView);
        make.right.equalTo(_contentView);
        make.bottom.equalTo(_contentView);
    }];
}
#pragma mark - actions
//增加难度
-(void)raiseDifficultyBtnClick:(UIButton *)sender{
    //0->(2x2),1->(2x3),2->(2x4),3->(3x4),4->(4x4),5->(4x5)，6(5x6)
    self.hardLevel ++;
    if (self.hardLevel == 6) sender.enabled = NO;
    if (self.reduceDifficultyBtn.enabled == NO) {
        self.reduceDifficultyBtn.enabled = YES;
    }
    [self setMemoryCardContentView];
}
//减少难度
-(void)reduceDifficultyBtnClick:(UIButton *)sender{
   //0->(2x2),1->(2x3),2->(2x4),3->(3x4),4->(4x4),5->(4x5)
    self.hardLevel --;
    if (self.hardLevel == 0) sender.enabled = NO;
    if (self.raiseDifficultyBtn.enabled == NO) {
        self.raiseDifficultyBtn.enabled = YES;
    }
    [self setMemoryCardContentView];
}
-(void)blackBtnClick:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)adsBtnClick:(UIButton *)sender{
    if ([[NPCommonConfig shareInstance]shouldShowAdvertise]) {
        [[NPCommonConfig shareInstance] showFullScreenAdORNativeAdForController:self];
    }
}
-(void)playSoundEffect{
    self.audioPlay = nil;
    NSString * soundPath = [[NSBundle mainBundle]pathForResource:@"4579.wav" ofType:nil];
    NSURL * soundUrl = [NSURL fileURLWithPath:soundPath];
    self.audioPlay = [[AVAudioPlayer alloc]initWithContentsOfURL:soundUrl error:nil];
    self.audioPlay.numberOfLoops = 5;
    [self.audioPlay prepareToPlay];
    [self.audioPlay play];
}
-(void)stopSoundEffect{
    if (self.audioPlay.isPlaying) {
        [self.audioPlay stop];
        self.audioPlay = nil;
    }
}
- (void)deviceOrientationDidChange: (NSNotification *)notification{
    
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        return;
    }
    UIDeviceOrientation  deviceOrient = [UIDevice currentDevice].orientation;
    if (self.deviceOrient == deviceOrient) return;
    self.deviceOrient = deviceOrient;
    if (self.memoryCardView!=nil && self.memoryCardView.isAnimationing == YES) {
        [self setMemoryCardContentView];
    }
}
-(void)advertiseInterstitialNotification:(NSNotification *)notification{
    [super advertiseInterstitialNotification:notification];
    self.adsBtn.hidden = NO;
}
-(void)removeAdNotification:(NSNotification *)notification{
    [super removeAdNotification:notification];
    [self.backBtn updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.bottomView.width);
    }];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//void playSoundEffect(){
//    NSString * soundPath = [[NSBundle mainBundle]pathForResource:@"4579.wav" ofType:nil];
//    NSURL * soundUrl = [NSURL fileURLWithPath:soundPath];
//    //1.获得系统声音ID
//    SystemSoundID soundID=0;
//    /**
//     * inFileUrl:音频文件url
//     * outSystemSoundID:声音id（此函数会将音效文件加入到系统音频服务中并返回一个长整形ID）
//     */
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(soundUrl), &soundID);
//    //如果需要在播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调函数
//    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
//    //2.播放音频
//    AudioServicesPlaySystemSound(soundID);//播放音效
//    //    AudioServicesPlayAlertSound(soundID);//播放音效并震动
//}
//
//void soundCompleteCallback(SystemSoundID soundID,void * clientData){
//    
//    if (isCanPlay == true)  playSoundEffect();
//    else isCanPlay = true;
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//- (BOOL)shouldAutorotate{
//    return YES;
//}
//
//#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
//- (NSUInteger)supportedInterfaceOrientations
//#else
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//#endif
//{
//    return UIInterfaceOrientationMaskLandscape;
//}

@end
