//
//  ViewController.m
//  LevelMmeter
//
//  Created by 何少博 on 16/9/22.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "MainViewController.h"
#import "CusSettingsViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "NPCommonConfig.h"
#import "NPInterstitialButton.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;

@property (weak, nonatomic) IBOutlet UIImageView *h_ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *v_ImageView;

@property (weak, nonatomic)  UIImageView *h_ball_ImageView;
@property (weak, nonatomic)  UIImageView *v_ball_ImageView;

@property (nonatomic,strong)CMMotionManager * motionManager;
@property (strong,nonatomic)NSOperationQueue * operaQue;
@property (assign, nonatomic) BOOL isPause;

@property (weak, nonatomic) IBOutlet UILabel *testLabelX;
@property (weak, nonatomic) IBOutlet UILabel *testLabelY;

@property (assign, nonatomic) CGFloat h_imageView_w;
@property (assign, nonatomic) CGFloat v_imageView_h;
@property (assign, nonatomic) CGFloat h_ball_w;
@property (assign, nonatomic) CGFloat v_ball_h;

@property (assign, nonatomic) BOOL changeImage_x;
@property (assign, nonatomic) BOOL changeImage_y;

@property (assign, nonatomic) int lockTimes;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.motionManager = [[CMMotionManager alloc]init];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting"] style:UIBarButtonItemStylePlain target:self action:@selector(settingBtnClick)];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UIImageView * barImageView = self.navigationController.navigationBar.subviews.firstObject;
    barImageView.alpha = 0;
    
    if ([self needsShowAdView]) {
        [[NPCommonConfig shareInstance] initAdvertise];
        NPInterstitialButton *interstitialButton = [NPInterstitialButton buttonWithType:NPInterstitialButtonTypeIcon viewController:self];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:interstitialButton];
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.h_ball_ImageView == nil) {
        CGFloat W = self.h_ImageView.bounds.size.height;
        CGFloat H = W;
        UIImageView * h_ball_imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, W, H)];
        [self.h_ImageView addSubview:h_ball_imageView];
        h_ball_imageView.image = [UIImage imageNamed:@"h_ball"];
        h_ball_imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.h_ball_ImageView = h_ball_imageView;
        h_ball_imageView.center = CGPointMake(self.h_ImageView.bounds.size.width/2, self.h_ImageView.bounds.size.height/2);
        self.h_imageView_w  = self.h_ImageView.bounds.size.width;
        self.h_ball_w = W;
        UIImageView * leftLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, W-4)];
        [self.h_ImageView addSubview:leftLine];
        leftLine.image = [UIImage imageNamed:@"line-left"];
        leftLine.contentMode = UIViewContentModeScaleAspectFit;
        leftLine.center = CGPointMake(self.h_ImageView.bounds.size.width/2-W/2, self.h_ImageView.bounds.size.height/2);
        
        UIImageView * rightLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, W-4)];
        [self.h_ImageView addSubview:rightLine];
        rightLine.image = [UIImage imageNamed:@"line-right"];
        rightLine.contentMode = UIViewContentModeScaleAspectFit;
        rightLine.center = CGPointMake(self.h_ImageView.bounds.size.width/2+W/2, self.h_ImageView.bounds.size.height/2);
        
    }
    if (self.v_ball_ImageView == nil) {
        CGFloat W = self.v_ImageView.bounds.size.width;
        CGFloat H = W;
        UIImageView * v_ball_imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, W, H)];
        v_ball_imageView.image = [UIImage imageNamed:@"v_ball"];
        v_ball_imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.v_ImageView addSubview:v_ball_imageView];
        self.v_ball_ImageView = v_ball_imageView;
        v_ball_imageView.center  = CGPointMake(self.v_ImageView.bounds.size.width/2, self.v_ImageView.bounds.size.height/2);
        
        self.v_imageView_h  = self.v_ImageView.bounds.size.height;
        self.v_ball_h = H;
        
        UIImageView * upLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, W-4, 20)];
        [self.v_ImageView addSubview:upLine];
        upLine.image = [UIImage imageNamed:@"line-up"];
        upLine.contentMode = UIViewContentModeScaleAspectFit;
        upLine.center = CGPointMake(self.v_ImageView.bounds.size.width/2, self.v_ImageView.bounds.size.height/2-W/2);
        
        UIImageView * downLine = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, W-4, 20)];
        [self.v_ImageView addSubview:downLine];
        downLine.image = [UIImage imageNamed:@"line-down"];
        downLine.contentMode = UIViewContentModeScaleAspectFit;
        downLine.center = CGPointMake(self.v_ImageView.bounds.size.width/2, self.v_ImageView.bounds.size.height/2+W/2);
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.stopBtn setImage:[UIImage imageNamed:@"hold_normal2"] forState:UIControlStateNormal];
    [self startDeviceMotion];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.stopBtn setImage:[UIImage imageNamed:@"hold_pressed2"] forState:UIControlStateNormal];
    [self stopDeviceMotion];
}
-(NSOperationQueue *)operaQue{
    if (_operaQue == nil) {
        _operaQue = [[NSOperationQueue alloc]init];
    }
    return _operaQue;
}

