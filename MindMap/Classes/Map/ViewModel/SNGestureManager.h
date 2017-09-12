//
//  SNGestureManager.h
//  MindMap
//
//  Created by 何少博 on 2017/8/8.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SNMindMapViewController;

@interface SNGestureManager : NSObject

@property (weak,nonatomic) SNMindMapViewController *mindMapViewController;

-(instancetype)initWithMindMapViewControlelr:(SNMindMapViewController *)controller;

-(void)editNodeAction:(id)sender;
@end
