//
//  LEDShowViewController.m
//  LED_MySelf
//
//  Created by Mac_H on 16/6/22.
//  Copyright © 2016年 何少博. All rights reserved.
//
#define CLEARCOLOR [UIColor clearColor]


#import "LEDShowViewController.h"
#import "GifShareController.h"
//#import "ColorModel.h"
#import "UIColor+x.h"
#import "singleTapLEDView.h"
#import "UIView+x.h"
#import "NSObject+x.h"
#import "MBProgressHUD.h"
#import "NPCommonConfig.h"
@interface LEDShowViewController ()<singleTapLEDViewDelegate>
@property (nonatomic,strong) LEDView * ledView;
@property (nonatomic,strong) LEDViewSecond * backgroundLEDView;
@property (nonatomic,strong) singleTapLEDView * singleTapView;
@property (nonatomic,strong) HSScanStr * dotStr;
@property (nonatomic,strong) MBProgressHUD * HUD;

@property (nonatomic,strong) NSMutableArray * dotMatrixArray;
@property (nonatomic,strong) NSMutableArray * ledViewSubViews;
@property (nonatomic,strong) NSArray * rainRowColorArray;
@property (nonatomic,strong) NSMutableString * cutString;
@property (nonatomic,strong) NSMutableArray * jieTuImagePathArray;
//led前进的定时器
@property (nonatomic,strong) NSTimer * timer;
@property (nonatomic,strong) NSTimer * Filckertimer;
@property (nonatomic,strong) NSTimer * dismissSingleTapViewtimer;;
@property (nonatomic,assign) NSTimeInterval tiemInterval;
@property (nonatomic,assign) CGRect blackGroundLEDView_oldFrame;
@property (nonatomic,assign) CGRect LEDView_oldFrame;
@property (nonatomic,assign) int speedMultiple;
@property (nonatomic,assign) int index;
@property (nonatomic,assign) BOOL isLoadingDot;
@property (nonatomic,assign) BOOL isShowOfSingleTapView;
@property (nonatomic,assign) BOOL isLandscapeOfiPad;
@property (nonatomic,assign) BOOL isLandscapeOfiPhone;
@property (nonatomic,assign) BOOL isViewAppear;
@property (nonatomic,assign) BOOL isShare;
@property (nonatomic,assign) BOOL isMakeGif;
@property (nonatomic,assign) BOOL isGetTimeInterval;
@property (nonatomic,assign) BOOL isLEDForward;
@property (nonatomic,assign) BOOL isJieTu_Ing;

@end

@implementation LEDShowViewController

-(instancetype)initShowModel:(NSShowModel) showModel offColor:(UIColor *)offColor dotModel:(NSDotModel)doeModel{
    self = [super init];
    if (self) {
        self.showModel = showModel;
        self.offColor  = offColor;
        self.dotModel  = doeModel;
        [self.ledView getLEDViewSubViews];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [UIApplication sharedApplication].statusBarHidden = YES;
    self.cutString = [NSMutableString stringWithFormat:@"%@",self.showString];
    self.view.backgroundColor = color_131a20;
    [self chuShiHuaBackgroundLEDView];
    //换算滚动速度
    [self chushihuaLEDForwardTimer];
//    CGFloat speed = self.ledSpeed * (-0.17) + 0.2;
//    if (self.showModel == NSShowModel64) speed = speed / 3;
//    _timer =  [NSTimer scheduledTimerWithTimeInterval: speed target:self selector:@selector(LEDForward:) userInfo:nil repeats:YES];
//    _timer.tolerance = 0.001;
    //换算闪烁频率
    if (self.ledIsFilcker) {
        CGFloat filcker = (1-self.ledFrequency+0.2)/2;
        _Filckertimer = [NSTimer scheduledTimerWithTimeInterval:filcker target:self selector:@selector(letLEDFlicker) userInfo:nil repeats:YES];
    }
    
    
    UITapGestureRecognizer * singleClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleClickView:)];
    [self.view addGestureRecognizer:singleClick];
    UITapGestureRecognizer * doubleClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleClickView:)];
    doubleClick.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleClick];
    [singleClick requireGestureRecognizerToFail:doubleClick];
   
    self.speedMultiple = [self getSpeedMultiple];
    
    //注册设备旋转的通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
}

