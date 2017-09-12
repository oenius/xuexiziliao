//
//  CustomAnimatedDelegate.h
//  MemoryTurnCard
//
//  Created by 何少博 on 16/10/25.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SingletonHelp.h"
@interface CustomAnimatedDelegate : NSObject<UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate>

//-(void)setAnimatedModel:()
//+(instancetype)shareInstance;
Singleton_H(Instance);
@end
