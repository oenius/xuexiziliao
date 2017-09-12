//
//  DTPromptHUD.m
//  DataTansfer
//
//  Created by 何少博 on 17/6/7.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTPromptHUD.h"
#import <AudioToolbox/AudioToolbox.h>
#define kWindowWidth [UIApplication sharedApplication].keyWindow.frame.size.width


@interface DTPromptHUD ()

@property (nonatomic,strong) UILabel * label;

@end


static NSUInteger const kHUDTAG = 9377842;

static CGFloat const kHeight = 64;

static CGFloat const kY = 20;

static NSString  *  _labelText = nil;

static BOOL _isShowing = NO;

@implementation DTPromptHUD

-(instancetype)initWithFrame:(CGRect)frame{
    
    CGRect newFrame = CGRectMake(0, -kHeight, kWindowWidth, kHeight);
    self = [super initWithFrame:newFrame];
    if (self) {
        self.frame = newFrame;
        self.backgroundColor = [UIColor colorWithRed:0.13 green:0.75 blue:0.40 alpha:1.00];
        CGRect labelFrame = CGRectMake(kHeight/2, kY, kWindowWidth-kHeight*2, kHeight-kY);
        self.label = [[UILabel alloc]initWithFrame:labelFrame];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [UIColor whiteColor];
        self.label.numberOfLines = 5;
        self.label.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.label];
        
        CGRect btnFrame = CGRectMake(kWindowWidth-kHeight, 4+kY, kHeight-8-kY, kHeight-8-kY);
        UIButton * dismissBtn = [[UIButton alloc]initWithFrame:btnFrame];
        [self addSubview:dismissBtn];
        dismissBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [dismissBtn setTitle:NSLocalizedString(@"OK", @"") forState:(UIControlStateNormal)];
        dismissBtn.titleLabel.font = [UIFont systemFontOfSize:19];
        [dismissBtn setTitleColor:[UIColor colorWithRed:0.13 green:0.75 blue:0.40 alpha:1.00] forState:(UIControlStateNormal)];
        dismissBtn.backgroundColor = [UIColor whiteColor ];
        dismissBtn.layer.masksToBounds = YES;
        dismissBtn.layer.cornerRadius = (kHeight-8-kY)/2.0;
        [dismissBtn addTarget:self action:@selector(disMissSelf) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return self;
}

+(BOOL)isShowing{
    return _isShowing;
}
+(NSString *)showString{
    return _labelText;
}

+(void)showWithString:(NSString *)promptText{
    UIWindow * keyWidow = [UIApplication sharedApplication].keyWindow;
    if ([promptText isEqualToString:_labelText]) {
        return;
    }
    if (_isShowing == YES) {
        UIWindow * keyWidow = [UIApplication sharedApplication].keyWindow;
        DTPromptHUD * hud = [keyWidow viewWithTag:kHUDTAG];
        [hud removeFromSuperview];
    }
    
    DTPromptHUD * hud = [[DTPromptHUD alloc]initWithFrame:CGRectZero];
    hud.label.text = promptText;
    _labelText = promptText;
    hud.tag = kHUDTAG;
    CGRect newFrame = CGRectMake(0, 0, kWindowWidth, kHeight);
    [keyWidow addSubview:hud];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self playSoundEffect:@"sound.caf"];
    });
    _isShowing = YES;
    [UIView animateWithDuration:0.3 animations:^{
        hud.frame = newFrame;
    }];
}

-(void)disMissSelf{
    UIWindow * keyWidow = [UIApplication sharedApplication].keyWindow;
    DTPromptHUD * hud = [keyWidow viewWithTag:kHUDTAG];

    if (hud) {
        CGRect newFrame = CGRectMake(0, -kHeight, kWindowWidth, kHeight);
        [UIView animateWithDuration:0.3 animations:^{
            hud.frame = newFrame;
        } completion:^(BOOL finished) {
            [hud removeFromSuperview];
            _isShowing = NO;
            _labelText = nil;
        }];
    }
}
+ (void)playSoundEffect:(NSString *)name {
    // 获取音效
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
    
    // 1、获得系统声音ID
    SystemSoundID soundID = 0;
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundComplete, NULL);
    
    // 2、播放音频
    AudioServicesPlaySystemSound(soundID); // 播放音效
}
/** 播放完成回调函数 */
void soundComplete(SystemSoundID soundID, void *clientData){
    
}
@end
