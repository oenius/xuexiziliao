//
//  SNMindMapViewController.m
//  MindMap
//
//  Created by 何少博 on 2017/8/8.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNMindMapViewController.h"
#import "SNContainerView.h"
#import "SNNodeTextView.h"
#import "SNLabel.h"
#import "SNNodeAsset.h"
#import "SNVCNotificationManager.h"
#import "SNGestureManager.h"
#import "SNNodeView.h"
#import "SNKeyBoardBar.h"
#import "UIColor+SN.h"
#import "SNNodeFrameMananger.h"
#import "MBProgressHUD.h"
#import "SNRect.h"
#import "SNNodeAsset.h"
#import <Photos/Photos.h>
#import "UIImage+SN.h"
#import "SNPathView.h"
#import "SNTipViewController.h"
#import "SNStyleViewController.h"
#import "SNImagePickerViewController.h"
#import "UIAlertController+SN.h"
#import "SNBaseNavigationController.h"
#import "UINavigationController+SN.h"
#import "SNMapStyle.h"
#import "MBProgressHUD.h"
#import "IDShareViewController.h"
#import "SNImagePickerViewController.h"
#import "SNMindFileViewModel.h"
#import "NPCommonConfig+FeiFan.h"
@interface SNMindMapViewController ()
<SNImagePickerDelegate
>

@property (assign, nonatomic) BOOL keyboardShown;

@property (weak, nonatomic) IBOutlet SNContainerView *tempContainer;
@property (weak, nonatomic) IBOutlet SNContainerView *mainContainer;
@property (weak, nonatomic) IBOutlet SNContainerView *textContainer;

@property (weak, nonatomic) IBOutlet UIImageView *line;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIImageView *knobA;
@property (weak, nonatomic) IBOutlet UIImageView *knobB;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *placeholderHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *placeholderWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *heightHoderView;
@property (weak, nonatomic) IBOutlet UIView *widthHodelView;
@property (weak, nonatomic) IBOutlet SNKeyBoardBar *bar;

@property (strong, nonatomic) UIViewController *styleController;
@property (strong, nonatomic) SNVCNotificationManager *notificationManager;
@property (strong, nonatomic) SNGestureManager *gestureManager;
@property (strong, nonatomic) SNNodeView *oldActiveNode;
@property (assign, nonatomic) NSInteger zoomTimeCount;
@property (assign, nonatomic) BOOL isOnce;
@end

@implementation SNMindMapViewController
-(void)dealloc{
    [_mainContainer removeObserver:self forKeyPath:@"transform"];
    [_notificationManager removeNotification];
}

