//
//  MainViewController.m
//  LEDBanner
//
//  Created by 何少博 on 16/6/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "MainViewController.h"

#import "FontTableViewCell.h"
#import "BannerTableViewCell.h"
#import "ScrSettingCell.h"
#import "UIView+x.h"
#import "UIColor+x.h"
#import "NSObject+x.h"
#import "CustomSettingsViewController.h"
#import "MBProgressHUD.h"
#import "NPInterstitialButton.h"
#import "NPGoProButton.h"
#import "HistoryManager.h"
@interface MainViewController ()<
    UITableViewDelegate,
    UITableViewDataSource,
    ScrsettingDelegate,
    BannerTableViewCellDelegate,
    FontTableViewCellDelegate
>

@property (weak, nonatomic) IBOutlet UIView *topView;

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UITableView *tabeleView;

@property (strong,nonatomic)HistoryManager * manager;
@property (nonatomic,assign) CGFloat ledSpeed;
@property (nonatomic,assign) CGFloat ledFrequency;
@property (nonatomic,assign) BOOL ledIsFilcker;
@property (nonatomic,assign) BOOL ledDirection;//right->YES,left->NO
@property (nonatomic,assign) BOOL adLoaded;
@property (weak ,nonatomic) UIButton * insertADBtn;
@property (weak ,nonatomic) UIButton * goProBtn;

//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottom;
@property (weak, nonatomic) IBOutlet UIView *ADContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ADContentViewHeight;

//@property (weak ,nonatomic) UIButton * fontAdsBtn;
//@property (weak ,nonatomic) UIButton * bannerAdsBtn;
@property (assign, nonatomic) BOOL isFisrt;


@end


static Boolean _isShowADSafe = YES;
static NSString * FontCell = @"FontCell";
static NSString * BannerCell = @"BannerCell";
static NSString * ScrSetCell = @"ScrSetCell";

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"LED Banner";
    self.isFisrt = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    NSDictionary * attributes = @{
                                  NSForegroundColorAttributeName:color_ffffff,
                                  NSFontAttributeName:[UIFont systemFontOfSize:17]
                                  };
    self.navigationController.navigationBar.titleTextAttributes = attributes;
    [self set_MainUI_Color];
    [self chuShiHua];
    [self addTapGestureRecognizerToView];
    [self reisterCell];
    NSMutableArray * itemAray = [NSMutableArray array];
    if ([[NPCommonConfig shareInstance] isLiteApp]) {
        // GO Pro button default size (30,30)
        NPGoProButton *goProButton = [NPGoProButton goProButton];
        self.goProBtn = goProButton;
        // NPGoProButton goProButtonWithFrame:CGRectMake(0, 0, 40, 40)]; //
        UIBarButtonItem *goProButtonItem = [[UIBarButtonItem alloc]initWithCustomView:goProButton];
        [itemAray addObject:goProButtonItem];
    };
    
    if ([self needsShowAdView]) {
        NPInterstitialButton *interstitialButton = [NPInterstitialButton buttonWithType:NPInterstitialButtonTypeIcon viewController:self];
        self.insertADBtn = interstitialButton;
        UIBarButtonItem *adIconBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:interstitialButton];
        [itemAray addObject:adIconBarButtonItem];
    }
    self.navigationItem.rightBarButtonItems = itemAray;
    //注册设备旋转的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(becommeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self addObserver:self forKeyPath:@"setTimes" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}


-(void)set_MainUI_Color{
    self.navigationController.navigationBar.tintColor = color_ffffff;
    self.navigationController.navigationBar.barTintColor = color_131a20;
    self.view.backgroundColor = color_000000;
    self.ADContentView.backgroundColor = color_131a20;
    self.topView.backgroundColor = color_131a20;
    self.textField.backgroundColor = color_26303c;
    self.startButton.backgroundColor = color_40d0d9;
    self.startButton.layer.cornerRadius = 8;
    self.startButton.layer.masksToBounds = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting"] style:UIBarButtonItemStyleDone target:self action:@selector(jumpSetting)];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.view.hidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.tabeleView reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelecedBtnFont object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelecedBtnBanner object:nil];
    if (self.manager == nil) {
        self.manager = [[HistoryManager alloc]initWithSize:self.textField.frame.size];
    }
    [self bounceAnimation:_insertADBtn];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf bounceAnimation:_goProBtn];
    });
    if (self.isFisrt != YES) {
        [[self class] showADRandom:3 forController:self];
    }
    self.isFisrt = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.view.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    [self.manager dismissHistoryView];
}

