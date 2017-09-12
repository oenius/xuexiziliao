//
//  SNTipReusableView.m
//  MindMap
//
//  Created by 何少博 on 2017/8/22.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNTipReusableView.h"
#import "SNTipSectionModel.h"
#import "UIColor+SN.h"
@interface SNTipReusableView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end


@implementation SNTipReusableView



-(void)setModel:(SNTipSectionModel *)model{
    _model = model;
    self.titleLabel.text = model.name;
//    NSStrokeColorAttributeName
//    NSStrokeWidthAttributeName
//    NSForegroundColorAttributeName
//    NSMutableAttributedString * string = [[NSMutableAttributedString alloc]initWithString:model.name];
//    NSRange range = NSMakeRange(0, string.length);
//    [string addAttribute:NSStrokeColorAttributeName value:[UIColor redColor] range:range];
//    [string addAttribute:NSStrokeWidthAttributeName value:[NSNumber numberWithFloat:20] range:range];
//    [string addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:range];
//    self.titleLabel.attributedText = string;
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

@end