-(void)once{
    UIImage * image = [self.addButton.currentBackgroundImage imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
    [self.addButton setBackgroundImage:image forState:(UIControlStateNormal)];
    CGPoint offset = CGPointMake(0,
                                 self.mainContainer.frame.size.height / 2 - self.view.frame.size.height / 2);
    [self.scrollview setContentOffset:offset animated:YES];
    self.scrollview.contentSize = self.mainContainer.frame.size;
    self.isOnce = NO;
}

-(BOOL)needLoadBannerAdView{
    return NO;
}

-(BOOL)userBGImage{
    return NO;
}

-(NSMutableArray<SNNodeView *> *)mainNodes{
    if (_mainNodes == nil) {
        _mainNodes = [NSMutableArray array];
    }
    return _mainNodes;
}

-(void)setScrollViewBottomSuggestHeight:(CGFloat)scrollViewBottomSuggestHeight{
    _scrollViewBottomSuggestHeight = scrollViewBottomSuggestHeight;
    NSLog(@"scrollViewBottomSuggestHeight:%f",scrollViewBottomSuggestHeight);
    self.placeholderHeightConstraint.constant = _scrollViewBottomSuggestHeight;
}

-(SNGestureManager *)gestureManager{
    if (_gestureManager == nil) {
        _gestureManager = [[SNGestureManager alloc]initWithMindMapViewControlelr:self];
    }
    return _gestureManager;
}


-(SNVCNotificationManager *)notificationManager{
    if (_notificationManager == nil) {
        _notificationManager = [[SNVCNotificationManager alloc]initWithHost:self];
    }
    return _notificationManager;
}


-(void)setActiveNode:(SNNodeView *)activeNode{
    SNNodeView * oldValue = _activeNode;
    _activeNode = activeNode;
    self.oldActiveNode = _activeNode;
    if (_activeNode == nil) {
        oldValue.status = SNNodeStatusNormal;
    }
    if (_activeNode == oldValue) {
        switch (_activeNode.status) {
            case SNNodeStatusHightLight:
                _activeNode.status = SNNodeStatusNormal;
                break;
            case SNNodeStatusNormal:
                _activeNode.status = SNNodeStatusHightLight;
                break;
            default:
                break;
        }
    }else{
        oldValue.status = SNNodeStatusNormal;
        _activeNode.status = SNNodeStatusHightLight;
    }
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.00];
    self.isOnce = YES;
    [self.mainContainer addObserver:self forKeyPath:@"transform" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
    [self gestureManager];
    [self notificationManager];
    [self hiddenAllKnob];
    [self invalidateAutoLayoutForKnob];
    self.bar.host = self;
    self.bar.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.line.image = [self.line.image imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
    
    self.placeholderWidthConstraint.constant = 0;
    self.placeholderHeightConstraint.constant = 0;
    [self.textEditor setInputAccessoryView:self.bar];
    self.textEditor.hidden = YES;
    self.textEditor.tintColor = [UIColor OrangeColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"fanhui"] style:(UIBarButtonItemStylePlain) target:self action:@selector(backItemClick)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"daochu-"] style:(UIBarButtonItemStylePlain) target:self action:@selector(shareItemClick)];
    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0];
    
    self.scrollview.clipsToBounds = NO;
    self.scrollview.delegate = self;
    self.scrollview.scrollEnabled = YES;
    self.canCheckScorllviewExtend = YES;
    self.canChangeScrollViewBottomByKeyBoardflag = YES;
    [self setupMap];
}


-(void)setupMap{
    if (_mainNodes != nil) {
        SNNodeView * first = self.mainNodes.firstObject;
        self.knobA.image = first.style.KnobImage;
        self.knobB.image = first.style.KnobImage;
        self.view.backgroundColor = first.style.mapBgColor;
        self.mainContainer.backgroundColor = first.style.mapBgColor;
        [self.addButton setImage:first.style.openImage forState:(UIControlStateNormal)];
        [self afterLoadNodes];
    }
    self.title = self.asset.displayName;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.isOnce == YES) {
        [self once];
        if (self.isNewMap) {
            [self creatMainNode];
            if ([[NPCommonConfig shareInstance] getProbabilityFor:1 from:2]) {
                [[NPCommonConfig shareInstance] showVipAlertView];
            }
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.isOnce == NO) {
        [self endEdit];
    }
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"transform"]) {
        CGAffineTransform  it =  CGAffineTransformInvert(self.mainContainer.transform);
        self.knobA.transform = it;
        self.knobB.transform = it;
        self.addButton.transform = it;
    }
}

#pragma mark - AnimationDelegate

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    UIViewController * style;
    for (UIViewController * vc in self.childViewControllers) {
        if ([vc isKindOfClass:[UIViewController class]]) {
            style = vc;
        }
    }
    if (style) {
        [style removeFromParentViewController];
    }
    
}

#pragma mark - ScrollViewDelegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.mainContainer;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
}


