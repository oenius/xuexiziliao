//
//  IDCutBGViewController.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/27.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDCutBGViewController.h"
#define MAS_SHORTHAND
#import "Masonry.h"
#import "IDTopToolView.h"
#import "IDBottomToolView.h"
#import "IDTouchDrawView.h"
#import "IDGrabCutTool.h"
#import "IDCutBGViewModel.h"
#import "IDMagnifier.h"
#import "NPCommonConfig.h"
#import <SVProgressHUD.h>
#import "IDClothesViewController.h"
#import "DXPopover.h"
#import "IDPreview.h"
#import <GPUImage.h>
#import "IDTipsViewController.h"
@interface IDCutBGViewController ()

@property (nonatomic,copy) NSString * idTyoe ;

@property (nonatomic,strong) UIImage * origImage;

@property (nonatomic,assign) IDPhotoBGType bgType;

@property (nonatomic,strong) UIImage * resizeImage;

@property (nonatomic,strong) UIImage * earseImage;

@property (nonatomic,strong) UIImage * clipEarseImage;

@property (nonatomic,strong) IDTopToolView * topToolView;

@property (nonatomic,strong) IDBottomToolView * bottomToolView;

@property (nonatomic,strong) UIImageView * resultImageView;

@property (nonatomic,strong) UIImageView * originalImageView;

@property (nonatomic,strong) IDTouchDrawView * touchDrawView;

@property (nonatomic,assign) CGPoint startPoint;

@property (nonatomic,assign) CGPoint endPoint;

@property (nonatomic,assign) CGRect grabCutRect;

@property (nonatomic,strong) IDGrabCutTool * grabCutManager;

@property (nonatomic,assign) TouchState touchState;

@property (nonatomic,strong) IDCutBGViewModel * viewModel;

@property (nonatomic,strong) IDMagnifier * trackingView;

@property (nonatomic,strong) NSUndoManager * undoRedoManager;

@property (nonatomic,strong) UIImage *undoImage;

@property (nonatomic,strong) UIButton * previewBtn;

@property (nonatomic,strong) UIButton * helpBtn;

@property (nonatomic,strong) DXPopover * popover;
//@property (nonatomic,strong) NSMutableArray *undoMarks;

@property (nonatomic,assign) int undoIndex;

@property (nonatomic,assign) BOOL canTouch;

@property (nonatomic,assign) BOOL isPrepareing;

@end

static const CGFloat topSpaccing = 0;
static const CGFloat toolViewHeight = 50;
static const NSUInteger kIterationCount = 5;
static const int kUndoMaxCount = 100;
cv:: Mat undoMasks[kUndoMaxCount];


@implementation IDCutBGViewController


-(instancetype)initWithImage:(UIImage *)image idType:(NSString *)idType BGType:(IDPhotoBGType)bgType{
    self = [super init];
    if (self) {
        self.idTyoe = idType;
        self.origImage = image;
        self.bgType = bgType;
        self.resizeImage = [self.viewModel getProperResizedImage:self.origImage];
        self.touchState = TouchStatePlus;
        self.undoIndex = 0;
    }
    return self;
}


-(NSUndoManager *)undoRedoManager{
    if (_undoRedoManager == nil) {
        _undoRedoManager = [[NSUndoManager alloc]init];
    }
    return _undoRedoManager;
}

-(IDGrabCutTool *)grabCutManager{
    if (nil == _grabCutManager) {
        _grabCutManager = [[IDGrabCutTool alloc]init];
        [_grabCutManager resetManager];
    }
    return _grabCutManager;
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
    [self setupSubViews];
    self.isPrepareing = YES;
    [SVProgressHUD show];
    WeakSelf
    [self runAsynchronous:^{
        [weakSelf.grabCutManager prepareGrabCut:self.resizeImage iterationCount:kIterationCount];
        weakSelf.isPrepareing = NO;
        [SVProgressHUD dismiss];
        undoMasks[_undoIndex] = [weakSelf.grabCutManager getMask];
    }];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#2c2e30"];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [UIApplication sharedApplication].statusBarHidden = YES;
    self.canTouch = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.canTouch = NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
}

#pragma mark - 初始化子控件

-(void)setupSubViews{
    [self setupTopToolView];
    [self setupBottomToolView];
    [self setupOrginalImageView];
    [self setupResultImageView];
    [self setupTouchDrawView];
//    [self tianjiaYueShu];
    [self setupBackGroundView];
    [self setPreViewBtn];
    [self setHelpBtn];

}

