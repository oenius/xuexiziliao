//
//  DatePickerTableViewCell.m
//  VoiceRemind
//
//  Created by 何少博 on 16/9/9.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "DatePickerTableViewCell.h"



@interface DatePickerTableViewCell ()

@property (assign,nonatomic)BOOL isFirst;

@end



@implementation DatePickerTableViewCell

- (IBAction)datePickerChanged:(UIDatePicker *)sender {
    NSDate *selectDate  = sender.date;
    NSString *dateStr  = [NSDateFormatter localizedStringFromDate:selectDate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
    NSString *timeStr = [NSDateFormatter localizedStringFromDate:selectDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    if ([self.delegate respondsToSelector:@selector(chooseDate:H_S:Y_M_D:)]) {
        [self.delegate chooseDate:selectDate H_S:timeStr Y_M_D:dateStr];
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.datePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:5*60];
    self.datePicker.date = [NSDate dateWithTimeIntervalSinceNow:30*60];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