-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)creatMainNode{
    SNNodeView * noteView = [[SNNodeView alloc]init];
    CGSize size  = MAIN_NODE_SIZE;
    noteView.frame = CGRectMake(self.view.bounds.size.width / 2 - size.width / 2 ,
                                self.mainContainer.bounds.size.height / 2 - size.height / 2,
                                size.width, size.height);
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        noteView.center = CGPointMake(180, self.mainContainer.bounds.size.height / 2);
    }
    noteView.frameManager.attributeText = [[NSAttributedString alloc]initWithString:NSLocalizedString(@"mian_node", @"中心主题")];
    noteView.style.depth = 0;
    self.mainContainer.backgroundColor = noteView.style.mapBgColor;
    self.view.backgroundColor = noteView.style.mapBgColor;
    [self.nodeContainer addSubview:noteView];
    [self.mainNodes addObject:noteView];
    self.activeNode = noteView;
    [self.textEditor attach:noteView];
    [self endEdit];
}



-(IBAction)addSubNode:(id)sender{
    CGFloat delayTime = 0;
    if (self.activeNode.closeButton != nil && self.activeNode.closeButton.selected == YES) {
        [self.activeNode closeOrOpenChild];
        delayTime = 0.4;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.activeNode = [self.activeNode append];
        [self beginEdit];
    });
}

-(void)shareItemClick{
    [self endEdit];
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = NSLocalizedString(@"wallpaper.builder", @"正在生成");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage * image = [self genImageIsThumb:NO];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            if (image == nil) {
                return ;
            }
            IDShareViewController * share = [[IDShareViewController alloc]initWithImage:image];
            SNBaseNavigationController * navi = [[SNBaseNavigationController alloc]initWithRootViewController:share];
            CATransition *animation = [CATransition animation];
            //设置运动轨迹的速度
            animation.timingFunction = UIViewAnimationCurveEaseInOut;
            
            /*
             Fade = 1,                   //淡入淡出
             Push,                       //推挤
             Reveal,                     //揭开
             MoveIn,                     //覆盖
             Cube,                       //立方体
             SuckEffect,                 //吮吸
             OglFlip,                    //翻转
             RippleEffect,               //波纹
             PageCurl,                   //翻页
             PageUnCurl,                 //反翻页
             CameraIrisHollowOpen,       //开镜头
             CameraIrisHollowClose,      //关镜头
             CurlDown,                   //下翻页
             CurlUp,                     //上翻页
             FlipFromLeft,               //左翻转
             */
            //设置动画类型为立方体动画
            animation.type = @"fade";
            //设置动画时长
            animation.duration =1.3f;
            //设置运动的方向
            animation.subtype =kCATransitionFromRight;
            
            [[UIApplication sharedApplication].keyWindow.layer addAnimation:animation forKey:nil];
            [self presentViewController:navi animated:NO completion:nil];
        });
    });
    
}

-(void)backItemClick{
    if (_isNewMap) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"MM_Reserve", @"保存") message:NSLocalizedString(@"Please enter name", @"请输入文件名") preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"";
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//            [self.navigationController popViewControllerAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction *makeSure = [UIAlertAction actionWithTitle:NSLocalizedString(@"MakeSure", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textFiled = [alert.textFields firstObject];
            BOOL canUse = [self checkName:textFiled.text];
            if (canUse) {
                [self.asset resetAssetPathWithName:textFiled.text];
                [self saveMap];
            }
            else{
                [UIAlertController alertMessage:NSLocalizedString(@"Name is not available", @"名称不可用") controller:self okHandler:^(UIAlertAction *okAction) {
                    
                }];
            }
        }];
        [alert addAction:cancel];
        [alert addAction:makeSure];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
    }else{
        [self saveMap];
    }
}

-(BOOL)checkName:(NSString *)name{
    if ([name containsString:@"."]||
        [name containsString:@"/"]||
        [name isEqualToString:NSLocalizedString(@"Untitled", @"未命名")]||
        name.length <= 0) {
        return NO;
    }
    return YES;
}

