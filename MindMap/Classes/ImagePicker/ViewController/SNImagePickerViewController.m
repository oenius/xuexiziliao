//
//  SNImagePickerViewController.m
//  MindMap
//
//  Created by 何少博 on 2017/8/29.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNImagePickerViewController.h"
#import "SNAssetViewModel.h"
#import "SNImagePickerCollectionViewCell.h"
#import "MBProgressHUD.h"
#import "UIImage+SN.h"
@interface SNImagePickerViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource
>
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *layout;
@property (strong, nonatomic) SNAssetViewModel *viewModel;


@end


static NSString * const kImagePickerCellID      = @"SNImagePickerCell";
static NSInteger        kColumnNumber           = 4;
static CGFloat          kItemMargin             = 5;


@implementation SNImagePickerViewController


#pragma mark - init set

-(SNAssetViewModel *)viewModel{
    if (_viewModel == nil) {
        _viewModel = [[SNAssetViewModel alloc]init];
    }
    return _viewModel;
}

-(void)setupCollectionView{
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:_layout];
    [self.view addSubview:_collectionView];
    CGFloat WIDTH = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    kColumnNumber = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 6 : 4;
    CGFloat itemWH = (WIDTH - (kColumnNumber + 1) * kItemMargin) / kColumnNumber;
    _layout.itemSize = CGSizeMake(itemWH, itemWH);
    _layout.minimumInteritemSpacing = kItemMargin;
    _layout.minimumLineSpacing = kItemMargin;
    self.collectionView.frame = self.view.bounds;
    [_collectionView setCollectionViewLayout:_layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[SNImagePickerCollectionViewCell class] forCellWithReuseIdentifier:kImagePickerCellID];
    _collectionView.backgroundColor = [UIColor clearColor];
}


#pragma mark - life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel", @"取消") style:(UIBarButtonItemStylePlain) target:self action:@selector(back)];
    [self setupCollectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}

#pragma mark - actions 

-(void)back{
    if ([self.delegate respondsToSelector:@selector(imagePickerCancel:)]) {
        [self.delegate imagePickerCancel:self];
    }
}


#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [self.viewModel numberOfSectionsInCollectionView];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.viewModel numberOfItemsInSection:section];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SNImagePickerCollectionViewCell * cell =[collectionView dequeueReusableCellWithReuseIdentifier:kImagePickerCellID forIndexPath:indexPath];
    cell.model = [self.viewModel modelAtIndexPath:indexPath];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(imagePicker:didSeleceted:)]) {
        id model = [self.viewModel modelAtIndexPath:indexPath];
        
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [SNAssetViewModel requestThumbImageWithAsset:model thumb:NO completed:^(UIImage *thumbImage) {
            UIImage * image = thumbImage;
            if (image) {
                UIImageOrientation imageOrientation = image.imageOrientation;
                if(imageOrientation != UIImageOrientationUp)
                {
                    // 以下为调整图片角度的部分
                    UIGraphicsBeginImageContext(image.size);
                    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                }
                image = [image imageWithCornerRadius:8];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                [self.delegate imagePicker:self didSeleceted:image];
            });
        }];
        
    }
}

@end
