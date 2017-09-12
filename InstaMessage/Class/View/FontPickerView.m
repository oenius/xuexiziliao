//
//  FontPickerView.m
//  InstaMessage
//
//  Created by Mac_H on 16/8/3.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "FontPickerView.h"
#import "CustonCollectionViewCell.h"

@interface FontPickerView ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *cancel;
@property (weak, nonatomic) IBOutlet UIButton *Done;

@property (nonatomic,strong)NSMutableArray * fontNameListArray;

@end


static NSString * cellID = @"cell";

@implementation FontPickerView
-(NSMutableArray *)fontNameListArray{
    if (_fontNameListArray == nil) {
        NSMutableArray * tempArray = [NSMutableArray array];
        NSArray *familyNames = [UIFont familyNames];
        for( NSString *familyName in familyNames )
        {
            NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
            for( NSString *fontName in fontNames )
            {
                [tempArray addObject:fontName];
            }
        }
        _fontNameListArray = tempArray;
    }
    return _fontNameListArray;
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
    CGSize size = self.collectionView.bounds.size;
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset=UIEdgeInsetsMake(5, 0, 5, 0);
    CGFloat min = size.height>size.width ? size.width : size.height;
    layout.itemSize= CGSizeMake(min+20,min-10);
    layout.minimumInteritemSpacing= 5;
    layout.minimumLineSpacing= 10;
    layout.scrollDirection=UICollectionViewScrollDirectionHorizontal;
    self.collectionView.collectionViewLayout = layout;
}
- (IBAction)onDoneButtonClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(fontPickerViewDoneButtonClick:)]) {
        [self.delegate fontPickerViewDoneButtonClick:self];
        [self removeFromSuperview];
    }
}
- (IBAction)onCancelButtonClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(fontPickerViewCancelButtonClick:)]) {
        [self.delegate fontPickerViewCancelButtonClick:self];
        [self removeFromSuperview];
    }
}
#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.fontNameListArray.count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CustonCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    cell.textFont = self.fontNameListArray[indexPath.row];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(fontPickerView:chooseFontName:)]) {
        NSString * fontName = [self.fontNameListArray objectAtIndex:indexPath.row];
        [self.delegate fontPickerView:self chooseFontName:fontName];
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
