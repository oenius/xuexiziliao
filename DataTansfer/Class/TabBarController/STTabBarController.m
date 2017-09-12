//
//  STTabBarController.m
//  Common
//
//  Created by 何少博 on 17/3/27.
//  Copyright © 2017年 camory. All rights reserved.
//

#import "STTabBarController.h"
#import "STTabBarMoreViewController.h"
#import "STTabBar.h"
#import "UIView+st.h"
#import "NPCommonConfig.h"
#import <objc/runtime.h>
static CGFloat const STTabBarDefaultHeight = 44.0;

NSUInteger const STTabBarMaxItemCount = 5;

@interface STTabBarController ()<STTabBarDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) UINavigationController * moreNavigationController;

@property (nonatomic,strong) STTabBarMoreViewController * moreViewController;

@property (nonatomic,weak) UIViewController * currentController;

@property (nonatomic,strong) STBarItem * moreTabBarItem;

@property (nonatomic,strong) UIView * containerView;

@property (nonatomic,assign) BOOL shouldShowMore;

@property (nonatomic,strong) NSLayoutConstraint * tabBarHeightCon;
@property (nonatomic,strong) NSLayoutConstraint * tabBarBottomCon;

@end

@implementation STTabBarController





- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    if (self.navigationController) {
        self.navigationController.navigationBar.hidden = YES;
    }
    
    [self setupSubView];
    
    BOOL shouldAD = [[NPCommonConfig shareInstance]shouldShowAdvertise];
    if (shouldAD) {
        [[NPCommonConfig shareInstance] initAdvertise];
    }
}

-(UINavigationItem *)navigationItem{
    if (self.selectedControllerNavigationItem) {
        return self.selectedViewController.navigationItem;
    }else{
        return [super navigationItem];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
-(BOOL)shouldIncreaseViewAppearCountForShowFullscreenAd{
    return NO;
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setupSubView];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSubView];
    }
    return self;
}

-(void)setupSubView{
    [self.tabBar removeFromSuperview];
    [self.containerView removeFromSuperview];
    
    self.tabBar = [[STTabBar alloc]initWithFrame:CGRectZero];
    _tabBar.delegate = self;
    
    self.containerView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:_containerView];
    [self.view addSubview:_tabBar];
    
    [self.tabBar addConstraintEqualLeftToSupview:self.view];
    [self.tabBar addConstraintEqualRightToSupview:self.view];
    self.tabBarHeightCon = [self.tabBar addConstraintEqualHeight:STTabBarDefaultHeight];
    self.tabBarBottomCon = [self.tabBar addConstraintEqualBottomToSupview:self.view];
    
    
    [self.containerView addConstraintEqualLeftToSupview:self.view];
    [self.containerView addConstraintEqualRightToSupview:self.view];
    [self.containerView addConstraintEqualTopToSupview:self.view];
    NSLayoutConstraint * containerBottom = [NSLayoutConstraint constraintWithItem:_containerView attribute:(NSLayoutAttributeBottom) relatedBy:(NSLayoutRelationEqual) toItem:self.tabBar attribute:(NSLayoutAttributeTop) multiplier:1.0 constant:0.0];
    [self.view addConstraint:containerBottom];
    
}

-(UIViewController *)viewControllerForTabBarItem:(STBarItem *)item{
    if (nil == item) {return nil;}
    
    if (item == self.moreTabBarItem)
        return self.moreNavigationController;
    
    NSPredicate * pre = [NSPredicate predicateWithBlock:^BOOL(UIViewController *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        if (evaluatedObject.st_tabBarItem == item){
            return YES;
        
        }
        else if ([evaluatedObject isKindOfClass:[UINavigationController class]]){
            UINavigationController * evNaiv = (UINavigationController *)evaluatedObject;
            UIViewController * rootVC = evNaiv.viewControllers[0];
            if (rootVC.st_tabBarItem == item)
                return YES;
            else
                return NO;
        }
        else{
            return NO;
        }
    }];
    
    NSArray * fileterViewController = [self.viewControllers filteredArrayUsingPredicate:pre];
    
    return fileterViewController.count ? fileterViewController[0]:nil;
}

