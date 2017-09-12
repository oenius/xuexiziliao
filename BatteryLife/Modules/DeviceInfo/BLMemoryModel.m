//
//  BLMemoryModel.m
//  BatteryLife
//
//  Created by vae on 16/11/18.
//  Copyright © 2016年 vae. All rights reserved.
//

#import "BLMemoryModel.h"
#import "SystemServices.h"

#define SystemSharedServices [SystemServices sharedServices]

@implementation BLMemoryModel

-(instancetype)init{

    if (self = [super init]) {
        NSString *MemoryRAM = NSLocalizedString(@"Total Memory", @"Total Memory");
        NSString *MemoryRAM_d = [NSString stringWithFormat:@"%.2f MB",[SystemSharedServices totalMemory]];
        // Used Memory
        NSString *UsedMemory = NSLocalizedString(@"Used Memory", @"Used Memory");
        NSString *UsedMemory_d = [NSString stringWithFormat:@"%.2f MB", [SystemSharedServices usedMemoryinRaw]];
        
        // Wired Memory
        NSString *WiredMemory = NSLocalizedString(@"Linkage Memory", @"Linkage Memory");
        NSString *WiredMemory_d = [NSString stringWithFormat:@"%.2f MB", [SystemSharedServices wiredMemoryinRaw]];
        
        // Active Memory
        NSString *ActiveMemory = NSLocalizedString(@"Active Memory", @"Active Memory");
        NSString *ActiveMemory_d = [NSString stringWithFormat:@" %.2f MB", [SystemSharedServices activeMemoryinRaw]];
        
        // Inactive Memory
        NSString *InactiveMemory =  NSLocalizedString(@"Inactive Memory", @"Inactive Memory");
        NSString *InactiveMemory_d = [NSString stringWithFormat:@"%.2f MB", [SystemSharedServices inactiveMemoryinRaw]];
        // Free Memory
        NSString *FreeMemory = NSLocalizedString(@"Remaining memory", @"Free Space");
        NSString *FreeMemory_d = [NSString stringWithFormat:@"%.2f MB", [SystemSharedServices freeMemoryinRaw]];
        // Purgeable Memory
        NSString *PurgeableMemory = NSLocalizedString(@"Purgeable Memory", @"Purgeable Memory");
        NSString *PurgeableMemory_d = [NSString stringWithFormat:@"%.2f MB", [SystemSharedServices purgableMemoryinRaw]];
        
        NSArray *array = @[MemoryRAM,UsedMemory,WiredMemory,ActiveMemory,InactiveMemory,FreeMemory,PurgeableMemory];
        NSArray *array_d = @[MemoryRAM_d,UsedMemory_d,WiredMemory_d,ActiveMemory_d,InactiveMemory_d,FreeMemory_d,PurgeableMemory_d];
        
        self.memoryTitleArray = array;
        self.memoryDetailsArray = array_d;
    }
    return self;
}

@end
