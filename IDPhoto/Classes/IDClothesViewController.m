//
//  IDClothesViewController.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/28.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDClothesViewController.h"
#import "IDMenClothesView.h"
#import "IDWomenClothesView.h"
#import "IDClotehsEraseView.h"
#import "IDShareViewController.h"
#import "IDTouchDrawView.h"
#import "IDMagnifier.h"
#import "IDCutBGViewModel.h"
#import <SVProgressHUD.h>
#define MAS_SHORTHAND
#import "Masonry.h"
#import "NPCommonConfig.h"
static CGFloat kHeigthOccupancy = 160;
static CGFloat kWidthOccupancy = 20;

@interface IDClothesViewController ()

@property (nonatomic,strong) NSString * idType;

@property (nonatomic,assign) IDPhotoBGType bgType;

@property (nonatomic,strong) UIImage * oriImage;
@property (nonatomic, strong) UIImageView * clotheImageView;
@property (nonatomic,strong) IDTouchDrawView * touchDrawView;
@property (nonatomic,strong) UIPinchGestureRecognizer *pinch;
@property (nonatomic,strong) UIPanGestureRecognizer *pan;
@property (nonatomic,strong) IDMagnifier * trackingView;
@property (nonatomic,assign) CGPoint startPoint;
@property (nonatomic,assign) CGPoint endPoint;
@property (nonatomic,assign) TouchState currentState;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic,strong) IDCutBGViewModel * viewModel;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *menClothesBtn;
@property (weak, nonatomic) IBOutlet UIButton *womenClothesBtn;
@property (weak, nonatomic) IBOutlet UIButton *eraseBtn;
@property (weak, nonatomic) IBOutlet IDMenClothesView *menClothesView;
@property (weak, nonatomic) IBOutlet IDWomenClothesView *womeClothesView;
@property (weak, nonatomic) IBOutlet IDClotehsEraseView *clothesEraseView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *womenViewWidth;


@end

@implementation IDClothesViewController

-(instancetype)initWithImage:(UIImage *)image
                      idType:(NSString *)idType
                      bgType:(IDPhotoBGType) bgTye{
    
    self = [super initWithNibName:@"IDClothesViewController" bundle:nil];
    if (self) {
        self.oriImage = image;
        self.idType = idType;
        self.bgType = bgTye;
        self.currentState = TouchStateNone;
    }
    return self;
}
-(IDCutBGViewModel *)viewModel{
    if (nil == _viewModel) {
        _viewModel = [[IDCutBGViewModel alloc]init];
    }
    return _viewModel;
}
#pragma mark - 视图生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"next"] style:(UIBarButtonItemStylePlain) target:self action:@selector(wanChengItemClick)];
    [self setupSubView];
    [self configMenClothesView];
    [self configWomenClothesView];
    [self configClothesEraseView];
    
    [self tianJiaShoushi];
    [self setShouShiEnable:YES];
    self.clotheImageView = [[UIImageView alloc]init];
    self.clotheImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.imageView addSubview:self.clotheImageView];
    self.imageView.clipsToBounds = YES;
    
    [self setubButtons];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#2c2e30"];
    self.contentView.backgroundColor = [UIColor colorWithHexString:@"#2c2e30"];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [UIApplication sharedApplication].statusBarHidden = NO;
}
-(void)setubButtons{
    self.menClothesBtn.selected = YES;
    [self.menClothesBtn setTitle:[IDConst instance].NanZhuang forState:(UIControlStateNormal)];
    self.menClothesBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.menClothesBtn setTitleColor:[UIColor colorWithHexString:@"#fe709a"] forState:(UIControlStateNormal)];
    [self.menClothesBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected)];
    self.womenClothesBtn.selected = NO;
    [self.womenClothesBtn setTitle:[IDConst instance].NvZhuang forState:(UIControlStateNormal)];
    self.womenClothesBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.womenClothesBtn setTitleColor:[UIColor colorWithHexString:@"#fe709a"] forState:(UIControlStateNormal)];
    [self.womenClothesBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected)];
    self.eraseBtn.selected = NO;
    [self.eraseBtn setTitle:[IDConst instance].Eraser forState:(UIControlStateNormal)];
    self.eraseBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.eraseBtn setTitleColor:[UIColor colorWithHexString:@"#fe709a"] forState:(UIControlStateNormal)];
    [self.eraseBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateSelected)];
}

