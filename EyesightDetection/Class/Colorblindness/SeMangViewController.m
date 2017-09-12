//
//  SeMangViewController.m
//  EyesightDetection
//
//  Created by 何少博 on 16/9/27.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//
#define  WIDTH  [UIScreen mainScreen].bounds.size.width
#define  HEIGHT  [UIScreen mainScreen].bounds.size.height

#import "SeMangViewController.h"
#import "Masonry.h"
#import "DXPopover.h"
#import "MBProgressHUD.h"
#import "UINavigationBar+x.h"
#import "NPGoProButton.h"
#import "NPInterstitialButton.h"
#import "NPCommonConfig.h"
#import "UIColor+x.h"
@interface SeMangViewController ()
@property (weak,nonatomic) UIImageView* imageView;
@property (weak,nonatomic) UIButton *lastBtn;
@property (weak,nonatomic) UIButton *nextBtn;
@property (weak,nonatomic) UIButton *detailBtn;
@property (weak,nonatomic) UIView * tempNatiView;
@property (strong,nonatomic) NSArray * imageNameArray;
@property (strong,nonatomic) NSArray * resultKeyArray;
@property (strong,nonatomic) UILabel * numLabel;
@property (assign,nonatomic) int index;
@property (assign,nonatomic) int viewTimes;
@end

@implementation SeMangViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self chuShiHua_UI];
    self.imageView.image = [UIImage imageNamed:self.imageNameArray[_index]];
    self.navigationItem.title = NSLocalizedString(@"color blindness test", @"Color blindness detection");
    self.navigationController.navigationBar.barTintColor = color_2bc083;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.view.backgroundColor = color_f2f2f2;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    if ([[NPCommonConfig shareInstance]shouldShowAdvertise]) {
        self.interstitialButton =[NPInterstitialButton buttonWithType:NPInterstitialButtonTypeIcon viewController:self];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.interstitialButton];
    }
    if ([NPCommonConfig shareInstance].isLiteApp&&[[NPCommonConfig shareInstance]shouldShowAdvertise]) {
        NPGoProButton * goPro = [NPGoProButton goProButton];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:goPro];
    }
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.viewTimes = 0;
}
-(BOOL)needLoadNativeAdView{
    return NO;
}
-(BOOL)needLoadBannerAdView{
    return YES;
}

-(void)chuShiHua_UI{
    CGFloat W = WIDTH / 3 * 2;
    UIImageView * imageView = [[UIImageView alloc]init];
    self.imageView = imageView;
    [self.view addSubview:imageView];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    UISwipeGestureRecognizer * left = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(leftSwipGe:)];
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:left];
    UISwipeGestureRecognizer * right = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(rightSwipGe:)];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:right];
    [self.view addSubview:imageView];
    __weak typeof(self) weakSelf = self;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(W, W));
        make.centerX.equalTo(weakSelf.view);
        make.centerY.equalTo(weakSelf.view).offset(-HEIGHT/7.0);
    }];
    CGFloat btn_w = (WIDTH - W)/2 > 100 ? 100 : (WIDTH - W)/2;
    
    UIButton * lastBtn = [[UIButton alloc]init];
    self.lastBtn = lastBtn;
    self.lastBtn.enabled = NO;
    [self.view addSubview:lastBtn];
    [lastBtn setImage:[UIImage imageNamed:@"last-unchoosed"] forState:UIControlStateNormal];
    [lastBtn addTarget:self action:@selector(lastBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [lastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(btn_w, 50));
        make.centerY.equalTo(weakSelf.imageView);
        make.centerX.equalTo(weakSelf.view).offset(-(WIDTH + W)/4);
    }];
    
    UIButton * nextBtn = [[UIButton alloc]init];
    self.nextBtn = nextBtn;
    [self.view addSubview:nextBtn];
    [nextBtn setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(btn_w, 50));
        make.centerY.equalTo(weakSelf.imageView);
        make.centerX.equalTo(weakSelf.view).offset((WIDTH + W)/4);
    }];
    
    UIView * tempView = [[UIView alloc]init];
    tempView.backgroundColor = color_f2f2f2;
    [self.view addSubview:tempView];
    [tempView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.bottom);
        make.centerX.equalTo(weakSelf.view);
        make.width.equalTo(imageView);
        make.bottom.equalTo(weakSelf.view);
    }];
    UIButton * detailBtn = [[UIButton alloc]init];
    [tempView addSubview:detailBtn];
    
    self.detailBtn = detailBtn;
    detailBtn.backgroundColor = [UIColor whiteColor];
    [detailBtn setTitleColor:color_2bc083 forState:UIControlStateNormal];
    [detailBtn setTitle:NSLocalizedString(@"View Results", @"View the result") forState:UIControlStateNormal];
    [detailBtn addTarget:self action:@selector(detailBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [detailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(imageView.height).multipliedBy(0.2);
        make.center.equalTo(tempView.center);
        make.width.equalTo(imageView);
    }];
    //添加边框
    detailBtn.layer.borderColor = color_2bc083.CGColor;
    detailBtn.layer.borderWidth = 1.5;
    detailBtn.layer.cornerRadius = 8;
    detailBtn.layer.masksToBounds = YES;
    
    UILabel * numLabel = [[UILabel alloc]init];
    self.numLabel = numLabel;
    numLabel.textColor = color_2bc083;
    [self.view addSubview:numLabel];
    numLabel.textAlignment = NSTextAlignmentCenter;
    numLabel.text = [NSString stringWithFormat:@"%d/%d",1,(int)self.imageNameArray.count];
    [numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.topMargin.equalTo(0);
        make.left.equalTo(self.imageView.left);
        make.right.equalTo(self.imageView.right);
        make.bottom.equalTo(self.imageView.top);
    }];
}
#pragma  mark - 数据
-(NSArray *)imageNameArray{
    if (_imageNameArray == nil) {
        NSString * path = [[NSBundle mainBundle]pathForResource:@"imageName" ofType:@"plist"];
        _imageNameArray = [NSArray arrayWithContentsOfFile:path];
    }
    return _imageNameArray;
}
-(NSArray *)resultKeyArray{
    if (_resultKeyArray == nil) {
        NSString * path = [[NSBundle mainBundle]pathForResource:@"resultKey" ofType:@"plist"];
        _resultKeyArray = [NSArray arrayWithContentsOfFile:path];
    }
    return _resultKeyArray;
}
#pragma mark - actions