-(void)saveMap{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = NSLocalizedString(@"DK_Saving", @"正在保存");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.asset.bgColor = self.mainContainer.backgroundColor;
        UIImage * image = [self genImageIsThumb:YES];
        self.asset.thumb = image;
        self.asset.modifiedDate = [NSDate date];
        self.asset.bgColor = self.mainContainer.backgroundColor;
        [self.fileViewModel saveMapWithAsset:self.asset nodes:self.mainNodes isNewMap:_isNewMap];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES afterDelay:0.0];
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    });
}



-(void)exportImage{
    MBProgressHUD * mainHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    mainHud.mode = MBProgressHUDModeDeterminate;
    mainHud.label.text = NSLocalizedString(@"wallpaper.builder", @"正在生成");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL flag = NO;
        UIImage * image = [self genImageIsThumb:NO];
        if (image) {
            flag = YES;
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            self.asset.thumb = image;
            self.asset.bgColor = self.mainContainer.backgroundColor;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [mainHud hideAnimated:YES];
        });
    });
}
-(UIImage *)genImageIsThumb:(BOOL) isThumb{
    UIView * first = self.nodeContainer.subviews.firstObject;
    if (first == nil) {
        return nil;
    }
    CGFloat minX = 999999999;
    CGFloat minY = 999999999;
    CGFloat maxX = 0;
    CGFloat maxY = 0;
    for (UIView * view in self.nodeContainer.subviews) {
        if ([view isKindOfClass:[SNNodeView class]]) {
            SNNodeView * node = (SNNodeView *)view;
            if (node.visiable) {
                minX = MIN(minX, CGRectGetMinX(view.frame));
                minY = MIN(minY, CGRectGetMinY(view.frame));
                maxX = MAX(maxX, CGRectGetMaxX(view.frame));
                maxY = MAX(maxY, CGRectGetMaxY(view.frame));
            }
        }
    }
    minX = MAX(minX - 50, 0);
    minY = MAX(minY - 50, 0);
    maxX = MIN(maxX + 50, self.mainContainer.bounds.size.width);
    maxY = MIN(maxY + 50, self.mainContainer.bounds.size.height);
    
    
    
    CGRect rect = CGRectMake(minX, minY, maxX - minX, maxY - minY);
    UIImage * image = [self getMapImageRect:rect isThumb:isThumb];
    if (isThumb) {
        image = [image imageToSquare:200 bgColor:self.mainContainer.backgroundColor];
    }
    return image;
    
}


-(UIImage *)getMapImageRect:(CGRect)rect isThumb:(BOOL)isThumb {
    CGFloat s = [UIScreen mainScreen].scale;
    if (isThumb) {
        s = 1;
    }
    CGRect bd = self.mainContainer.bounds;
    UIGraphicsBeginImageContextWithOptions(bd.size, YES, s);
    CGContextRef contex = UIGraphicsGetCurrentContext();
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, bd.size.width, bd.size.height)];
    [self.mainContainer.backgroundColor setFill];
    [path fill];
    CGContextTranslateCTM(contex, -bd.origin.x, -bd.origin.y);
    [self.pathContainer.layer renderInContext:contex];
    [self.nodeContainer.layer renderInContext:contex];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGRect clipRect = CGRectMake(rect.origin.x * s,
                                 rect.origin.y * s,
                                 rect.size.width * s,
                                 rect.size.height * s);
    CGImageRef cgimage = CGImageCreateWithImageInRect(image.CGImage, clipRect);
    UIImage * newimage = nil;
    if (cgimage) {
        newimage =  [UIImage imageWithCGImage:cgimage];
    }
    CGImageRelease(cgimage);
    return newimage;
}

#pragma mark - other

-(void)awakeChild:(SNNodeView *)node{
    if (node == nil) {
        return;
    }
    if (node) {
        [self.nodeContainer addSubview:node];
    }
    for (SNNodeView * n in node.childs) {
        [self awakeChild:n];
    }
    [node updateLinkedPathBetweenNode];
    [node.frameManager updateNodeFrame];
}

