//
//  MEEqualizerListViewController.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/5.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "MEEqualizerListViewController.h"
#import "MEEqualizerListCollectionViewCell.h"
#import "MEEqualizerListViewModel.h"
#import "MEEqualizer.h"


@interface MEEqualizerListViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong,nonatomic) UICollectionView * collectionView;

@property (strong,nonatomic) MEEqualizerListViewModel * viewModel;

@property (strong,nonatomic) NSIndexPath * selectIndexPath;

@property (copy,nonatomic) EQSelectBlock block;

@property (strong,nonatomic) UIBarButtonItem * deleteItem ;

@end

NSString * const collectionViewCellID = @"MEEqualizerListCollectionViewCell";
CGFloat const spacing = 5.0;
NSInteger const lineCount = 4;

@implementation MEEqualizerListViewController

#pragma mark - 懒加载
-(MEEqualizerListViewModel *)viewModel{
    if (nil == _viewModel) {
        _viewModel = [MEEqualizerListViewModel new];
    }
    return _viewModel;
}

-(UIBarButtonItem *)deleteItem{
    if (nil == _deleteItem) {
        _deleteItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"delete"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteItemClick:)];
    }
    return _deleteItem;
}

#pragma mark - 视图相关

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupCollectionView];
}
-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
     
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    //设置layout和collectionFrame
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
    
    CGFloat collecWidth = self.view.bounds.size.width-spacing*2;
    CGFloat width = (collecWidth-(lineCount+1)*spacing)/4.0;
    flowLayout.itemSize = CGSizeMake(width, width);
    flowLayout.minimumLineSpacing = spacing;
    flowLayout.minimumInteritemSpacing = spacing;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView.collectionViewLayout = flowLayout;
    self.collectionView.frame = CGRectMake(spacing, spacing, collecWidth, self.view.bounds.size.height-spacing-self.bannerView.bounds.size.height);
}

-(void)setupCollectionView{
    self.view.backgroundColor = [UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1];
    
    
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1];
    UINib * nib = [UINib nibWithNibName:NSStringFromClass([MEEqualizerListCollectionViewCell class]) bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:collectionViewCellID];
    [self.view addSubview:self.collectionView];
}

#pragma mark - actions 

-(void)deleteItemClick:(UIBarButtonItem *)sender{
    [self.viewModel deleteEqualizerAtIndexPath:self.selectIndexPath];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [self.viewModel numberOfSectionsInCollectionView];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.viewModel numberOfItemsInSection:section];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MEEqualizerListCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionViewCellID forIndexPath:indexPath];
    [self fillCellInfo:cell atIndexPath:indexPath];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self fixCellHightStateAtIndexPath:self.selectIndexPath toHightState:NO];
    self.selectIndexPath = indexPath;
    [self fixCellHightStateAtIndexPath:self.selectIndexPath toHightState:YES];
    MEEqualizer * equalizer = [self.viewModel getEQModelAtIndexPath:indexPath];
    [self checkRightItemAtIndexPath:indexPath];
    self.block(equalizer);
}
#pragma actions

-(void)EQSelectedCallBack:(EQSelectBlock)block{
    self.block = block;
}

-(void)checkRightItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger count = [self.viewModel getDefaultEQCount];
    if (indexPath.row >= count) {
        if (self.navigationItem.rightBarButtonItem == nil) {
            self.navigationItem.rightBarButtonItem = self.deleteItem;
        }
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
}
#pragma mark - Other

-(void)fixCellHightStateAtIndexPath:(NSIndexPath *)indexPath toHightState:(BOOL) hightState{
    if (indexPath == nil) {return;}
    UICollectionViewCell  * cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    if (hightState) {
        cell.layer.borderColor = [UIColor whiteColor].CGColor;
    }else{
        cell.layer.borderColor = cell.backgroundColor.CGColor;
    }
    cell.layer.borderWidth = 2.0;
}

-(void)fillCellInfo:(MEEqualizerListCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    MEEqualizer * equalizer = [self.viewModel getEQModelAtIndexPath:indexPath];
    cell.nameLabel.text = [self fixEqualizerName:equalizer.name];
    cell.layer.cornerRadius = 8;
    cell.layer.masksToBounds = YES;
    if (self.selectIndexPath) {
        if (indexPath.row == self.selectIndexPath.row) {
            cell.layer.borderColor = [UIColor whiteColor].CGColor;
        }else{
            cell.layer.borderColor = cell.backgroundColor.CGColor;
        }
        cell.layer.borderWidth = 2.0;
    }
    
}
-(NSString *)fixEqualizerName:(NSString * )equalierName{
    NSString * name = equalierName;
    if ([equalierName isEqualToString:@"none"]) {
        name = MEL_none;
    }
    else if ([equalierName isEqualToString:@"Pop"]){
        name = MEL_Pop;
    }
    else if ([equalierName isEqualToString:@"Subwoofer"]){
        name = MEL_MegaBass;
    }
    else if ([equalierName isEqualToString:@"man_voice"]){
        name = MEL_Vocal;
    }
    else if ([equalierName isEqualToString:@"on_site"]){
        name = MEL_Live;
    }
    else if ([equalierName isEqualToString:@"Rock_Roll"]){
        name = MEL_Rock_Roll;
    }
    else if ([equalierName isEqualToString:@"ballad"]){
        name = MEL_Ballad;
    }
    else if ([equalierName isEqualToString:@"Drum & Bass"]){
        name = MEL_Drum_Bass;
    }
    else if ([equalierName isEqualToString:@"Jazz"]){
        name = MEL_Jazz;
    }
    else if ([equalierName isEqualToString:@"classical"]){
        name = MEL_Classic;
    }
    else if ([equalierName isEqualToString:@"Heavy_metals"]){
        name = MEL_HeavyMetal;
    }
    return name;
}







@end