#pragma mark - 初始化子视图


-(void)chuShiHuaBackgroundLEDView{
    LEDViewSecond * backgroundLEDView = [[LEDViewSecond alloc]init];
    CGRect frame = self.view.bounds;
    if (frame.size.width > frame.size.height) {
        CGFloat temp = frame.size.width;
        frame.size.width = frame.size.height;
        frame.size.height = temp;
    }

    backgroundLEDView.frame = frame;
    backgroundLEDView.offColor = self.offColor;
    backgroundLEDView.showModel = self.showModel;
    backgroundLEDView.dotModel = self.dotModel;
//    backgroundLEDView.rows = [self getRows];
    self.backgroundLEDView = backgroundLEDView;
    [self.view addSubview:backgroundLEDView];
    backgroundLEDView.userInteractionEnabled = NO;
}

-(void)chuShiHuaSingleTapLEDView{

    singleTapLEDView * single = [singleTapLEDView viewWithNib:@"singleTapLEDView" owner:nil];
    CGRect frame = CGRectMake(0,-50,self.view.size.width,50);
    single.frame = frame;
    single.delegate =self;
    self.singleTapView = single;
    self.singleTapView.hidden = YES;
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:single];
    [window bringSubviewToFront:single];
}
-(void)chushihuaLEDForwardTimer{
    if (self.timer) [self.timer invalidate];
    CGFloat speed = self.ledSpeed * (-0.17) + 0.2;
    if (self.showModel == NSShowModel64) {
        speed = speed / 4;
    }
    _timer =  [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(LEDForward:) userInfo:nil repeats:YES];
    _timer.tolerance = 0.001;
}
#pragma mark -

-(NSArray *)rainRowColorArray{
    if (!_rainRowColorArray) {
        _rainRowColorArray = [UIColor getRainbowColor];
    }
    return _rainRowColorArray;
}
-(NSMutableArray *)jieTuImagePathArray{
    if (_jieTuImagePathArray == nil) {
        _jieTuImagePathArray = [NSMutableArray array];
    }
    return _jieTuImagePathArray;
}
//加载点阵模型对象
-(HSScanStr *)dotStr{
    if (_dotStr == nil) {
        _dotStr = [[HSScanStr alloc]init];
        _dotStr.showModel = _showModel;
        _dotStr.fontColor = _onColor;
        _dotStr.offColor = _offColor;
        _dotStr.font = _font;
        _dotStr.ledDirection = _ledDirection;
    }
    return _dotStr;
}

//获取LEDView的所有子控件可以封装到LEDView内部
-(NSMutableArray *)ledViewSubViews{
    if (_ledViewSubViews.count == 0) {
        _ledViewSubViews= [_ledView getLEDViewSubViews];
    }
    return _ledViewSubViews;
}

//加载LEDView
-(LEDView *)ledView{
    
    if (_ledView == nil) {
        _ledView = [[LEDView alloc]init];
        _ledView.offColor = self.offColor;
        _ledView.showModel = self.showModel;
        _ledView.frame = [UIApplication sharedApplication].keyWindow.bounds;
        _ledView.backgroundColor = [UIColor clearColor];
        _ledView.dotModel = self.dotModel;
        _ledView.userInteractionEnabled = NO;
    }
    [self.view addSubview:_ledView];
    return _ledView;
}
//加载并重置点阵数组
-(NSArray *)dotMatrixArray{
    if (_dotMatrixArray.count == 0) {
        NSMutableString * firstshowstr = [NSMutableString stringWithString:[self cutWordString:self.cutString]];
        _dotMatrixArray = [NSMutableArray arrayWithArray:[self.dotStr getStingDotMatrix:firstshowstr]];
    }
    return _dotMatrixArray;
}

