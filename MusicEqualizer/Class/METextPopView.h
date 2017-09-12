//
//  METextPopView.h
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface METextPopView : UIView

@property (nonatomic,strong) NSString * text;

@property (nonatomic,strong) UIColor * textColor;

@property (nonatomic,strong) UIColor * fillColor;

@property (nonatomic,strong) UIColor * borderColor;

@property (nonatomic,strong) UIFont * textFont;

@property (nonatomic,assign) CGFloat borderWidth;

@end
