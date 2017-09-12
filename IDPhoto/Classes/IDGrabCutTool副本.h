//
//  IDGrabCutTool.h
//  IDPhoto
//
//  Created by 何少博 on 17/4/27.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDGrabCutTool : NSObject

-(void)prepareGrabCut:(UIImage*)sourceImage iterationCount:(int)iterCount;

//-(UIImage*)doGrabCut:(UIImage*)sourceImage foregroundBound:(CGRect) rect iterationCount:(int)iterCount;

-(UIImage*)doGrabCutWithMask:(UIImage*)sourceImage maskImage:(UIImage*)maskImage iterationCount:(int) iterCount;

-(void) resetManager;

@end
