//
//  CIGuideViewController.m
//  CutoutImage
//
//  Created by 何少博 on 17/2/17.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "CIGuideViewController.h"
#import "CIGuideDeatilView.h"
#import "UIColor+x.h"

@interface CIGuideViewController ()<UIScrollViewDelegate>
@property (strong, nonatomic)  UIScrollView * scrollView;
@property (strong, nonatomic)  NSMutableArray * scrollViewSubviews;
@property (strong, nonatomic)  UIPageControl *pageControl;
@property (strong, nonatomic)  NSLayoutConstraint *scrollViewBottom;
@property (assign, nonatomic)  UIEdgeInsets contentInsets;
@end

@implementation CIGuideViewController

-(NSMutableArray *)scrollViewSubviews{
    if (nil == _scrollViewSubviews) {
        _scrollViewSubviews  = [NSMutableArray array];
    }
    return _scrollViewSubviews;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupView];
    self.navigationItem.title = CI_Tutorial;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:CI_Back style:(UIBarButtonItemStylePlain) target:self action:@selector(disMissSelf)];
    NSDictionary * attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationController.navigationBar.titleTextAttributes = attributes;
}


-(void)disMissSelf{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)setupView{
    //根据BMMaintennanceDetailVie的枚举类型添加View，公用五中
    self.scrollView = [[UIScrollView alloc]init];
    [self.view addSubview:self.scrollView];
    for (int i = 0; i < 5; i ++) {
        CIGuideDeatilView * deatilView = [[CIGuideDeatilView alloc]initWithFrame:CGRectZero type:i];
        [self.scrollView addSubview:deatilView];
        [self.scrollViewSubviews addObject:deatilView];
    }
    self.scrollView.delegate =self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor colorWithRed:17.0/255 green:17.0/255 blue:17.0/255 alpha:1];
    
    self.pageControl = [[UIPageControl alloc]init];
    [self.view addSubview:self.pageControl];
    self.pageControl.numberOfPages = 5;
    self.pageControl.tintColor = [UIColor whiteColor];
    self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"f08d33"];
    [self.pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:(UIControlEventValueChanged)];
}

-(void)setContentInsets:(UIEdgeInsets)contentInsets{
    _contentInsets = contentInsets;
    CGRect frame = self.view.bounds;
    frame.size.height -= _contentInsets.bottom;
    self.scrollView.frame = frame;
    CGFloat viewWidth = frame.size.width;
    CGFloat viewHeight = frame.size.height;
    
    self.pageControl.frame = CGRectMake(0, 0, viewWidth/2, 30);
    self.pageControl.center = CGPointMake(viewWidth/2, viewHeight-10-15);
    
    for (int i = 0; i < self.scrollViewSubviews.count; i ++) {
        CIGuideDeatilView * detailView = self.scrollViewSubviews[i];
        CGFloat x = i * viewWidth;
        detailView.frame = CGRectMake(x, 0, viewWidth, viewHeight);
    }
    self.scrollView.contentSize = CGSizeMake(viewWidth*self.scrollViewSubviews.count, viewWidth);
    LOG(@"%@",NSStringFromCGRect(self.view.frame));
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    if (self.contentInsets.top != -1) {
        self.contentInsets = UIEdgeInsetsMake(-1, 0, 0, 0);
    }
}

-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    contentInsets.top = -1;
    self.contentInsets = contentInsets;
}

- (void)setCurrentPage:(NSInteger)page animated:(BOOL)animated
{
    if(page >= [self.scrollViewSubviews count]){ return;}
    
    CGRect rect = CGRectMake(page*_scrollView.bounds.size.width, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height);
    [self.scrollView scrollRectToVisible:rect animated:animated];
}
- (void)pageControlValueChanged:(UIPageControl *)sender {
    [self setCurrentPage:sender.currentPage animated:YES];
}
#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger  page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    if (page != self.pageControl.currentPage) {
        self.pageControl.currentPage = page;
    }
}
@end
