//
//  DTPromptHUD.h
//  DataTansfer
//
//  Created by 何少博 on 17/6/7.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTPromptHUD : UIView

+(void)showWithString:(NSString *)promptText;

+(BOOL)isShowing;
+(NSString *)showString;
@end