//LED向前滚动
-(void)LEDForward:(NSTimer*)timer{
    NSArray * rowsDotM = self.dotMatrixArray.firstObject;
    if (rowsDotM.count - (self.index+1)*self.speedMultiple <= 200) {
        [self performSelectorInBackground:@selector(loadDotMatrixArray) withObject:nil];
    }
    if (!self.isViewAppear) return;
    if (self.ledDirection) {
        [self setLedViews_RightToLeft_WithONColor:self.onColor andOFFColor:self.offColor];
    }else{
        [self setLedViews_LeftToRight_WithONColor:self.onColor andOFFColor:self.offColor];
    }
}

-(void)loadDotMatrixArray{
    if (self.cutString.length == 0) return;
    if (_isLoadingDot) return;
    _isLoadingDot = YES;
    
    NSMutableArray * tempDotArray = [NSMutableArray arrayWithArray:self.dotMatrixArray];
    NSString * dotWord ;
    if (self.ledDirection) {
        dotWord = [self cutWordString:self.cutString];
    }else{
        dotWord = [self.cutString substringToIndex:1];
        self.cutString = [NSMutableString stringWithString:[self.cutString substringFromIndex:1]];
    }
    NSArray * newCharMatrix = [self.dotStr getStingDotMatrix:dotWord];
    
    if (newCharMatrix== nil) return;
    NSInteger trows = tempDotArray.count;
    NSInteger nrows = newCharMatrix.count;
    //取最小值避免越界
    NSInteger rows = trows <= nrows ? trows : nrows;
    for (int i =0; i < rows; i++) {
        NSMutableArray * rowDotarray = [tempDotArray objectAtIndex:i];
        NSMutableArray * newDotarray = [newCharMatrix objectAtIndex:i];
        [rowDotarray addObjectsFromArray:newDotarray];
    }
    [self.dotMatrixArray setArray:tempDotArray];
    _isLoadingDot = NO;
}

