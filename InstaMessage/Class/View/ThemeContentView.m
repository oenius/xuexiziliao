//
//  ThemeContentView.m
//  InstaMessage
//
//  Created by 何少博 on 16/7/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "ThemeContentView.h"
#import "UIColor+x.h"
#import "Macros.h"
#import "NPCommonConfig.h"
#define SCROLLVIEW_TAG 1000

@interface ThemeContentView ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UIScrollViewDelegate
>
//============================




@property (strong,nonatomic) UIScrollView * scrollView;
@property (strong,nonatomic) UISlider * slider;

@property (strong,nonatomic) NSString * currentThemeName;
@property (strong,nonatomic) NSMutableArray *allThemeNameArray;
@property (strong,nonatomic) NSMutableArray * scrollViewButtonArray;
@property (strong,nonatomic) NSMutableArray *allThemeItemArray;
@property (strong,nonatomic) NSMutableArray *allThemeItemModelArray;
@property (strong,nonatomic) NSMutableArray *themePostionOnCollectionViewArray;
@property (strong,nonatomic) NSMutableArray *themePostionOnScrollViewArray;

@property (assign,nonatomic) NSInteger totalThemeItem;
@property (assign,nonatomic) CGSize cellSize;
@property (assign,nonatomic) BOOL isCounting;


@end

static NSString * cell_ID = @"cell_ID";
static int space = 10;

@implementation ThemeContentView

#pragma mark - 初始化
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        //添加editThemeCollectionView
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset=UIEdgeInsetsMake(5, 0, 5, 0);
        layout.itemSize= CGSizeMake(frame.size.height/2,frame.size.height/2);
        layout.minimumInteritemSpacing= space;
        layout.minimumLineSpacing= space;
        layout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
        self.editThemeCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self.editThemeCollectionView.delegate = self;
        self.editThemeCollectionView.dataSource = self;
        [self.editThemeCollectionView registerClass:[CustonCollectionViewCell class] forCellWithReuseIdentifier:cell_ID];
        [self addSubview: self.editThemeCollectionView];
        
        //添加scrollView
        self.scrollView = [[UIScrollView alloc]init];
        self.scrollView.delegate = self;
        self.scrollView.tag = SCROLLVIEW_TAG;
        int count = (int)self.allThemeNameArray.count;
        for (int i =0; i< count; i++) {
            UIButton * button = [[UIButton alloc]init];
            button.tag = i;
            [button addTarget:self action:@selector(onScrollViewButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//            button.backgroundColor = []
            [self.scrollViewButtonArray addObject:button];
            [self.scrollView addSubview:button];
        }
        [self addSubview:self.scrollView];
        
        //添加slider
        self.slider = [[UISlider alloc]init];
        self.slider.value = 1;
        [self.slider addTarget:self action:@selector(onSliderValueChange:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.slider];
        
        self.editThemeCollectionView.backgroundColor = [UIColor whiteColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(advertiseInterstitialNotification:) name:kAdvertiseGoogleInterstitialNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAdNotification:) name:kAdvertiseRemoveAdsNotification object:nil];

    }
    return self;
}

-(void)becomeActiveNotification{
    [self.editThemeCollectionView reloadData];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat H = self.bounds.size.height;
    CGFloat W = self.bounds.size.width;
    //设置collectionView
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset=UIEdgeInsetsMake(5, 0, 5, 0);
    layout.itemSize= CGSizeMake(H/2,H/2);
    self.cellSize = layout.itemSize;
    layout.minimumInteritemSpacing= space;
    layout.minimumLineSpacing= space;
    layout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    self.editThemeCollectionView.frame = CGRectMake(0, H/4, W, H/2);
    self.editThemeCollectionView.collectionViewLayout = layout;
    //设置UIScrollView
    self.scrollView.frame = CGRectMake(0, H*3/4, W, H/4);
    int count = (int)self.allThemeNameArray.count;
    double x = 0;
    for (int i =0; i< count; i++) {
        
        UIButton * button = self.scrollViewButtonArray[i];
        NSString * titleString = self.allThemeNameArray[i];
        [button setTitle:titleString forState:UIControlStateNormal];
        UIColor * color = [UIColor grayColor];
        if (i==0)  color = color_2083fc;
        [button setTitleColor:color forState:UIControlStateNormal];
        UIFont * font = [UIFont systemFontOfSize:15];
        button.titleLabel.font = font;
        button.titleLabel.lineBreakMode =NSLineBreakByTruncatingTail ;
        
        button.frame =CGRectMake(x,0,W/2, H/4);
        if (i == 0) [self.themePostionOnScrollViewArray removeAllObjects];
        [self.themePostionOnScrollViewArray addObject:[NSNumber numberWithDouble:x]];
        x += W/2;
    }
    self.scrollView.contentSize = CGSizeMake(W, 0);
    //设置slider
    self.slider.frame = CGRectMake(W/4,0, W/2, H/4);
    [self performSelectorInBackground:@selector(countThemePostionOnCollectionView) withObject:nil];
}

#pragma mark - 加载
-(NSMutableArray *)allThemeItemArray{
    if (_allThemeItemArray == nil) {
        _allThemeItemArray = [ThemeItemModel getAllThemeItemArray];
    }
    return _allThemeItemArray;
}
-(NSMutableArray *)allThemeNameArray{
    if (_allThemeNameArray == nil) {
        _allThemeNameArray = [NSMutableArray arrayWithObjects:@"Base", @"Photo", nil];
    }
    return _allThemeNameArray;
}
-(NSMutableArray *)scrollViewButtonArray{
    if (_scrollViewButtonArray == nil) {
        _scrollViewButtonArray = [NSMutableArray array];
    }
    return _scrollViewButtonArray;
}
-(NSMutableArray *)allThemeItemModelArray{
    if (_allThemeItemModelArray == nil) {
        
        _allThemeItemModelArray = [self getAllThemeItemModelArrayAddADAction:[self adIsReady]];
    }
    return _allThemeItemModelArray;
}


