//
//  CIUserDefaultManager.h
//  CutoutImage
//
//  Created by 何少博 on 17/2/20.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CIUserDefaultManager : NSObject

+(void)setFirstLaunchMark:(BOOL)first;
+(BOOL)getFirstLaunchMark;

+(BOOL)getShouldShowAD;
+(void)setShouldShowAD:(BOOL)should;

@end
