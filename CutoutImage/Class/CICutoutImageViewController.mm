//
//  CICutoutImageViewController.m
//  CutoutImage
//
//  Created by 何少博 on 17/2/5.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "CICutoutImageViewController.h"
#define MAS_SHORTHAND
#import "Masonry.h"
#import "CITopToolView.h"
#import "CIBottomToolView.h"
#import "CITouchDrawView.h"
#import "CIIntelligentChooseView.h"
#import "GrabCutManager.h"
#import "CICutoutImageViewModel.h"
#import "MBProgressHUD.h"
#import "CIFinagerTrackingView.h"
#import "CIEraserSizeChooseView.h"
#import "CIAddBackGroundViewController.h"
#import "UIColor+x.h"
#import "NPCommonConfig.h"
#import "CIUserDefaultManager.h"
static const CGFloat topSpaccing = 20;
static const CGFloat toolViewHeight = 50;
static const CGFloat subToolViewHeight = 40;
static const CGFloat trackingViewWidth = 90;
@interface CICutoutImageViewController ()<CIEarseSizeChooseViewDelegate>

@property (nonatomic,strong) UIImage * originalImage;

@property (nonatomic,strong) UIImage * resizeImage;

@property (nonatomic,strong) UIImage * earseImage;

@property (nonatomic,strong) UIImage * clipEarseImage;

@property (nonatomic,strong) CITopToolView * topToolView;

@property (nonatomic,strong) CIBottomToolView * bottomToolView;

@property (nonatomic,strong) CIIntelligentChooseView * intelligentChooseView;

@property (nonatomic,strong) CIEraserSizeChooseView * eraserSizeChooseView;

@property (nonatomic,strong) UIImageView * resultImageView;

@property (nonatomic,strong) UIImageView * originalImageView;

@property (nonatomic,strong) CITouchDrawView * touchDrawView;

@property (nonatomic,assign) CGPoint startPoint;

@property (nonatomic,assign) CGPoint endPoint;

@property (nonatomic,assign) CGRect grabCutRect;

@property (nonatomic,strong) GrabCutManager * grabCutManager;

@property (nonatomic,assign) CITouchState touchState;

@property (nonatomic,assign) CITouchState tempTouchState;

@property (nonatomic,strong) CICutoutImageViewModel * viewModel;

@property (nonatomic,strong) CIFinagerTrackingView * trackingView;

@property (nonatomic,strong) MBProgressHUD *hud;

@property (nonatomic,strong) NSUndoManager * undoRedoManager;

@property (nonatomic,strong) UIImage *undoImage;

@property (nonatomic,strong) NSMutableArray *undoMarks;

@property (nonatomic,assign) NSInteger undoIndex;

@property (nonatomic,assign) BOOL canTouch;

@property (nonatomic,assign) BOOL isShowAD;


@end

@implementation CICutoutImageViewController


-(instancetype)initWithImage:(UIImage *)image{
    self = [super init];
    if (self) {
        self.originalImage = image;
        self.resizeImage = [self.viewModel getProperResizedImage:self.originalImage];
        self.touchState = CITouchStateRect;
        self.tempTouchState = self.touchState;
        
    }
    return self;
}

-(NSMutableArray *)undoMarks{
    if (_undoMarks == nil) {
        _undoMarks = [NSMutableArray array];
    }
    return _undoMarks;
}

-(NSUndoManager *)undoRedoManager{
    if (_undoRedoManager == nil) {
        _undoRedoManager = [[NSUndoManager alloc]init];
    }
    return _undoRedoManager;
}

-(GrabCutManager *)grabCutManager{
    if (nil == _grabCutManager) {
        _grabCutManager = [[GrabCutManager alloc]init];
        [_grabCutManager resetManager];
    }
    return _grabCutManager;
}

-(CICutoutImageViewModel *)viewModel{
    if (nil == _viewModel) {
        _viewModel = [[CICutoutImageViewModel alloc]init];
    }
    return _viewModel;
}

#pragma mark - 广告相关

-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    [self genXinYueShu:contentInsets.bottom];
}