-(void)chuShiHua{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    NSString * textString = [userDefault objectForKey:kCacheTextString];
    textString = (textString!=nil)?textString:NSLocalizedString(@"hello",@"hello");
    self.textField.text = textString;
    
    self.textField.returnKeyType = UIReturnKeyDone;
    [self.textField addTarget:self action:@selector(inputDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.textField addTarget:self action:@selector(showHistory) forControlEvents:UIControlEventEditingDidBegin|UIControlEventTouchDown];
    
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    NSData * data = [userDefault objectForKey:kSaveColorData];
    NSMutableDictionary * saveColorDic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    UIColor * backGroundColor = [saveColorDic objectForKey:kBlackGroundColor];
    backGroundColor = (backGroundColor!=nil)?backGroundColor:[UIColor darkGrayColor];
    
    self.textField.backgroundColor = backGroundColor;
    
    UIColor * textColor = [saveColorDic objectForKey:kTextColor];
    textColor = (textColor!=nil)?textColor:color_ffffff;
    self.textField.textColor = textColor;
    
    NSString * textFontName = [userDefault objectForKey:kTextFontName];
    UIFont * textFont ;
    if ([textFontName isEqualToString:@"systemFont"]||textFontName == nil) {
        textFont = [UIFont systemFontOfSize:16];
    }else{
        textFont = [UIFont fontWithName:textFontName size:16];
    }
    self.textField.font = textFont;
    
    self.tabeleView.delegate = self;
    self.tabeleView.dataSource = self;
    self.tabeleView.backgroundColor = [UIColor clearColor];
    self.tabeleView.separatorColor = color_303844;
    
    self.onColor = textColor;
    self.offColor = backGroundColor;
    self.showModel = [userDefault integerForKey:kShowModel];// NSShowModel32;
    self.dotModel = [userDefault integerForKey:kDotModel];//NSDotModelSquare;
    self.font = textFont;
    
    self.ledDirection = [userDefault boolForKey:kLedDirection];
    self.ledIsFilcker = [userDefault boolForKey:kLedIsFilcker];
    self.ledSpeed = [userDefault floatForKey:kLedSpeed];
    self.ledFrequency = [userDefault floatForKey:kLedFrequency];
    self.isMulticolour = [userDefault boolForKey:kIsMulticolour];
    
    [userDefault synchronize];
}

-(void)reisterCell{
    [self.tabeleView registerNib:[UINib nibWithNibName:@"FontTableViewCell" bundle:nil] forCellReuseIdentifier:FontCell];
    [self.tabeleView registerNib:[UINib nibWithNibName:@"BannerTableViewCell" bundle:nil] forCellReuseIdentifier:BannerCell];
    [self.tabeleView registerNib:[UINib nibWithNibName:@"ScrSettingCell" bundle:nil] forCellReuseIdentifier:ScrSetCell];
}

#pragma mark actions

-(void)inputDone:(UITextField*)textField{
    NSLog(@"------%@",textField.text);
    [self.manager dismissHistoryView];
    [self.textField resignFirstResponder];
}
-(void)showHistory{
    CGFloat x = self.topView.frame.origin.x;
    CGFloat y = self.topView.frame.origin.y + self.topView.frame.size.height;
    [self.manager showAtPoint:CGPointMake(x, y) size:self.textField.frame.size inView:self.view];
    [self.manager historyStringDidSelecd:^(NSString *historyString) {
        _textField.text = historyString;
        [_textField resignFirstResponder];
    }];
}


- (IBAction)startBtnClick:(UIButton *)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        LEDShowViewController * ledVC = [[LEDShowViewController alloc]init];
        ledVC.showModel = self.showModel;
        ledVC.dotModel = self.dotModel;
        ledVC.showString = _textField.text;
        ledVC.font = self.font;
        ledVC.isMulticolour = self.isMulticolour;
        ledVC.onColor = self.onColor;
        ledVC.offColor = self.offColor;
        ledVC.ledFrequency = self.ledFrequency;
        ledVC.ledSpeed = self.ledSpeed;
        ledVC.ledIsFilcker = self.ledIsFilcker;
        ledVC.ledDirection = self.ledDirection;
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self presentViewController:ledVC animated:YES completion:nil];
        });
    });
    //数据持久化
     [self.manager addUserTextStringToUserDefault:_textField.text];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString * textString = [userDefault objectForKey:kCacheTextString];
    if (![textString isEqualToString:self.textField.text]) {
        [userDefault setObject:self.textField.text forKey:kCacheTextString];
    }
    [userDefault synchronize];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -UITableViewDelegate,UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell;
    switch (indexPath.section) {
        case 0:{
            FontTableViewCell * Fcell = [tableView dequeueReusableCellWithIdentifier:FontCell];
            Fcell.delegate = self;
            
            cell = Fcell;
        }
            break;
        case 1:{
            BannerTableViewCell* Bcell = [tableView dequeueReusableCellWithIdentifier:BannerCell];
            Bcell.delegate = self;
            
            cell = Bcell;
        }
            break;
        case 2:{
            ScrSettingCell* Scell = [tableView dequeueReusableCellWithIdentifier:ScrSetCell];
            Scell.delegate = self;
            cell = Scell;
        }
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight ];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) return 216;
    else if (indexPath.section == 1) return 268;
    return 292;
}
//-----------------------------
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 24;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 24, 100)];
    header.backgroundColor = [UIColor blackColor];
    return header;
}

