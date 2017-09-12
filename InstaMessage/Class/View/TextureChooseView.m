//
//  TextureChooseView.m
//  InstaMessage
//
//  Created by 何少博 on 16/8/2.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "TextureChooseView.h"
#import "CustonCollectionViewCell.h"

@interface TextureChooseView ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *cancel;
@property (weak, nonatomic) IBOutlet UIButton *Done;

@property (nonatomic,strong)NSMutableArray * wenLiImageNameListArray;

@end

static NSString * cellID = @"cell";

@implementation TextureChooseView
-(NSMutableArray *)wenLiImageNameListArray{
    if (_wenLiImageNameListArray == nil) {
        NSString * path = [[NSBundle mainBundle]pathForResource:@"wenLiImageName" ofType:@"plist"];
        _wenLiImageNameListArray = [NSMutableArray arrayWithContentsOfFile:path];
    }
    return _wenLiImageNameListArray;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[CustonCollectionViewCell class] forCellWithReuseIdentifier:cellID];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    //设置collectionView
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset=UIEdgeInsetsMake(10, 0, 10, 0);
    layout.itemSize= CGSizeMake(40,40);
    layout.minimumInteritemSpacing= 5;
    layout.minimumLineSpacing= 10;
    layout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    self.collectionView.collectionViewLayout = layout;
}
- (IBAction)onDoneButtonClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(textureChooseViewDoneButtonClick:)]) {
        [self.delegate textureChooseViewDoneButtonClick:self];
        [self removeFromSuperview];
    }
}
- (IBAction)onCancelButtonClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(textureChooseViewCancelButtonClick:)]) {
        [self.delegate textureChooseViewCancelButtonClick:self];
        [self removeFromSuperview];
    }
}
#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.wenLiImageNameListArray.count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CustonCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    NSString * path = [[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"%@",self.wenLiImageNameListArray[indexPath.row]] ofType:nil];
    cell.image =[UIImage imageWithContentsOfFile:path];
    cell.layer.cornerRadius = 8;
    cell.layer.masksToBounds = YES;
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(textureChooseView:chooseImageWithName:)]) {
        NSString * imageName = [self.wenLiImageNameListArray objectAtIndex:indexPath.row];
        [self.delegate textureChooseView:self chooseImageWithName:imageName];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
