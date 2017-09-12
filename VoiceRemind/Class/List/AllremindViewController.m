//
//  AllremindViewController.m
//  VoiceRemind
//
//  Created by 何少博 on 16/8/24.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "AllremindViewController.h"
#import "ListViewController.h"
#import "CalendarViewController.h"
#import "AppDelegate.h"
#import "NPCommonConfig.h"
#import "NPInterstitialButton.h"


@interface AllremindViewController ()

@property (nonatomic,weak)UIViewController * showingVc;
@property (nonatomic,weak)UIView * contentView;


@end

@implementation AllremindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    UIView * contentView = [[UIView alloc]initWithFrame:ScreenBound];
    [self.view addSubview:contentView];
    self.contentView = contentView;
    ListViewController * listVC = [[ListViewController alloc]init];
    listVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addChildViewController:listVC];
    CalendarViewController * calendarVC = [[CalendarViewController alloc]init];
    calendarVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addChildViewController:calendarVC];
    self.showingVc = self.childViewControllers[0];
    [self.contentView addSubview:self.showingVc.view];
    UISegmentedControl * segCtr = [[UISegmentedControl alloc]initWithItems:@[
                                                                             NSLocalizedString(@"List", @"List"),
                                                                             NSLocalizedString(@"calendar", @"calendar")]];
    [segCtr addTarget:self action:@selector(listModelChanged:) forControlEvents:UIControlEventValueChanged];
    segCtr.selectedSegmentIndex = 0;
    self.navigationItem.titleView = segCtr;
    BOOL shouldShowAd = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (shouldShowAd) {
        NPInterstitialButton *interstitialButton = [NPInterstitialButton buttonWithType:NPInterstitialButtonTypeIcon viewController:self];
        UIBarButtonItem *adIconBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:interstitialButton];
        self.navigationItem.rightBarButtonItem = adIconBarButtonItem;
    }
    LOG(@"%@",Voice_directory);
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    AppDelegate * appD = [UIApplication sharedApplication].delegate;
    UITabBarController * tabarController = appD.tabarController;
    UITabBarItem * itemAllRemind = [tabarController.tabBar.items objectAtIndex:1];
    NSArray * notices = [[UIApplication sharedApplication]scheduledLocalNotifications];
    int num = (int)notices.count;
    NSString * badgeValue = [NSString stringWithFormat:@"%d",num];
    if (num == 0) {
        badgeValue = nil;
    }
    itemAllRemind.badgeValue = badgeValue;
}
-(void)listModelChanged:(UISegmentedControl*)sender{
    [self.showingVc.view removeFromSuperview];
    int flag = 0;
    if (sender.selectedSegmentIndex == 0) {
        self.showingVc = self.childViewControllers[0];
    }else{
        self.showingVc = self.childViewControllers[1];
        flag = 1;
    }
    self.showingVc.view.frame = self.contentView.bounds;
    self.showingVc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:self.showingVc.view];
    
//     动画
        CATransition *animation = [CATransition animation];
        animation.type = @"push";
        animation.subtype = flag == 1 ? kCATransitionFromRight : kCATransitionFromLeft;
        animation.duration = 0.35;
        [self.contentView.layer addAnimation:animation forKey:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL) shouldAutorotate
{
    return NO;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
/** type
 *
 *  各种动画效果  其中除了'fade', `moveIn', `push' , `reveal' ,其他属于似有的API(我是这么认为的,可以点进去看下注释).
 *  ↑↑↑上面四个可以分别使用'kCATransitionFade', 'kCATransitionMoveIn', 'kCATransitionPush', 'kCATransitionReveal'来调用.
 *  @"cube"                     立方体翻滚效果
 *  @"moveIn"                   新视图移到旧视图上面
 *  @"reveal"                   显露效果(将旧视图移开,显示下面的新视图)
 *  @"fade"                     交叉淡化过渡(不支持过渡方向)             (默认为此效果)
 *  @"pageCurl"                 向上翻一页
 *  @"pageUnCurl"               向下翻一页
 *  @"suckEffect"               收缩效果，类似系统最小化窗口时的神奇效果(不支持过渡方向)
 *  @"rippleEffect"             滴水效果,(不支持过渡方向)
 *  @"oglFlip"                  上下左右翻转效果
 *  @"rotate"                   旋转效果
 *  @"push"
 *  @"cameraIrisHollowOpen"     相机镜头打开效果(不支持过渡方向)
 *  @"cameraIrisHollowClose"    相机镜头关上效果(不支持过渡方向)
 */

/** type
 *
 *  kCATransitionFade            交叉淡化过渡
 *  kCATransitionMoveIn          新视图移到旧视图上面
 *  kCATransitionPush            新视图把旧视图推出去
 *  kCATransitionReveal          将旧视图移开,显示下面的新视图
 */

@end