#pragma mark - 视图相关
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#1d1d1d"];;
    [self setupSubViews];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.earseImage == nil) {
        self.earseImage = [self getEarseImage];
    }
    if (self.intelligentChooseView == nil) {        
        [self showIntelligentChooseView];
    }
    
    if (_isShowAD) {
        BOOL showAd = [[NPCommonConfig shareInstance]shouldShowAdvertise];
        if (showAd == YES) {
            [[NPCommonConfig shareInstance] showInterstitialAdInViewController:self];
            self.isShowAD = NO;
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.canTouch = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.canTouch = NO;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}


#pragma 添加子视图
-(void)setupSubViews{
    [self setupTopToolView];
    [self setupBottomToolView];
    [self setupOrginalImageView];
    [self setupResultImageView];
    [self setupTouchDrawView];
    [self tianjiaYueShu];
    [self setupBackGroundView];
}
-(void)setupBackGroundView{
    UIView * backGroundView = [[UIView alloc]init];
    backGroundView.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:backGroundView atIndex:0];
    [backGroundView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topToolView.bottom);
        make.bottom.equalTo(self.bottomToolView.top).offset(-subToolViewHeight);
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
    }];
}

-(void)setupTopToolView{
    self.topToolView = [[CITopToolView alloc]init];
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
    [_topToolView previewButtonAddTarget:self action:@selector(topPreviewButtonClick)];
}

-(void)setupBottomToolView{
    self.bottomToolView = [[CIBottomToolView alloc]init];
    [self.view addSubview:_bottomToolView];
    [_bottomToolView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
        make.bottom.equalTo(self.view.bottom);
        make.height.equalTo(@(toolViewHeight));
    }];
    [_bottomToolView intelligentButtonAddTarget:self action:@selector(bottomIntelligentButtonClick)];
    [_bottomToolView eraserButtonButtonAddTarget:self action:@selector(bottomEarserButtonClick)];
    [self.bottomToolView setLightState:CIBottomToolViewHightStateInteli];
}

-(void)setupResultImageView{
    self.resultImageView = [[UIImageView alloc]init];
    _resultImageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_resultImageView];
   
}

-(void)setupOrginalImageView{
    self.originalImageView = [[UIImageView alloc]init];
    [_originalImageView setImage:_originalImage];
    _originalImageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_originalImageView];
    
}

-(void)setupTouchDrawView{
    self.touchDrawView = [[CITouchDrawView alloc]init];
    [self.view addSubview:_touchDrawView];
    
}
-(void)tianjiaYueShu{
    
    CGFloat maxH  = self.view.bounds.size.height - topSpaccing - toolViewHeight * 2 - subToolViewHeight - 20;
    CGFloat maxW = self.view.bounds.size.width;
    
    CGSize properSize = [self.viewModel getProperImageViewSize:_originalImage.size maxWidth:maxW maxHeight:maxH];
    CGFloat offset = (topSpaccing - subToolViewHeight) / 2;
    [_resultImageView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(properSize.width));
        make.height.equalTo(@(properSize.height));
        make.centerX.equalTo(self.view.centerX);
        make.centerY.equalTo(self.view.centerY).offset(offset);
    }];
    [_originalImageView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(properSize.width));
        make.height.equalTo(@(properSize.height));
        make.centerX.equalTo(self.view.centerX);
        make.centerY.equalTo(self.view.centerY).offset(offset);
    }];
    [_touchDrawView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topToolView.bottom);
        make.bottom.equalTo(self.bottomToolView.top).offset(-subToolViewHeight);
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
    }];
}

-(void)genXinYueShu:(CGFloat)bottom{
    [self.bottomToolView updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.bottom).offset(-bottom);
    }];
    CGFloat maxH  = self.view.bounds.size.height - topSpaccing - toolViewHeight * 2 - subToolViewHeight - 20 - bottom;
    CGFloat maxW = self.view.bounds.size.width;
    
    CGSize properSize = [self.viewModel getProperImageViewSize:_originalImage.size maxWidth:maxW maxHeight:maxH];
    CGFloat offset = (topSpaccing - subToolViewHeight-bottom) / 2;
    [_resultImageView updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(properSize.width));
        make.height.equalTo(@(properSize.height));
        make.centerY.equalTo(self.view.centerY).offset(offset);
    }];
    [_originalImageView updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(properSize.width));
        make.height.equalTo(@(properSize.height));
        make.centerY.equalTo(self.view.centerY).offset(offset);
    }];
    [_touchDrawView updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topToolView.bottom);
        make.bottom.equalTo(self.bottomToolView.top).offset(-subToolViewHeight);
    }];
    
    [self performSelector:@selector(updateChooseView) withObject:nil afterDelay:0.5];
}

