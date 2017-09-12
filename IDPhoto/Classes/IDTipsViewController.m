//
//  IDTipsViewController.m
//  IDPhoto
//
//  Created by 何少博 on 17/5/9.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDTipsViewController.h"
#import "DTipsViews.h"
@interface IDTipsViewController ()<UIScrollViewDelegate>
@property (strong, nonatomic)  UIScrollView * scrollView;
@property (strong, nonatomic)  NSMutableArray * scrollViewSubviews;
@property (strong, nonatomic)  UIPageControl *pageControl;
@property (strong, nonatomic)  NSLayoutConstraint *scrollViewBottom;
@property (assign, nonatomic)  UIEdgeInsets contentInsets;

@end

@implementation IDTipsViewController
-(NSMutableArray *)scrollViewSubviews{
    if (nil == _scrollViewSubviews) {
        _scrollViewSubviews  = [NSMutableArray array];
    }
    return _scrollViewSubviews;
}
- (void)viewDidLoad {
    [super viewDidLoad];
     [self setupView];
}
-(void)disMissSelf{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)setupView{
    
    self.scrollView = [[UIScrollView alloc]init];
    [self.view addSubview:self.scrollView];
    DTipsViews * tips = [[DTipsViews alloc]init];
    [tips addKnowBtnTarget:self action:@selector(disMissSelf)];
    [self.scrollViewSubviews addObjectsFromArray:tips.tipViews];
    for (int i = 0; i < self.scrollViewSubviews.count; i ++) {
        UIView * tip = self.scrollViewSubviews[i];
        [self.scrollView addSubview:tip];
    }
    self.scrollView.delegate =self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor colorWithRed:17.0/255 green:17.0/255 blue:17.0/255 alpha:1];
    
    self.pageControl = [[UIPageControl alloc]init];
    [self.view addSubview:self.pageControl];
    self.pageControl.numberOfPages = self.scrollViewSubviews.count;
    self.pageControl.tintColor = [UIColor whiteColor];
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
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
        UIView * detailView = self.scrollViewSubviews[i];
        CGFloat x = i * viewWidth;
        detailView.frame = CGRectMake(x, 0, viewWidth, viewHeight);
    }
    self.scrollView.contentSize = CGSizeMake(viewWidth*self.scrollViewSubviews.count, viewWidth);
   
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
