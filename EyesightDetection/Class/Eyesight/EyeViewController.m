//
//  EyeViewController.m
//  EyesightDetection
//
//  Created by 何少博 on 16/9/27.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//




#import "EyeViewController.h"
#import <sys/utsname.h>
#import "NPCommonConfig.h"
#import "Masonry.h"
#import "Ruler.h"
#import "DXPopover.h"
#import "PopTableViewCell.h"
#import "UIColor+x.h"
#define PointPerCmIpadMini2 64.f
#define PointPerCmIpad 52.f
// 每英寸多少个点 6+
#define PointPerCmPlus  61.f
#define RulerPointPerCm 163/2.54


#define  WIDTH  [UIScreen mainScreen].bounds.size.width
#define  HEIGHT  [UIScreen mainScreen].bounds.size.height

#define  ruleHeight 50
#define distanceBtnHeiht 35
#define  optionViewHeight 130 // 5+50+5+35+5=100
#define  Space 15
//static CGFloat randomFloatBetweenLowAndHigh(CGFloat low, CGFloat high) {
//    CGFloat diff = high - low;
//    return (((CGFloat)rand() / RAND_MAX) * diff) + low;
//}
static NSString *cellId = @"cellIdentifier";
@interface EyeViewController ()<RulerDelegate,UITableViewDataSource, UITableViewDelegate> {
    CGFloat _popoverWidth;
}


@property (weak,nonatomic)UIView * imageContentView;
@property (weak,nonatomic)UIView * optionsContentView;
@property (weak,nonatomic)UIImageView* imageView;
@property (weak,nonatomic)UILabel * leftEyeLabel;
@property (weak,nonatomic)UILabel * rightEyeLabel;
@property (weak,nonatomic)UIButton * disChooseBtn;
@property (weak,nonatomic)UIButton * leftEyeBtn;
@property (weak,nonatomic)UIButton * rightEyeBtn;
@property (weak,nonatomic)Ruler * ruler;
@property (nonatomic, strong) DXPopover *popover;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *configs;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, assign) int shili;
@property (nonatomic,assign) int viewTimes;
@property (nonatomic, assign) BOOL is_5;
@property (nonatomic, assign) BOOL is_right;
@property (nonatomic, assign) BOOL is_openYao;
@end

@implementation EyeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.is_openYao = [[NSUserDefaults standardUserDefaults]boolForKey:YaoYiYao];
    NSString * disStr = [[NSUserDefaults standardUserDefaults]objectForKey:TestDistance];
    self.distance = [self distanceChangeDetail:disStr];
    NSString * shilitableStyle = [[NSUserDefaults standardUserDefaults]objectForKey:ShiLiTableStyle];
    if (![shilitableStyle isEqualToString:@"1.0"]) {
        _is_5 = YES;
    }
    if (_is_5) {
        self.shili = [self shiliQuZheng:4.0];
    }else{
        self.shili = [self shiliQuZheng:0.1];
    }
    self.view.backgroundColor = [UIColor blackColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [[NPCommonConfig shareInstance]initAdvertise];
    self.navigationItem.title = NSLocalizedString(@"eyesight test", @"Vision detection");
    [self chuShiHuaNav];
    [self chuShiHua_UI];
    [self addObserver:self forKeyPath:@"distance" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:@"shili" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    NSNotificationCenter * notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(shiLiTableStyleChange:) name:ShiLiTableStyleChanged object:nil];
    [notification addObserver:self selector:@selector(yaoYiYaoOpenChange:) name:YaoYiYao object:nil];
    self.navigationController.navigationBar.barTintColor = color_2bc083;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.view.backgroundColor = color_f2f2f2;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.viewTimes = 0;
    [self E_WeightAngel:self.shili distance:self.distance];
}

