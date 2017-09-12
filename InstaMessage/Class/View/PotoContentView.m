//
//  PotoContentView.m
//  InstaMessage
//
//  Created by 何少博 on 16/7/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "PotoContentView.h"
#import "NSObject+x.h"
#import "CustonCollectionViewCell.h"
#import "UIColor+x.h"
#import "Macros.h"
#import "NPCommonConfig.h"
@interface PotoContentView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UISlider *duiBiDuSlider;
@property (weak, nonatomic) IBOutlet UISlider *liangDuSlider;
@property (weak, nonatomic) IBOutlet UISlider *baoHeDuSlider;
@property (weak, nonatomic) IBOutlet UISlider *maoBoLiSlider;

@property (assign,nonatomic) CGSize cellSize;
@property (strong,nonatomic)NSMutableArray * photoActionArray;
@property (strong,nonatomic) NSIndexPath * currIndexPath;
@end

static NSString * cellID = @"cell";

@implementation PotoContentView

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(NSMutableArray *)photoActionArray{
    if (_photoActionArray == nil) {
        //后期将切图名称写入plist文件，加载
        
        _photoActionArray = [self getPhotoActionArraAddADAction:[self adIsReady]];
    }
    return _photoActionArray;
}

-(BOOL)adIsReady{
    BOOL isReady = NO;
    isReady = ([[NPCommonConfig shareInstance]isInterstitialAdReady]||[[NPCommonConfig shareInstance]isNativeExpress250HAdReady]);
    return isReady;
}

-(NSMutableArray *)getPhotoActionArraAddADAction:(BOOL)addADAction{
    //后期将切图名称写入plist文件，加载
    NSMutableArray * tempArray = [NSMutableArray array];
    NSString * path = [[NSBundle mainBundle]pathForResource:@"photoAction" ofType:@"plist"];
    NSArray * dicArray = [NSArray arrayWithContentsOfFile:path];
    for (NSDictionary * dic in dicArray) {
        TextViewModel * model = [TextViewModel textViewModelWithDictionary:dic];
        if (!addADAction) {
            if ([model.imageName isEqualToString:@"AD"]) {
                continue;
            }
        }
        
        [tempArray addObject:model];
    }
    return tempArray;
}

-(void)reloadDataWithAD:(BOOL)ad{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray * tempArray = [weakSelf getPhotoActionArraAddADAction:ad];
        if (weakSelf.photoActionArray.count != tempArray.count) {
            weakSelf.photoActionArray = tempArray;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.collectionView reloadData];
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



-(void)awakeFromNib{
    [super awakeFromNib];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[CustonCollectionViewCell class] forCellWithReuseIdentifier:cellID];
    [self setDuiBiDuSliderHidden:YES liangDuSliderHidden:YES baoHeDuSliderHidden:YES maoBoLiSliderHidden:YES];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(advertiseInterstitialNotification:) name:kAdvertiseGoogleInterstitialNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAdNotification:) name:kAdvertiseRemoveAdsNotification object:nil];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    //设置collectionView
    CGSize size = self.collectionView.bounds.size;
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset=UIEdgeInsetsMake(3, 0, 3, 0);
    layout.itemSize= CGSizeMake(40,40);
    self.cellSize = layout.itemSize;
    layout.minimumInteritemSpacing= 3;
    layout.minimumLineSpacing= 10;
    layout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    self.collectionView.collectionViewLayout = layout;
}


