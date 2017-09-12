//
//  MainViewController.m
//  MemoryTurnCard
//
//  Created by 何少博 on 16/10/21.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//




#define MAS_SHORTHAND
#define MAS_SHORTHAND_GLOBALS

#define FRUIT    111
#define ANIMAL   222
#define ABC      333
#define OTHER    444
#define FISH_H   50
#import "MainViewController.h"
#import "GameViewController.h"
#import "CustomAnimatedDelegate.h"
#import "NPInterstitialButton.h"
#import "CusSettingsViewController.h"
#import "NPCommonConfig.h"
#import "NPGoProButton.h"
#import "Masonry.h"

@interface MainViewController ()<CAAnimationDelegate>

@property (nonatomic,weak) UIView * contentView;
//@property (nonatomic,weak) CALayer *fishLayer;
//@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic,assign) BOOL showFullAD ;
@end

@implementation MainViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    BOOL shouldShowAd = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (shouldShowAd) {
        [[NPCommonConfig shareInstance]initAdvertise];
        self.interstitialButton = [NPInterstitialButton buttonWithType:NPInterstitialButtonTypeIcon viewController:self];
        UIBarButtonItem *adIconBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.interstitialButton];
        self.navigationItem.rightBarButtonItem = adIconBarButtonItem;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:123.0/255.0 green:71.0/255.0 blue:110.0/255.0 alpha:1];
    
    NPInterstitialButton * intersitialBtn = [NPInterstitialButton buttonWithType:NPInterstitialButtonTypeDefault viewController:self];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:intersitialBtn];//
    UIBarButtonItem * settingItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"setting"] style:UIBarButtonItemStylePlain target:self action:@selector(jumpSetting)];
    NPGoProButton * goProBtn = [NPGoProButton goProButtonWithImage:[UIImage imageNamed:@"title_gopro_icon"] Frame:CGRectMake(0, 0, 44, 44)];
    NSMutableArray * items = [NSMutableArray array];
    UIBarButtonItem * goProItem = [[UIBarButtonItem alloc]initWithCustomView:goProBtn];
    [items addObject:settingItem];
    if ([[NPCommonConfig shareInstance] shouldShowAdvertise]) {
        [items addObject:goProItem];
    }
    self.navigationItem.rightBarButtonItems = items;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self chuSHiHua_UI];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIImageView * barImageView = self.navigationController.navigationBar.subviews.firstObject;
    barImageView.alpha = 0;
    self.navigationController.navigationBar.hidden = NO;

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.3 animations:^{
        self.navigationController.navigationBar.alpha = 1.0;
    }];
    if (self.showFullAD) {
        [[NPCommonConfig shareInstance] showFullScreenAdORNativeAdForController:self];
        self.showFullAD = NO;
    }
//    [self createdFishLayer];
}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [self removeFishLayer];
}

#pragma mark - 布局控件

-(void)chuSHiHua_UI{

    //添加backgroundImageView
    UIImageView * backGroundImageView = [[UIImageView alloc]init];
    [self.view addSubview:backGroundImageView];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        backGroundImageView.image = [UIImage imageNamed:@"backgroung-for-ipad"];
    }else{
        backGroundImageView.image = [UIImage imageNamed:@"BackGroundiPhone"];
    }
    [backGroundImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    //添加按钮ContentView
    UIView * contentView = [[UIView alloc]init];
    [self.view addSubview:contentView];
    self.contentView = contentView;
    contentView.backgroundColor = [UIColor clearColor];
    CGFloat min = kScreenW > kScreenH ? kScreenH : kScreenW;
    CGFloat w = min/4*3;
    CGFloat x = (kScreenW - w)/2;
    CGFloat y = (kScreenH - w)/2;
    contentView.frame = CGRectMake(x, y, w, w);
//    [contentView makeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(self.view.width).multipliedBy(2/3.0);
//        make.height.equalTo(self.view.width).multipliedBy(2/3.0);
//        make.center.equalTo(self.view);
//    }];
    
    //添加按钮
    UIButton * fruitBtn = [[UIButton alloc]init];
    [contentView addSubview:fruitBtn];
    fruitBtn.imageView.contentMode = UIViewContentModeScaleToFill;
//    fruitBtn.backgroundColor = [UIColor redColor];
    [fruitBtn addTarget:self action:@selector(jumpToGameVC:) forControlEvents:UIControlEventTouchUpInside];
    fruitBtn.tag = FRUIT;
//    [fruitBtn setTitle:@"水果" forState:UIControlStateNormal];
    [fruitBtn setImage:[UIImage imageNamed:@"caomeizhu.png"] forState:UIControlStateNormal];
    [fruitBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(contentView.width).multipliedBy(2.0/5.0);
        make.height.equalTo(contentView.width).multipliedBy(2.0/5.0);
        make.bottom.equalTo(contentView.bottom);
        make.right.equalTo(contentView.right);
    }];
    
    UIButton * animalBtn = [[UIButton alloc]init];
    [contentView addSubview:animalBtn];
