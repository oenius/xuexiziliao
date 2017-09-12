//
//  EditViewController+Text.m
//  InstaMessage
//
//  Created by 何少博 on 16/8/1.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "EditViewController+Text.h"
#import "UIView+x.h"
#import "NPCommonConfig.h"
#import "MBProgressHUD.h"
@implementation EditViewController (Text)


-(void)initTextContentView{
    self.textContentView = [TextContentView viewWithNib:@"TextContentView" owner:nil];
    self.textContentView.delegate = self;
    self.textContentView.frame = self.editOptionsBackGroundView.bounds;
    self.textContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.editOptionsBackGroundView addSubview:self.textContentView];
}
-(void)addTextView{
    
    CustomTextView * textView = [[CustomTextView alloc]initWithFrame:CGRectMake(0,0,200, 200)];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"Please enter your text!"];
    if (self.textView) {
        [self adjustTextViewStatus:textView];
    }
    self.textView = textView;
    text.yy_font = [UIFont systemFontOfSize:30];
    text.yy_color = [UIColor blackColor];
    text.yy_lineSpacing = 4;
    text.yy_firstLineHeadIndent = 0;
    self.textView.attributedText = text;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.delegate = self;
    self.textView.customDelegate = self;
    self.textView.clipsToBounds = YES;
    self.textView.center = self.frontImageView.center;
    self.textView.scrollIndicatorInsets = self.textView.contentInset;
    self.textView.scrollEnabled = NO;
    [self.textView sizeToFit];
    [self.editPreviewBackGroundView addSubview:self.textView];
    
}
-(void)addColorPickerView{
    
    ColorPickerView * colorPicker = [self.textContentView viewWithTag:ColorPickerViewTag];
    if (colorPicker == nil) {
        colorPicker = [ColorPickerView viewWithNib:@"ColorPickerView" owner:nil];
        CGRect frame = CGRectMake(0, 0, self.textContentView.bounds.size.width, 100);
        colorPicker.frame = frame;
        colorPicker.delegate = self;
        colorPicker.tag = ColorPickerViewTag;
        [self.textContentView addSubview:colorPicker];
    }
}

-(void)removeColorPickerView{
    [self removeUnderlineStyleView];
    ColorPickerView * colorPicker = [self.textContentView viewWithTag:ColorPickerViewTag];
    if (colorPicker) {
        [colorPicker removeFromSuperview];
        self.bannerView.hidden = NO;
    }
}
-(void)addTextureChooseView{
    
    TextureChooseView * textureChoose = [self.textContentView viewWithTag:TextureChooseViewTag];
    if (textureChoose == nil) {
        textureChoose = [TextureChooseView viewWithNib:@"TextureChooseView" owner:nil];
        textureChoose.frame = CGRectMake(0, 0, self.textContentView.bounds.size.width, 100);
        textureChoose.delegate = self;
        textureChoose.tag = TextureChooseViewTag;
        [self.textContentView addSubview:textureChoose];
    }
}

-(void)removeTextureChooseView{
    TextureChooseView * textureChoose = [self.textContentView viewWithTag:TextureChooseViewTag];
    if (textureChoose) {
        [textureChoose removeFromSuperview];
        self.bannerView.hidden = NO;
    }
}
-(void)addFontPickerView{
    FontPickerView * fontPicker = [self.textContentView viewWithTag:FontPickerViewTag];
    if (fontPicker == nil) {
        fontPicker = [FontPickerView viewWithNib:@"FontPickerView" owner:nil];
        CGRect frame = CGRectMake(0, 0, self.textContentView.bounds.size.width, 100);
        fontPicker.frame = frame;
        fontPicker.delegate = self;
        fontPicker.tag = FontPickerViewTag;
        [self.textContentView addSubview:fontPicker];
    }
}
-(void)removeFontPickerView{
    FontPickerView * fontPicker = [self.textContentView viewWithTag:FontPickerViewTag];
    if (fontPicker) {
        [fontPicker removeFromSuperview];
        self.bannerView.hidden = NO;
    }
}
-(void)addUnderlineStyleView{
    TextUnderLineStyleView * underlineStyleView = [self.textContentView viewWithTag:TextUnderlineStyleViewTag];
    if (underlineStyleView == nil) {
        underlineStyleView = [TextUnderLineStyleView viewWithNib:@"TextUnderLineStyleView" owner:nil];
        CGRect frame = CGRectMake(0, 100, self.textContentView.bounds.size.width, 60);
        underlineStyleView.frame = frame;
        underlineStyleView.delegate = self;
        underlineStyleView.tag = TextUnderlineStyleViewTag;
        [self.textContentView addSubview:underlineStyleView];
    }
}
-(void)removeUnderlineStyleView{
    TextUnderLineStyleView * underlineStyle = [self.textContentView viewWithTag:TextUnderlineStyleViewTag];
    if (underlineStyle) {
        [underlineStyle removeFromSuperview];
        self.bannerView.hidden = NO;
    }
}