-(STBarItem *)tabBarItemForViewController:(UIViewController *)viewcontroller{
    STBarItem * item = viewcontroller.st_tabBarItem;
    
    if (nil == item) {
        NSString * itemTitle = viewcontroller.title;
        UIImage * selectdImage,*unSelectdImage;
        BOOL isTabTitleHidden = NO;
        if ([viewcontroller respondsToSelector:@selector(tabTitleHidden)]) {
            isTabTitleHidden = viewcontroller.tabTitleHidden;
        }
        
        if ([viewcontroller respondsToSelector:@selector(tabTitle)]) {
            itemTitle = viewcontroller.tabTitle;
        }
        
        if ([viewcontroller respondsToSelector:@selector(selectedTabImage)]) {
            selectdImage = viewcontroller.selectedTabImage;
        }
        
        if ([viewcontroller respondsToSelector:@selector(unselectedTabImage)]) {
            unSelectdImage = viewcontroller.unselectedTabImage;
        }
        
        NSString * title = isTabTitleHidden ? nil : itemTitle;
        
        item = [[STBarItem alloc]initWithTitle:title image:selectdImage];
        [item setSelectedImage:selectdImage withUnselectedImage:unSelectdImage];
        
        viewcontroller.st_tabBarItem = item;
    }
    return item;
}

- (UIView *)traverseSubviewsToGetViewOfClass:(Class)viewClass inView:(UIView *)view{
    if(!view) return nil;
    
    if([view isKindOfClass:[viewClass class]])
        return view;
    else
        return [self traverseSubviewsToGetViewOfClass:viewClass inView:view.subviews.firstObject];
}

- (void)selectTabBarItem:(STBarItem *)tabBarItem{
    UIViewController *viewController = [self viewControllerForTabBarItem:tabBarItem];
    
    if(viewController == self.selectedViewController) return;
    
    [self.selectedViewController willMoveToParentViewController:nil];
    [self.selectedViewController.view removeFromSuperview];
    [self.selectedViewController removeFromParentViewController];
    
    [self addChildViewController:viewController];
    [self.containerView addSubview:viewController.view];
    [viewController.view addConstraintEqualBottomToSupview:self.containerView];
    [viewController.view addConstraintEqualLeftToSupview:self.containerView];
    [viewController.view addConstraintEqualRightToSupview:self.containerView];
    [viewController.view addConstraintEqualTopToSupview:self.containerView];
    
    self.selectedViewController = viewController;
    _selectedIndex = [self.tabBar.items indexOfObject:tabBarItem];
    [self adjustSelectedViewControllerInsetsIfNeeded];
    [viewController didMoveToParentViewController:self];
}


- (void)adjustSelectedViewControllerInsetsIfNeeded {
    if(self.shouldAdjustSelectedViewContentInsets) {
        UIScrollView *toppestScrollView = (UIScrollView *)[self traverseSubviewsToGetViewOfClass:[UIScrollView class] inView:self.selectedViewController.view];
        if(toppestScrollView.contentInset.bottom == 0.0f) { //Won't adjust scrollView contentInsets if scrollview contentInset have already set.
            UIEdgeInsets scrollViewContentInsets = (UIEdgeInsets)toppestScrollView.contentInset;
            scrollViewContentInsets.bottom = CGRectGetHeight(self.tabBar.bounds);
            toppestScrollView.contentInset = scrollViewContentInsets;
        }
    }
}

-(CGFloat)tabBarHeight{
    return STTabBarDefaultHeight;
}


-(void)setIsTabBarHidden:(BOOL)isTabBarHidden{
    [self setTabBarHidden:isTabBarHidden animated:NO];
}

