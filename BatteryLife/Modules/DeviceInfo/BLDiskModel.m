//
//  BLDiskModel.m
//  BatteryLife
//
//  Created by vae on 16/11/18.
//  Copyright © 2016年 vae. All rights reserved.
//

#import "BLDiskModel.h"
#import "SystemServices.h"

#define SystemSharedServices [SystemServices sharedServices]



@implementation BLDiskModel

-(instancetype)init{
    if (self = [super init]) {
        NSString * UnKnown_D = NSLocalizedString(@"Unknown state", @"Unknown state");
        
        // Total Disk Space
        NSString *TotalDiskSpace = NSLocalizedString(@"Total Disk Space", @"Total Disk Space");
        NSString *TotalDiskSpace_d = [SystemSharedServices diskSpace];
        if (TotalDiskSpace_d == nil) {
            TotalDiskSpace_d = UnKnown_D;
        }
        // Used Disk Space
        NSString *UsedDiskSpace =  NSLocalizedString(@"Used Disk Space", @"Used Disk Space");
        NSString *UsedDiskSpace_d = [NSString stringWithFormat:@"%@", [SystemSharedServices usedDiskSpaceinRaw]];
        if (UsedDiskSpace_d == nil) {
            UsedDiskSpace_d = UnKnown_D;
        }
        // Free Disk Space
        NSString *FreeDiskSpace = NSLocalizedString(@"Free Disk Space", @"Free Disk Space");;
        NSString *FreeDiskSpace_d = [NSString stringWithFormat:@"%@", [SystemSharedServices freeDiskSpaceinRaw]];
        if (FreeDiskSpace_d == nil) {
            FreeDiskSpace_d = UnKnown_D;
        }
        
        NSArray *array = @[TotalDiskSpace, UsedDiskSpace, FreeDiskSpace];
        NSArray *array_d = @[TotalDiskSpace_d, UsedDiskSpace_d, FreeDiskSpace_d];
        self.diskTitleArray = array;
        self.diskDetailsArray = array_d;
    }
    

    return self;
}



@end
