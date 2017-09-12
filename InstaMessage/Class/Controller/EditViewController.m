//
//  EditViewController.m
//  InstaMessage
//
//  Created by 何少博 on 16/7/27.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "EditViewController.h"
#import "EditViewController+Theme.h"
#import "EditViewController+Text.h"
#import "EditViewController+Photo.h"
#import "PreviewViewController.h"
#import "UIView+YYAdd.h"
#import "MBProgressHUD.h"
#import "NSObject+x.h"
#import "NPCommonConfig.h"

@interface EditViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewHight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewWight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previewBottom;
@property (assign,nonatomic) BOOL tempBannerViewHidden;

@property (assign,nonatomic) BOOL isFirsrEnter;


@end



@implementation EditViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFirsrEnter = YES;
    self.tempBannerViewHidden = YES;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.editPreviewBackGroundView.clipsToBounds = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(blackButtonItemClick)];
    NSString * previewString = NSLocalizedString(@"message.photo preview", @"Preview");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:previewString style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonItemClick)];
    self.view.backgroundColor = color_e0dfe0;
    self.navigationController.navigationBar.barTintColor = color_2083fc;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //设置图片
    [self.textBtn setImage:[UIImage imageNamed:@"text"] forState:UIControlStateNormal];
    [self.themeBtn setImage:[UIImage imageNamed:@"theme"] forState:UIControlStateNormal];
    [self.photoBtn setImage:[UIImage imageNamed:@"pictures"] forState:UIControlStateNormal];
    self.editOptionsBackGroundView.userInteractionEnabled = YES;
    //方法的实现在相应的分类里面
    [self initPhotoContentView];
    [self initThemeContentView];
    [self initTextContentView];
    
    [self addShouShi];
    self.toolSelectItem = TEXT;
    [self setToolBarButtonDidSelectedWithText:YES Theme:NO Photo:NO];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardFun:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    CGFloat W = [UIScreen mainScreen].bounds.size.width;
    CGFloat H = [UIScreen mainScreen].bounds.size.height;
    W = W-10;
    H = H - 214-64;
    
    CGFloat min = W<H?W:H;
    self.previewHight.constant = min;
    self.previewWight.constant = min;
    CGFloat bottom = (H+10 - min)/2;
    
    self.previewBottom.constant = bottom;
    [self.textView becomeFirstResponder];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.isFirsrEnter) {
        [self addTextView];
        [self.textView becomeFirstResponder];
        self.isFirsrEnter = NO;
    }
    if ([[NPCommonConfig shareInstance] shouldShowAdvertise]) {
            //  从预览界面返回台广告
            if (self.showAds) {
                [[NPCommonConfig shareInstance] showFullScreenAdORNativeAdForController:self];
                self.showAds = NO;
            }
    }
    
    self.blackGroundImageViewOldFrame = self.blackgroundImageView.frame;
    self.blackGroundImageViewOldTransform = self.blackgroundImageView.transform ;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (![[NPCommonConfig shareInstance]shouldShowAdvertise]) {
        NSArray * unLock =[[NSUserDefaults standardUserDefaults] objectForKey:kCommentArray];
        if ((unLock == nil)||(unLock.count == 0)) {
            [self.themeContentView.editThemeCollectionView reloadData];
        }
    }
    self.textView.border.hidden = NO;
    self.textView.delelBtn.hidden = NO;
    if (!self.textView.beiScaAndRot) {
        self.textView.doneBtn.hidden = NO;
        self.textView.frameBtn.hidden = NO;
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.blackgroundImageView.transform = self.blackGroundImageViewOldTransform;
    self.blackgroundImageView.frame = self.blackGroundImageViewOldFrame;
}
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)addTishiLabel{
    UILabel * tishiLabel = [self.photoContentView viewWithTag:PhotoPromptLableTag];
    if (tishiLabel==nil) {
        CGFloat y = 0;
        if ([[NPCommonConfig shareInstance] shouldShowAdvertise]) {
            y = -100;
        }
        CGRect frame = CGRectMake(0, y, self.photoContentView.frame.size.width, 100);
        tishiLabel = [[UILabel alloc]initWithFrame:frame];
        tishiLabel.tag = PhotoPromptLableTag;
        tishiLabel.backgroundColor = [UIColor whiteColor];
        tishiLabel.text = NSLocalizedString(@"Picture can not be edited in current theme", @"Picture can not be edited in current theme");
        tishiLabel.textColor = [UIColor lightGrayColor];
        tishiLabel.textAlignment = NSTextAlignmentCenter;
        tishiLabel.lineBreakMode = NSLineBreakByCharWrapping;
        tishiLabel.numberOfLines = 0;
        [self.photoContentView addSubview:tishiLabel];
        self.photoContentView.userInteractionEnabled = NO;
        self.photoContentView.collectionView.userInteractionEnabled = NO;
    }
}
-(void)removeTishiLabel{
    UILabel * tishiLabel = [self.photoContentView viewWithTag:PhotoPromptLableTag];
    if (tishiLabel) {
        [tishiLabel removeFromSuperview];
        self.photoContentView.userInteractionEnabled = YES;
        self.photoContentView.collectionView.userInteractionEnabled = YES;
    }
}

