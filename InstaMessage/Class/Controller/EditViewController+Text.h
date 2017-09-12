//
//  EditViewController+Text.h
//  InstaMessage
//
//  Created by 何少博 on 16/8/1.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//


#import "EditViewController.h"
#import "ColorPickerView.h"
#import "TextureChooseView.h"
#import "FontPickerView.h"
#import "TextUnderLineStyleView.h"

@interface EditViewController (Text)
<
TextContentViewDelegate,
YYTextViewDelegate,
ColorPickerViewDelegate,
TextureChooseViewDelegate,
FontPickerViewDelegate,
TextUnderLineStyleViewDelegate,
CustomTextViewDelegate
>


-(void)initTextContentView;
-(void)addTextView;
@end