//设置ledView的SubViews 也可以搞到LEDView里面
//从左向右的语言
-(void)setLedViews_LeftToRight_WithONColor:(UIColor *)onColor andOFFColor:(UIColor*)offColor {
    if (self.isLEDForward) return;
    self.isLEDForward = YES;
    if (self.dotMatrixArray.count == 0){
        self.index = -1;
        return;
    }
    int indexAdditional = -1;
    
    NSInteger cloum = self.ledViewSubViews.count;
    int ii ;
    int flag ;
    for (int i =0; i < cloum; i++) {
        ii = i + _speedMultiple;
        flag = -1;
        if (ii >= cloum) {
            ii = i;
            flag = 0;
            indexAdditional ++;
        }
        int totleIndex = self.index*_speedMultiple+indexAdditional;
        NSArray *columnViews1 = _ledViewSubViews[i];
        NSArray *columnViews2 = _ledViewSubViews[ii];
        UIColor * rainRowColor;
        if (_isMulticolour) {
            if (totleIndex <0) totleIndex = 0;
            rainRowColor = [self.rainRowColorArray objectAtIndex:totleIndex%7];
        }
        for (int j =0; j< _showModel; j++) {
            NSArray * rowsDotMatrix = self.dotMatrixArray[j];
            if (flag == -1) {
                UIView * view1 = columnViews1[_showModel-j-1];
                UIView * view2 = columnViews2[_showModel-j-1];
                view1.backgroundColor = [view2 backgroundColor];
            }
            if (flag == 0) {
                UIView * view1 = columnViews1[_showModel-j-1];
                if ((totleIndex >= rowsDotMatrix.count)&&(totleIndex <= rowsDotMatrix.count + cloum)) {
                    view1.backgroundColor = CLEARCOLOR;
                    view1.alpha = 0;
                }
                else if (totleIndex >= rowsDotMatrix.count + cloum) {
                    self.index = 0;
                    if (self.isShare == YES) {
                        if (self.timer)  [self.timer invalidate];
                        if (!self.isMakeGif) {
                            self.isMakeGif = YES;
                            [self makeGifAndShare];
                            
                        }
                    }
                }else{
                    if (totleIndex < rowsDotMatrix.count) {
                        NSNumber * model = [rowsDotMatrix objectAtIndex:totleIndex];
                        if (model.boolValue) {
                            if (_isMulticolour) {
                                view1.backgroundColor = rainRowColor;
                            }else{
                                view1.backgroundColor = onColor;
                                view1.alpha = 1;
                            }
                        }else{
                            view1.backgroundColor = CLEARCOLOR;
                            view1.alpha = 0;
                        }
                    }
                }
            }
        }
    }
    if ((self.isShare ==YES)&&(self.index>=cloum/2)) {
        if (self.isJieTu_Ing == NO&&self.isMakeGif==NO){
            __weak typeof (self) weakself = self;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                weakself.isJieTu_Ing = YES;
                NSString * imagePath = [GifShareController getImageWithFullViewShot:weakself.view];
                [weakself.jieTuImagePathArray addObject:imagePath];
                weakself.isJieTu_Ing = NO;
                
            });
        } 
    }
    //获取时间间隔
    if (self.tiemInterval == 0) {
        NSDate *date=[NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval timeInterval=[date timeIntervalSince1970];
        self.tiemInterval = timeInterval;
    }else{
        if (!self.isGetTimeInterval) {
            NSDate *date=[NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval timeInterval=[date timeIntervalSince1970];
            self.tiemInterval = ABS(self.tiemInterval - timeInterval);
            if (self.showModel == NSShowModel64) {
                self.tiemInterval=self.tiemInterval * 3;
            }
            self.isGetTimeInterval = YES;
        }
    }
    self.index ++;
    self.isLEDForward = NO;
}
//从右向左
-(void)setLedViews_RightToLeft_WithONColor:(UIColor *)onColor andOFFColor:(UIColor*)offColor {
    if (self.isLEDForward) return;
    self.isLEDForward = YES;
    if (self.dotMatrixArray.count == 0){
        self.index = -1;
        return;
    }
    int indexAdditional = -1;
    
    NSInteger cloum = self.ledViewSubViews.count;
    int ii ;
    int flag ;
        for (int i = cloum-1; i >=0; i--) {
            ii = i - _speedMultiple;
            flag = -1;
            if (ii < 0) {
                ii = i;
                flag = 0;
                indexAdditional ++;
            }
            int totleIndex = self.index*_speedMultiple+indexAdditional;
            NSArray *columnViews1 = _ledViewSubViews[i];
            NSArray *columnViews2 = _ledViewSubViews[ii];
            UIColor *rainRowColor;
            if (_isMulticolour) {
                if (totleIndex<0) totleIndex = 0;
                rainRowColor = [self.rainRowColorArray objectAtIndex:(totleIndex%7)];
            }
            for (int j =0; j< _showModel; j++) {
                NSArray * rowsDotMatrix = self.dotMatrixArray[_showModel-j-1];
                if (flag == -1) {
                    UIView * view1 = columnViews1[j];
                    UIView * view2 = columnViews2[j];
                    view1.backgroundColor = [view2 backgroundColor];
                }
                if (flag == 0) {
                    UIView * view1 = columnViews1[j];
                    if ((totleIndex >= rowsDotMatrix.count)&&(totleIndex <= rowsDotMatrix.count + cloum)) {
                        view1.backgroundColor = CLEARCOLOR;
                        view1.alpha = 0;
                    }
                    else if (totleIndex >= rowsDotMatrix.count + cloum) {
                        self.index = 0;
                        if (self.isShare == YES) {
                            if (self.timer)  [self.timer invalidate];
                            if (!self.isMakeGif) {
                                self.isMakeGif = YES;
                                [self makeGifAndShare];
                            }
                        }
                    }else{
                        if (totleIndex < rowsDotMatrix.count) {
                            NSNumber * model1 = [rowsDotMatrix objectAtIndex: totleIndex];
                            if (model1.boolValue) {
                                if (_isMulticolour) {
                                    view1.backgroundColor = rainRowColor;
                                }else{
                                    view1.backgroundColor = onColor;
                                    view1.alpha = 1;
                                }
                            }else{
                                view1.backgroundColor = CLEARCOLOR;
                                view1.alpha = 0;
                            }
                        }
                    }
                }
            }
        }
    if ((self.isShare ==YES)&&(self.index>=cloum/2)) {
        if (self.isJieTu_Ing == NO&&self.isMakeGif==NO){
            __weak typeof (self) weakself = self;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                weakself.isJieTu_Ing = YES;
                NSString * imagePath = [GifShareController getImageWithFullViewShot:weakself.view];
                [weakself.jieTuImagePathArray addObject:imagePath];
                weakself.isJieTu_Ing = NO;
            });
        }
    }
    //获取时间间隔
    if (self.tiemInterval == 0) {
        NSDate *date=[NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval timeInterval=[date timeIntervalSince1970];
        self.tiemInterval = timeInterval;
    }else{
        if (!self.isGetTimeInterval) {
            NSDate *date=[NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval timeInterval=[date timeIntervalSince1970];
            self.tiemInterval = ABS(self.tiemInterval - timeInterval);
            if (self.showModel == NSShowModel64) {
                self.tiemInterval=self.tiemInterval * 3;
            }
            self.isGetTimeInterval = YES;
        }
    }

    
    self.index ++;
    self.isLEDForward = NO;
}

//闪烁
-(void)letLEDFlicker{
    if (self.ledView.alpha == 0) {
        self.ledView.alpha = 1;
    }else{
        self.ledView.alpha = 0;
    }
}
//截取字符串
-(NSString *)cutWordString:(NSMutableString *)selfCutstring{
    if (selfCutstring.length == 0) return @"";
    NSRange range = [selfCutstring rangeOfString:@" "];
    NSString * subString ;
    if (range.location == NSNotFound) {
        if (selfCutstring.length>1) {
            subString = [selfCutstring substringToIndex:1];
            self.cutString = [NSMutableString stringWithString:[self.cutString substringFromIndex:1]];
        }else{
            subString =[NSString stringWithFormat:@"%@ ",[selfCutstring substringToIndex:selfCutstring.length]]  ;
            [self.cutString setString:@""];
        }
    }else{
        subString = [selfCutstring substringToIndex:range.location+1];
        self.cutString = [NSMutableString stringWithString:[self.cutString substringFromIndex:range.location+1]];
    }
    return subString;
}

//singleTapLEDView的代理fangfa
-(void)tuiChu{
    [self.singleTapView removeFromSuperview];
    [self dismissViewControllerAnimated:NO completion:^{
    }];
}
-(void)zanTing:(BOOL)isPause{
    //psuse=YES -> 暂停
    if (isPause == YES) {
        [self.timer invalidate];
        
        if ([[NPCommonConfig shareInstance] shouldShowAdvertise]) {
//            [self dismissSingleTapView];
            [[NPCommonConfig shareInstance] showNativeAdAlertViewInView:nil];
        }
    }else{
        [self chushihuaLEDForwardTimer];
    }
    if (self.dismissSingleTapViewtimer) [self.dismissSingleTapViewtimer invalidate];
    self.dismissSingleTapViewtimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(dismissSingleTapView) userInfo:nil repeats:YES];
}
-(void)fenXiang{
    self.isShare = YES;
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    for (UIView * view in self.ledView.subviews) {
        view.backgroundColor = CLEARCOLOR;
    }
    self.index = 0;
    [self.singleTapView setIsPause:NO];
    [self chushihuaLEDForwardTimer];
    self.HUD = [MBProgressHUD showHUDAddedTo:window animated:YES];
    self.HUD.backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    self.HUD.label.text = [NSString stringWithFormat:@"Gif%@",NSLocalizedString(@"making", @"Generating")];
    [self.HUD.button setTitle:NSLocalizedString(@"common.Cancel", @"Cancel") forState:UIControlStateNormal];
    [self.HUD.button addTarget:self action:@selector(cancelWork:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)cancelWork:(MBProgressHUD*)sender{
    [self.HUD hideAnimated:YES];
    NSFileManager * fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:GIF_directory error:nil];
  
    self.isShare = NO;
    self.isMakeGif = NO;
    self.isGetTimeInterval = NO;
    self.isLEDForward = NO;
    self.isJieTu_Ing = NO;
    self.index = 0;
    for (UIView * view in self.ledView.subviews) {
        view.backgroundColor = CLEARCOLOR;
    }
    [self chushihuaLEDForwardTimer];
}
//处理点击事件
-(void)singleClickView:(UITapGestureRecognizer*)Recognizer{
    
    CGRect frame = self.singleTapView.frame;
    if (!self.isShowOfSingleTapView) {
        self.singleTapView.hidden = !self.singleTapView.hidden;
        frame.origin.y += 50;
    }else{
        frame.origin.y -= 50;
    }
    [self.view bringSubviewToFront:self.singleTapView];
    [UIView animateWithDuration:0.25 animations:^{
        self.singleTapView.frame = frame;
    } completion:^(BOOL finished) {
        if (self.isShowOfSingleTapView) {
            self.singleTapView.hidden = NO;
        }else{
            self.singleTapView.hidden = YES;
        }
    }];
    self.isShowOfSingleTapView = !self.isShowOfSingleTapView;
}
-(void)doubleClickView:(UITapGestureRecognizer*)Recognizer{
    [self tuiChu];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.dismissSingleTapViewtimer) [self.dismissSingleTapViewtimer invalidate];
    self.dismissSingleTapViewtimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(dismissSingleTapView) userInfo:nil repeats:YES];
}
//隐藏单击时出来的View
-(void)dismissSingleTapView{
    
    CGRect frame = CGRectMake(0,-50,self.view.size.width,50);
    [UIView animateWithDuration:0.25 animations:^{
        self.singleTapView.frame = frame;
    } completion:^(BOOL finished) {
        self.isShowOfSingleTapView = NO;
        self.singleTapView.hidden = YES;
    }];
    if (self.dismissSingleTapViewtimer) [self.dismissSingleTapViewtimer invalidate];
}
//速度倍率选择
-(int)getSpeedMultiple{
    int speedMultople = 1;
    CGFloat speed = self.ledSpeed;
    if (self.showModel == NSShowModel64) {
        
        if (speed<=0.5)                 speedMultople = 1;
        else if (speed>0.5&&speed<0.8)  speedMultople = 2;
        else if (speed>=0.8)            speedMultople = 4;
        
    }
    else if (self.showModel == NSShowModel32){
        if      (speed<=0.4)            speedMultople = 1;
        else if (speed>0.4&&speed<0.8)  speedMultople = 2;
        else if (speed>=0.8)            speedMultople = 3;
    }
    return speedMultople;
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [self chuShiHuaSingleTapLEDView];
//    self.view.hidden = NO;
    self.isViewAppear = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.timer) [self.timer invalidate];
    if (self.Filckertimer) [self.Filckertimer invalidate];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self chuShiHuaBackgroundLEDView];
    CGFloat shift = self.view.center.x - self.view.center.y;
    if ([self isIPad]&&self.isLandscapeOfiPhone==NO) {
        if (shift>0) {
            self.isLandscapeOfiPad = YES;
            self.backgroundLEDView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            self.ledView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            CGPoint center  = self.ledView.center;
            center.y = center.y - shift;
            center.x = center.x - shift;
            self.ledView.center = center;
            center.x = center.x + shift;
            center.y = center.y + shift;
            self.backgroundLEDView.center = center;
        }
    }else{
        [self adjustLEDViewAndBsckGroundLEDViewPostion_iPhone_LEDview];
        [self adjustLEDViewAndBsckGroundLEDViewPostion_iPhone_backGroundLEDview];
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//屏幕发生旋转
-(void)OrientationDidChange:(NSNotification*)notification{
    UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;

    switch (orient)
    {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            self.backgroundLEDView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            self.ledView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            break;
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            if ([self isIPad]&&self.isLandscapeOfiPhone==NO) {
                self.backgroundLEDView.transform = CGAffineTransformMakeRotation(0);
                self.ledView.transform = CGAffineTransformMakeRotation(0);
            }
            break;
        default:
            break;
    }
    if ([self isIPad]&&self.isLandscapeOfiPhone==NO) {
        [self adjustLEDViewAndBsckGroundLEDViewPostion_iPad_backGroundLEDview];
        [self adjustLEDViewAndBsckGroundLEDViewPostion_iPad_LEDview];
    }
}
-(void)makeGifAndShare{
//    [self LOG];
    self.blackGroundLEDView_oldFrame = self.backgroundLEDView.frame;
    self.LEDView_oldFrame = self.ledView.frame;
    NSURL *url = [GifShareController startMakeGifWithImageArray:self.jieTuImagePathArray andTimeInterval:self.tiemInterval];
    NSArray *items = [NSArray arrayWithObjects:url, nil];
    NSFileManager *fm = [NSFileManager defaultManager];
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    if ([self isIPad]) {
        UIPopoverController * popVC = [[UIPopoverController alloc]initWithContentViewController:activityViewController];
        [popVC presentPopoverFromRect:self.singleTapView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }else{
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    self.backgroundLEDView.alpha = 0;
    self.ledView.alpha = 0;
    __weak typeof (self) weakself = self;
    UIActivityViewControllerCompletionWithItemsHandler  shareAfter2 = ^(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
        weakself.backgroundLEDView.frame = weakself.blackGroundLEDView_oldFrame;
        weakself.ledView.frame = weakself.LEDView_oldFrame;
        [UIView animateWithDuration:0.25 animations:^{
            weakself.ledView.alpha = 1;
            weakself.backgroundLEDView.alpha = 1;
        }];
        
        [fm removeItemAtURL:url error:nil];
        [weakself LOG];
        //换算滚动速度
        CGFloat speed = weakself.ledSpeed * (-0.17) + 0.2;
        if (weakself.showModel == NSShowModel64) {
            speed = speed / 4;
        }
        weakself.isShare = NO;
        weakself.isMakeGif = NO;
        weakself.isGetTimeInterval = NO;
        weakself.tiemInterval = 0;
        weakself.isLEDForward = NO;
        weakself.isJieTu_Ing = NO;
        weakself.index = 0;
        for (UIView * view in weakself.ledView.subviews) {
            view.backgroundColor = CLEARCOLOR;
        }
        
//        if ([[NPCommonConfig shareInstance]shouldShowAdvertise]) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[NPCommonConfig shareInstance]showFullScreenAdWithNativeAdAlertViewForController:self];
//            });
//        }
        
        weakself.timer =  [NSTimer scheduledTimerWithTimeInterval:speed target:weakself selector:@selector(LEDForward:) userInfo:nil repeats:YES];
    };
    
    activityViewController.completionWithItemsHandler = shareAfter2;
    [self.HUD hideAnimated:YES];
}

///调整LEDView和backgroundLEDView的位置
-(void)adjustLEDViewAndBsckGroundLEDViewPostion_iPhone_LEDview{
    CGPoint LEDViewCenter = self.ledView.center;
    CGFloat LEDViewShift = LEDViewCenter.x - LEDViewCenter.y;
    if (LEDViewShift< 0) {
        LEDViewCenter.x -= LEDViewShift;
        LEDViewCenter.y += LEDViewShift;
    }else{
        LEDViewCenter.x -= LEDViewShift;
        LEDViewCenter.y -= LEDViewShift;
    }
    self.ledView.center = LEDViewCenter;
}
//*****************************************************
-(void)adjustLEDViewAndBsckGroundLEDViewPostion_iPad_LEDview{
    CGPoint center  = self.ledView.center;
    CGFloat shift = center.x - center.y;
    CGPoint origin = self.ledView.frame.origin;
    
    if (self.isLandscapeOfiPad) {
        center.x -=origin.x;
        center.y -=origin.y;
        UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;
        if ((orient == UIDeviceOrientationLandscapeLeft)||(orient==UIDeviceOrientationLandscapeRight)) {
            center.y += -3*ABS(shift)-origin.y ;
        }
    }else{
        center.x -= origin.x;
        center.y -= origin.y;
    }
    self.ledView.center = center;
    
    if (self.ledView.frame.origin.x!=self.view.frame.origin.x&&
        self.ledView.frame.origin.y!=self.view.frame.origin.y) {
        CGRect frame_led = self.ledView.frame;
        frame_led.origin.x = self.view.frame.origin.x;
        frame_led.origin.y = self.view.frame.origin.y;
        self.ledView.frame = frame_led;
    }
}
//调整LEDView和backgroundLEDView的位置
-(void)adjustLEDViewAndBsckGroundLEDViewPostion_iPhone_backGroundLEDview{
    CGPoint backGroundLEDViewCenter = self.backgroundLEDView.center;
    CGFloat LEDViewShift = backGroundLEDViewCenter.x - backGroundLEDViewCenter.y;
    if (LEDViewShift< 0) {
        backGroundLEDViewCenter.x -= LEDViewShift;
        backGroundLEDViewCenter.y += LEDViewShift;
    }else{
        backGroundLEDViewCenter.x -= LEDViewShift;
        backGroundLEDViewCenter.y -= LEDViewShift;
    }
    self.backgroundLEDView.center = backGroundLEDViewCenter;
}
-(void)adjustLEDViewAndBsckGroundLEDViewPostion_iPad_backGroundLEDview{
    CGPoint center  = self.ledView.center;
    CGFloat shift = center.x - center.y;
    CGPoint origin = self.ledView.frame.origin;
    
    if (self.isLandscapeOfiPad) {
        center.x -=origin.x;
        center.y -=origin.y;
        UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;
        if ((orient == UIDeviceOrientationLandscapeLeft)||(orient==UIDeviceOrientationLandscapeRight)) {
            center.y += ABS(shift)-origin.y ;
        }
    }else{
        center.x -= origin.x;
        center.y -= origin.y;
    }
    self.backgroundLEDView.center = center;
    
    if (self.backgroundLEDView.frame.origin.x!=self.view.frame.origin.x&&
        self.backgroundLEDView.frame.origin.y!=self.view.frame.origin.y) {
        CGRect frame_led = self.backgroundLEDView.frame;
        frame_led.origin.x = self.view.frame.origin.x;
        frame_led.origin.y = self.view.frame.origin.y;
        self.backgroundLEDView.frame = frame_led;
    }
}

//************************************************
//-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
//    
//}
//-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
//
//}
- (BOOL) shouldAutorotate
{
    return YES;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
- (NSUInteger)supportedInterfaceOrientations
{
    self.isLandscapeOfiPhone = YES;
    self.backgroundLEDView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.ledView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    return UIInterfaceOrientationMaskLandscape;
}

-(void)dealloc{
    LOG(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)LOG{
    LOG(@"==============");
    LOG(@"self.view.center=%@",NSStringFromCGPoint(self.view.center));
    LOG(@"self.view.frame=%@",NSStringFromCGRect(self.view.frame));
    LOG(@"self.ledView.center=%@",NSStringFromCGPoint(self.ledView.center));
    LOG(@"self.ledView.frame=%@",NSStringFromCGRect(self.ledView.frame));
    LOG(@"self.backgroundLEDView.center=%@",NSStringFromCGPoint(self.backgroundLEDView.center));
    LOG(@"self.backgroundLEDView.framer=%@",NSStringFromCGRect(self.backgroundLEDView.frame));
}
-(NSString * )deviceModelName{
    NSString * deviceModeName = nil;
    UIUserInterfaceIdiom   interfaceIdiom = [[UIDevice currentDevice] userInterfaceIdiom];
    switch (interfaceIdiom) {
        case UIUserInterfaceIdiomPhone:
            deviceModeName = @"iPhone/iPod";
            break;
        case UIUserInterfaceIdiomPad:
            deviceModeName = @"iPad";
            break;
        case UIUserInterfaceIdiomTV:
            deviceModeName = @"Apple TV";
            break;
        case UIUserInterfaceIdiomCarPlay:
            deviceModeName = @"CarPlay";
            break;
        default:
            deviceModeName = @"";
            break;
    }
    return deviceModeName;
}
//-(void)dealloc{
//    
//}
@end