- (void)removeAdNotification:(NSNotification *)notification{
    [super removeAdNotification:notification];
    self.navigationItem.rightBarButtonItems = nil;
    [self.tabeleView reloadData];
    self.ADContentViewHeight.constant = 0;
}
- (void)advertiseInterstitialNotification:(NSNotification *)notification{
    [super advertiseInterstitialNotification:notification];
    NSNumber *enableInterstitial = notification.object;
    if (enableInterstitial.boolValue) {
        
    }else{
        
    }
}

-(BOOL)needLoadBannerAdView{
    return NO;
}
-(BOOL)needLoadNativeAdView{
    return YES;
}

-(void)showNativeAdView:(UIView *)nativeAdView{
    [super showNativeAdView:nativeAdView];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.ADContentViewHeight.constant = nativeAdView.bounds.size.height;
        [self.ADContentView addSubview:nativeAdView];
    });
    
    
//    self.tableViewBottom.constant = nativeAdView.bounds.size.height;
}

//-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
//    [super setAdEdgeInsets:contentInsets];
//    self.tableViewBottom.constant = contentInsets.bottom;
//    
//}

//_________________________

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}
-(void)adsButtomItemClick{

    if ([self needsShowAdView]) {
        [[NPCommonConfig shareInstance] showFullScreenAdWithNativeAdAlertViewForController:self];
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
}

//#pragma mark -
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.tabeleView reloadData];
}
//-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
//    
//}
//设置界面
-(void)jumpSetting
{
    CustomSettingsViewController *vc = [[CustomSettingsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}
//添加手势，点击其他位置退出键盘
-(void)addTapGestureRecognizerToView{
    [self.tabeleView addTapGestureRecognizer:self forAction:@selector(resignKeyBord:)];
}
-(void)resignKeyBord:(UITapGestureRecognizer*)recognizer{
    [self.textField resignFirstResponder];
    [self.manager dismissHistoryView];
}

/**
 *  FontTableViewCell和BannerTableViewCell用的是属性
    ScrSettingCell 使用的代理
 */
#pragma mark - FontTableViewCellDelegate
- (void)setFontDefaultChooseColorClick:(UIColor *)color{
    self.onColor = color;
    self.textField.textColor = color;
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSData * dataOld = [userDefault objectForKey:kSaveColorData];
    NSMutableDictionary * saveColorDic = [NSKeyedUnarchiver unarchiveObjectWithData:dataOld];
    //文字颜色
    [saveColorDic setValue:color forKey:kTextColor];
    //将dic转换成为NSData类型
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:saveColorDic];
    [userDefault setObject:data forKey:kSaveColorData];
    [userDefault synchronize];

}
- (void)setMulticolourClick:(BOOL)isMulticolour{
    self.isMulticolour = isMulticolour;
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:isMulticolour forKey:kIsMulticolour];
    [userDefault synchronize];

    
}
- (void)setFontCustomColorBtnClick:(UIColor *)color{
    self.onColor = color;
    self.textField.textColor = color;
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSData * dataOld = [userDefault objectForKey:kSaveColorData];
    NSMutableDictionary * saveColorDic = [NSKeyedUnarchiver unarchiveObjectWithData:dataOld];
    //文字颜色
    [saveColorDic setValue:color forKey:kCustomBtnFontColor];
    [saveColorDic setValue:color forKey:kTextColor];
    //将dic转换成为NSData类型
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:saveColorDic];
    [userDefault setObject:data forKey:kSaveColorData];
    [userDefault synchronize];

}
- (void)fontAdsBtnClick{
    if ([self needsShowAdView]) {
        [[NPCommonConfig shareInstance] showFullScreenAdWithNativeAdAlertViewForController:self];
    }
}
- (void)setFontChoose:(NSString *)fontName{
    
    UIFont * font = [UIFont fontWithName:fontName size:16];
    self.font = font;
    self.textField.font = font;
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:fontName forKey:kTextFontName];
    [userDefault synchronize];

}

