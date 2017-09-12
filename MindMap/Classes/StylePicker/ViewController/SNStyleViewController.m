//
//  SNStyleViewController.m
//  MindMap
//
//  Created by 何少博 on 2017/8/22.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNStyleViewController.h"
#import "SNStyleViewModel.h"
#import "SNStylePickerCell.h"
#import "SNMapStyle.h"
@interface SNStyleViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *styleCollection;
@property (strong, nonatomic) SNStyleViewModel *viewModel;
@end


static NSString * const kStyleCellID = @"kStyleCellID";
static CGFloat kItemSize = 150;

@implementation SNStyleViewController


#pragma mark - life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel", @"取消") style:(UIBarButtonItemStylePlain) target:self action:@selector(back)];
}

#pragma mark - initSet

-(SNStyleViewModel *)viewModel{
    if (_viewModel == nil) {
        _viewModel = [[SNStyleViewModel alloc]init];
    }
    return _viewModel;
}

-(void)setupSubViews{
    UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout *)self.styleCollection.collectionViewLayout;
    layout.itemSize = CGSizeMake(kItemSize, kItemSize);
    self.styleCollection.delegate = self;
    self.styleCollection.dataSource = self;
    self.styleCollection.backgroundColor = [UIColor clearColor];
    self.styleCollection.contentInset = UIEdgeInsetsMake(0, 20, 0, 20);
    [self.view addSubview:self.styleCollection];
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"bg4"].CGImage);
}

-(void)back{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <UICollectionViewDelegate,UICollectionViewDataSource>


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [self.viewModel numberOfSectionsInCollectionView];;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.viewModel numberOfItemsInSection:section];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SNStylePickerCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kStyleCellID forIndexPath:indexPath];
    cell.model = [self.viewModel modelAtIndexPath:indexPath];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.styleCallBack) {
        Class styleClass = [self.viewModel getSelectedStyleClassAtIndexPath:indexPath];
        self.styleCallBack(styleClass);
    }
}


-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    UIEdgeInsets  old = self.styleCollection.contentInset;
    old.bottom = contentInsets.bottom;
    self.styleCollection.contentInset = old;
}












@end