-(void)setPreViewBtn{
    self.previewBtn = [[UIButton alloc]init];
    [self.previewBtn setImage:[UIImage imageNamed:@"view"] forState:(UIControlStateNormal)];
    [self.previewBtn addTarget:self action:@selector(previewBtnTouchDown) forControlEvents:(UIControlEventTouchDown)];
    [self.previewBtn addTarget: self action:@selector(previewBtnTouchCancel) forControlEvents:(UIControlEventTouchUpInside)];
    [self.previewBtn addTarget: self action:@selector(previewBtnTouchCancel) forControlEvents:(UIControlEventTouchCancel)];
    [self.previewBtn addTarget: self action:@selector(previewBtnTouchCancel) forControlEvents:(UIControlEventTouchUpOutside)];
    [self.view addSubview:self.previewBtn];
    
    [self.previewBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(60));
        make.height.equalTo(@(30));
        make.bottom.equalTo(self.bottomToolView.top).offset(2);
        make.right.equalTo(self.view).offset(0);
    }];
}
-(void)setHelpBtn{
    self.helpBtn = [[UIButton alloc]init];
    [self.helpBtn setImage:[UIImage imageNamed:@"help"] forState:(UIControlStateNormal)];
    [self.helpBtn addTarget:self action:@selector(helpBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
   
    [self.view addSubview:self.helpBtn];
    
    [self.helpBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(60));
        make.height.equalTo(@(30));
        make.bottom.equalTo(self.bottomToolView.top).offset(2);
        make.left.equalTo(self.view).offset(0);
    }];
}

-(void)setupBackGroundView{
    UIView * backGroundView = [[UIView alloc]init];
    backGroundView.backgroundColor = [UIColor colorWithRed:0.17 green:0.18 blue:0.19 alpha:1.00];
    [self.view insertSubview:backGroundView atIndex:0];
    [backGroundView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topToolView.bottom);
        make.bottom.equalTo(self.bottomToolView.top);
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
    }];
    [self tianjiaYueShuWithBuJuView:backGroundView];
}
-(void)setupTopToolView{
    self.topToolView = [[IDTopToolView alloc]init];
    self.topToolView.backgroundColor = [UIColor colorWithRed:0.17 green:0.18 blue:0.19 alpha:1.00];
    [self.view addSubview:_topToolView];
    [_topToolView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left).offset(0);
        make.right.equalTo(self.view.right).offset(0);
        make.top.equalTo(self.view.top).offset(topSpaccing);
        make.height.equalTo(@(toolViewHeight));
    }];
    
    [_topToolView backButtonAddTarget:self action:@selector(topBackButtonClick)];
    [_topToolView undoButtonAddTarget:self action:@selector(topUndoButtonClick)];
    [_topToolView resetButtonAddTarget:self action:@selector(topResetButtonClick)];
    [_topToolView redoButtonAddTarget:self action:@selector(topRedoButtonClick)];
    [_topToolView nextStepButtonAddTarget:self action:@selector(topNextTepButtonClick)];
}

-(void)setupBottomToolView{
    WeakSelf
    self.bottomToolView = [[IDBottomToolView alloc]initWithAction:^(BottomToolAction action, CGFloat value) {
        if (action == BottomToolActionEraser) {
            weakSelf.touchState = TouchStateEarse;
            weakSelf.touchDrawView.currentState = TouchStateEarse;
            weakSelf.touchDrawView.eraseSize = value;
        }
        else if (action == BottomToolActionKouTu){
            weakSelf.touchState = TouchStatePlus;
            weakSelf.touchDrawView.currentState = TouchStatePlus;
            weakSelf.touchDrawView.plusSize = value;
        }
        
    }];
    [self.view addSubview:_bottomToolView];
    [_bottomToolView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
        make.bottom.equalTo(self.view.bottom);
        make.height.equalTo(@(kBottomToolViewHeight));
    }];

}

-(void)setupResultImageView{
    self.resultImageView = [[UIImageView alloc]init];
    _resultImageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_resultImageView];
    
}

-(void)setupOrginalImageView{
    self.originalImageView = [[UIImageView alloc]init];
    [_originalImageView setImage:_origImage];
    _originalImageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_originalImageView];
    
}

