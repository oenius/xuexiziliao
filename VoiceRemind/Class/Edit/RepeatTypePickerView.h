//
//  RepeatTypePickerView.h
//  VoiceRemind
//
//  Created by 何少博 on 16/8/26.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VoiceRemindENUM.h"

@protocol RepeatTypePickerViewDelegate;

@interface RepeatTypePickerView : UIView

@property (nonatomic,strong)id<RepeatTypePickerViewDelegate> delegate;

@end




@protocol RepeatTypePickerViewDelegate <NSObject>

-(void)chooseRepeatType:(RepeatType)repeatType string:(NSString *)stringType;

@end