#pragma mark - 数据
-(NSArray *)configs{
    if (_configs == nil) {
        _configs = [NSArray arrayWithObjects:@"30cm",@"60cm",@"1.0m",@"1.5m",@"2.0m",@"2.5m", nil];
    }
    return _configs;
}
-(NSMutableArray*)shiliArray{
    NSMutableArray * array ;
    if (_is_5) {
        array = [NSMutableArray arrayWithObjects:@"4.0",@"4.1",@"4.2",@"4.3",@"4.4",@"4.5",@"4.6",@"4.7",@"4.8",@"4.9",@"5.0",@"5.1",@"5.2",@"5.3", nil];
    }else{
        array= [NSMutableArray arrayWithObjects:@"0.1",@"0.12",@"0.15",@"0.2",@"0.25",@"0.3",@"0.4",@"0.5",@"0.6",@"0.8",@"1.0",@"1.2",@"1.5",@"2.0", nil];
    }
    return array;
}
#pragma mark - 布局控件
-(void)chuShiHua_UI{
    
    UIView * imageContentView = [[UIView alloc]init];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageContentViewTap:)];
    [imageContentView addGestureRecognizer:tap];
    UIView * optionsContentView = [[UIView alloc]initWithFrame:CGRectMake(0, HEIGHT-optionViewHeight-64-44, WIDTH, optionViewHeight)];
    self.optionsContentView = optionsContentView;
    optionsContentView.backgroundColor = [UIColor whiteColor];
    //标尺
    Ruler * ruler = [[Ruler alloc]initWithFrame:CGRectMake(WIDTH/6,13,WIDTH/3*2,ruleHeight)];
    self.ruler = ruler;
    ruler.delegate = self;
    ruler.numberArray = [self shiliArray];
    [ruler showInView:optionsContentView];
    [self.view addSubview:optionsContentView];
    
    UILabel * leftEyeLabel = [[UILabel alloc]initWithFrame:CGRectMake(5,15+ruleHeight+15, WIDTH/6, distanceBtnHeiht)];
    self.leftEyeLabel = leftEyeLabel;
    [optionsContentView addSubview:leftEyeLabel];
    NSString* leftEyeStr = NSLocalizedString(@"left eye", @"Left eye");
    NSString * leftText = [NSString stringWithFormat:@"%@ %.2f",leftEyeStr,0.1];
    if (_is_5) {
        leftText = [NSString stringWithFormat:@"%@ %.1f",leftEyeStr,4.0];
    }
    leftEyeLabel.text = leftText;
    leftEyeLabel.textAlignment = NSTextAlignmentCenter;
    leftEyeLabel.numberOfLines = 1;
    leftEyeLabel.adjustsFontSizeToFitWidth = YES;
    UILabel * rightEyeLabel = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH/6*5-5,15+ruleHeight+15, WIDTH/6, distanceBtnHeiht)];
    self.rightEyeLabel = rightEyeLabel;
    [optionsContentView addSubview:rightEyeLabel];
    NSString * rightnEyeStr = NSLocalizedString(@"right eye", @"Right eye");
    NSString * rightText = [NSString stringWithFormat:@"%@ %.2f",rightnEyeStr,0.1];;
    if (_is_5) {
        rightText = [NSString stringWithFormat:@"%@ %.1f",rightnEyeStr,4.0];
    }
    rightEyeLabel.text = rightText;
    rightEyeLabel.textAlignment = NSTextAlignmentCenter;
    rightEyeLabel.numberOfLines = 1;
    rightEyeLabel.adjustsFontSizeToFitWidth = YES;
    
    UIButton * disChooseBtn = [[UIButton alloc]initWithFrame:CGRectMake(WIDTH/6,15+ruleHeight+15,WIDTH/3*2,distanceBtnHeiht)];
    self.disChooseBtn = disChooseBtn;
    [optionsContentView addSubview:disChooseBtn];
    [disChooseBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    NSString * title = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Test distance", @"Test distance"),[[NSUserDefaults standardUserDefaults]objectForKey:TestDistance]];
    [disChooseBtn setTitle:title forState:UIControlStateNormal];
    [disChooseBtn addTarget:self
                 action:@selector(showPopover)
       forControlEvents:UIControlEventTouchUpInside];
    //    E的父视图
    self.imageContentView = imageContentView;
    [self.view addSubview:imageContentView];
    imageContentView.backgroundColor = [UIColor whiteColor];
    [imageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.topMargin.equalTo(29);
        make.leftMargin.equalTo(15);
        make.rightMargin.equalTo(-15);
        make.bottomMargin.equalTo(self.optionsContentView.top).offset(-29);
    }];
    UIImageView * imageView = [[UIImageView alloc]init];
    //E的ImageView
    self.imageView = imageView;
    imageView.image = [UIImage imageNamed:@"left_E"];
    [imageContentView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@1);
        make.height.equalTo(@1);
        make.center.equalTo(imageContentView);
    }];
    
    //配置popView
    UITableView *blueView = [[UITableView alloc] init];
    blueView.frame = CGRectMake(0, 0, _popoverWidth, HEIGHT/4);
    blueView.dataSource = self;
    blueView.delegate = self;
    self.tableView = blueView;
    [self.tableView registerClass:[PopTableViewCell class] forCellReuseIdentifier:cellId];
    [self resetPopover];
}