#pragma mark - 加载
-(UIVisualEffectView *)visualEffectView{
    if (_visualEffectView == nil) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        //  毛玻璃view 视图
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        //添加到要有毛玻璃特效的控件中
        effectView.frame = self.blackgroundImageView.bounds;
        effectView.alpha = 0;
        [self.blackgroundImageView addSubview:effectView];
        _visualEffectView = effectView;
    }
    return _visualEffectView;
}

#pragma mark - 重写set方法


-(void)setBlackGroundImageViewTempImage:(UIImage *)blackGroundImageViewTempImage{
    _blackGroundImageViewTempImage = blackGroundImageViewTempImage;
    self.blackgroundImageView.image = blackGroundImageViewTempImage;
}
-(void)setPhotoEnabled:(BOOL)photoEnabled{
    _photoEnabled = photoEnabled;
    if (photoEnabled==NO) {
        self.blackGroundImageViewTempImage = nil;
    }
}
#pragma mark - 初始化

-(void)addShouShi{
    self.blackgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    //    self.frontImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.blackgroundImageView.userInteractionEnabled = NO;
    self.frontImageView.userInteractionEnabled = NO;
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(Scaler:)];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(Move:)];
    
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    
    doubleTap.numberOfTapsRequired = 2;
    
    [self.view addGestureRecognizer:pinch];
    [self.view addGestureRecognizer:pan];
    [self.view addGestureRecognizer:rotation];
    [self.view addGestureRecognizer:doubleTap];
    
    rotation.delegate = self;
    pinch.delegate = self;
}

#pragma mark - addGestureRecognizer

-(void)doubleTap:(UITapGestureRecognizer *)tap{
    self.textView.border.hidden = YES;
    self.textView.delelBtn.hidden = YES;
    self.textView.doneBtn.hidden = YES;
    self.textView.frameBtn.hidden = YES;
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
    if (self.toolSelectItem == TEXT) return;
    if (self.photoEnabled == NO) return;
    CGPoint point = [tap locationInView:self.blackgroundImageView];
    CGRect rect = self.blackgroundImageView.bounds;
    if (!CGRectContainsPoint(rect, point)) return;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.navigationBar.barTintColor = color_2083fc;
    picker.navigationBar.tintColor = [UIColor whiteColor];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
    
}

