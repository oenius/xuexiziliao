//
//  CIUserDefaultManager.m
//  CutoutImage
//
//  Created by 何少博 on 17/2/20.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "CIUserDefaultManager.h"

#define kFirstLaunchMark     @"kFirstLaunchMark"
#define kShouldShowAD        @"kShouldShowAD"

@implementation CIUserDefaultManager

+(void)setFirstLaunchMark:(BOOL)first{
    BOOL newFirst = !first;
    [[NSUserDefaults standardUserDefaults] setBool:newFirst forKey:kFirstLaunchMark];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)getFirstLaunchMark{
    BOOL firstLaunchMark = [[NSUserDefaults standardUserDefaults]boolForKey:kFirstLaunchMark];
    return !firstLaunchMark;
}

+(BOOL)getShouldShowAD{
    BOOL showAD = [[NSUserDefaults standardUserDefaults]boolForKey:kShouldShowAD];
    return showAD;
}

+(void)setShouldShowAD:(BOOL)should{
    [[NSUserDefaults standardUserDefaults] setBool:should forKey:kShouldShowAD];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