-(void)chuShiHuaNav{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    NSString* leftEyeStr = NSLocalizedString(@"left eye", @"Left eye");
    NSString * rightnEyeStr = NSLocalizedString(@"right eye", @"Right eye");
    UIButton * leftEyeBtn = [[UIButton alloc]initWithFrame:CGRectZero];
    self.leftEyeBtn = leftEyeBtn;
    [leftEyeBtn setTitle:leftEyeStr forState:UIControlStateNormal];
    [leftEyeBtn setTitleColor:color_208a5f forState:UIControlStateNormal];
    [leftEyeBtn sizeToFit];
    [leftEyeBtn addTarget:self action:@selector(leftEyeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftEyeBtn];
    UIButton * rigghtEyeBtn = [[UIButton alloc]initWithFrame:CGRectZero];
    self.rightEyeBtn = rigghtEyeBtn;
    
    [rigghtEyeBtn setTitle:rightnEyeStr forState:UIControlStateNormal];
    [rigghtEyeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rigghtEyeBtn sizeToFit];
    [rigghtEyeBtn addTarget:self action:@selector(rightEyeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    NSMutableArray * itemArray = [NSMutableArray array];
    UIBarButtonItem * rightEyeItem = [[UIBarButtonItem alloc]initWithCustomView:rigghtEyeBtn];
    [itemArray addObject:rightEyeItem];
    if ([[NPCommonConfig shareInstance]shouldShowAdvertise]) {
        self.interstitialButton =[NPInterstitialButton buttonWithType:NPInterstitialButtonTypeIcon viewController:self];
        [itemArray addObject: [[UIBarButtonItem alloc]initWithCustomView:self.interstitialButton]];
    }
    self.navigationItem.rightBarButtonItems = itemArray;
}

#pragma mark - popview方法
- (void)resetPopover{
    self.popover = [DXPopover new];
    _popoverWidth = WIDTH/3;
}

- (void)showPopover {
    [self updateTableViewFrame];
    CGFloat y = self.optionsContentView.frame.origin.y + 10 + ruleHeight + 15;
    CGPoint startPoint = CGPointMake(WIDTH/2,y);
    [self.popover showAtPoint:startPoint
               popoverPostion:DXPopoverPositionUp
              withContentView:self.tableView
                       inView:self.view];
   
    
    __weak typeof(self) weakSelf = self;
    self.popover.didDismissHandler = ^{
        [weakSelf bounceTargetView:weakSelf.disChooseBtn];
    };
}

- (void)bounceTargetView:(UIView *)targetView {
    targetView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [UIView animateWithDuration:0.5
                          delay:0.0
         usingSpringWithDamping:0.3
          initialSpringVelocity:5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         targetView.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];
}

- (void)updateTableViewFrame {
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size.width = _popoverWidth;
    self.tableView.frame = tableViewFrame;
    self.popover.contentInset = UIEdgeInsetsZero;
    self.popover.backgroundColor = [UIColor whiteColor];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.configs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[PopTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellId];
    }
    cell.text = self.configs[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * title = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Test distance", @"Test distance"),self.configs[indexPath.row]];
    [_disChooseBtn setTitle:title forState:UIControlStateNormal];
    [self.popover dismiss];
    NSString * disString = self.configs[indexPath.row];
    self.distance = [self distanceChangeDetail:disString];
}

-(CGFloat)distanceChangeDetail:(NSString*)disString{
    CGFloat distance;
//    @"30cm",@"60cm",@"1.0m",@"1.5m",@"2.0m",@"2.5m",
    if ([disString isEqualToString:@"30cm"]) {
        distance = 0.3;
    }
    else if ([disString isEqualToString:@"60cm"]){
        distance = 0.6;
    }
    else if ([disString isEqualToString:@"1.0m"]){
        distance = 1.0;
    }
    else if ([disString isEqualToString:@"1.5m"]){
        distance = 1.5;
    }
    else if ([disString isEqualToString:@"2.0m"]){
        distance = 2.0;
    }
    else if ([disString isEqualToString:@"2.5m"]){
        distance = 2.5;
    }
    [[NSUserDefaults standardUserDefaults]setObject:disString forKey:TestDistance];
    [[NSUserDefaults standardUserDefaults]synchronize];
    return distance;
}
#pragma mark - actioins

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if ([self lockYaoYiYao]) return;
    if (_is_openYao) {
        [_ruler nextItem];
    }
}
-(BOOL)lockYaoYiYao{
    BOOL  lock = NO;
    BOOL pinglun = [NPCommonConfig shareInstance].isAnyVersionRated;
    BOOL shangxian = [NPCommonConfig shareInstance].isCurrentVersionOnline;
    if (pinglun == NO && shangxian == YES) {
        lock = YES;
    }
    return lock;
}
-(void)imageContentViewTap:(UIGestureRecognizer *)sender{
    [UIView animateWithDuration:0.3 animations:^{
       [_ruler nextItem];
    }];
}

-(void)leftEyeBtnClick:(UIButton*)sender{
    [sender setTitleColor:color_208a5f forState:UIControlStateNormal];
    [self.rightEyeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _is_right = NO;
    [self bounceTargetView:self.leftEyeLabel];
}

-(void)rightEyeBtnClick:(UIButton*)sender{
    [sender setTitleColor:color_208a5f forState:UIControlStateNormal];
    [self.leftEyeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _is_right = YES;
    [self bounceTargetView:self.rightEyeLabel];
}
#pragma mark - E的宽度换算
//每厘米多少个点
-(float)perCmForPoint{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * strModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
//    NSLog(@"%@",strModel);
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"DeviceModelDPIMap" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
//    NSLog(@"%d", [[data objectForKey:strModel][@"ppi"] intValue]);//直接打印数据。
    
    NSInteger dpiInteger = [[data objectForKey:strModel][@"ppi"] intValue];
    float pointPerCm;
    
    pointPerCm = (float)dpiInteger/[UIScreen mainScreen].scale/2.54;
    
    //    float h = [UIScreen mainScreen].nativeBounds.size.height;
    if ([[data objectForKey:strModel][@"ppi"] intValue] == 401) {
        pointPerCm = PointPerCmPlus;
    } else if ([data objectForKey:strModel][@"productName"]  == nil){
        pointPerCm = PointPerCmPlus;
        //        pointPerCm = 326.0/[UIScreen mainScreen].scale/2.54;
    } else {
        // 一定要注意释放问题
        pointPerCm = (float)dpiInteger/[UIScreen mainScreen].scale/2.54;
        //                pointPerCm = 326.0/[UIScreen mainScreen].scale/2.54;=
    }
    return pointPerCm;
}
//当前视力与距离下的E的大小
-(void)E_WeightAngel:(int)shili distance:(CGFloat)distance{
    //将视力转换为视角
    CGFloat angle = [self shili:shili];
    //E的实际宽度换算为厘米
    CGFloat w = tan(angle)*distance*1000;
    //E在屏幕上的点宽
    w  = w * [self perCmForPoint];
    LOG(@"w=%f",w);
    //更新约束
    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(w);
        make.height.equalTo(w);
        make.center.equalTo(self.imageContentView);
    }];
    //随机变换方向
    int ori = arc4random() % 4;
    UIImage *image;
    switch (ori) {
        case 0: image = [UIImage imageNamed:@"left_E"]; break;
        case 1: image = [UIImage imageNamed:@"up_E"]; break;
        case 2: image = [UIImage imageNamed:@"right_E"]; break;
        case 3: image = [UIImage imageNamed:@"down_E"]; break;
        default: break;
    }
    self.imageView.image = image;
    [self viewTimesshowInterstitialAd];
}
-(void)viewTimesshowInterstitialAd{
    self.viewTimes ++;
    if (self.viewTimes % 9  == 8) {
        if ([[NPCommonConfig shareInstance]shouldShowAdvertise]) {
            [[NPCommonConfig shareInstance]showFullScreenAdORNativeAdForController:self];
        }
    }
}
//将视力转换为视角
-(CGFloat)shili:(int)shili{
    CGFloat angle;
    if (_is_5) {
        switch (shili) {
            case 40 : angle = 10.00; break;//4.0
            case 41 : angle = 7.943; break;//4.1
            case 42 : angle = 6.310; break;//4.2
            case 43 : angle = 5.012; break;//4.3
            case 44 : angle = 3.981; break;//4.4
            case 45 : angle = 3.162; break;//4.5
            case 46 : angle = 2.512; break;//4.6
            case 47 : angle = 1.995; break;//4.7
            case 48 : angle = 1.585; break;//4.8
            case 49 : angle = 1.259; break;//4.9
            case 50 : angle = 1.000; break;//5.0
            case 51 : angle = 0.794; break;//5.1
            case 52 : angle = 0.631; break;//5.2
            case 53 : angle = 0.501; break;//5.3
            default: break;
        }
    }else{
        switch (shili) {
            case 10 : angle = 10.00; break;//4.0
            case 12 : angle = 7.943; break;//4.1
            case 15 : angle = 6.310; break;//4.2
            case 20 : angle = 5.012; break;//4.3
            case 25 : angle = 3.981; break;//4.4
            case 30 : angle = 3.162; break;//4.5
            case 40 : angle = 2.512; break;//4.6
            case 50 : angle = 1.995; break;//4.7
            case 60 : angle = 1.585; break;//4.8
            case 80 : angle = 1.259; break;//4.9
            case 100: angle = 1.000; break;//5.0
            case 120: angle = 0.794; break;//5.1
            case 150: angle = 0.631; break;//5.2
            case 200: angle = 0.501; break;//5.3
            default: break;
        }
    }
    //换算为弧度
    angle = angle*1.0/60*M_PI/180/2;
    return angle;
}
#pragma mark - rulerdelegate

-(void)rulerDidDrag:(CGFloat)rulerValue{
    NSString* leftEyeStr = NSLocalizedString(@"left eye", @"Left eye");
    NSString * rightnEyeStr = NSLocalizedString(@"right eye", @"Right eye");
    LOG(@"%g",rulerValue);
    if (_is_right) {
        if (_is_5) {
            _rightEyeLabel.text = [NSString stringWithFormat:@"%@ %.1f",rightnEyeStr,rulerValue];
        }else{
            _rightEyeLabel.text = [NSString stringWithFormat:@"%@ %.2f",rightnEyeStr,rulerValue];;
        }
    }else{
        if (_is_5) {
            _leftEyeLabel.text = [NSString stringWithFormat:@"%@ %.1f",leftEyeStr,rulerValue];
        }else{
            _leftEyeLabel.text = [NSString stringWithFormat:@"%@ %.2f",leftEyeStr,rulerValue];;
        }
    }
    self.shili = [self shiliQuZheng:rulerValue];
}
-(int)shiliQuZheng:(CGFloat)shulif{
    int shili;
    if (_is_5) {
        //保留后1位四舍五入
        shulif = shulif + 0.05;
        shili = shulif * 10;
    }else{
        //保留后两位四舍五入
        shulif = shulif + 0.005;
        shili = shulif * 100;
    }
    return shili;
}
#pragma mark - 横幅广告
//横幅广告刷新
-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    //更新UI
    if ([self needsShowAdView]) {
        CGRect frame = self.optionsContentView.frame;
        CGFloat y ;
        if (IS_OS_IPAD) {
            y = HEIGHT-optionViewHeight - 64 - 44 - 90;
        }else{
            y = HEIGHT-optionViewHeight - 64 - 44 - 50;
        }
        if (frame.origin.y == y) return;
        frame.origin.y = y;
        [UIView animateWithDuration:0.5 animations:^{
         self.optionsContentView.frame = frame;
        }];
    }
}
//移除广告通知
- (void)removeAdNotification:(NSNotification *)notification{
    [super removeAdNotification:notification];
    CGRect frame = self.optionsContentView.frame;
    frame.origin.y = HEIGHT-optionViewHeight - 64 - 44;
    [UIView animateWithDuration:0.5 animations:^{
        self.optionsContentView.frame = frame;
    }];

}
#pragma mark - KVO
-(void)shiLiTableStyleChange:(NSNotification*)notification{
    NSString * style = [notification.userInfo objectForKey:@"info"];
    BOOL tempIs_5;
    if ([style isEqualToString:@"1.0"]) {
        tempIs_5 = NO;
    }else{
        tempIs_5 = YES;
    }
    if (_is_5 == tempIs_5) return;
    _is_5 = tempIs_5;
    if (_is_5) {
        self.shili = [self shiliQuZheng:4.0];
    }else{
        self.shili = [self shiliQuZheng:0.1];
    }
    CGRect frame = self.ruler.frame;
    [self.ruler removeFromSuperview];
    Ruler * ruler = [[Ruler alloc]initWithFrame:frame];
    self.ruler = ruler;
    ruler.delegate = self;
    ruler.numberArray = [self shiliArray];
    [ruler showInView:_optionsContentView];
    NSString* leftEyeStr = NSLocalizedString(@"left eye", @"Left eye");
    NSString * rightnEyeStr = NSLocalizedString(@"right eye", @"Right eye");
    if (_is_5) {
        _leftEyeLabel.text = [NSString stringWithFormat:@"%@ %.1f",leftEyeStr,4.0];
        _rightEyeLabel.text = [NSString stringWithFormat:@"%@ %.1f",rightnEyeStr,4.0];
    }else{
         _leftEyeLabel.text = [NSString stringWithFormat:@"%@ %.2f",leftEyeStr,0.1];
        _rightEyeLabel.text = [NSString stringWithFormat:@"%@ %.1f",rightnEyeStr,0.1];
    }
}
-(void)yaoYiYaoOpenChange:(NSNotification *)notic{
    NSNumber * number = [notic.userInfo objectForKey:YaoYiYao];
    _is_openYao = [number boolValue];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    [self E_WeightAngel:self.shili distance:self.distance];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self removeObserver:self forKeyPath:@"distance"];
    [self removeObserver:self forKeyPath:@"shili"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
