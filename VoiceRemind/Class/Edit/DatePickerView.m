//
//  DatePickerView.m
//  VoiceRemind
//
//  Created by 何少博 on 16/8/25.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "DatePickerView.h"

@interface DatePickerView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DatePickerView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.contentView.layer.cornerRadius = 8;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.datePickker.datePickerMode = UIDatePickerModeDateAndTime;
}

@end
