//
//  MemoryCardContentView.h
//  MemoryTurnCard
//
//  Created by 何少博 on 16/10/24.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^succeedBlock)(NSInteger step);

typedef void(^finish)(BOOL finish);
@interface MemoryCardContentView : UIView

@property (nonatomic,assign,readonly) BOOL isAnimationing;

-(void)removeSelfWithAnimation;

-(instancetype)initWithFrame:(CGRect)frame dardLevel:(NSInteger)hardLevel imageType:(GameImageType)imageType succeedBlock:(succeedBlock)block;

-(instancetype)initWithHardLevel:(NSInteger)hardLevel imageType:(GameImageType)imageType succeedBlock:(succeedBlock)block;

@end