- (void)Scaler:(UIPinchGestureRecognizer *)pinch{
    [self textViewResignFirstResponder];
    UIView *view;
    if (self.toolSelectItem == TEXT) {
        if (self.textView.isFirstResponder) return;
        CGPoint point = [pinch locationInView:self.textView];
        CGRect rect = self.textView.bounds;
        if (!CGRectContainsPoint(rect, point)){
            [self.textView resignFirstResponder];
            return;
        }
        self.textView.beiScaAndRot = YES;
        view = self.textView;
    }
    if (self.toolSelectItem == THEME||self.toolSelectItem == PHOTO) {
        if (self.photoEnabled == NO){
            CGPoint point = [pinch locationInView:self.textView];
            CGRect rect = self.textView.bounds;
            if (!CGRectContainsPoint(rect, point)) return;
            self.textView.beiScaAndRot = YES;
            view = self.textView;
        }else{
            CGPoint point = [pinch locationInView:self.blackgroundImageView];
            CGRect rect = self.blackgroundImageView.bounds;
            if (!CGRectContainsPoint(rect, point)) return;
            view = self.blackgroundImageView;
        }
    }
    view.transform = CGAffineTransformScale(view.transform, pinch.scale, pinch.scale);
    pinch.scale = 1;
    
}
- (void)rotate:(UIRotationGestureRecognizer *)rotate{
    [self textViewResignFirstResponder];
    UIView *view;
    if (self.toolSelectItem == TEXT) {
        if (self.textView.isFirstResponder) return;
        CGPoint point = [rotate locationInView:self.textView];
        CGRect rect = self.textView.bounds;
        if (!CGRectContainsPoint(rect, point)){
            [self.textView resignFirstResponder];
            return;
        }
        self.textView.beiScaAndRot = YES;
        view = self.textView;
    }
    else if (self.toolSelectItem == THEME||self.toolSelectItem == PHOTO) {
        if (self.photoEnabled == NO){
            CGPoint point = [rotate locationInView:self.textView];
            CGRect rect = self.textView.bounds;
            if (!CGRectContainsPoint(rect, point)) return;
            self.textView.beiScaAndRot = YES;
            view = self.textView;
        }else{
            CGPoint point = [rotate locationInView:self.blackgroundImageView];
            CGRect rect = self.blackgroundImageView.bounds;
            if (!CGRectContainsPoint(rect, point)) return;
            view = self.blackgroundImageView;
            if (self.beiFanZhuan) {
                rotate.rotation = -rotate.rotation;
            }
        };
    }
    if (rotate.state == UIGestureRecognizerStateBegan || rotate.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformRotate(view.transform, rotate.rotation);
        [rotate setRotation:0];
    }
    
}
- (void)Move:(UIPanGestureRecognizer *)pan{
    [self textViewResignFirstResponder];
    UIView *view;
    if (self.toolSelectItem == TEXT) {
        if (self.textView.isFirstResponder) return;
        CGPoint point = [pan locationInView:self.textView];
        CGRect rect = self.textView.bounds;
        if (!CGRectContainsPoint(rect, point)){
            [self.textView resignFirstResponder];
            return;
        }
        view = self.textView;
    }
    if (self.toolSelectItem == THEME||self.toolSelectItem == PHOTO) {
        if (self.photoEnabled == NO){
            CGPoint point = [pan locationInView:self.textView];
            CGRect rect = self.textView.bounds;
            if (!CGRectContainsPoint(rect, point)) return;
            view = self.textView;
        }else{
            CGPoint point = [pan locationInView:self.blackgroundImageView];
            CGRect rect = self.blackgroundImageView.bounds;
            if (!CGRectContainsPoint(rect, point)) return;
            view = self.blackgroundImageView;
        }
    }
    if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [pan translationInView:view.superview];
        CGRect rect = view.superview.bounds;
        CGPoint point = [pan locationInView:self.editPreviewBackGroundView];
        if (!CGRectContainsPoint(rect,point)) return;
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [pan setTranslation:CGPointZero inView:view.superview];
    }
}


#pragma  mark -- 手势代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark - action
- (IBAction)onEditTextBtnClick:(UIButton *)sender {
    [self removeTishiLabel];
    self.bannerView.hidden = self.tempBannerViewHidden;
    [self.editOptionsBackGroundView bringSubviewToFront:self.textContentView];
    self.toolSelectItem = TEXT;
    self.textView.isCanMove = YES;
    [self setToolBarButtonDidSelectedWithText:YES Theme:NO Photo:NO];
}
- (IBAction)onEdtiThemeBtnClick:(UIButton *)sender {
    [self removeTishiLabel];
    [self.editOptionsBackGroundView bringSubviewToFront:self.themeContentView];
    self.toolSelectItem = THEME;
    self.textView.isCanMove = YES;
    [self setToolBarButtonDidSelectedWithText:NO Theme:YES Photo:NO];
    self.tempBannerViewHidden = self.bannerView.hidden;
    self.bannerView.hidden = YES;
}
- (IBAction)onEditPhotoBtnClick:(UIButton *)sender {
    self.bannerView.hidden = self.tempBannerViewHidden;
    if (self.photoEnabled==NO) {
        [self addTishiLabel];
    }else{
        [self removeTishiLabel];
    }
    
    [self.editOptionsBackGroundView bringSubviewToFront:self.photoContentView];
    self.toolSelectItem = PHOTO;
    self.textView.isCanMove = NO;
    [self setToolBarButtonDidSelectedWithText:NO Theme:NO Photo:YES];
}


#pragma  mark -- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.blackGroundImageViewTempImage = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//通知
-(void)keyBoardFun:(NSNotification*)info{
    //
    //    NSDictionary * userInfo = info.userInfo;
    //    LOG(@"%@",info);
    //    NSString * CenterBeginUser_string = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"UIKeyboardCenterBeginUserInfoKey"]];
    //    CGPoint CenterBeginUser = CGPointFromString(CenterBeginUser_string);
    //    NSString * CenterEndUser_string = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"UIKeyboardCenterEndUserInfoKey"]];
    //    CGPoint CenterEndUser = CGPointFromString(CenterEndUser_string);
    //    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //    CGRect frame = self.view.frame;
    //    CGFloat offsetY = CenterBeginUser.y - CenterEndUser.y;
    //    frame.origin.y = frame.origin.y - offsetY;
    //    if (offsetY > 0) {
    ////        self.textContentView.textField.text = self.textLable.text;
    //    }
    //    [UIView animateWithDuration:duration animations:^{
    //        self.view.frame = frame;
    //    }];
}