#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photoActionArray.count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CustonCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    TextViewModel * model = self.photoActionArray[indexPath.row];
    cell.textModel = model;
    cell.layer.cornerRadius = 6;
    cell.layer.masksToBounds = YES;
    if (indexPath != self.currIndexPath) {
        cell.backgroundColor = [UIColor whiteColor];
    }else{
        cell.backgroundColor = [color_2083fc colorWithAlphaComponent:0.3];
    }
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CustonCollectionViewCell * cell = (CustonCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    PhotoActionTag tag = cell.textModel.acrionTag.integerValue;
    switch (tag) {
        case PhotoAction_Camera:
        case PhotoAction_Album:
        case PhotoAction_UpDown:
        case PhotoAction_LeftRight:
        {
            [self setDuiBiDuSliderHidden:YES liangDuSliderHidden:YES baoHeDuSliderHidden:YES maoBoLiSliderHidden:YES];
//            if ([self.delegate respondsToSelector:@selector(potoContentView:actionWithTag:)]) {
//                [self.delegate potoContentView:self actionWithTag:tag];
//            }
        }
            break;
        case PhotoAction_BaoHeDu:
            [self setDuiBiDuSliderHidden:YES liangDuSliderHidden:YES baoHeDuSliderHidden:NO maoBoLiSliderHidden:YES];
            break;
        case PhotoAction_LiangDu:
            [self setDuiBiDuSliderHidden:YES liangDuSliderHidden:NO baoHeDuSliderHidden:YES maoBoLiSliderHidden:YES];
            break;
        case PhotoAction_DuiBiDu:
            [self setDuiBiDuSliderHidden:NO liangDuSliderHidden:YES baoHeDuSliderHidden:YES maoBoLiSliderHidden:YES];
            break;
        case PhotoAction_MaoBoLi:
            [self setDuiBiDuSliderHidden:YES liangDuSliderHidden:YES baoHeDuSliderHidden:YES maoBoLiSliderHidden:NO];
            break;
        default:
            break;
    }
    if ([self.delegate respondsToSelector:@selector(potoContentView:actionWithTag:)]) {
        [self.delegate potoContentView:self actionWithTag:tag];
    }
    cell.backgroundColor = [color_2083fc colorWithAlphaComponent:0.3];
    self.currIndexPath = indexPath;
    [self setSelectCellStayusIndexPath:indexPath];
}
-(void)setSelectCellStayusIndexPath:(NSIndexPath *)indexPath{
    int count = (int)self.photoActionArray.count;
    for (int i = 0; i<count; i++) {
        if (i == indexPath.row) continue;
        NSIndexPath * indexPath_ = [NSIndexPath indexPathForRow:i inSection:0];
        CustonCollectionViewCell * cell = (CustonCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath_];
        cell.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - sliderAction
- (IBAction)duiBiDuSliderTouchUpInside:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(potoContentView:duiBiDuValue:)]) {
        [self.delegate potoContentView:self duiBiDuValue:sender.value];
    }
}
- (IBAction)liangDuSliderTouchUpInside:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(potoContentView:liangDuValue:)]) {
        [self.delegate potoContentView:self liangDuValue:sender.value];
    }
}
- (IBAction)baoheDuSliderTouchUpInside:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(potoContentView:baoHeDuValue:)]) {
        [self.delegate potoContentView:self baoHeDuValue:sender.value];
    }
}

- (IBAction)maoaBoLiValueChange:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(potoContentView:maoBoLiValue:)]) {
        [self.delegate potoContentView:self maoBoLiValue:sender.value];
    }
}

-(void)setDuiBiDuSliderHidden:(BOOL)duibidu liangDuSliderHidden:(BOOL)liangdu baoHeDuSliderHidden:(BOOL)baohedu maoBoLiSliderHidden:(BOOL)maoboli{
    self.duiBiDuSlider.hidden = duibidu;
    self.liangDuSlider.hidden = liangdu;
    self.baoHeDuSlider.hidden = baohedu;
    self.maoBoLiSlider.hidden = maoboli;
}

-(BOOL)isHiddenBannerView{
    BOOL hidden = NO;
    if (self.duiBiDuSlider.hidden == NO ||
        self.liangDuSlider.hidden == NO ||
        self.baoHeDuSlider.hidden == NO ||
        self.maoBoLiSlider.hidden == NO)
    {
        hidden = YES;
    }
    return hidden;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
