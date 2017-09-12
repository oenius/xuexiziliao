//
//  SucceedView.h
//  MemoryTurnCard
//
//  Created by 何少博 on 16/10/25.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BtnClickBlock)(BOOL isAgain ,BOOL remove ,BOOL isNext);

@interface SucceedView : UIView

-(void)setADView:(UIView*)adView hardLevel:(int)hareLavel btnClickBlock:(BtnClickBlock)block;

@end
