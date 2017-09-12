//
//  EditViewController.h
//  InstaMessage
//
//  Created by 何少博 on 16/7/27.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"
#import "ThemeContentView.h"
#import "TextContentView.h"
#import "PotoContentView.h"

#import "NSAttributedString+YYText.h"
#import "YYTextKeyboardManager.h"
#import "YYTextView.h"
#import "CustomTextView.h"

#import "UIView+x.h"
#import "He_enum.h"

@interface EditViewController : BaseViewController

<
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIGestureRecognizerDelegate
>

@property (weak,nonatomic) IBOutlet UIView *editPreviewBackGroundView;
@property (weak,nonatomic) IBOutlet UIView *editOptionsBackGroundView;
@property (weak,nonatomic) IBOutlet UIImageView * blackgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *blackGroundImageViewSupView;
@property (weak,nonatomic) IBOutlet UIImageView * frontImageView;
@property (weak, nonatomic) IBOutlet UIView *toolBar;
@property (weak, nonatomic) IBOutlet UIButton *photoBtn;
@property (weak, nonatomic) IBOutlet UIButton *themeBtn;
@property (weak, nonatomic) IBOutlet UIButton *textBtn;

@property (weak,nonatomic) CustomTextView * textView;
@property (strong,nonatomic) TextContentView *textContentView;
@property (strong,nonatomic) ThemeContentView *themeContentView;
@property (strong,nonatomic) PotoContentView *photoContentView;
@property (strong,nonatomic) UIImage * blackGroundImageViewTempImage;

@property (assign,nonatomic) EditToolBarSelectItem  toolSelectItem;
@property (strong,nonatomic) ThemeItemModel * currentThemeModel;
@property (assign,nonatomic) CGRect blackGroundImageViewOldFrame;
@property (assign,nonatomic) CGAffineTransform blackGroundImageViewOldTransform;
@property (strong,nonatomic) UIColor * oldColor;
@property (strong,nonatomic) UIFont * oldFont;
@property (assign,nonatomic) NSUnderlineStyle oldUnderLineStyle;
@property (weak,nonatomic) UIVisualEffectView * visualEffectView;
@property (strong,nonatomic) NSMutableArray * textViewArray;

@property (assign,nonatomic) BOOL photoEnabled;
@property (assign,nonatomic) BOOL textUnderLineEnable;
@property (assign,nonatomic) BOOL textColorEnable;
@property (assign,nonatomic) BOOL textShadowEnable;
@property (assign,nonatomic) BOOL textInnerShadowEnable;
@property (assign,nonatomic) BOOL showAds;
@property (assign,nonatomic) BOOL beiFanZhuan;

//@property (assign,nonatomic) BOOL isAlreadyShowAD;

@end