//    animalBtn.backgroundColor = [UIColor redColor];
    animalBtn.imageView.contentMode = UIViewContentModeScaleToFill;
    [animalBtn addTarget:self action:@selector(jumpToGameVC:) forControlEvents:UIControlEventTouchUpInside];
    animalBtn.tag = ANIMAL;
//    [animalBtn setTitle:@"动物" forState:UIControlStateNormal];
    [animalBtn setImage:[UIImage imageNamed:@"yazizhu.png"] forState:UIControlStateNormal];
    [animalBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(contentView.width).multipliedBy(2.0/5.0);
        make.height.equalTo(contentView.width).multipliedBy(2.0/5.0);
        make.top.equalTo(contentView.top);
        make.left.equalTo(contentView.left);
    }];
    
    UIButton * nationalFlagBtn = [[UIButton alloc]init];
    [contentView addSubview:nationalFlagBtn];
//    nationalFlagBtn.backgroundColor = [UIColor redColor];
    [nationalFlagBtn addTarget:self action:@selector(jumpToGameVC:) forControlEvents:UIControlEventTouchUpInside];
    nationalFlagBtn.tag = ABC;
//    [nationalFlagBtn setTitle:@"ABC" forState:UIControlStateNormal];
    nationalFlagBtn.imageView.contentMode = UIViewContentModeScaleToFill;
    [nationalFlagBtn setImage:[UIImage imageNamed:@"Azhu.png"] forState:UIControlStateNormal];
    [nationalFlagBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(contentView.width).multipliedBy(2.0/5.0);
        make.height.equalTo(contentView.width).multipliedBy(2.0/5.0);
        make.bottom.equalTo(contentView.bottom);
        make.left.equalTo(contentView.left);
    }];
    
    UIButton * otherBtn = [[UIButton alloc]init];
    [contentView addSubview:otherBtn];
//    otherBtn.backgroundColor = [UIColor redColor];
    [otherBtn addTarget:self action:@selector(jumpToGameVC:) forControlEvents:UIControlEventTouchUpInside];
    otherBtn.tag = OTHER;
    otherBtn.imageView.contentMode = UIViewContentModeScaleToFill;
//    [otherBtn setTitle:@"其他" forState:UIControlStateNormal];
    [otherBtn setImage:[UIImage imageNamed:@"UKzhu.png"] forState:UIControlStateNormal];
    [otherBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(contentView.width).multipliedBy(2.0/5.0);
        make.height.equalTo(contentView.width).multipliedBy(2.0/5.0);
        make.top.equalTo(contentView.top);
        make.right.equalTo(contentView.right);
    }];
    //添加topImageView
    //    UIImageView * topImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 280, 40)];
    //    topImageView.image = [UIImage imageNamed:@"title"];
    //    self.navigationItem.titleView = topImageView;
    UIImageView * topImageView = [[UIImageView alloc]init];
    topImageView.image = [UIImage imageNamed:@"title"];
    [self.view addSubview:topImageView];
    [topImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(40);
        make.width.equalTo(self.view.width).multipliedBy(1.0/3.0);
        make.height.equalTo(self.view.width).multipliedBy(1.0/21.0);
        make.centerX.equalTo(self.view.centerX);
    }];
}


#pragma mark - fishLayer

