//
//  LCFilterChooserView.m
//  LightCamera
//
//  Created by 何少博 on 16/12/13.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "LCFilterChooserView.h"
#import "LCFilterArray.h"

@interface LCFilterChooserView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong)UICollectionView * collectionview;

@property(nonatomic,copy)NSArray * filterArr;


@end


@implementation LCFilterChooserView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSomthing];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSomthing];
    }
    return self;
}

-(void)initSomthing{
    self.backgroundColor = [UIColor clearColor];
    _filterArr = [LCFilterArray filterArray];
    [self addSubview:self.collectionview];
}

-(void)awakeFromNib{
    [super awakeFromNib];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat sreenHeight = [UIScreen mainScreen].bounds.size.height;
    if (_collectionview != nil) {
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setItemSize:CGSizeMake(sreenHeight/9, sreenHeight/9)];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal]; //控制滑动分页用
        flowLayout.minimumInteritemSpacing =0;
        _collectionview.collectionViewLayout = flowLayout;
        _collectionview.frame = self.bounds;
    }
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _filterArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LCFilterChooseCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    //    NSLog(@"%ld",(long)indexPath.row);
    cell.nameLab.text = [_filterArr[indexPath.row] objectForKey:@"name"];
    cell.index = indexPath.row;
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_backback) {
        GPUImageOutput<GPUImageInput> * pixellateFilter = (GPUImageOutput<GPUImageInput> *)[_filterArr[indexPath.row] objectForKey:@"filter"];
        _backback(pixellateFilter);
    }
}
-(UICollectionView *)collectionview
{
    if (!_collectionview) {
        
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setItemSize:CGSizeMake(80, self.bounds.size.height)];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal]; //控制滑动分页用
        flowLayout.minimumInteritemSpacing =0;
        
        _collectionview = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _collectionview.bounces = NO;
        _collectionview.showsHorizontalScrollIndicator = NO;
        [_collectionview registerClass:[LCFilterChooseCell class] forCellWithReuseIdentifier:@"cellid"];
        _collectionview.backgroundColor = [UIColor clearColor];
        
        _collectionview.delegate = self;
        _collectionview.dataSource = self;
        _collectionview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        _collectionview.autoresizesSubviews = YES;
    }
    return _collectionview;
}
@end






#pragma mark - LCFilterChooseCell

@interface LCFilterChooseCell ()

@property (nonatomic,strong) NSArray * filterArray;

@end

@implementation LCFilterChooseCell


-(NSArray *)filterArray{
    if (_filterArray == nil) {
        _filterArray = [LCFilterArray filterArray];
    }
    return _filterArray;
}
#pragma mark - notictions abserve

-(void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)orientationChanged:(NSNotification *)notif {
    CGFloat angle;
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIDeviceOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = - M_PI_2;
            break;
        case UIDeviceOrientationPortrait:
            angle = 0;
            break;
        default:
            return;
    }
    
    CGAffineTransform t = CGAffineTransformMakeRotation(angle);
    
    [UIView animateWithDuration:.3 animations:^{
        self.transform = t;
        
    } completion:^(BOOL finished) {
    }];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSomthings];
    }
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSomthings];
    }
    return self;
}

-(void)setIndex:(NSInteger)index{
    
    _index = index;
    
    UIImage * inputImage = [UIImage imageNamed:@"samplePicture.jpg"];
    
    GPUImageOutput<GPUImageInput> * filter = (GPUImageOutput<GPUImageInput> *)[self.filterArray[index] objectForKey:@"filter"];
    
    //设置要渲染的区域
    [filter forceProcessingAtSize:inputImage.size];
    
    [filter useNextFrameForImageCapture];
    
    //获取数据源
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
    //加上滤镜
    [stillImageSource addTarget:filter];
    //开始渲染
    
    [stillImageSource processImage];
    //获取渲染后的图片
    UIImage *newImage = [filter imageFromCurrentFramebuffer];
    
    _iconImg.image = newImage;
}

-(void)initSomthings{
    self.backgroundColor = [UIColor clearColor];
    _iconImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];

    [self.contentView addSubview:_iconImg];
    
    _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 80-15, 80, 15)];
    _nameLab.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _nameLab.text = @"plplplp";
    _nameLab.textColor = [UIColor whiteColor];
    _nameLab.textAlignment = NSTextAlignmentCenter;
    _nameLab.font = [UIFont systemFontOfSize:14];
    _nameLab.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_nameLab];
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    [self addNotification];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.iconImg.frame = self.bounds;
    self.nameLab.frame = CGRectMake(0, self.bounds.size.height - 15, self.bounds.size.width, 15);
    
}

// 图片进行滤镜添加操作
- (UIImage *)filterImage:(UIImage *)originalImage withLUTNamed:(NSString *)lutName {
    
    // 建立原图与
    GPUImagePicture *originalImageSource = [[GPUImagePicture alloc] initWithImage:originalImage];
    GPUImagePicture *lookupImageSource = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:lutName]];
    
    // 使用这个滤镜类就可以直接对图片进行滤镜添加操作
    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
    
    // 进行滤镜处理
    [originalImageSource addTarget:lookupFilter];
    [originalImageSource processImage];
    
    [lookupImageSource addTarget:lookupFilter];
    [lookupImageSource processImage];
    
    [lookupFilter useNextFrameForImageCapture];
    
    
    return [lookupFilter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
}
@end