#pragma mark textContentViewdelegate
-(void)textContentView:(TextContentView *)textContentView fontSettingCellClick:(TextActionTag)tag{
    self.textUnderLineEnable = NO;
    self.textColorEnable = NO;
    self.textShadowEnable = NO;
    self.textInnerShadowEnable  = NO;
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }

    NSMutableAttributedString * text = [[NSMutableAttributedString alloc]initWithAttributedString: self.textView.attributedText];
    
    switch (tag) {
            //设置字体
        case TextActionTag_addText:
        {
            [self removeColorPickerView];
            [self removeTextureChooseView];
            [self removeUnderlineStyleView];
            [self removeFontPickerView];
            [self addTextView];
            self.bannerView.hidden = NO;
        }
            break;
//设置字体
        case TextActionTag_font:
        {
            [self removeColorPickerView];
            [self removeTextureChooseView];
            [self removeUnderlineStyleView];
            [self addFontPickerView];
            self.oldFont = text.yy_font;
            self.bannerView.hidden = YES;
        }
            break;
//设置字体颜色
        case TextActionTag_color:
        {
            [self removeTextureChooseView];
            [self removeUnderlineStyleView];
            [self removeFontPickerView];
            [self addColorPickerView];
            self.oldColor = text.yy_color;
            self.textColorEnable = YES;
            self.bannerView.hidden = YES;
        }
            break;
//字体居中
        case TextActionTag_text_center:
            [self removeTextureChooseView];
            [self removeUnderlineStyleView];
            [self removeFontPickerView];
            [self removeColorPickerView];
            text.yy_alignment = NSTextAlignmentCenter;
            self.bannerView.hidden = NO;
            break;
//左对齐
        case TextActionTag_text_left:
            [self removeTextureChooseView];
            [self removeUnderlineStyleView];
            [self removeColorPickerView];
            [self removeFontPickerView];
            text.yy_alignment = NSTextAlignmentLeft;
            self.bannerView.hidden = NO;
            break;
//右对齐
        case TextActionTag_text_right:
            [self removeTextureChooseView];
            [self removeUnderlineStyleView];
            [self removeColorPickerView];
            [self removeFontPickerView];
            text.yy_alignment = NSTextAlignmentRight;
            self.bannerView.hidden = NO;
            break;

//外阴影
        case TextActionTag_waiYinYing:
        {
            
            [self removeTextureChooseView];
            [self removeUnderlineStyleView];
            [self removeFontPickerView];
            [self addColorPickerView];
            self.oldColor = text.yy_textShadow.color;
            self.textShadowEnable = YES;
            self.bannerView.hidden = YES;
        }
            break;
//纹理
        case TextActionTag_tuPianWenZi:
            [self removeColorPickerView];
            [self removeUnderlineStyleView];
            [self addTextureChooseView];
            [self removeFontPickerView];
            self.oldColor = text.yy_color;
            self.bannerView.hidden = YES;
            break;
//下划线
        case TextActionTag_xiaHuaXian:
        {
            self.textUnderLineEnable = YES;
            [self removeTextureChooseView];
            [self removeFontPickerView];
            [self addUnderlineStyleView];
            [self addColorPickerView];
            text.yy_underlineStyle = NSUnderlineStyleSingle;
            self.bannerView.hidden = YES;
        }
            break;
//横排
        case TextActionTag_hengPai:
            [self removeTextureChooseView];
            [self removeColorPickerView];
            [self removeFontPickerView];
            [self removeUnderlineStyleView];
            self.textView.verticalForm = NO;
            self.bannerView.hidden = NO;
            break;
//竖排
        case TextActionTag_shuPai:
            
            [self removeTextureChooseView];
            [self removeColorPickerView];
            [self removeFontPickerView];
            [self removeUnderlineStyleView];
            self.textView.verticalForm = YES;
            self.bannerView.hidden = NO;
            break;
//广告
        case TextActionTag_ads:
            
            [self removeTextureChooseView];
            [self removeColorPickerView];
            [self removeFontPickerView];
            [self removeUnderlineStyleView];
            [self addQuanPingADS];
            self.bannerView.hidden = NO;
            
            break;
        default:
            
            [self removeTextureChooseView];
            [self removeColorPickerView];
            [self removeFontPickerView];
            [self removeUnderlineStyleView];
            self.bannerView.hidden = YES;
            break;
    }
    if (text.length == 0||text == nil) {
      text = [[NSMutableAttributedString alloc] initWithString:@"Please enter your text!"];
      text.yy_font = [UIFont systemFontOfSize:30];
    }
    self.textView.attributedText = text;