-(void)afterLoadNodes{
    for (SNNodeView * node in self.mainNodes) {
        [self awakeChild:node];
    }
    for (SNNodeView * node in self.mainNodes) {
        [node refreshChild];
    }
    [self extendScrollViewIfNeed];
}

- (void)invalidateAutoLayoutForKnob {
    self.knobA.translatesAutoresizingMaskIntoConstraints = YES;
    self.knobB.translatesAutoresizingMaskIntoConstraints = YES;
    self.line.translatesAutoresizingMaskIntoConstraints = YES;
    self.addButton.translatesAutoresizingMaskIntoConstraints = YES;
    
}

-(void)hiddenAllKnob{
    self.knobA.hidden = YES;
    self.knobB.hidden = YES;
    self.line.hidden = YES;
    self.addButton.hidden = YES;
}

#pragma mark - update

-(void)extendScrollViewIfNeed{
    
    
    UIView * firstView = self.nodeContainer.subviews.firstObject;
    if (firstView == nil) {
        return;
    }
    CGRect all = firstView.frame;
    NSMutableArray * tmpNodeArr = [NSMutableArray array];
    for (UIView * v in self.nodeContainer.subviews) {
        if ([v isKindOfClass:[SNNodeView class]]) {
            SNNodeView * vv = (SNNodeView *)v;
            if (vv.visiable) {
                [tmpNodeArr addObject:v];
            }
        }
    }
    for (SNNodeView * node in tmpNodeArr) {
        all = CGRectUnion(all, node.frame);
    }
    
    CGRect r = [self.nodeContainer convertRect:all toView:self.mainContainer];
    r = CGRectInset(r, -100, -100);
    CGRect c = self.mainContainer.bounds;
    CGFloat left = MAX(CGRectGetMinX(c)-CGRectGetMinX(r), 0);
    CGFloat top = MAX(CGRectGetMinY(c)-CGRectGetMinY(r), 0);
    CGFloat bottom = MAX(CGRectGetMaxY(r)-CGRectGetMaxY(c), 0);
    CGFloat right = MAX(CGRectGetMaxX(r)-CGRectGetMaxX(c), 0);
    
    UIEdgeInsets inset = UIEdgeInsetsMake(top, left, bottom, right);
    [self changeContainerSize:inset];
    [self.view setNeedsUpdateConstraints];
    
}


-(void)changeContainerSize:(UIEdgeInsets)inset{
    CGRect mainC = self.mainContainer.frame;
    mainC.size.width += inset.right + inset.left;
    mainC.size.height += inset.bottom + inset.top;
    self.mainContainer.frame = mainC;
    
    CGRect pathC = self.pathContainer.frame;
    pathC.size = mainC.size;
    self.pathContainer.frame = pathC;
    
    CGRect nodeC = self.nodeContainer.frame;
    nodeC.size = mainC.size;
    self.nodeContainer.frame = nodeC;
    
    CGRect tmpC = self.tempContainer.frame;
    tmpC.size = mainC.size;
    self.tempContainer.frame = tmpC;
    
    CGRect textC = self.textContainer.frame;
    textC.size = mainC.size;
    self.textContainer.frame = textC;
    
    CGRect knobC = self.knobContainer.frame;
    knobC.size = mainC.size;
    self.knobContainer.frame = knobC;
    
    self.scrollview.contentSize = mainC.size;
    [self changeRootNodeFrameWithMainContainerSize:mainC.size];
}

-(void)changeRootNodeFrameWithMainContainerSize:(CGSize)size{
    SNNodeView * rootNode = [self findRootNodeView];
    if (rootNode == nil) {
        return;
    }
    CGRect frame = rootNode.frame;
    frame.origin.y = size.height / 2 - frame.size.height / 2;
    rootNode.frame = frame;
}