-(void)updateChooseView{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_touchState == CITouchStateEarse) {
            [self hiddenIntelligentChooseView];
            [self showEarseSizeChooseView];
        }else{
            [self showIntelligentChooseView];
            [self hiddenEarseSizeChooseView];
        }
    });
}

-(void)showIntelligentChooseView{
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat Y = CGRectGetMinY(self.bottomToolView.frame) - subToolViewHeight;
    if (self.intelligentChooseView == nil) {
        CGRect frame = CGRectMake(-width, Y, width, subToolViewHeight);
        self.intelligentChooseView = [[CIIntelligentChooseView alloc]initWithFrame:frame];
        [self.view addSubview:_intelligentChooseView];
        [_intelligentChooseView rectButtonAddTarget:self action:@selector(intelligentRectButtonClick)];
        [_intelligentChooseView plusButtonAddTarget:self action:@selector(intelligentPlusButtonClick)];
        [_intelligentChooseView minusButtonAddTarget:self action:@selector(intelligentMinusButtonClick)];
        _intelligentChooseView.touchState = CITouchStateRect;
    }
    CGRect properFrame = CGRectMake(0, Y, width, subToolViewHeight);
    [UIView animateWithDuration:0.5 animations:^{
        _intelligentChooseView.frame = properFrame;
    }];
}
-(void)hiddenIntelligentChooseView{
    
    if(self.intelligentChooseView == nil) return;
    CGRect hiddenFrame = _intelligentChooseView.frame;
    hiddenFrame.origin.x = -self.view.bounds.size.width;
    [UIView animateWithDuration:0.5 animations:^{
        _intelligentChooseView.frame = hiddenFrame;
    }];
}

-(void)showEarseSizeChooseView{
    CGFloat width = self.view.bounds.size.width;
    CGFloat Y = CGRectGetMinY(self.bottomToolView.frame) - subToolViewHeight;
    if (self.eraserSizeChooseView == nil) {
        CGRect frame = CGRectMake(width*2, Y, width, subToolViewHeight);
        self.eraserSizeChooseView = [[CIEraserSizeChooseView alloc]initWithFrame:frame sliderMaxValue:30];
        self.eraserSizeChooseView.delegate = self;
        [self.view addSubview:_eraserSizeChooseView];
    }
    CGRect properFrame = CGRectMake(0, Y, width, subToolViewHeight);
    [UIView animateWithDuration:0.5 animations:^{
        _eraserSizeChooseView.frame = properFrame;
    }];
    self.eraserSizeChooseView.backgroundColor = [UIColor colorWithHexString:@"1d1d1d"];
}
-(void)hiddenEarseSizeChooseView{
    if(self.eraserSizeChooseView == nil) return;
    CGRect hiddenFrame = _eraserSizeChooseView.frame;
    hiddenFrame.origin.x = self.view.bounds.size.width;
    [UIView animateWithDuration:0.5 animations:^{
        _eraserSizeChooseView.frame = hiddenFrame;
    }];
}
#pragma mark - touch

