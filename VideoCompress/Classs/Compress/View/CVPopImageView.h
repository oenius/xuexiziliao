//
//  CVPopImageView.h
//  VideoCompress
//
//  Created by 何少博 on 17/4/13.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CVPopImageView : UIView

@property (nonatomic,strong) UIImage * image;

@property (nonatomic,strong) UIColor * fillColor;

@property (nonatomic,strong) UIColor * borderColor;

@property (nonatomic,assign) CGFloat borderWidth;

@end