//-(void)createdFishLayer{
////    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(createBubble) userInfo:nil repeats:YES];
//    CGSize layerSize = CGSizeMake(FISH_H, FISH_H);
//    CALayer *movingLayer = [CALayer layer];
//    movingLayer.bounds = CGRectMake(0, 0, layerSize.width, layerSize.height);
//    movingLayer.anchorPoint = CGPointMake(0,0);
//    movingLayer.position = CGPointMake(-100, self.view.bounds.size.height - 2*FISH_H);
//    UIImage * image = [UIImage imageNamed:@"fish.png"];
//    movingLayer.contents = (__bridge id _Nullable)(image.CGImage);
//    [self.view.layer addSublayer:movingLayer];
//    self.fishLayer = movingLayer;
//    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fishLayerClick:)];
//    [self.view addGestureRecognizer:_tapGesture];
//    [self goFishLayer];
//}

//要在viewdidApear

//float randomFloatBetween(float smallNumber,float bigNumber){
//    float diff = bigNumber - smallNumber;
//    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
//}

//-(void)goFishLayer{
//    float small = self.contentView.frame.origin.y + self.contentView.frame.size.height;
//    float big = self.view.bounds.size.height - FISH_H;
//    CGPoint startPoint = CGPointMake(-100, randomFloatBetween(small, big));
//    CGPoint endPoint = CGPointMake(kScreenW+100, randomFloatBetween(small, big));
//    CAKeyframeAnimation *moveLayerAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//    moveLayerAnimation.values = @[[NSValue valueWithCGPoint:startPoint],
//                                  [NSValue valueWithCGPoint:endPoint]];
//    moveLayerAnimation.duration = 12.0;
//    moveLayerAnimation.autoreverses = NO;
//    moveLayerAnimation.repeatCount = 0;
//    moveLayerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//    moveLayerAnimation.delegate = self;
//    [self.fishLayer addAnimation:moveLayerAnimation forKey:@"move"];
//}
//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
//    if (flag) {
//        [self.fishLayer removeAllAnimations];
//        [self goFishLayer];
//    }
//}
//-(void)removeFishLayer{
////    [self.timer invalidate];
//    [self.fishLayer removeAllAnimations];
//    [self.fishLayer removeFromSuperlayer];
//    [self.view removeGestureRecognizer:self.tapGesture];
//}

//-(void)fishLayerClick:(UITapGestureRecognizer *)tapGesture {
//    CGPoint touchPoint = [tapGesture locationInView:self.view];
//    if ([self.fishLayer.presentationLayer hitTest:touchPoint]) {
//        [self createBubble];
//        //创建CATransition对象
//        CATransition *animation = [CATransition animation];
//        
//        //设置运动时间
//        animation.duration = 3;
//        
//        //设置运动type
//        animation.type = @"rippleEffect";
//        //设置子类
//        animation.subtype = kCATransitionFromBottom;
//        animation.autoreverses = YES;
//        //设置运动速度
//        animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
//        
//        [self.fishLayer addAnimation:animation forKey:@"animation"];
////        NSLog(@"presentationLayer");
////        if ([[NPCommonConfig shareInstance]shouldShowAdvertise]) {
////            [[NPCommonConfig shareInstance]showInterstitialAdInViewController:self];
////        }
//    }
//}

#pragma mark - actions
-(void)jumpToGameVC:(UIButton *)sender{
    GameImageType type;
    switch (sender.tag) {
        case FRUIT:
            type = GameImageTypeFruit;
            break;
        case ANIMAL:
            type = GameImageTypeAnimal;
            break;
        case ABC:
            type = GameImageTypeABC;
            break;
        case OTHER:
            type = GameImageTypeOther;
            break;
        default:
            type = GameImageTypeFruit;
            break;
    }
    if (type == GameImageTypeABC ){
        if ([self lockThisAction]) {
            [[NPCommonConfig shareInstance] showPinlunJiesuoView];
            return;
        }
    }
    
    if (type  == GameImageTypeOther) {
        if ([self fufeiLock]) {
            [[NPCommonConfig shareInstance] showFeatureLockedForGoProAlertView];
            return;
        }
    }
    GameViewController * gameVC = [[GameViewController alloc]initWithGameImageType:type];
    [self.navigationController pushViewController:gameVC animated:YES];
    self.showFullAD = YES;
}
-(BOOL)lockThisAction{
    return [[NPCommonConfig shareInstance]shouldJiaShuoForPinlun];
}
-(BOOL)fufeiLock{
    BOOL isLite = [[NPCommonConfig shareInstance] isLiteApp];
    if (NO == isLite) {
        return NO;
    }
    BOOL isShangXian = [[NPCommonConfig shareInstance] isCurrentVersionOnline];
    NSUInteger days = [[NPCommonConfig shareInstance] appUseDaysCount];
    BOOL isSafe = NO;
    if (isShangXian || (days > 0)) {
        isSafe = YES;
    }
    if (isSafe) {
        return YES;
    }
    return NO;
}
-(void)jumpSetting{
    CusSettingsViewController * setting = [[CusSettingsViewController alloc]init];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:setting];
    nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:nav animated:YES completion:nil];
    
}



