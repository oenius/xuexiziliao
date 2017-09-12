//
//  SNTipViewController.m
//  MindMap
//
//  Created by 何少博 on 2017/8/17.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNTipViewController.h"
#import "SNTipPickerCell.h"
#import "SNTipViewModel.h"
#import "SNTipReusableView.h"
@interface SNTipViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(weak, nonatomic) IBOutlet UICollectionView * tipCollectionView;
@property (strong, nonatomic) SNTipViewModel *viewModel;

@end


static CGFloat kCellSize            = 40;
static NSString *kTipCellID         = @"kTipCellID";
static NSString *kReusableViewID    = @"kReusableViewID";

@implementation SNTipViewController



#pragma mark - life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel", @"取消") style:(UIBarButtonItemStylePlain) target:self action:@selector(back)];
    [self setupSubViews];
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.tipCollectionView.frame = self.view.bounds;
    
}

#pragma mark - init

-(SNTipViewModel *)viewModel{
    if (_viewModel == nil) {
        _viewModel = [[SNTipViewModel alloc]init];
    }
    return _viewModel;
}

-(void)setupSubViews{
    UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout *)self.tipCollectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(kCellSize, kCellSize);
    UINib * Nib = [UINib nibWithNibName:@"SNTipReusableView" bundle:nil];
    [self.tipCollectionView registerNib:Nib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kReusableViewID];
    self.tipCollectionView.delegate = self;
    self.tipCollectionView.dataSource = self;
    self.tipCollectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tipCollectionView];
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"bg4"].CGImage);
//    [self.tipCollectionView supplementaryViewForElementKind:<#(nonnull NSString *)#> atIndexPath:<#(nonnull NSIndexPath *)#>]
}


#pragma mark - <UICollectionViewDelegate,UICollectionViewDataSource>
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [self.viewModel numberOfSectionsInCollectionView];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.viewModel numberOfItemsInSection:section];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SNTipPickerCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTipCellID forIndexPath:indexPath];
    cell.model = [self.viewModel modelAtIndexPath:indexPath];
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    SNTipReusableView * rView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kReusableViewID forIndexPath:indexPath];
    rView.model = [self.viewModel sectionModelAtIndexPath:indexPath];
    
    return rView;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 60);
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tipImageCallBack) {
        UIImage * image = [self.viewModel getTipImageAtIndexPath:indexPath];
        self.tipImageCallBack(image);
    }
}

-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    UIEdgeInsets  old = self.tipCollectionView.contentInset;
    old.bottom = contentInsets.bottom;
    self.tipCollectionView.contentInset = old;
}

-(void)back{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