//    [self.textView sizeToFit];
}

-(void)textContentView:(TextContentView *)textContentView lineSpaceValueChange:(CGFloat)value{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }

    [self adjustTextViewStatus:self.textView];
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc]initWithAttributedString: self.textView.attributedText];
    text.yy_lineSpacing = value* 50;
    self.textView.attributedText = text;
//    [self.textView sizeToFit];
    
}

-(void)textContentView:(TextContentView *)textContentView charSpaceValueChange:(CGFloat)value{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }

    [self adjustTextViewStatus:self.textView];
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc]initWithAttributedString: self.textView.attributedText];
    text.yy_kern = [NSNumber numberWithInteger:value];
    self.textView.attributedText = text;
//    [self.textView sizeToFit];
}

-(void)textContentView:(TextContentView *)textContentView fontSizeValueChange:(CGFloat)value{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }

    [self adjustTextViewStatus:self.textView];
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc]initWithAttributedString: self.textView.attributedText];
    UIFont * font = text.yy_font;
    text.yy_font = [font fontWithSize:value];
    self.textView.attributedText = text;
//    [self.textView sizeToFit];
}
-(void)textContentView:(TextContentView *)textContentView textAlphaValueChange:(CGFloat)value{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
    [self adjustTextViewStatus:self.textView];
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc]initWithAttributedString: self.textView.attributedText];
    UIColor * oldColor = text.yy_color;
    text.yy_color = [oldColor colorWithAlphaComponent:value];
    self.textView.attributedText = text;
}

#pragma  mark -- CustomaTextViewDelegate

-(void)returnCurrentCustomTextView:(CustomTextView *)textView{
    [self adjustTextViewStatus:textView];
}
#pragma mark textviewdelegate

- (void)textViewDidBeginEditing:(CustomTextView *)textView {
    
}
-(void)textViewDidChange:(YYTextView *)textView{
//    [self.textView sizeToFit];
}
- (void)textViewDidEndEditing:(CustomTextView *)textView {
//    [self.textView sizeToFit];
}
-(BOOL)textViewShouldBeginEditing:(CustomTextView *)textView{
    [self adjustTextViewStatus:textView];
    if (self.textView.isCanMove == NO) {
        return NO;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
    }
    if (self.textView.beiScaAndRot) {
        self.textView.delelBtn.hidden = NO;
//        self.textView.doneBtn.hidden = NO;
        self.textView.border.hidden = NO;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = NSLocalizedString(@"Text can't be modified after rotating or scaling.", @"Text can't be modified after rotating or scaling.");
        [hud hideAnimated:YES afterDelay:1.f];
        return NO;
    }
    return YES;
}
//根据输入内容调整textView大小
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    LOG(@"--------------------------------");
//    LOG(@"scrollView.contentOffset.x->%f",scrollView.contentOffset.x);
//    LOG(@"scrollView.contentOffset.y->%f",scrollView.contentOffset.y);
//    LOG(@"scrollView.contentSize->%@",NSStringFromCGSize(scrollView.contentSize));
//    if (!self.textView.beiScaAndRot) {
        CGRect frame = self.textView.frame;
//        frame.origin.x -= scrollView.contentOffset.x;
//        frame.origin.y -= scrollView.contentOffset.y;
        frame.size.height = scrollView.contentSize.height;
        frame.size.width = scrollView.contentSize.width;
        self.textView.frame = frame;
//    }
    self.textView.contentOffset = CGPointZero;
    
}



#pragma mark - ColorPickerViewDelegate

-(void)colorPickerViewDoneButtonClick:(ColorPickerView *)colorPickerView{
    [self removeColorPickerView];
    self.bannerView.hidden = NO;
}

