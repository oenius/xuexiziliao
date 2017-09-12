//
//  RecoderViewController.m
//  VoiceRemind
//
//  Created by 何少博 on 16/8/24.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "RecoderViewController.h"
#import "EditViewController.h"
#import "AVRecoder.h"
#import "NSObject+x.h"
#import "EZAudio.h"
#import "UIColor+x.h"
#import "NPCommonConfig.h"
#import "NPInterstitialButton.h"


#define AudioPlotViewTag 999999

@interface RecoderViewController ()<
EZMicrophoneDelegate,
AVRecoderDelegate
>

@property (weak, nonatomic) IBOutlet UIView *audioPlotContentView;
//@property (strong, nonatomic) EZAudioPlot *audioPlotView;
@property (weak, nonatomic) IBOutlet UIButton *doneRecoderingBtn;
@property (weak, nonatomic) IBOutlet UIButton *recoderingBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *goProBtn;

@property (weak, nonatomic) IBOutlet UILabel *recodertimeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recoderBottom;
@property (nonatomic, strong) NSString *voiceName;
@property (nonatomic, strong) NSString *voicePath;
@property (nonatomic, strong) AVRecoder * recoder;
@property (nonatomic, strong) EZMicrophone *microphone;
@property (nonatomic, assign) NSTimeInterval recoderTimeLength;

@property (nonatomic, assign) BOOL isFirstClickRecordBtn;
@property (nonatomic,assign)  BOOL saveRecordSuccess;

@end

@implementation RecoderViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [[NPCommonConfig shareInstance] initAdvertise];
    BOOL shouldShowAd = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (shouldShowAd) {
        NPInterstitialButton *interstitialButton = [NPInterstitialButton buttonWithType:NPInterstitialButtonTypeIcon viewController:self];
        UIBarButtonItem *adIconBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:interstitialButton];
        self.navigationItem.rightBarButtonItem = adIconBarButtonItem;
    }
    self.view.backgroundColor = color_eaeaea;
    self.audioPlotContentView.backgroundColor = color_414140;
    [self.recoderingBtn setImage:[UIImage imageNamed:@"_recording"] forState:UIControlStateNormal];
    self.isFirstClickRecordBtn = YES;
    self.recoderingBtn.layer.cornerRadius = 40;
    self.recoderingBtn.layer.masksToBounds = YES;
    self.doneRecoderingBtn.layer.cornerRadius = 30;
    self.doneRecoderingBtn.layer.masksToBounds = YES;
    self.cancelBtn.layer.cornerRadius = 30;
    self.cancelBtn.layer.masksToBounds = YES;
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
    self.title = NSLocalizedString(@"page.title record", @"Recording");
    if (![self needsShowAdView]) {
        self.goProBtn.hidden = YES;
        self.recoderBottom.constant = 60;
    }else{
        self.recoderBottom.constant = 90;
    }
//    [self.navigationController.navigationBar setTitleTextAttributes:
//     @{NSFontAttributeName:[UIFont systemFontOfSize:18.0 weight:0.1],
//       NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#facd1a"]}];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.microphone) {
        [self.microphone stopFetchingAudio];
    }
    [self removeAudioPlotView];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [self doneRecoderingBtnClick:self.doneRecoderingBtn];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.saveRecordSuccess) {
        self.isFirstClickRecordBtn = YES;
    }
}

#pragma mark - 原生广告
- (BOOL)needLoadNativeAdView {
    if ([self needsShowAdView]) {
        return YES;
    }else{
        return NO;
    }
}
-(BOOL)needLoadBannerAdView{
    return NO;
}
- (void)showNativeAdView:(UIView *)nativeAdView {
    [super showNativeAdView:nativeAdView];
    CGRect nativeLoction = self.view.frame;
    nativeAdView.center = CGPointMake(nativeLoction.size.width /2.0, nativeLoction.size.height - 40);
    [self.view addSubview:nativeAdView];
}
#pragma mark - 加载
-(void)addAudioPlotView{
    EZAudioPlot * audioPlotView = [self.audioPlotContentView viewWithTag:AudioPlotViewTag];
    if (audioPlotView == nil) {
        audioPlotView = [[EZAudioPlot alloc]initWithFrame:self.audioPlotContentView.bounds];
        audioPlotView = [[EZAudioPlot alloc]initWithFrame:self.audioPlotContentView.bounds];
        audioPlotView.plotType = EZPlotTypeRolling;//EZPlotTypeBuffer;//
        audioPlotView.shouldMirror = YES;
        audioPlotView.shouldFill = YES;
        audioPlotView.gain = 2;
        audioPlotView.backgroundColor = color_414140;
        audioPlotView.color = [UIColor orangeColor];
        audioPlotView.tag = AudioPlotViewTag;
        [self.audioPlotContentView addSubview:audioPlotView];
    }
}
-(void)removeAdNotification:(NSNotification *)notification{
    self.goProBtn.hidden = YES;
}
-(void)removeAudioPlotView{
    EZAudioPlot * audioPlotView = [self.audioPlotContentView viewWithTag:AudioPlotViewTag];
    if (audioPlotView != nil) {
        [audioPlotView removeFromSuperview];
    }
}


-(AVRecoder *)recoder{
    if (_recoder == nil) {
        _recoder = [[AVRecoder alloc]init];
    }
    return _recoder;
}

#pragma mark - 初始化