#pragma mark - actions
- (IBAction)stopBtnClick:(UIButton *)sender {
    self.isPause = !self.isPause;
    self.lockTimes ++;
    if (self.isPause) {
        [sender setImage:[UIImage imageNamed:@"hold_pressed2"] forState:UIControlStateNormal];
        [self stopDeviceMotion];
    }else{
        [sender setImage:[UIImage imageNamed:@"hold_normal2"] forState:UIControlStateNormal];
        [self startDeviceMotion];
    }
    if (self.lockTimes == 4) {
        self.lockTimes = 0;
        if ([self needsShowAdView]) {
            [[NPCommonConfig shareInstance] showInterstitialAdInViewController:self];
        }
    }
}
- (void)settingBtnClick {
    CusSettingsViewController * setting = [[CusSettingsViewController alloc]init];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:setting];
    nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:nav animated:YES completion:nil];
    
}
- (void)startDeviceMotion {
    //设置采样间隔
    _motionManager.deviceMotionUpdateInterval = 0.01;
    __weak typeof(self) weakSelf = self;
    //开始采样
    [_motionManager startDeviceMotionUpdatesToQueue:self.operaQue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        
        __block double picth_x = motion.attitude.pitch;
        __block double roll_y = motion.attitude.roll;
        __block double way1 = acos(-motion.gravity.z) * 180.0/M_PI;
        __block double way2 = atan2(motion.gravity.x, motion.gravity.y);
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if (way1 > 48) {
                if (way2 < 0)  way2 = way2 + M_PI;
                else           way2 = way2 - M_PI;
                roll_y = -way2;
            }
            [weakSelf updateUI_radiansX:picth_x radiansY:roll_y];
        }];

    }];
}

-(void)updateUI_radiansX:(double)pitch radiansY:(double)roll{
    self.testLabelX.text = [NSString stringWithFormat:@"x:%0.1f°",ABS(pitch)*180/M_PI];//ABS(pitch)*180/M_PI
    self.testLabelY.text = [NSString stringWithFormat:@"y:%0.1f°",ABS(roll)*180/M_PI];//ABS(roll)*180/M_PI
    CGPoint h_ball_center = self.h_ball_ImageView.center;
    CGPoint v_ball_center = self.v_ball_ImageView.center;
    
    //调整y方向
//    if (ABS(roll)<0.005) {
//        if (_changeImage_y == NO) {
//            self.h_ball_ImageView.image = nil;
//            _changeImage_y = YES;
//        }
//    }else{
//        if (_changeImage_y == YES) {
//            self.h_ball_ImageView.image = [UIImage imageNamed:@"h_ball2"];
//            _changeImage_y = NO;
//        }
//    }
    CGFloat h_offset = _h_imageView_w * 0.065 + _h_ball_w/2;
    if (ABS(roll)>M_PI_4) {
        if (roll<0) {
            h_ball_center.x = _h_imageView_w  - h_offset ;
        }else{
            h_ball_center.x = h_offset;
        }
    }else{
        h_ball_center.x = roll * ((2 * h_offset - _h_imageView_w) / M_PI_2)  + _h_imageView_w / 2;
    }
    
//调整x方向
//    if (ABS(pitch)<0.005) {
//        if (_changeImage_x == NO) {
//            self.v_ball_ImageView.image = nil;
//            _changeImage_x = YES;
//        }
//    }else{
//        if (_changeImage_x == YES) {
//            self.v_ball_ImageView.image = [UIImage imageNamed:@"v_ball2"];
//            _changeImage_x = NO;
//        }
//    }
    CGFloat v_offset = _v_imageView_h * 0.065 + _v_ball_h/2;
    if (ABS(pitch)>M_PI_4) {
        if (pitch<0) {
            v_ball_center.y = _v_imageView_h - v_offset;
        }else{
            v_ball_center.y = v_offset;
        }
    }else{
        v_ball_center.y = pitch * ((2 * v_offset - _v_imageView_h) / M_PI_2)  + _v_imageView_h / 2;
    }
    self.h_ball_ImageView.center = h_ball_center;
    self.v_ball_ImageView.center = v_ball_center;
}
- (void)stopDeviceMotion {
    [_motionManager stopDeviceMotionUpdates];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