-(void)setupSubView{
    self.imageView = [[UIImageView alloc]init];
    [self.contentView addSubview:self.imageView];
    self.touchDrawView = [[IDTouchDrawView alloc]init];
    self.touchDrawView.currentState = TouchStateEarse;
    self.touchDrawView.shadowEnable = YES;
    self.touchDrawView.showCircle = YES;
    [self.imageView insertSubview:_touchDrawView atIndex:0];
    self.imageView.image  = self.oriImage;
    
    CGFloat maxH  = self.view.bounds.size.height - kHeigthOccupancy;
    CGFloat maxW = self.view.bounds.size.width - kWidthOccupancy;
    
    CGSize properSize = [self.viewModel getProperImageViewSize:_oriImage.size maxWidth:maxW maxHeight:maxH];
    [_imageView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(properSize.width));
        make.height.equalTo(@(properSize.height));
        make.centerX.equalTo(self.contentView.centerX);
        make.centerY.equalTo(self.contentView.centerY);
    }];
    [_touchDrawView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.top);
        make.bottom.equalTo(self.imageView.bottom);
        make.left.equalTo(self.imageView.left);
        make.right.equalTo(self.imageView.right);
    }];
}
-(void)genXinYueShu:(CGFloat)bottom{
    self.bottomCon.constant = bottom;
    
    CGFloat maxH  = self.view.bounds.size.height - kHeigthOccupancy - bottom;
    CGFloat maxW = self.view.bounds.size.width - kWidthOccupancy;
    
    CGSize properSize = [self.viewModel getProperImageViewSize:_oriImage.size maxWidth:maxW maxHeight:maxH];
    [_imageView updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(properSize.width));
        make.height.equalTo(@(properSize.height));
    }];
    [self.view setViewLayoutAnimation];
}
-(void)tianJiaShoushi{
    _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(Scaler:)];
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(Move:)];
    
    [self.view addGestureRecognizer:_pinch];
    [self.view addGestureRecognizer:_pan];
}

#pragma mark - button actions

-(void)wanChengItemClick{
    [SVProgressHUD show];
    
    UIImage * drawImage = [self.touchDrawView maskImageWithPainting];
    UIImage * newImage = [self.viewModel drawImage:drawImage atImage:self.oriImage];
    UIImage * clotheImage = self.clotheImageView.image;
    CGRect clotehImageViewFrame = self.clotheImageView.frame;
    CGFloat widthScale = self.imageView.image.size.width/self.imageView.bounds.size.width;
    CGFloat heightScale = self.imageView.image.size.height/self.imageView.bounds.size.height;
    clotehImageViewFrame.origin.x = clotehImageViewFrame.origin.x * widthScale;
    clotehImageViewFrame.origin.y = clotehImageViewFrame.origin.y * heightScale;
    clotehImageViewFrame.size.width = clotehImageViewFrame.size.width * widthScale;
    clotehImageViewFrame.size.height = clotehImageViewFrame.size.height * heightScale;
    UIImage * resultImage = [self.viewModel drawImage:clotheImage atImage:newImage withRect:clotehImageViewFrame];
    [SVProgressHUD dismiss];
    IDShareViewController * share = [[IDShareViewController alloc]initWithImage:resultImage withIdType:self.idType];
    [self.navigationController pushViewController:share animated:YES];
}

- (IBAction)menClothesClick:(id)sender {
    [self.touchDrawView clear];
    self.menClothesBtn.selected = YES;
    self.womenClothesBtn.selected = NO;
    self.eraseBtn.selected = NO;
    [self setShouShiEnable:YES];
    self.currentState = TouchStateNone;
    self.menViewWidth.constant = [UIScreen mainScreen].bounds.size.width;
    self.womenViewWidth.constant =  0.0001;
    WeakSelf
    self.view.userInteractionEnabled = NO;
    [self.view setViewLayoutAnimationCompletion:^(BOOL finish) {
        weakSelf.clothesEraseView.alpha = 0;
        weakSelf.view.userInteractionEnabled = YES;
    }];
}