-(SNNodeView *)findRootNodeView{
    if (self.activeNode) {
        return [self.activeNode root];
    }else{
        SNNodeView * node ;
        for (UIView * v in self.nodeContainer.subviews) {
            if ([v isKindOfClass:[SNNodeView class]]) {
                node = (SNNodeView *)v;
                break;
            }
        }
        if (node) {
            return [node root];
        }
    }
    return nil;
}


-(void)updateKnobPosition{
    SNNodeFrameMananger * fm = self.activeNode.frameManager;
    if (!fm) {
        return;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0];
    self.knobA.center = fm.A;
    self.knobB.center = fm.B;
    
    SNRect *line_frame_sn = [SNRect Rect:self.line.frame];
    line_frame_sn.leftCenter = fm.B;
    self.line.frame = line_frame_sn.rect;
    self.addButton.center = line_frame_sn.rightCenter;
    [UIView commitAnimations];
    
}

-(void)updateNodeStatus{
    if (self.activeNode == nil) {
        [self hiddenAllKnob];
        return;
    }
    switch (self.activeNode.status) {
        case SNNodeStatusNormal:
            self.knobA.hidden = YES;
            self.knobB.hidden = YES;
            self.line.hidden = YES;
            self.addButton.hidden = YES;
            break;
        case SNNodeStatusEditing:
        case SNNodeStatusHightLight:
        {
            self.knobA.hidden = NO;
            self.knobB.hidden = NO;
            self.line.hidden = NO;
            self.addButton.hidden = NO;
            [self updateKnobPosition];
            self.line.tintColor = self.activeNode.style.lineColor;
        }
            break;
        default:
            break;
    }
    
}



-(void)beginUpdateActivite{
    NSMutableArray * arr1 = [NSMutableArray array];
    for (UIView * v in self.nodeContainer.subviews) {
        if (v != self.activeNode) {
            [arr1 addObject:v];
        }
    }
    for (UIView * v in arr1) {
        if ([v isKindOfClass:[SNNodeView class]]) {
            ((SNNodeView *)v).needRedraw = NO;
        }
    }
}

-(void)commitUpdateActivite{
    for (UIView * v in self.nodeContainer.subviews) {
        if ([v isKindOfClass:[SNNodeView class]]) {
            ((SNNodeView *)v).needRedraw = YES;
        }
    }
}

-(void)beginEdit{
    if (self.activeNode == nil) {
        return;
    }
    
    [self.scrollview setZoomScale:1 animated:YES];
    self.scrollview.maximumZoomScale = 1;
    self.scrollview.minimumZoomScale = 1;
    self.scrollview.bouncesZoom = NO;
    
    [self.textEditor attach:self.activeNode];
    self.activeNode.status = SNNodeStatusEditing;
    [self.textEditor becomeFirstResponder];
    [self.scrollview scrollRectToVisible:self.activeNode.frame animated:YES];
    self.textEditor.hidden = NO;
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)endEdit{
    if (self.activeNode == nil) {
        return;
    }
    [self.textEditor resignFirstResponder];
    [self.textEditor deattach];
    self.scrollview.minimumZoomScale = 0.25;
    self.scrollview.maximumZoomScale = 2;
    self.scrollview.bouncesZoom = YES;
    self.activeNode.status = SNNodeStatusNormal;
    self.textEditor.hidden = YES;
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
}



#pragma mark - bar action

-(void)activeNodeBrother{
    if (![self.activeNode isRoot]) {
        self.activeNode = [self.activeNode.parent append];
        [self beginEdit];
    }
}
-(void)activeNodeChild{
    [self addSubNode:nil];
}

-(void)activeNodeDelete{
    if ([self.activeNode isRoot]) {
        return;
    }
    [self.activeNode remove];
    [SNPathView animateWithDuration:0.3 animations:^{
        [self.activeNode.root refreshChild];
    }];
    [self endEdit];
    self.activeNode = nil;
}

