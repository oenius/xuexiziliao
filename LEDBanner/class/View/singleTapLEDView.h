//
//  singleTapLEDView.h
//  LEDBanner
//
//  Created by 何少博 on 16/7/5.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol singleTapLEDViewDelegate <NSObject>

-(void)tuiChu;
-(void)zanTing:(BOOL)isPause;
-(void)fenXiang;
@end



@interface singleTapLEDView : UIView
@property (nonatomic,weak) id <singleTapLEDViewDelegate> delegate;
@property (nonatomic,assign)BOOL isPause;

@end
 