-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    BOOL isHidden = YES;
    if (self.toolSelectItem == TEXT) {
        isHidden = [self.textContentView isHiddenBannerView];
    }else if (self.toolSelectItem == THEME){
        
    }else if (self.toolSelectItem == PHOTO){
        isHidden = [self.photoContentView isHiddenBannerView];
    }
    self.bannerView.hidden = isHidden;
}

//释放jianpan
-(void)textViewResignFirstResponder{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}


-(void)doneButtonItemClick{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.textView.delelBtn.hidden = YES;
        self.textView.doneBtn.hidden = YES;
        self.textView.frameBtn.hidden = YES;
        self.textView.border.hidden = YES;
        
        UIGraphicsBeginImageContextWithOptions(self.editPreviewBackGroundView.bounds.size,YES,[[UIScreen mainScreen] scale]);
        [self.editPreviewBackGroundView.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        PreviewViewController * prVC = [[PreviewViewController alloc]init];
        
        NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
        if ([self.currentThemeModel.photoEnabled isEqualToString:@"YES"]) {
            NSArray * goProAray = [userDefault objectForKey:kGoProArray];
            if ([goProAray containsObject:self.currentThemeModel.imageName]) {
                prVC.saveAction = GOPRO;
            }else{
                prVC.saveAction = SAVE;
            }
        }else{
            NSArray * commentAray = [userDefault objectForKey:kCommentArray];
            if ([commentAray containsObject:self.currentThemeModel.imageName] ) {
                prVC.saveAction = COMMENT;
            }else{
                prVC.saveAction = SAVE;
            }
        }

        prVC.image = image;
        prVC.editVC = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:prVC animated:YES];
            [hud hideAnimated:YES];
        });
        
    });

}
-(void)blackButtonItemClick{
    
    UIAlertController * alertcontroller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"camera.back", @"Back") message:NSLocalizedString(@"Are you sure?", @"Are you sure?") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"common.Cancel", @"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * OK = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alertcontroller addAction:cancel];
    [alertcontroller addAction:OK];
    [self presentViewController:alertcontroller animated:YES completion:nil];
}

-(void)setToolBarButtonDidSelectedWithText:(BOOL)text Theme:(BOOL)theme Photo:(BOOL)photo{
    if (text) {
        [self.textBtn setImage:[UIImage imageNamed:@"textchoosed"] forState:UIControlStateNormal];
        self.textContentView.hidden = NO;
        self.title = NSLocalizedString(@"Edit Text", @"Edit Text");
    }else{
        [self.textBtn setImage:[UIImage imageNamed:@"text"] forState:UIControlStateNormal];
        self.textContentView.hidden = YES;
    }
    if (theme){
        [self.themeBtn setImage:[UIImage imageNamed:@"themechoosed"] forState:UIControlStateNormal];
        self.themeContentView.hidden = NO;
        self.title = NSLocalizedString(@"Select Theme", @"Select Theme");
    }
    else{
        [self.themeBtn setImage:[UIImage imageNamed:@"theme"] forState:UIControlStateNormal];
        self.themeContentView.hidden = YES;
    }
    if (photo){
        [self.photoBtn setImage:[UIImage imageNamed:@"pictureschoosed"] forState:UIControlStateNormal];
        self.photoContentView.hidden = NO;
        self.title = NSLocalizedString(@"Edit Picture", @"Edit Picture");
    }else{
        [self.photoBtn setImage:[UIImage imageNamed:@"pictures"] forState:UIControlStateNormal];
        self.photoContentView.hidden = YES;
    }
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    CGFloat W = [UIScreen mainScreen].bounds.size.width;
    CGFloat H = [UIScreen mainScreen].bounds.size.height;
    W = W-10;
    H = H - 214-64;
    
    CGFloat min = W<H?W:H;
    self.previewHight.constant = min;
    self.previewWight.constant = min;
    CGFloat bottom = (H+10 - min)/2;
    
    self.previewBottom.constant = bottom;
}
-(void)removeTextViewSubViews{
    ColorPickerView * colorPicker = [self.editOptionsBackGroundView viewWithTag:ColorPickerViewTag];
    if (colorPicker) {
        [colorPicker removeFromSuperview];
    }
    TextureChooseView * textureChoose = [self.editOptionsBackGroundView viewWithTag:TextureChooseViewTag];
    if (textureChoose) {
        [textureChoose removeFromSuperview];
    }
    FontPickerView * fontPicker = [self.view viewWithTag:FontPickerViewTag];
    if (fontPicker) {
        [fontPicker removeFromSuperview];
    }
    TextUnderLineStyleView * underlineStyle = [self.view viewWithTag:TextUnderlineStyleViewTag];
    if (underlineStyle) {
        [underlineStyle removeFromSuperview];
    }
}
-(float)adViewBottomOffsetFromSuperViewBottom{
    if ([self isIPad]) {
        return 113;
    }
    return 133;
}
@end