-(BOOL)checkTouchPoint:(CGPoint)point{
    BOOL allow = NO;
    CGFloat topL = topSpaccing + toolViewHeight +10;
    CGFloat bottomL = toolViewHeight + subToolViewHeight + 10;
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
    if(_touchState == CITouchStateRect){
        [self.touchDrawView clear];
    }else if(_touchState == CITouchStatePlus || _touchState == CITouchStateMinus || _touchState == CITouchStateEarse){
        [self.touchDrawView touchStarted:self.startPoint];
        self.trackingView = [[CIFinagerTrackingView alloc]initWithFrame:CGRectMake(0, topSpaccing+toolViewHeight, trackingViewWidth, trackingViewWidth)];
        self.trackingView.positionState = CIPositionStateOne;
        [self.trackingView beganTrackingView:self.view];
        CGPoint point = [touch locationInView:self.view];
        [self checkPointTracking:point];
        [self.trackingView trackingPoint:point];
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.canTouch) {
        return;
    }
    LOG(@"moved");
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.touchDrawView];
    if (!CGRectContainsPoint(self.touchDrawView.bounds, point)) {
        return;
    }
    if(_touchState == CITouchStateRect){
        CGRect rect = [self.viewModel getTouchedRect:_startPoint endPoint:point];
        [self.touchDrawView drawRectangle:rect];
    }else if(_touchState == CITouchStatePlus || _touchState == CITouchStateMinus || _touchState == CITouchStateEarse){
        [self.touchDrawView touchMoved:point];
        if (self.trackingView) {
            CGPoint pointT = [touch locationInView:self.view];
            [self checkPointTracking:pointT];
            [self.trackingView trackingPoint:pointT];
        }
    }
}



-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.canTouch) {
        return;
    }
    LOG(@"ended");
    UITouch *touch = [touches anyObject];
    
    self.endPoint = [touch locationInView:self.touchDrawView];
    if(_touchState == CITouchStateRect){
        CGRect touchRect = [self.viewModel getTouchedRect:self.startPoint endPoint:self.endPoint];
        CGRect fixRect = [self.viewModel covertRect:touchRect fromView:self.touchDrawView toView:self.originalImageView];
        _grabCutRect = [self.viewModel getTouchedRectWithImageSize:_resizeImage.size atView:self.originalImageView andRect:fixRect];
    }else if(_touchState == CITouchStatePlus || _touchState == CITouchStateMinus || _touchState == CITouchStateEarse){
        [self.touchDrawView touchEnded:self.endPoint];
    }
    if (self.trackingView) {
        [self.trackingView endTracking];
        self.trackingView = nil;
    }
    [self doGrabcut];
    
}

-(void)checkPointTracking:(CGPoint)point{
    BOOL containsPoint = CGRectContainsPoint(self.trackingView.frame, point);
    if (containsPoint) {
        CGFloat centerY = topSpaccing + toolViewHeight + trackingViewWidth/2;
        CGFloat centerX = self.view.bounds.size.width - trackingViewWidth/2;
        if (self.trackingView.positionState == CIPositionStateOne) {
            self.trackingView.positionState = CIPositionStateTwo;
        }else{
            centerX = trackingViewWidth/2;
            self.trackingView.positionState = CIPositionStateOne;
        }
        [UIView animateWithDuration:0.5 animations:^{
            self.trackingView.center = CGPointMake(centerX, centerY);
        }];
        
    }
}


#pragma mark - Grabcut

-(UIImage *)getEarseImage{
    UIImage * image = [self.viewModel imageFromView:self.view rect:self.touchDrawView.frame];

//    [self writeImage:image saveToAlbum:NO];
    return image;
}



-(IBAction)doGrabcut{
    if(_touchState == CITouchStateRect){
        
        if([self.viewModel isUnderMinimumRect:_grabCutRect]){
            MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = CI_ReselectArea;
            [self.touchDrawView clear];
            [hud hideAnimated:YES afterDelay:1.0];
            return;
        }
        
        [self doGrabcutWithMaskImage:nil];

    }else if(_touchState == CITouchStatePlus || _touchState == CITouchStateMinus){
        CGRect fixRect = [self.originalImageView convertRect:self.originalImageView.bounds toView:self.touchDrawView];
//        UIImage * touchedMask2 = [self.touchDrawView maskImageWithPainting];
        UIImage * touchedMask = [self.touchDrawView maskImagePaintingAtRect:fixRect];
//        [self writeImage:touchedMask2 saveToAlbum:NO];
//        [self writeImage:touchedMask saveToAlbum:NO];
         UIImage *checkImage = [self.viewModel trimmedBetterSize:self.resultImageView.image];
        CGFloat mins = checkImage.size.width < checkImage.size.height ? checkImage.size.width :checkImage.size.height;
        if (checkImage == nil || mins < 20) {
            if (_touchState == CITouchStateMinus) {
                [self.touchDrawView clear];
                return;
            }else{
                [self.grabCutManager resetManager];
                self.grabCutManager = nil;
            }
        }
        
        [self doGrabcutWithMaskImage:touchedMask];
        
    }else if (_touchState == CITouchStateEarse){
        CGRect fixRect = [self.originalImageView convertRect:self.originalImageView.bounds toView:self.touchDrawView];
        self.clipEarseImage = [self.touchDrawView maskImagePaintingAtRect:fixRect];
//        [self writeImage:self.clipEarseImage saveToAlbum:YES];
        UIImage * maskImage = [self.viewModel getMaskImageFromImageAlpha:self.clipEarseImage];
//        [self writeImage:maskImage saveToAlbum:YES];
        UIImage * image = [self.viewModel maskimageSourceImage:self.resultImageView.image maskImage:maskImage];
//        [self writeImage:image saveToAlbum:YES];
        [self setResultImageViewImage:image];
        [self.touchDrawView clear];
        [self setUndoMarksArray:NO];
    }
}

