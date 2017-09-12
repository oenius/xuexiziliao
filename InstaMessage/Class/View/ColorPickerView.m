//
//  ColorPickerView.m
//  ColorPicker
//
//  Created by Mac_H on 16/8/1.
//  Copyright © 2016年 何少博. All rights reserved.
//

#import "ColorPickerView.h"
#import "UIColor+x.h"

@interface ColorPickerView ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *cancel;
@property (weak, nonatomic) IBOutlet UIButton *Done;

@property (nonatomic,strong)NSMutableArray * colorListArray;

@end

static NSString * cellID = @"cell";

@implementation ColorPickerView

-(NSMutableArray *)colorListArray{
    if (_colorListArray == nil) {
        NSString * path = [[NSBundle mainBundle]pathForResource:@"colorList" ofType:@"plist"];
        _colorListArray = [NSMutableArray arrayWithContentsOfFile:path];
    }
    return _colorListArray;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
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
    if ([self.delegate respondsToSelector:@selector(colorPickerViewDoneButtonClick:)]) {
        [self.delegate colorPickerViewDoneButtonClick:self];
    }
}
- (IBAction)onCancelButtonClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(colorPickerViewCancelButtonClick:)]) {
        [self.delegate colorPickerViewCancelButtonClick:self];
    }
}
#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.colorListArray.count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.backgroundColor =[UIColor colorWithHexString:self.colorListArray[indexPath.row]];
    cell.layer.cornerRadius = 8;
    cell.layer.masksToBounds = YES;
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(colorPickerView:colorChoose:)]) {
        NSString * hex = [self.colorListArray objectAtIndex:indexPath.row];
        [self.delegate colorPickerView:self colorChoose:[UIColor colorWithHexString:hex]];
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
