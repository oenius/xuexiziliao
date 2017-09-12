//
//  IDTypeChoiceViewController.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/21.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDTypeChoiceViewController.h"
#import "IDTypeViewModel.h"
#import "IDTypeCollectionViewCell.h"
#import "IDPhotoChoiceViewController.h"
#import "UINavigationController+x.h"
#import "IDSettingsViewController.h"
#import "NPCommonConfig.h"

@interface IDTypeChoiceViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) IDTypeViewModel * viewModel;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewBottom;


@end


static NSString * const kIDTypeCollectionViewCellID = @"IDTypeCollectionViewCellID";


@implementation IDTypeChoiceViewController


#pragma mark - 

#pragma mark - 视图生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [IDConst instance].CommonlyUsedSize;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController usingTheGradient];
    [self.navigationController usingWhiteColor];
    UIImage * backImage = [UIImage imageNamed:@"iphonebg"]; ;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        backImage = [UIImage imageNamed:@"ipadbg"];
    }
    
    self.view.layer.contents = (__bridge id _Nullable)(backImage.CGImage);
    [self setupCollection];
    [self setupNavi];
}

-(void)setupNavi{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"set"] style:(UIBarButtonItemStylePlain) target:self action:@selector(goSettings)];
    if ([[NPCommonConfig shareInstance] shouldShowAdvertise]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ads@pro"] style:(UIBarButtonItemStylePlain) target:self action:@selector(goPro)];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController usingTheGradient];
    [self.navigationController usingWhiteColor];
}

-(void)setupCollection{
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    UICollectionViewFlowLayout * flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    NSUInteger rowCount = 2;
    CGFloat spacing = 20;
    if ([self isPad]) {
        rowCount = 4;
        spacing = 40;
    }
    CGFloat cellWidth = (self.view.bounds.size.width - spacing * (rowCount+1))/rowCount;
    CGFloat cellHeight = cellWidth*3/2;
    flowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
    flowLayout.minimumLineSpacing = spacing;
    flowLayout.minimumInteritemSpacing  = spacing;
    self.collectionView.collectionViewLayout = flowLayout;
    self.collectionView.contentInset = UIEdgeInsetsMake(spacing/2, spacing, 0, spacing);
}


#pragma mark - 懒加载
-(IDTypeViewModel *)viewModel{
    if (_viewModel == nil) {
        _viewModel = [IDTypeViewModel new];
    }
    return _viewModel;
}


#pragma mark - <UICollectionViewDelegate,UICollectionViewDataSource>
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [self.viewModel numberOfSectionsInCollectionView];
    
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.viewModel numberOfItemsInSection:section];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    IDTypeCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kIDTypeCollectionViewCellID forIndexPath:indexPath];
    cell.model = [self.viewModel cellModelAtIndexPath:indexPath];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    IDTypeModel * model = [self.viewModel cellModelAtIndexPath:indexPath];
    IDPhotoChoiceViewController * photoChoice = [[IDPhotoChoiceViewController alloc]initWithIDType:model.IPType];
    [self.navigationController pushViewController:photoChoice animated:YES];
}

#pragma mark - actions

-(void)goSettings{
    IDSettingsViewController * set = [[IDSettingsViewController alloc]init];
    [self.navigationController pushViewController:set animated:YES];
}
-(void)goPro{
    [[NPCommonConfig shareInstance]gotoBuyProVersion];
}

#pragma mark - 加载广告位置调整

-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    self.collectionViewBottom.constant = contentInsets.bottom;
    [self.view setViewLayoutAnimation];
}

-(void)removeAdNotification:(NSNotification *)notification{
    [super removeAdNotification:notification];
    self.navigationItem.rightBarButtonItem = nil;
}

@end
