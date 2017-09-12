//
//  SoundPickerView.h
//  VoiceRemind
//
//  Created by 何少博 on 16/8/26.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVRecoder.h"

@protocol SoundPickerViewDelegate;

@interface SoundPickerView : UIView

@property (nonatomic,strong)id<SoundPickerViewDelegate> delegate;
@property (strong,nonatomic)AVRecoder * recoderPlay;
@end

@protocol SoundPickerViewDelegate <NSObject>

-(void)chooseSoundNameCaf:(NSString*)namecaf name_:(NSString *)name_ showPinlun:(BOOL)showPinLun;

@end