-(void)setupTouchDrawView{
    self.touchDrawView = [[IDTouchDrawView alloc]init];
    [self.view addSubview:_touchDrawView];
    
}
-(void)tianjiaYueShuWithBuJuView:(UIView *)buJuView{
    
//    UIView * buJuView = [[UIView alloc]init];
//    buJuView.backgroundColor = [UIColor clearColor];
    
    [_touchDrawView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(buJuView.top);
        make.bottom.equalTo(buJuView.bottom);
        make.left.equalTo(buJuView.left);
        make.right.equalTo(buJuView.right);
    }];
    
    CGFloat maxH  = self.view.bounds.size.height - topSpaccing - toolViewHeight - kBottomToolViewHeight - 50;
    CGFloat maxW = self.view.bounds.size.width;
    
    CGSize properSize = [self.viewModel getProperImageViewSize:_origImage.size maxWidth:maxW maxHeight:maxH];
    [_resultImageView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(properSize.width));
        make.height.equalTo(@(properSize.height));
        make.centerX.equalTo(buJuView.centerX);
        make.centerY.equalTo(buJuView.centerY);
    }];
    [_originalImageView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(properSize.width));
        make.height.equalTo(@(properSize.height));
        make.centerX.equalTo(buJuView.centerX);
        make.centerY.equalTo(buJuView.centerY);
    }];
}

-(void)genXinYueShu:(CGFloat)bottom{
    [self.bottomToolView updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.bottom).offset(-bottom);
    }];
    CGFloat maxH  = self.view.bounds.size.height - topSpaccing - toolViewHeight - kBottomToolViewHeight - 20 - bottom;
    CGFloat maxW = self.view.bounds.size.width;
    
    CGSize properSize = [self.viewModel getProperImageViewSize:_origImage.size maxWidth:maxW maxHeight:maxH];
    [_resultImageView updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(properSize.width));
        make.height.equalTo(@(properSize.height));
    }];
    [_originalImageView updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(properSize.width));
        make.height.equalTo(@(properSize.height));
    }];
    [self.view setViewLayoutAnimation];
}

-(UIImage *)getEarseImage{
    UIImage * image = [self.viewModel imageFromView:self.view rect:self.touchDrawView.frame];
    
    return image;
}
#pragma mark touch event
-(BOOL)checkTouchPoint:(CGPoint)point{
    BOOL allow = NO;
    CGFloat topL = topSpaccing + toolViewHeight +10;
    CGFloat bottomL = toolViewHeight + 10;
    if (point.y >= topL && point.y <= bottomL ) {
        allow = YES;
    }
    return allow;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.canTouch) {
        return;
    }
    UITouch *touch = [touches anyObject];
    
    self.startPoint = [touch locationInView:self.touchDrawView];
    if (!CGRectContainsPoint(self.touchDrawView.bounds, self.startPoint)) {
        return;
    }
    if (self.trackingView) {
        [self.trackingView removeFromSuperview];
        self.trackingView = nil;
    }
    if(_touchState == TouchStateRect){
        [self.touchDrawView clear];
    }else if(_touchState == TouchStatePlus || _touchState == TouchStateMinus || _touchState == TouchStateEarse){
        [self.touchDrawView touchStarted:self.startPoint];
        self.trackingView = [[IDMagnifier alloc]init];
        self.trackingView.viewToMagnify = self.view.window;
        CGPoint point = [touch locationInView:self.view];
        [self checkPointTracking:point];
        self.trackingView.pointToMagnify = point;
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.canTouch) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.touchDrawView];
    if (!CGRectContainsPoint(self.touchDrawView.bounds, point)) {
        return;
    }
    if(_touchState == TouchStateRect){
        CGRect rect = [self.viewModel getTouchedRect:_startPoint endPoint:point];
        [self.touchDrawView drawRectangle:rect];
    }else if(_touchState == TouchStatePlus || _touchState == TouchStateMinus || _touchState == TouchStateEarse){
        [self.touchDrawView touchMoved:point];
        CGPoint pointT = [touch locationInView:self.view];
        [self checkPointTracking:pointT];
        self.trackingView.pointToMagnify = pointT;
    }
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.canTouch) {
        return;
    }
    UITouch *touch = [touches anyObject];
    self.trackingView.hidden = YES;
    self.endPoint = [touch locationInView:self.touchDrawView];
    if(_touchState == TouchStateRect){
        CGRect touchRect = [self.viewModel getTouchedRect:self.startPoint endPoint:self.endPoint];
        CGRect fixRect = [self.viewModel covertRect:touchRect fromView:self.touchDrawView toView:self.originalImageView];
        _grabCutRect = [self.viewModel getTouchedRectWithImageSize:_resizeImage.size atView:self.originalImageView andRect:fixRect];
    }else if(_touchState == TouchStatePlus || _touchState == TouchStateMinus || _touchState == TouchStateEarse){
        [self.touchDrawView touchEnded:self.endPoint];
    }
    [self doGrabcut];
    
}
-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.trackingView.hidden = YES;
}