//- (void)createBubble {
//    if (self.fishLayer == nil) {
//        return;
//    }
//    UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bubble"]];
//    
//    CGFloat size = randomFloatBetween(5, 15);
//    /* If you are not animating your fish, this will work fine
//     [bubbleImageView setFrame:CGRectMake(self.fishImageView.frame.origin.x + 5, self.fishImageView.frame.origin.y + 80, size, size)]; */
//    
//    // If you are animating your fish, you need to get the starting point from the
//    // fish's presentation layer, since it will be animating at the time.
//    CGFloat X = [self.fishLayer.presentationLayer frame].origin.x + 5;
//    CGFloat Y = [self.fishLayer.presentationLayer frame].origin.y + [self.fishLayer.presentationLayer frame].size.height/2;
//    [bubbleImageView setFrame:CGRectMake( X, Y, size, size)];
//    
//    bubbleImageView.alpha = randomFloatBetween(.1, 1);
//    
//    [self.view addSubview:bubbleImageView];
//    
//    UIBezierPath *zigzagPath = [[UIBezierPath alloc] init];
//    CGFloat oX = bubbleImageView.frame.origin.x;
//    CGFloat oY = bubbleImageView.frame.origin.y;
//    CGFloat eX = oX;
//    CGFloat eY = oY - randomFloatBetween(50, 300);
//    CGFloat t =  randomFloatBetween(20, 100);
//    CGPoint cp1 = CGPointMake(oX - t, ((oY + eY) / 2));
//    CGPoint cp2 = CGPointMake(oX + t, cp1.y);
//    
//    // randomly switch up the control points so that the bubble
//    // swings right or left at random
//    NSInteger r = arc4random() % 2;
//    if (r == 1) {
//        CGPoint temp = cp1;
//        cp1 = cp2;
//        cp2 = temp;
//    }
//    
//    // the moveToPoint method sets the starting point of the line
//    [zigzagPath moveToPoint:CGPointMake(oX, oY)];
//    // add the end point and the control points
//    [zigzagPath addCurveToPoint:CGPointMake(eX, eY) controlPoint1:cp1 controlPoint2:cp2];
//    
//    [CATransaction begin];
//    [CATransaction setCompletionBlock:^{
//        // transform the image to be 1.3 sizes larger to
//        // give the impression that it is popping
//        [UIView transitionWithView:bubbleImageView
//                          duration:0.1f
//                           options:UIViewAnimationOptionTransitionCrossDissolve
//                        animations:^{
//                            bubbleImageView.transform = CGAffineTransformMakeScale(1.3, 1.3);
//                        } completion:^(BOOL finished) {
//                            [bubbleImageView removeFromSuperview];
//                        }];
//    }];
//    
//    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//    pathAnimation.duration = 2;
//    pathAnimation.path = zigzagPath.CGPath;
//    // remains visible in it's final state when animation is finished
//    // in conjunction with removedOnCompletion
//    pathAnimation.fillMode = kCAFillModeForwards;
//    pathAnimation.removedOnCompletion = NO;
//    
//    [bubbleImageView.layer addAnimation:pathAnimation forKey:@"movingAnimation"];
//    
//    [CATransaction commit];
//    
//    
//}
//
#pragma mark - 屏幕转屏
-(void)deviceOrientationDidChange:(NSNotification*) noti{
    if (!([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)) {
        return;
    }
    //旋转之后拿不到正确的尺寸
    CGFloat min = kScreenW > kScreenH ? kScreenH : kScreenW;
    CGFloat w = min/3*2;
    CGFloat x = (kScreenW - w)/2;
    CGFloat y = (kScreenH                                                                                                                                   - w)/2;
    _contentView.frame = CGRectMake(x, y, w, w);

}

//- (BOOL)shouldAutorotate{
//    return NO;
//}
//
//#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
//- (NSUInteger)supportedInterfaceOrientations
//#else
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//#endif
//{
//    return UIInterfaceOrientationMaskPortrait;
//}

@end
