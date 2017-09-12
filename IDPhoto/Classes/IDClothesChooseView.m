//
//  IDClothesChooseView.m
//  IDPhoto
//
//  Created by 何少博 on 17/5/2.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDClothesChooseView.h"
#import "IDClothesCollectionViewCell.h"

@interface IDClothesChooseView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) NSArray * dataSource;

@property (nonatomic,strong) UICollectionView * collectionView;

@property (nonatomic,copy) ClothesBlock block;

@property (nonatomic,strong) NSIndexPath * selectIndexPath;

@end


static NSString * const kClotehsCellID = @"kClotehsCellID";

@implementation IDClothesChooseView

-(instancetype)initDataSource:(NSArray <NSString *>*) clothes didSelected:(ClothesBlock)block{
    self = [super init];
    if (self) {
        self.dataSource = clothes;
        self.block = block;
        self.selectIndexPath = nil;
        [self setupSubView];
    }
    return self;
    
}

-(void)setDataSource:(NSArray <NSString *>*)dataSource selectBlock:(ClothesBlock)block{
    self.dataSource = dataSource;
    self.block = block;
    self.selectIndexPath = nil;
    [self.collectionView reloadData];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSubView];
    }
    return self;
}

-(void)setupSubView{
    UICollectionViewFlowLayout * flowLayout= [[UICollectionViewFlowLayout alloc]init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 5;
    flowLayout.minimumInteritemSpacing = 5;
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout ];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    UINib * nib  = [UINib nibWithNibName:@"IDClothesCollectionViewCell" bundle:[NSBundle mainBundle]];    
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:kClotehsCellID];
    [self addSubview:self.collectionView];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    UICollectionViewFlowLayout * flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat WIDTH = self.bounds.size.height;
    flowLayout.itemSize = CGSizeMake(WIDTH-5, WIDTH-5);
    self.collectionView.collectionViewLayout = flowLayout;
    self.collectionView.frame = self.bounds;
}


#pragma mark- collectionDelegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
   return  self.dataSource.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    IDClothesCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kClotehsCellID forIndexPath:indexPath];
    if (self.selectIndexPath == indexPath) {
        cell.isSelect = YES;
    }else{
        cell.isSelect = NO;
    }
    cell.clothesName = self.dataSource[indexPath.row];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.selectIndexPath == indexPath) {
        return;
    }
    if (self.block) {
        NSString * clotheName = self.dataSource[indexPath.row];
        if (indexPath.row == 0) {
            clotheName = @"";
        }
        self.block(clotheName);
    }
    
    NSIndexPath * lastIndexPath = self.selectIndexPath;
    self.selectIndexPath = indexPath;
    if (lastIndexPath != nil) {
        [collectionView reloadItemsAtIndexPaths:@[indexPath,lastIndexPath]];
    }else{
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    
}

@end