-(void)activeNodeTip{
    UIStoryboard * stro = [UIStoryboard storyboardWithName:@"TipStyle" bundle:[NSBundle mainBundle]];
    SNTipViewController * tips = [stro instantiateViewControllerWithIdentifier:@"SNTipViewController"];;
    SNBaseNavigationController * navi = [[SNBaseNavigationController alloc]initWithRootViewController:tips];
    __weak typeof(self) weakSelf = self;
    tips.tipImageCallBack = ^(UIImage *tipImage) {
        weakSelf.activeNode.frameManager.tipImage = tipImage;
        [weakSelf.textEditor attach:weakSelf.activeNode];
        [weakSelf updateKnobPosition];
        [navi dismissViewControllerAnimated:YES completion:nil];
    };
    [self endEdit];
    [self presentViewController:navi animated:YES completion:nil];
}

-(void)mindMapStyleAction{
    UIStoryboard * stro = [UIStoryboard storyboardWithName:@"TipStyle" bundle:[NSBundle mainBundle]];
    SNStyleViewController * style = [stro instantiateViewControllerWithIdentifier:@"SNStyleViewController"];;
    SNBaseNavigationController * navi = [[SNBaseNavigationController alloc]initWithRootViewController:style];
    __weak typeof(self) weakSelf = self;
    style.styleCallBack = ^(Class styleClass) {
        SNMapStyle * styleTmp = [[styleClass alloc]init];
        weakSelf.knobA.image = styleTmp.KnobImage;
        weakSelf.knobB.image = styleTmp.KnobImage;
        weakSelf.mainContainer.backgroundColor = styleTmp.mapBgColor;
        weakSelf.view.backgroundColor = styleTmp.mapBgColor;
        [weakSelf.addButton setImage:styleTmp.openImage forState:(UIControlStateNormal)];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray * nodes = self.nodeContainer.subviews;
            for (UIView * v in nodes) {
                if ([v isKindOfClass:[SNNodeView class]]) {
                    SNMapStyle * style = [[styleClass alloc]init];
                   ((SNNodeView *)v).style = style;
                }
            }
        });
        
        [navi dismissViewControllerAnimated:YES completion:nil];
    };
    [self endEdit];
    [self presentViewController:navi animated:YES completion:nil];
}

// - imagePicker
- (void)activeAddImage {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusNotDetermined:
        {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (PHAuthorizationStatusAuthorized == status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self pickerImage];
                    });
                }
            }];
        }
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
            [self authorizationStatusDeniedAlertViewType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        case PHAuthorizationStatusAuthorized:
            [self pickerImage];
            break;
        default:
            break;
    }
}

-(void)authorizationStatusDeniedAlertViewType:(UIImagePickerControllerSourceType)type{
    
    UIAlertController * alertCon = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"layout_tips", @"提示") message:NSLocalizedString(@"Failed to get the album permissions, please go to the system settings to open", @"未能获得相册权限,请到系统设置里打开") preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction * done = [UIAlertAction actionWithTitle:NSLocalizedString(@"SetPage", @"设置") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
        NSURL * settingUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication]canOpenURL:settingUrl]) {
            [[UIApplication sharedApplication]openURL:settingUrl];
        }
    }];
    
    [alertCon addAction:cancel];
    [alertCon addAction:done];
    
    [self presentViewController:alertCon animated:YES completion:nil];
}

-(void)pickerImage{
    [self endEdit];
    SNImagePickerViewController * imagePicker = [[SNImagePickerViewController alloc]init];
    SNBaseNavigationController * naiv = [[SNBaseNavigationController alloc]initWithRootViewController:imagePicker];
    imagePicker.delegate = self;
    [self presentViewController:naiv animated:YES completion:nil];
}

-(void)imagePicker:(SNImagePickerViewController *)imagePicker didSeleceted:(UIImage *)image{
    self.activeNode.frameManager.image = image;
    [self.textEditor attach:self.activeNode];
    [self updateKnobPosition];
    [self endEdit];
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerCancel:(SNImagePickerViewController *)imagePicker{
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
}

@end



