-(BOOL)maikefengQuanxian{
    __block BOOL result = NO;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {//麦克风权限
        if (granted) {
            NSLog(@"Authorized");
            result = YES;
        }else{
            UIAlertController *alertVC=[UIAlertController alertControllerWithTitle:NSLocalizedString(@"user.Prompt", @"Prompt") message:NSLocalizedString(@"setting.permissions", @"No permission in current app,whether go to settings?") preferredStyle: UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAct=[UIAlertAction actionWithTitle:NSLocalizedString(@"common.Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *settingAct=[UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", @"Settings") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }];
            [alertVC addAction:cancelAct];
            [alertVC addAction:settingAct];
            [self presentViewController:alertVC animated:YES completion:^{
            }];
        }
    }];
    return result;
}

-(void)startRecoder{
    if (![self maikefengQuanxian])return;
    NSDate *date=[NSDate date];
    NSDateFormatter*dateFormat = [[NSDateFormatter alloc]init];//格式化
    [dateFormat setDateFormat:@"yyyyMMddHHmmss"];
    NSString *strTime=[dateFormat stringFromDate:date];
    NSString *voiceName=[NSString stringWithFormat:@"%@.caf",strTime];
    self.voiceName = voiceName;
    NSString *voicePath = [Voice_directory stringByAppendingPathComponent:voiceName];
    self.voicePath = voicePath;
    if ([self.recoder RecorderWithFileUrl:voicePath OpenTimerdelegate:self]) {
        [self.recoderingBtn setImage:[UIImage imageNamed:@"suspend"] forState:UIControlStateNormal];
        [self.cancelBtn setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [self.doneRecoderingBtn setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
    }
}
#pragma mark - actions
- (IBAction)recoderingBtnClick:(UIButton *)sender {
    if (self.isFirstClickRecordBtn) {
        [self startRecoder];
        [self.microphone startFetchingAudio];
        [self addAudioPlotView];
        self.isFirstClickRecordBtn = NO;
        self.saveRecordSuccess = NO;
    }
    else if ([self.recoder recording]){
        [self.recoder pauseRecord];
        if (self.microphone) {
            [self.microphone stopFetchingAudio];
        }
//        self.audioPlotView.hidden = YES;
        [sender setImage:[UIImage imageNamed:@"start-"] forState:UIControlStateNormal];
    }else{
        [self.recoder resumeRecord];
        [self.microphone startFetchingAudio];
        [self addAudioPlotView];
        [sender setImage:[UIImage imageNamed:@"suspend"] forState:UIControlStateNormal];
    }
}

- (IBAction)doneRecoderingBtnClick:(UIButton *)sender {
    if (self.isFirstClickRecordBtn == YES) return;
    [self.recoder stopRecord];
    if (self.microphone) {
        [self.microphone stopFetchingAudio];
    }
    [self removeAudioPlotView];
    EditViewController * editVC = [[EditViewController alloc]init];
    editVC.voiceFileName = self.voiceName;
    editVC.timeLength = self.recodertimeLabel.text;
    [self.recoderingBtn setImage:[UIImage imageNamed:@"_recording"] forState:UIControlStateNormal];
    [self.doneRecoderingBtn setImage:[UIImage imageNamed:@"save-unchoosed"] forState:UIControlStateNormal];
    [self.cancelBtn setImage:[UIImage imageNamed:@"delete-unchoosed"] forState:UIControlStateNormal];
    self.recodertimeLabel.text = @"00:00:00";
    self.recoder = nil;
    [self presentViewController:editVC animated:YES completion:nil];
    self.saveRecordSuccess = YES;
}
- (IBAction)cancelBtnClick:(UIButton *)sender {
    [self.recoder stopRecord];
    if (self.microphone) {
        [self.microphone stopFetchingAudio];
    }
    [self removeAudioPlotView];
    NSFileManager * fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:self.voicePath error:nil];
    [self.recoderingBtn setImage:[UIImage imageNamed:@"_recording"] forState:UIControlStateNormal];
    [self.doneRecoderingBtn setImage:[UIImage imageNamed:@"save-unchoosed"] forState:UIControlStateNormal];
    [self.cancelBtn setImage:[UIImage imageNamed:@"delete-unchoosed"] forState:UIControlStateNormal];
    self.recodertimeLabel.text = @"00:00:00";
    self.isFirstClickRecordBtn = YES;
    self.recoder = nil;
}
- (IBAction)goProBtnClick:(UIButton *)sender {
    [[NPCommonConfig shareInstance] gotoBuyProVersion];
}

#pragma mark - EZMicrophoneDelegate

- (void)microphone:(EZMicrophone *)microphone hasAudioReceived:(float **)buffer withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels
{
    EZAudioPlot * audioPlotView = [self.audioPlotContentView viewWithTag:AudioPlotViewTag];
    if (audioPlotView == nil) return;
//    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [audioPlotView updateBuffer:buffer[0] withBufferSize:bufferSize];
    });
}
- (void)microphone:(EZMicrophone *)microphone hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription
{
    [EZAudioUtilities printASBD:audioStreamBasicDescription];
}
#pragma mark - AVRecoderDelegate

-(void)currentRecoderTime:(NSTimeInterval)time timeString:(NSString *)timeString{
    if (!self.recoder.recording) return;
    self.recodertimeLabel.text = timeString;
    self.recoderTimeLength = time;
}

#pragma mark - 调整广告位置

-(float)adViewBottomOffsetFromSuperViewBottom{
    CGFloat view_h = self.view.bounds.size.height;
    CGFloat ads_h  = [self isIPad]?90:50;
    return view_h - ads_h-2;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self setAdViewHiden:YES];
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self adjustAdview];
    [self setAdViewHiden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