-(void)checkPointTracking:(CGPoint)point{
//    BOOL containsPoint = CGRectContainsPoint(self.trackingView.frame, point);
//    if (containsPoint) {
//        CGFloat centerY = topSpaccing + toolViewHeight + trackingViewWidth/2;
//        CGFloat centerX = self.view.bounds.size.width - trackingViewWidth/2;
//        
//        [UIView animateWithDuration:0.5 animations:^{
//            self.trackingView.center = CGPointMake(centerX, centerY);
//        }];
//        
//    }
}

#pragma mark - 图片处理相关

-(void)doGrabcut{
    if(_touchState == TouchStateRect){
        
        if([self.viewModel isUnderMinimumRect:_grabCutRect]){
            [SVProgressHUD showInfoWithStatus:[IDConst instance].ReSelectArea];
            [self.touchDrawView clear];
            [SVProgressHUD dismissWithDelay:1.5];
            return;
        }
        
        [self doGrabcutWithMaskImage:nil];
        
    }else if(_touchState == TouchStatePlus || _touchState == TouchStateMinus){
        CGRect fixRect = [self.originalImageView convertRect:self.originalImageView.bounds toView:self.touchDrawView];
        UIImage * touchedMask = [self.touchDrawView maskImagePaintingAtRect:fixRect];
        UIImage *checkImage = [self.viewModel trimmedBetterSize:self.resultImageView.image];
        CGFloat mins = checkImage.size.width < checkImage.size.height ? checkImage.size.width :checkImage.size.height;
        if (checkImage == nil || mins < 20) {
            if (_touchState == TouchStateMinus) {
                [self.touchDrawView clear];
                return;
            }else{
                [self.grabCutManager resetManager];
                self.grabCutManager = nil;
            }
        }
        
        [self doGrabcutWithMaskImage:touchedMask];
        
        
    }else if (_touchState == TouchStateEarse){
        CGRect fixRect = [self.originalImageView convertRect:self.originalImageView.bounds toView:self.touchDrawView];
        self.clipEarseImage = [self.touchDrawView maskImagePaintingAtRect:fixRect];
        UIImage * maskImage = [self.viewModel getMaskImageFromImageAlpha:self.clipEarseImage];
        UIImage * image = [self.viewModel maskimageSourceImage:self.resultImageView.image maskImage:maskImage];
        
        [self setResultImageViewImage:image];
        [self.touchDrawView clear];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature * methodSignature  = [[self class] instanceMethodSignatureForSelector:aSelector];
    
    if (!methodSignature) {
        methodSignature = [NSMethodSignature signatureWithObjCTypes:"v@:*"];
    }
    return methodSignature;
}

-(void)doGrabcutWithMaskImage:(UIImage*)image{
    if (_touchState == TouchStateMinus && self.resultImageView.image == nil) {
        [self.touchDrawView clear];
        return;
    }
    [SVProgressHUD showWithStatus:[IDConst instance].Processing];
    self.view.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        UIImage * maskImage = [weakSelf.viewModel resizeImage:image size:weakSelf.resizeImage.size] ;
        UIImage* resultImageOr = [weakSelf.grabCutManager doGrabCutWithMask:weakSelf.resizeImage maskImage:maskImage iterationCount:kIterationCount];
        _undoIndex ++;
        for (int i = _undoIndex; i < kUndoMaxCount; i++) {
            undoMasks[i] = 0;
        }
        undoMasks[_undoIndex] = [weakSelf.grabCutManager getMask];
//        UIImage* resultImage = [weakSelf.viewModel masking:weakSelf.origImage mask:[weakSelf.viewModel resizeImage:resultImageOr size:weakSelf.origImage.size]];
        resultImageOr = [resultImageOr imageToScale:2];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [weakSelf.touchDrawView clear];
            [weakSelf setResultImageViewImage:resultImageOr];
            [weakSelf.resultImageView setAlpha:0.4];
            [SVProgressHUD dismiss];
            weakSelf.view.userInteractionEnabled = YES;
           
        });
    });
}

#pragma mark - undo Redo

-(void)setResultImageViewImage:(UIImage *)image{
    if (self.undoImage != image) {
        [[self.undoRedoManager prepareWithInvocationTarget:self]setResultImageViewImage:self.undoImage];;
        self.resultImageView.image = image;
        self.undoImage = image;
    }else{
        self.resultImageView.image = image;
    }
}
#pragma mark - preview Btn event

-(void)helpBtnClick{
    IDTipsViewController * tip = [[IDTipsViewController alloc]init];
    [self presentViewController:tip animated:YES completion:nil];
}