#pragma mark - BannerTableViewCellDelegate

/* 默认提供颜色的设置 */
- (void)setDefaultChooseColorClick:(UIColor *)color {
    self.offColor = color;
    self.textField.backgroundColor = color;
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSData * dataOld = [userDefault objectForKey:kSaveColorData];
    NSMutableDictionary * saveColorDic = [NSKeyedUnarchiver unarchiveObjectWithData:dataOld];
    [saveColorDic setValue:color forKey:kBlackGroundColor];
    //将dic转换成为NSData类型
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:saveColorDic];
    [userDefault setObject:data forKey:kSaveColorData];
    [userDefault synchronize];

}
/* 形状选择 */
- (void)setXingzhuangChange:(NSDotModel)dotModel{
    self.dotModel = dotModel;
    [[NSUserDefaults standardUserDefaults]setInteger:dotModel forKey:kDotModel];
    [[NSUserDefaults standardUserDefaults]synchronize];

}
/* 清晰度选择 */
- (void)setQingxiduChange:(NSShowModel)showModel{
    self.showModel = showModel;
    [[NSUserDefaults standardUserDefaults]setInteger:showModel forKey:kShowModel];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
/*  */
- (void)setCustomColorClick:(UIColor *)color{
    self.offColor = color;
    self.textField.backgroundColor = color;
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSData * dataOld = [userDefault objectForKey:kSaveColorData];
    NSMutableDictionary * saveColorDic = [NSKeyedUnarchiver unarchiveObjectWithData:dataOld];
    [saveColorDic setValue:color forKey:kBlackGroundColor];
    [saveColorDic setValue:color forKey:kCustomBtnBannColor];
    //将dic转换成为NSData类型
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:saveColorDic];
    [userDefault setObject:data forKey:kSaveColorData];
    [userDefault synchronize];

}

- (void)ADSBttonClick{
    if ([self needsShowAdView]) {
         [[NPCommonConfig shareInstance] showFullScreenAdWithNativeAdAlertViewForController:self];
    }
}
-(void)bounceAnimation:(UIButton *)button{
    if (button) {
        button.transform=CGAffineTransformMakeScale(0.1f, 0.1f);
        [UIView animateWithDuration:1.0f delay:0.0f usingSpringWithDamping:0.3f initialSpringVelocity:10 options:UIViewAnimationOptionCurveLinear animations:^{
            button.transform=CGAffineTransformIdentity ;
        } completion:^(BOOL finished) {
        }];
    }
}
#pragma mark - ScrSettingCelldelegate
-(void)setDirectionChange:(BOOL)direction{
    self.ledDirection = direction;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:direction forKey:kLedDirection];
    [userDefault synchronize];
}
-(void)setSpeedChange:(CGFloat)speed{
    self.ledSpeed = speed;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setFloat:speed forKey:kLedSpeed];
    [userDefault synchronize];}
-(void)setFlickerChange:(BOOL)flicker{
    self.ledIsFilcker = flicker;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setBool:flicker forKey:kLedIsFilcker];
    [userDefault synchronize];
}
-(void)setFrequencyChange:(CGFloat)frequency{
    self.ledFrequency = frequency;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setFloat:frequency forKey:kLedFrequency];
    [userDefault synchronize];
}

-(void)OrientationDidChange:(NSNotification*)notification{
    UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;
    
    switch (orient)
    {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            [self.manager dismissHistoryView];
            break;
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            break;
        default:
            break;
    }
    [self adjustAdview];
}


-(void)dealloc{
    [self removeObserver:self forKeyPath:@"setTimes"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
+(void)showADRandom:(NSInteger) random forController:(UIViewController *)controller{
    if (_isShowADSafe == NO) { return ;}
    if ([[NPCommonConfig shareInstance]shouldShowAdvertise] ) {
        if ([[NPCommonConfig shareInstance] getProbabilityFor:1 from:random]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _isShowADSafe = NO;
                [[NPCommonConfig shareInstance] showFullScreenAdWithNativeAdAlertViewForController:controller];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _isShowADSafe = YES;
                });
            });
        }
    }
}
-(void)becommeActive{
    _isShowADSafe = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _isShowADSafe = YES;
    });
}
@end