-(void)viewTimesshowInterstitialAd{
    self.viewTimes ++;
    if (self.viewTimes % 5  == 4) {
        if ([[NPCommonConfig shareInstance]shouldShowAdvertise]) {
            [[NPCommonConfig shareInstance]showFullScreenAdORNativeAdForController:self];
        }
    }
}
-(void)lastBtnClick:(UIButton *)sender{
    
    _index--;
    if (_index < 0) {
        _index = 0;
        sender.enabled = NO;
        [sender setImage:[UIImage imageNamed:@"last-unchoosed"] forState:UIControlStateNormal];
        return;
    }
    if (self.nextBtn.enabled == NO) {
        self.nextBtn.enabled = YES;
        [self.nextBtn setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
    }
    self.numLabel.text = [NSString stringWithFormat:@"%d/%d",_index+1,(int)self.imageNameArray.count];
    self.imageView.image = [UIImage imageNamed:self.imageNameArray[_index]];
    [self animationCurlDown:self.imageView];
    [self viewTimesshowInterstitialAd];
}
-(void)rightSwipGe:(UIGestureRecognizer*)sender{
    [self lastBtnClick:self.lastBtn];
}
-(void)nextBtnClick:(UIButton *)sender{
    
    _index ++;
    if (_index > self.imageNameArray.count-1) {
        _index = (int)self.imageNameArray.count-1;
        sender.enabled = NO;
        [sender setImage:[UIImage imageNamed:@"next-unchoosed"] forState:UIControlStateNormal];
        return;
    }
    if (self.lastBtn.enabled == NO) {
        self.lastBtn.enabled = YES;
        [self.lastBtn setImage:[UIImage imageNamed:@"last"] forState:UIControlStateNormal];
    }
    self.numLabel.text = [NSString stringWithFormat:@"%d/%d",_index+1,(int)self.imageNameArray.count];
    self.imageView.image = [UIImage imageNamed:self.imageNameArray[_index]];
    [self animationCurlUp:self.imageView];
    [self viewTimesshowInterstitialAd];
}
-(void)leftSwipGe:(UIGestureRecognizer*)sender{
    [self nextBtnClick:self.nextBtn];
}
-(void)animationCurlUp:(UIView*)view
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.35f];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:view cache:NO];
    [UIView commitAnimations];
}

-(void)animationCurlDown:(UIView*)view
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.35f];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:view cache:NO];
    [UIView commitAnimations];
}
-(void)detailBtnClick:(UIButton *)sender{
    
    NSString * labelStr = self.resultKeyArray[_index];
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = NSLocalizedString(labelStr, labelStr);
   
//    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:18]};
//    CGSize size = [labelStr boundingRectWithSize:CGSizeMake(WIDTH/3*2.3, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    CGFloat H = self.view.bounds.size.height;
    CGRect frame = self.imageView.frame;
    CGFloat x = self.view.bounds.size.width/2;
    CGFloat y = (H + frame.origin.y + frame.size.height)/2;
    CGPoint point = CGPointMake(x, y);
    textLabel.numberOfLines = 0;//表示label可以多行显示
    textLabel.frame = CGRectMake(0, 0, WIDTH/3*2.3, HEIGHT/5);//保持原来Label的位置和宽度，只是改变高度。
    textLabel.backgroundColor = [UIColor whiteColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.adjustsFontSizeToFitWidth = YES;
    DXPopover *popover = [DXPopover popover];
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0.75;
    [popover addGestureRecognizer:longPress];
    [popover showAtPoint:point popoverPostion:DXPopoverPositionUp withContentView:textLabel inView:self.view];
    
}


-(void)longPress:(UIGestureRecognizer*)sender{
    if(sender.state != UIGestureRecognizerStateBegan) return;
    NSString * text = self.resultKeyArray[_index];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:text];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text =NSLocalizedString(@"copy successfully", @"Copy success.");
    [hud hideAnimated:YES afterDelay:1.f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)removeAdNotification:(NSNotification *)notification{
    [super removeAdNotification:notification];
    self.navigationItem.leftBarButtonItem = nil;
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