-(void)setUndoMarksArray:(BOOL)mark{
    
    [self.undoMarks insertObject:[NSNumber numberWithBool:mark] atIndex:self.undoIndex];
    self.undoIndex ++;
    NSRange range = NSMakeRange(self.undoIndex, self.undoMarks.count-self.undoIndex);
    [self.undoMarks removeObjectsInRange:range];
    
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
    [self setUndoMarksArray:YES];
    if (_touchState == CITouchStateMinus && self.resultImageView.image == nil) {
        [self.touchDrawView clear];
        return;
    }
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        UIImage* resultImageOr;
        if (image == nil) {
            resultImageOr= [weakSelf.grabCutManager doGrabCut:weakSelf.resizeImage foregroundBound:weakSelf.grabCutRect iterationCount:5];
            
        }else{
            resultImageOr = [weakSelf.grabCutManager doGrabCutWithMask:weakSelf.resizeImage maskImage:[weakSelf.viewModel resizeImage:image size:weakSelf.resizeImage.size] iterationCount:5];
        }
        UIImage* resultImage = [weakSelf.viewModel masking:weakSelf.originalImage mask:[weakSelf.viewModel resizeImage:resultImageOr size:weakSelf.originalImage.size]];
//        [self writeImage:resultImageOr saveToAlbum:NO];
//        [self writeImage:self.originalImage saveToAlbum:NO];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (_touchState == CITouchStateRect) {
                [weakSelf intelligentPlusButtonClick];
            }
            [weakSelf.touchDrawView clear];
            [weakSelf setResultImageViewImage:resultImageOr];
            [weakSelf.resultImageView setAlpha:0.6];
            [weakSelf.hud hideAnimated:YES];
            weakSelf.view.userInteractionEnabled = YES;
        });
    });
}

//-(void)writeImage:(UIImage *)image saveToAlbum:(BOOL)saveToAlbum{
//    NSString * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
//    NSData * imagedata = UIImagePNGRepresentation(image);
//    NSString * name = [[NSUUID UUID]UUIDString];
//    path = [path stringByAppendingPathComponent:[name stringByAppendingString:@".png"]];
//    [imagedata writeToFile:path atomically:YES];
//    if (saveToAlbum) {
//        UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:imagedata], nil, nil, nil);
//    }
//    LOG(@"path:%@",path);
//
//}
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

#pragma mark - 处理智能区域选择视图

-(void)intelligentRectButtonClick{
     LOG(@"%s",__func__);
    _touchState = CITouchStateRect;
    
    self.intelligentChooseView.touchState = CITouchStateRect;
}
-(void)intelligentPlusButtonClick{
     LOG(@"%s",__func__);
    _touchState = CITouchStatePlus;
    self.intelligentChooseView.touchState = CITouchStatePlus;
    [_touchDrawView setCurrentState:CITouchStatePlus];
}
-(void)intelligentMinusButtonClick{
     LOG(@"%s",__func__);
    _touchState = CITouchStateMinus;
    self.intelligentChooseView.touchState = CITouchStateMinus;
    [_touchDrawView setCurrentState:CITouchStateMinus];
}