-(BOOL)adIsReady{
    BOOL isReady = NO;
    isReady = ([[NPCommonConfig shareInstance]isInterstitialAdReady]||[[NPCommonConfig shareInstance]isNativeExpress250HAdReady]);
    return isReady;
}


-(NSMutableArray *)getAllThemeItemModelArrayAddADAction:(BOOL)addADAction{
    NSMutableArray * tempAllThemeItemModelArray = [NSMutableArray array];
    for (NSArray * tempArray in self.allThemeItemArray) {
        for (NSDictionary * dic in tempArray) {
            ThemeItemModel * model = [ThemeItemModel themeItemModelWithDictionary:dic];
            if (!addADAction) {
                if ([model.thumbImageName isEqualToString:@"AD_147.png"]) {
                    continue;
                }
            }
            [tempAllThemeItemModelArray addObject:model];
        }
    }
    return tempAllThemeItemModelArray;
}

-(void)reloadDataWithAD:(BOOL)ad{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray * tempArray = [weakSelf getAllThemeItemModelArrayAddADAction:ad];
        if (weakSelf.allThemeItemModelArray.count != tempArray.count) {
            weakSelf.allThemeItemModelArray = tempArray;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.editThemeCollectionView reloadData];
            });
        }
    });
    
}

//全屏广告加载出来
-(void)advertiseInterstitialNotification:(NSNotification *)notif{
    [self reloadDataWithAD:YES];
}

//移除广告通知
-(void)removeAdNotification:(NSNotification *)notif{
    [self reloadDataWithAD:NO];
}



-(NSMutableArray *)themePostionOnCollectionViewArray{
    if (_themePostionOnCollectionViewArray == nil) {
        _themePostionOnCollectionViewArray = [NSMutableArray array];
    }
    return _themePostionOnCollectionViewArray;
}
-(NSMutableArray *)themePostionOnScrollViewArray{
    if (_themePostionOnScrollViewArray == nil) {
        _themePostionOnScrollViewArray = [NSMutableArray array];
    }
    return _themePostionOnScrollViewArray;
}
//计算themePostionOnCollectionViewArray内容
-(void)countThemePostionOnCollectionView{
    
    int count = (int)self.allThemeItemArray.count;
    double position = 0;
    for (int i = 0; i < count; i++) {
        position += ([self.allThemeItemArray[i] count] * (self.cellSize.width + space));
        [self.themePostionOnCollectionViewArray addObject:[NSNumber numberWithDouble:position]];
    }
}

//设置偏移量
-(void)setOffset:(CGFloat)offsetX{
    self.isCounting = YES;
    int count = (int)self.themePostionOnCollectionViewArray.count;
    double position;
    for (int i = 0; i < count; i++) {
        NSNumber * num = self.themePostionOnCollectionViewArray[i];
        position = num.doubleValue;
        if (offsetX<position) {
            [self setButtontTitleColor:i];
            break;
        }
    }
    self.isCounting = NO;
}
//计算所有主题总共包含的样式个数
-(NSInteger)totalThemeItem{
    if (_totalThemeItem == 0){
        _totalThemeItem = self.allThemeItemModelArray.count;
    }
    return _totalThemeItem;
}

#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.totalThemeItem;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CustonCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cell_ID forIndexPath:indexPath];
    ThemeItemModel * model = self.allThemeItemModelArray[indexPath.row];
    cell.model = model;
    cell.layer.cornerRadius = 8;
    cell.layer.masksToBounds = YES;
    cell.layer.borderColor = color_2083fc.CGColor;
    cell.layer.borderWidth = 1;
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CustonCollectionViewCell * cell = (CustonCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(themeContentView:ChooseTheme:)]) {
        [self.delegate themeContentView:self ChooseTheme:cell.model];
    }
}
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath {
    
}
#pragma mark - UIScrollViewDelegate
//检测collectionView滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView.tag == SCROLLVIEW_TAG) return;
    if (self.isCounting) return;
    [self setOffset:scrollView.contentOffset.x];
}


#pragma mark - action
-(void)onScrollViewButtonClick:(UIButton*)sender{
    LOG(@"%ld",(long)sender.tag);
    [self setButtontTitleColor:sender.tag];
    double position = 0;
    CGPoint offset = CGPointZero;
    if (sender.tag == 0) {
        offset.x = position;
    }else{
        NSNumber * num = self.themePostionOnCollectionViewArray[sender.tag-1];
        position = num.doubleValue;
        offset.x = position;
    }
    self.editThemeCollectionView.contentOffset = offset;
}
-(void)onSliderValueChange:(UISlider*)sender{
    LOG(@"%g",sender.value);
    if ([self.delegate respondsToSelector:@selector(themeContentView:SliderValueChange:)]) {
        [self.delegate themeContentView:self SliderValueChange:sender.value];
    }
}
-(void)setButtontTitleColor:(NSInteger)btntag{
    for (UIButton * btn in self.scrollViewButtonArray) {
        if (btn.tag == btntag) {
            [btn setTitleColor:color_2083fc forState:UIControlStateNormal];
        }else{
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
    }
}

@end
