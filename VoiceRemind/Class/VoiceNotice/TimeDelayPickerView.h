//
//  TimeDelayPickerView.h
//  VoiceRemind
//
//  Created by 何少博 on 16/9/6.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimeDelayPickerViewDelegate <NSObject>

-(void)timeDelaychoosed:(NSDate*)date string:(NSString *)delayStr;

@end

@interface TimeDelayPickerView : UIView

@property (weak,nonatomic) id<TimeDelayPickerViewDelegate>delegate;

@property (strong,nonatomic)NSDate * date;

@end