#pragma mark - 处理橡皮擦size选择

-(void)sizeChanged:(CIEraserSizeChooseView *)sizeChooseView size:(CGFloat)size{
    self.touchDrawView.eraseSize = size;
}


#pragma mark - 顶部工具视图相关方法

-(void)topBackButtonClick{
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:CI_Prompt message:CI_Areyousure preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:CI_Cancel style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:CI_Sure style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [CIUserDefaultManager setShouldShowAD:YES];
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertCon addAction:cancel];
    [alertCon addAction:ok];
    
    [self presentViewController:alertCon animated:YES completion:nil];
}

-(void)topUndoButtonClick{
    if (self.undoRedoManager.isRedoing || self.undoRedoManager.isUndoing) {
        return;
    }
    [self.undoRedoManager undo];
//    LOG(@"橡皮擦undo");
//    self.undoIndex --;
//    BOOL grabCutUndo = [self.undoMarks objectAtIndex:self.undoIndex];
//    if (grabCutUndo) {
//        LOG(@"grabCutUndo");
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.grabCutManager undo];
        });
//    }
    
    
}
-(void)topResetButtonClick{
    LOG(@"%s",__func__);
    [self.originalImageView setImage:_originalImage];
    [self setResultImageViewImage:nil];
    [self.originalImageView setAlpha:1.0];
    self.resultImageView.alpha  = 1.0;
    _touchState = CITouchStateRect;
    _tempTouchState = _touchState;
    [self.intelligentChooseView setTouchState:CITouchStateRect];
    [self showIntelligentChooseView];
    [self hiddenEarseSizeChooseView];
    [self.grabCutManager resetManager];
    self.undoRedoManager = nil;
    [self bottomIntelligentButtonClick];
}
-(void)topRedoButtonClick{
    LOG(@"%s",__func__);
    if (self.undoRedoManager.isRedoing || self.undoRedoManager.isUndoing) {
        return;
    }
    [self.undoRedoManager redo];
//    LOG(@"橡皮擦redo");
//    self.undoIndex ++;
//    BOOL grabCutRedo = [self.undoMarks objectAtIndex:self.undoIndex];
//    if (grabCutRedo) {
//        LOG(@"grabCutRedo");
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.grabCutManager redo];
        });
//    }
    
}
-(void)topPreviewButtonClick{
    
    LOG(@"%s",__func__);
    if (self.resultImageView.image == nil) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = CI_ReselectArea;
        [self.touchDrawView clear];
        [hud hideAnimated:YES afterDelay:1.0];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *image = [weakSelf.viewModel maskimageSourceImage:self.originalImage maskImage:self.resultImageView.image];
        image = [self.viewModel trimmedBetterSize:image];

        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
//            [weakSelf writeImage:image saveToAlbum:YES];
            if (image == nil) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = CI_ReselectArea;
                [self.touchDrawView clear];
                [hud hideAnimated:YES afterDelay:1.0];
                return ;
            }else{
                
            }
            CIAddBackGroundViewController * addBackGround = [[CIAddBackGroundViewController alloc]initWithImage:image];
            weakSelf.isShowAD = YES;
            [weakSelf presentViewController:addBackGround animated:YES completion:nil];
        });
    });
}

#pragma mark - 底部工具视图相关方法

-(void)bottomIntelligentButtonClick{
    LOG(@"%s",__func__);
    
    [self hiddenEarseSizeChooseView];
    [self showIntelligentChooseView];
    [self.bottomToolView setLightState:CIBottomToolViewHightStateInteli];
    _touchState = _tempTouchState;
    [_touchDrawView setCurrentState:_touchState];
}
-(void)bottomEarserButtonClick{
    LOG(@"%s",__func__);
    [self.bottomToolView setLightState:CIBottomToolViewHightStateEraser];
    [self hiddenIntelligentChooseView];
    [self showEarseSizeChooseView];
    _tempTouchState = _touchState;
    _touchState = CITouchStateEarse;
    [_touchDrawView earseWithImage:self.earseImage];
    [_touchDrawView setCurrentState:CITouchStateEarse];
}




@end