-(void)previewBtnTouchDown{
    
    CGFloat scale = self.origImage.size.height/self.origImage.size.width;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width/5*2;
    width = width > 300 ? 300 : width;
    CGFloat height = width * scale;
    
    IDPreview * preView = [[IDPreview alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    preView.backgroundColor = [self getBGColorWithType:self.bgType];
    [preView.activityView startAnimating];
    _popover = [DXPopover popover];
    _popover.contentInset = UIEdgeInsetsMake(2, 2, 2, 2);
    _popover.maskType = DXPopoverMaskTypeNone;
    _popover.animationIn = 0.3;
    _popover.animationOut = 0.3;
    [_popover showAtView:self.previewBtn
         popoverPostion:DXPopoverPositionUp
        withContentView:preView
                 inView:self.view];

    WeakSelf;
    [self runAsynchronous:^{
        UIImage *image = [weakSelf.viewModel maskimageSourceImage:weakSelf.origImage maskImage:weakSelf.resultImageView.image];
        
        [weakSelf runAsyncOnMainThread:^{
            preView.imageView.image = image;
            [preView.activityView stopAnimating];
        }];
    }];
   
    
}
-(void)previewBtnTouchCancel{
    [self.popover dismiss];
    [IDConst showADRandom:5 forController:self];
}

#pragma mark - 顶部工具视图相关方法

-(void)topBackButtonClick{
[self.navigationController popViewControllerAnimated:YES];
//    WeakSelf
//    [UIAlertController showMessageOKAndCancel:@"确定执行此操作" action:^(AlertActionType actionType) {
//        if (actionType == AlertActionTypeOK) {
//            [weakSelf.navigationController popViewControllerAnimated:YES];
//        }else{
//            
//        }
//    }];
}

-(void)topUndoButtonClick{
    if (self.undoRedoManager.isRedoing || self.undoRedoManager.isUndoing) {
        return;
    }
    if ([self.undoRedoManager canUndo]) {
        [self.undoRedoManager undo];
        _undoIndex --;
        [self.grabCutManager setMask:undoMasks[_undoIndex]];
    }
}
-(void)topResetButtonClick{
    [self.originalImageView setImage:_origImage];
    [self setResultImageViewImage:nil];
    [self.originalImageView setAlpha:1.0];
    self.resultImageView.alpha  = 1.0;
    _touchState = TouchStatePlus;
    [self.grabCutManager resetManager];
    self.undoRedoManager = nil;
    _undoIndex = 1;
    for (int i = 0; i < kUndoMaxCount; i ++) {
        undoMasks[i] = 0;
    }
}
-(void)topRedoButtonClick{
    if (self.undoRedoManager.isRedoing || self.undoRedoManager.isUndoing) {
        return;
    }
    if ([self.undoRedoManager canRedo]) {
        [self.undoRedoManager redo];
        _undoIndex ++;
        [self.grabCutManager setMask:undoMasks[_undoIndex]];
    }
    
    
}
-(void)topNextTepButtonClick{
    
    if (self.resultImageView.image == nil) {
        [SVProgressHUD showInfoWithStatus:[IDConst instance].ReSelectArea];
        [SVProgressHUD dismissWithDelay:1.5];
        [self.touchDrawView clear];
        return;
    }
    [SVProgressHUD showWithStatus:[IDConst instance].Processing];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIImage * maskImage = weakSelf.resultImageView.image;
        //放大遮罩图片
//        maskImage = [maskImage imageToScale:2.25];

         maskImage = [weakSelf.viewModel getNewMaskFrom:maskImage];
        //遮罩图片边缘去锯齿
        maskImage = [weakSelf.grabCutManager bianYuanQuJuChi:maskImage];
        //遮罩图片边缘羽化
        maskImage = [weakSelf.grabCutManager bianYuanXuHua:maskImage];
        UIImage * image = [weakSelf.viewModel masked:weakSelf.origImage WithMask:maskImage];
        image = [image imageToScale:1];
        image = [weakSelf.viewModel image:image addBGColor:[self getBGColorWithType:self.bgType]];

        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (image == nil) {
                [SVProgressHUD showInfoWithStatus:[IDConst instance].ReSelectArea];
                [self.touchDrawView clear];
                [SVProgressHUD dismissWithDelay:1.5];
                return ;
            }else{
                IDClothesViewController * clothes = [[IDClothesViewController alloc]initWithImage:image idType:self.idTyoe bgType:self.bgType];
                self.navigationController.navigationBar.hidden = NO;
                [self.navigationController pushViewController:clothes animated:YES];
            }

        });
    });
}

#pragma mark - 广告相关

-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    [self genXinYueShu:contentInsets.bottom];
}


@end
