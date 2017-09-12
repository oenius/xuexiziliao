//
//  DatePickerView.h
//  VoiceRemind
//
//  Created by 何少博 on 16/8/25.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  DatePickerViewDeleagte;

@interface DatePickerView : UIView

@property (weak,nonatomic)id<DatePickerViewDeleagte> delegate;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickker;
@end

@protocol DatePickerViewDeleagte <NSObject>

-(void)chooseDate:(NSDate*)date H_S:(NSString*)xiaoFen Y_M_D:(NSString*)nianYR;

@end