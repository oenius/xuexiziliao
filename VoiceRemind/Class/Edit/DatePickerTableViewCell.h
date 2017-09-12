//
//  DatePickerTableViewCell.h
//  VoiceRemind
//
//  Created by 何少博 on 16/9/9.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  DatePickerViewDeleagte;


@interface DatePickerTableViewCell : UITableViewCell

@property (weak,nonatomic)id<DatePickerViewDeleagte> delegate;

@property (weak, nonatomic) IBOutlet UILabel *myDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *myTitleLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@end

@protocol DatePickerViewDeleagte <NSObject>

-(void)chooseDate:(NSDate*)date H_S:(NSString*)xiaoFen Y_M_D:(NSString*)nianYR;

@end