- (IBAction)womenClothesClick:(id)sender {
    [self.touchDrawView clear];
    self.menClothesBtn.selected = NO;
    self.womenClothesBtn.selected = YES;
    self.eraseBtn.selected = NO;
    [self setShouShiEnable:YES];
    self.currentState = TouchStateNone;
    self.menViewWidth.constant =  0.0001;
    self.womenViewWidth.constant = [UIScreen mainScreen].bounds.size.width;
    WeakSelf
    self.view.userInteractionEnabled = NO;
    [self.view setViewLayoutAnimationCompletion:^(BOOL finish) {
        weakSelf.clothesEraseView.alpha = 0;
        weakSelf.view.userInteractionEnabled = YES;
    }];
}

- (IBAction)eraseBtnClick:(id)sender {
    self.menClothesBtn.selected = NO;
    self.womenClothesBtn.selected = NO;
//    self.menClothesBtn.enabled = NO;
//    self.womenClothesBtn.enabled = NO;
    self.eraseBtn.selected = YES;
    [self setShouShiEnable:NO];
    self.currentState = TouchStateEarse;
    self.clothesEraseView.alpha = 1;
    self.menViewWidth.constant =  0.0001;
    self.womenViewWidth.constant =  0.0001;
    WeakSelf
    self.view.userInteractionEnabled = NO;
    [self.view setViewLayoutAnimationCompletion:^(BOOL finish) {
        weakSelf.view.userInteractionEnabled = YES;
    }];
}

#pragma mark - touch event

-(BOOL)checkTouchPoint:(CGPoint)point{
    BOOL allow = NO;
    CGFloat topL = CGRectGetMinY(self.imageView.frame);
    CGFloat bottomL = CGRectGetMaxY(self.imageView.frame) + 10;
    if (point.y >= topL && point.y <= bottomL ) {
        allow = YES;
    }
    return allow;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.currentState == TouchStateNone) { return; }
    UITouch *touch = [touches anyObject];
    
    self.startPoint = [touch locationInView:self.touchDrawView];
    if (!CGRectContainsPoint(self.touchDrawView.bounds, self.startPoint)) {
        return;
    }
    if (self.trackingView) {
        [self.trackingView removeFromSuperview];
        self.trackingView = nil;
    }
        [self.touchDrawView touchStarted:self.startPoint];
        self.trackingView = [[IDMagnifier alloc]init];
        self.trackingView.viewToMagnify = self.view.window;
        CGPoint point = [touch locationInView:self.view];
        self.trackingView.pointToMagnify = point;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.currentState == TouchStateNone) { return; }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.touchDrawView];
    if (!CGRectContainsPoint(self.touchDrawView.bounds, point)) {
        return;
    }
    [self.touchDrawView touchMoved:point];
    CGPoint pointT = [touch locationInView:self.view];
    pointT.y += 64;
    self.trackingView.pointToMagnify = pointT;
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.currentState == TouchStateNone) { return; }
    UITouch *touch = [touches anyObject];
    self.trackingView.hidden = YES;
    self.endPoint = [touch locationInView:self.touchDrawView];
    [self.touchDrawView touchEnded:self.endPoint];
    
}
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.currentState == TouchStateNone) { return; }
    self.trackingView.hidden = YES;
}


#pragma mark - 手势

-(void)setShouShiEnable:(BOOL)enable{
    _pan.enabled = enable;
    _pinch.enabled = enable;
}