-(void)colorPickerViewCancelButtonClick:(ColorPickerView *)colorPickerView{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }

    NSMutableAttributedString * text = [[NSMutableAttributedString alloc]initWithAttributedString: self.textView.attributedText];
    text.yy_color = self.oldColor;
    text.yy_underlineStyle = self.oldUnderLineStyle;
    self.textView.attributedText = text;
    [self removeColorPickerView];
    self.bannerView.hidden = NO;
//    [self.textView sizeToFit];
}


-(void)colorPickerView:(ColorPickerView *)colorPickerView colorChoose:(UIColor *)color{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc]initWithAttributedString: self.textView.attributedText];
    if (self.textUnderLineEnable == YES) {
        text.yy_underlineColor = color;
    }
    else if (self.textColorEnable == YES){
        text.yy_color = color;
    }
    else if (self.textShadowEnable == YES) {
        
        YYTextShadow *shadow = [YYTextShadow new];
        shadow.color = color;
        shadow.offset = CGSizeMake(0, 1);
        shadow.radius = 5;
        text.yy_textShadow = shadow;
    }
    self.textView.attributedText = text;
    //    [self.textView sizeToFit];
}
#pragma mark - TextureViewDelegate
-(void)textureChooseViewDoneButtonClick:(TextureChooseView *)textureChooseView{
    self.bannerView.hidden = NO;
}

-(void)textureChooseViewCancelButtonClick:(TextureChooseView *)textureChooseView{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }

    NSMutableAttributedString * text = [[NSMutableAttributedString alloc]initWithAttributedString: self.textView.attributedText];

    text.yy_color = self.oldColor;
    self.textView.attributedText = text;
    self.bannerView.hidden = NO;
}

-(void)textureChooseView:(TextureChooseView *)textureChooseView chooseImageWithName:(NSString *)imageName{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc]initWithAttributedString: self.textView.attributedText];
    NSString * path = [[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"%@",imageName] ofType:nil];
    UIImage * wenLIimage =[UIImage imageWithContentsOfFile:path];
    text.yy_color = [UIColor colorWithPatternImage:wenLIimage];
    self.textView.attributedText = text;
//    [self.textView sizeToFit];
}

#pragma mark - FontPickerViewDelegate

-(void)fontPickerView:(FontPickerView *)fontPickerView chooseFontName:(NSString *)fontName{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
    [self adjustTextViewStatus:self.textView];
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc]initWithAttributedString: self.textView.attributedText];
    CGFloat fontSize = text.yy_font.pointSize;
    text.yy_font = [UIFont fontWithName:fontName size:fontSize];
    self.textView.attributedText = text;
}
-(void)fontPickerViewDoneButtonClick:(FontPickerView *)fontPickerView{
    self.bannerView.hidden = NO;
}
-(void)fontPickerViewCancelButtonClick:(FontPickerView *)fontPickerView{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc]initWithAttributedString: self.textView.attributedText];
    text.yy_font = self.oldFont;
    self.textView.attributedText = text;
    self.bannerView.hidden = NO;
}

#pragma mark - FontPickerViewDelegate
-(void)textUnderLineStyleViewCancelButtonClick:(TextUnderLineStyleView *)textUnderLineStyleView{
}
-(void)textUnderLineStyleView:(TextUnderLineStyleView *)textUnderLineStyleView chooseUnderlineStyle:(NSUnderlineStyle)underlineStyle{
    if (self.textView.isFirstResponder) {
        [self.textView resignFirstResponder];
    }
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc]initWithAttributedString: self.textView.attributedText];
    text.yy_underlineStyle = underlineStyle;
    self.textView.attributedText = text;
    
}

-(void)adjustTextViewStatus:(CustomTextView*)textView{
    if (![self.textView isEqual:textView]) {
        self.textView.border.hidden = YES;
        self.textView.delelBtn.hidden = YES;
        self.textView.doneBtn.hidden = YES;
        self.textView.frameBtn.hidden = YES;
        self.textView = textView;
        [self.editPreviewBackGroundView bringSubviewToFront:textView];
    }
    textView.border.hidden = NO;
    textView.delelBtn.hidden = NO;
    textView.doneBtn.hidden = NO;
    textView.frameBtn.hidden = NO;
    if (self.textView.beiScaAndRot) {
        self.textView.frameBtn.hidden = YES;
        self.textView.doneBtn.hidden = YES;
    }
}

-(void)addQuanPingADS{
    if ([[NPCommonConfig shareInstance] shouldShowAdvertise]) {
        [[NPCommonConfig shareInstance] showFullScreenAdORNativeAdForController:self];
    }
}

@end
