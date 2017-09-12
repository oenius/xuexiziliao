 //
//  TextContentView.m
//  InstaMessage
//
//  Created by 何少博 on 16/7/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "TextContentView.h"
#import "TextViewModel.h"
#import "CustonCollectionViewCell.h"
//#import "NSObject+x.h"
#import "UIColor+x.h"
#import "Macros.h"
#import "NPCommonConfig.h"
@interface TextContentView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectonView;
@property (weak, nonatomic) IBOutlet UISlider *fontSizeSlider;
@property (weak, nonatomic) IBOutlet UISlider *hangJianJuSlider;
@property (weak, nonatomic) IBOutlet UISlider *ziJianJuSlider;
@property (weak, nonatomic) IBOutlet UISlider *textAlphaSlider;


@property (assign,nonatomic) CGSize cellSize;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sliderBottom;


@property (strong,nonatomic) NSIndexPath * currIndexPath;
@property (strong,nonatomic)NSMutableArray * textActionlArray;

@property (assign,nonatomic)BOOL isEditingText;
@end

static NSString * cellID = @"cell";

@implementation TextContentView


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(NSMutableArray *)textActionlArray{
    if (_textActionlArray == nil) {
        
        _textActionlArray = [self getTextActionArrayAddADAction:[self adIsReady]];
    }
    return _textActionlArray;
}

-(BOOL)adIsReady{
    BOOL isReady = NO;
    isReady = ([[NPCommonConfig shareInstance]isInterstitialAdReady]||[[NPCommonConfig shareInstance]isNativeExpress250HAdReady]);
    return isReady;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.collectonView.delegate = self;
    self.collectonView.dataSource = self;
    self.collectonView.backgroundColor = [UIColor whiteColor];
    self.ziJianJuSlider.hidden = YES;
    self.hangJianJuSlider.hidden = YES;
    self.fontSizeSlider.hidden = NO;
    self.textAlphaSlider.hidden = YES;
    [self.collectonView registerClass:[CustonCollectionViewCell class] forCellWithReuseIdentifier:cellID];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(advertiseInterstitialNoti:) name:kAdvertiseGoogleInterstitialNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAdNoti:) name:kAdvertiseRemoveAdsNotification object:nil];
}

-(NSMutableArray *)getTextActionArrayAddADAction:(BOOL)addADAction{
    //后期将切图名称写入plist文件，加载
    NSMutableArray * tempArray = [NSMutableArray array];
    NSString * path = [[NSBundle mainBundle]pathForResource:@"textAction" ofType:@"plist"];
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
        NSMutableArray * tempArray = [weakSelf getTextActionArrayAddADAction:ad];
        if (weakSelf.textActionlArray.count != tempArray.count) {
            weakSelf.textActionlArray = tempArray;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.collectonView reloadData];
            });
        }
    });
    
}

//全屏广告加载出来
-(void)advertiseInterstitialNoti:(NSNotification *)notif{
    [self reloadDataWithAD:YES];
}

//移除广告通知
-(void)removeAdNoti:(NSNotification *)notif{
    [self reloadDataWithAD:NO];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    //设置collectionView
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset=UIEdgeInsetsMake(3, 0, 3, 0);
    layout.itemSize= CGSizeMake(40,40);
    self.cellSize = layout.itemSize;
    layout.minimumInteritemSpacing= 3;
    layout.minimumLineSpacing= 10;
    layout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    self.collectonView.collectionViewLayout = layout;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.sliderTop.constant = 30;
        self.sliderBottom.constant = 30;
    }
}
#pragma mark - sliderValueChange

- (IBAction)lineSpaceValueChange:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(textContentView:lineSpaceValueChange:)]) {
        [self.delegate textContentView:self lineSpaceValueChange:sender.value];
    }
}

- (IBAction)fontSizeValueChange:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(textContentView:fontSizeValueChange:)]) {
        [self.delegate textContentView:self fontSizeValueChange:sender.value];
    }
}

- (IBAction)charSpaceValueChange:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(textContentView:charSpaceValueChange:)]) {
        [self.delegate textContentView:self charSpaceValueChange:sender.value];
    }
}
- (IBAction)textAlphaValueChange:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(textContentView:textAlphaValueChange:)]) {
        [self.delegate textContentView:self textAlphaValueChange:sender.value];
    }
}


#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.textActionlArray.count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CustonCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    TextViewModel * model = self.textActionlArray[indexPath.row];
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
    TextActionTag tag = cell.textModel.acrionTag.integerValue;
    
    if (tag == TextActionTag_size) {
        [self setFontSizeSliderHidden:NO hangJianJuSliderHidden:YES ziJianJuSliderHidden:YES textAlphaSilderHidden:YES];
    }
    else if (tag == TextActionTag_char_space){
        [self setFontSizeSliderHidden:YES hangJianJuSliderHidden:YES ziJianJuSliderHidden:NO textAlphaSilderHidden:YES];
    }
    else if (tag == TextActionTag_line_space){
        [self setFontSizeSliderHidden:YES hangJianJuSliderHidden:NO ziJianJuSliderHidden:YES textAlphaSilderHidden:YES];
    }
    else if (tag == TextActionTag_textAlpha){
        [self setFontSizeSliderHidden:YES hangJianJuSliderHidden:YES ziJianJuSliderHidden:YES textAlphaSilderHidden:NO];
    }
    else{
        [self setFontSizeSliderHidden:YES hangJianJuSliderHidden:YES ziJianJuSliderHidden:YES textAlphaSilderHidden:YES];
    }
    
    if ([self.delegate respondsToSelector:@selector(textContentView:fontSettingCellClick:)]) {
        [self.delegate textContentView:self fontSettingCellClick:tag];
    }
    cell.backgroundColor = [color_2083fc colorWithAlphaComponent:0.3];
    self.currIndexPath = indexPath;
    [self setSelectCellStayusIndexPath:indexPath];
}

-(void)setSelectCellStayusIndexPath:(NSIndexPath *)indexPath{
    int count = (int)self.textActionlArray.count;
    for (int i = 0; i<count; i++) {
        if (i == indexPath.row) continue;
        NSIndexPath * indexPath_ = [NSIndexPath indexPathForRow:i inSection:0];
        CustonCollectionViewCell * cell = (CustonCollectionViewCell *)[self.collectonView cellForItemAtIndexPath:indexPath_];
        cell.backgroundColor = [UIColor whiteColor];
    }
}

-(void)setFontSizeSliderHidden:(BOOL)fontHidden hangJianJuSliderHidden:(BOOL)hangHidden ziJianJuSliderHidden:(BOOL)ziHidden textAlphaSilderHidden:(BOOL)textAlphaHidden{
    self.ziJianJuSlider.hidden = ziHidden;
    self.hangJianJuSlider.hidden = hangHidden;
    self.fontSizeSlider.hidden = fontHidden;
    self.textAlphaSlider.hidden = textAlphaHidden;
}
-(BOOL)isHiddenBannerView{
    BOOL hidden = NO;
    if (self.ziJianJuSlider.hidden == NO ||
        self.hangJianJuSlider.hidden == NO ||
        self.fontSizeSlider.hidden == NO ||
        self.textAlphaSlider.hidden == NO)
    {
        hidden = YES;
    }
    return hidden;
}

@end