- (void)Scaler:(UIPinchGestureRecognizer *)pinch{
    if (self.clotheImageView.image == nil) { return; }
    UIView *view = self.clotheImageView;
    CGPoint point = [pinch locationInView:self.imageView];
    CGRect rect = self.imageView.bounds;
    if (!CGRectContainsPoint(rect, point)) return;
    view.transform = CGAffineTransformScale(view.transform, pinch.scale, pinch.scale);
    pinch.scale = 1;
}
- (void)Move:(UIPanGestureRecognizer *)pan{
    if (self.clotheImageView.image == nil) { return; }
    UIView *view = self.clotheImageView;
    CGPoint point = [pan locationInView:self.imageView];
    CGRect rect = self.imageView.bounds;
    if (!CGRectContainsPoint(rect, point)) return;
    if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [pan translationInView:view.superview];
//        CGRect rect = view.superview.bounds;
//        CGPoint point = [pan locationInView:self.imageView];
//        if (!CGRectContainsPoint(rect,point)) return;
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [pan setTranslation:CGPointZero inView:view.superview];
    }
}
#pragma mark - 衣服选择
-(void)configClothesEraseView{
    self.clothesEraseView.alpha = 0;
    [self.clothesEraseView.cancelBtn addTarget:self action:@selector(eraseCancelBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
    [self.clothesEraseView.okBtn addTarget:self action:@selector(eraserOkBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
    UIColor * eraseColor = [self getBGColorWithType:self.bgType];
    
    self.clothesEraseView.eraseColor = eraseColor;
    self.touchDrawView.eraseColor = eraseColor;
    WeakSelf
    [self.clothesEraseView valueChanged:^(CGFloat value) {
        weakSelf.touchDrawView.eraseSize = value;
    }];
}

-(void)eraseCancelBtnClick{
    self.menClothesBtn.enabled = YES;
    self.womenClothesBtn.enabled = YES;
    [self.touchDrawView clear];
    [self menClothesClick:self.menClothesBtn];
}
-(void)eraserOkBtnClick{
    self.menClothesBtn.enabled = YES;
    self.womenClothesBtn.enabled = YES;
    UIImage * drawImage = [self.touchDrawView maskImageWithPainting];
    UIImage * newImage = [self.viewModel drawImage:drawImage atImage:self.oriImage];
    self.oriImage = newImage;
    self.imageView.image = newImage;
    [self menClothesClick:self.menClothesBtn];
    [IDConst showADRandom:4 forController:self];
//    UIImage * clotheImage = self.clotheImageView.image;//[self.viewModel getImageAtView:self.clotheImageView];
//    CGRect clotehImageViewFrame = self.clotheImageView.frame;
//    CGFloat widthScale = self.imageView.image.size.width/self.imageView.bounds.size.width;
//    CGFloat heightScale = self.imageView.image.size.height/self.imageView.bounds.size.height;
//    clotehImageViewFrame.origin.x = clotehImageViewFrame.origin.x * widthScale;
//    clotehImageViewFrame.origin.y = clotehImageViewFrame.origin.y * heightScale;
//    clotehImageViewFrame.size.width = clotehImageViewFrame.size.width * widthScale;
//    clotehImageViewFrame.size.height = clotehImageViewFrame.size.height * heightScale;
//    UIImage * jj = [self.viewModel drawImage:clotheImage atImage:newImage withRect:clotehImageViewFrame];
}
-(void)configMenClothesView{
    self.menViewWidth.constant = [UIScreen mainScreen].bounds.size.width;
    WeakSelf
    [self.menClothesView clotheSelectBlock:^(NSString *clothesName) {
        [weakSelf changeClotheImageView:clothesName];
    }];
}
-(void)configWomenClothesView{
    self.womenViewWidth.constant =  0.0001;
    WeakSelf
    [self.womeClothesView clotheSelectBlock:^(NSString *clothesName) {
        [weakSelf changeClotheImageView:clothesName];
    }];
}
-(void)changeClotheImageView:(NSString *)clothesName{
  
    UIImage * image = [UIImage imageWithContentsOfFile:clothesName];

    CGFloat Width = self.imageView.bounds.size.width/3*2;
    CGFloat height = Width * (image.size.height/image.size.width);
    CGFloat X = (self.imageView.bounds.size.width - Width)/2;
    CGFloat Y = (self.imageView.bounds.size.height - height);
    if (image == nil) {
        self.clotheImageView.frame = CGRectZero;
    }else{
        self.clotheImageView.frame = CGRectMake(X, Y, Width, height);
    }

    self.clotheImageView.image = image;
    
}
#pragma mark - 广告相关

-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    [self genXinYueShu:contentInsets.bottom];
}



@end