-(void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated{
    _isTabBarHidden = hidden;
    
    CGFloat height = hidden ? 0.1 : STTabBarDefaultHeight;
    
    CGFloat duration = animated ? UINavigationControllerHideShowBarDuration : 0.0;
    self.tabBar.userInteractionEnabled = NO;
    [UIView animateWithDuration:duration animations:^{
        self.tabBarHeightCon.constant = height;
    } completion:^(BOOL finished) {
        self.tabBar.userInteractionEnabled = YES;
    }];
    
}

-(UINavigationController *)moreNavigationController{
    if (!_moreNavigationController) {
        STTabBarMoreViewController * moreViewController = [[STTabBarMoreViewController alloc]init];
        UINavigationController * navi = [[UINavigationController alloc]initWithRootViewController:moreViewController];
        _moreViewController = moreViewController;
        _moreNavigationController = navi;
        _moreViewController.tabBarController = self;
    }
    return _moreNavigationController;
}

-(void)setSelectedIndex:(NSUInteger)selectedIndex{
    if (_selectedIndex == selectedIndex) return;
    
    if (selectedIndex > self.tabBar.items.count-1) {
        [[NSException exceptionWithName:NSRangeException reason:@"选择的下标数大于TabBar items的总数" userInfo:nil] raise];
        return;
    }
    _selectedIndex = selectedIndex;
    STBarItem * item = self.tabBar.items[selectedIndex];
    [item sendActionsForControlEvents:UIControlEventTouchUpInside];
}

-(BOOL)shouldShowMore{
    return self.viewControllers.count > STTabBarMaxItemCount ? YES :NO;
}

-(void)setViewControllers:(NSArray *)viewControllers{
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated{
    _viewControllers = [viewControllers copy];
    
    NSMutableArray * items = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    
    [viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL * _Nonnull stop) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        UIViewController * rootVC = viewController;
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController * navi = (UINavigationController *)viewController;
            rootVC = navi.viewControllers.count ? navi.viewControllers[0] : rootVC;
            navi.delegate = self;
        }
        
        STBarItem * item;
        if (idx == STTabBarMaxItemCount-1 && strongSelf.shouldShowMore) {
            *stop = YES;
            item = [strongSelf tabBarItemForViewController:strongSelf.moreNavigationController];
            strongSelf.moreTabBarItem = item;
        }else{
            item = [strongSelf tabBarItemForViewController:rootVC];
        }
        [items addObject:item];
    }];
    self.tabBar.items = items;
}

-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    self.tabBarBottomCon.constant = -contentInsets.bottom;
   // if (self.currentController) {
    //    CGRect frame = self.currentController.view.frame;
    //    frame.size.height = self.currentController.view.superview.bounds.size.height-64;
     //   self.currentController.view.frame = frame;
    //}
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    NSLog(@"zzzzz");
}

-(void)viewWillLayoutSubviews{
    NSLog(@"ssss");
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(BOOL)childViewControllerShouldNeedBannerView{
    if ([self isKindOfClass:[STTabBarController class]]){
        return YES;
    }
    else if (self.st_tabBarController){
        if ([self.st_tabBarController isKindOfClass:[STTabBarController class]])
            return NO;
    }
    return YES;
}

+(void)load{
    Method method1 = class_getInstanceMethod([BaseViewController class], NSSelectorFromString(@"needLoadBannerAdView"));
    
    Method method2 = class_getInstanceMethod([self class], @selector(childViewControllerShouldNeedBannerView));
    method_exchangeImplementations(method1, method2);
}


#pragma mark - delehate

-(BOOL)tabBar:(STTabBar *)tabBar shouldSelectItem:(STBarItem *)item{
    if ([self.delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]) {
        return [self.delegate tabBarController:self shouldSelectViewController:[self viewControllerForTabBarItem:item]];
    }
    return YES;
}

-(void)tabBar:(STTabBar *)tabBar didSelectItem:(STBarItem *)item{
    if ([self.delegate respondsToSelector:@selector(tabBarController:willSelectViewController:)]) {
        [self.delegate tabBarController:self willSelectViewController:[self viewControllerForTabBarItem:item]];
    }
    [self selectTabBarItem:item];
    if (self.navigationController) {
        self.navigationController.navigationBar.hidden = YES;
    }
    
    if ([self.delegate respondsToSelector:@selector(tabbarController:didSelectViewController:)]) {
        [self.delegate tabbarController:self didSelectViewController:[self viewControllerForTabBarItem:item]];
    }
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    self.currentController = viewController;
}
-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
}
@end

@implementation UIViewController (STTabBarControllerItem)

static char *STTabBarItemKey;

-(void)setSt_tabBarItem:(STBarItem *)st_tabBarItem{
    objc_setAssociatedObject(self, &STTabBarItemKey, st_tabBarItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(STBarItem *)st_tabBarItem{
    return objc_getAssociatedObject(self, &STTabBarItemKey);
}

-(STTabBarController *)st_tabBarController{
    
    if ([self.parentViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController * parent = self.parentViewController;
        if ([parent.parentViewController isKindOfClass:[STTabBarController class]]) {
            return (STTabBarController *)parent.parentViewController;
        }else{
            return nil;
        }
    }
    else if ([self.parentViewController isKindOfClass:[STTabBarController class]]) {
        return (STTabBarController *)self.parentViewController;
    }else{
        return nil;
    }
}



@end

