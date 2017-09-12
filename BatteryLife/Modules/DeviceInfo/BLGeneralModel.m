//
//  BLGeneralModel.m
//  BatteryLife
//
//  Created by vae on 16/11/17.
//  Copyright © 2016年 vae. All rights reserved.
//

#import "BLGeneralModel.h"
#import "SystemServices.h"
#import "DeviceModel.h"


#define SystemSharedServices [SystemServices sharedServices]

@interface BLGeneralModel()

//title
@property (nonatomic,copy) NSString *device;

@property (nonatomic,copy) NSString *hostName;

@property (nonatomic,copy) NSString *systemName;

@property (nonatomic,copy) NSString *sysVersion;

@property (nonatomic,copy) NSString *ScreenResolution;

@property (nonatomic,copy) NSString *screenBrightnees;

@property (nonatomic,copy) NSString *multiTasking;

@property (nonatomic,copy) NSString *ProximitySensor;

//details
@property (nonatomic,copy) NSString *device_d;

@property (nonatomic,copy) NSString *hostName_d;

@property (nonatomic,copy) NSString *systemName_d;

@property (nonatomic,copy) NSString *sysVersion_d;

@property (nonatomic,copy) NSString *ScreenResolution_d;

@property (nonatomic,copy) NSString *screenBrightnees_d;

@property (nonatomic,copy) NSString *multiTasking_d;

@property (nonatomic,copy) NSString *ProximitySensor_d;


@end




@implementation BLGeneralModel


-(instancetype)init{
    
    if (self = [super init]) {
        NSString * UnKnown_G = NSLocalizedString(@"Unknown state", @"Unknown state");
        //title
        self.device = NSLocalizedString(@"Device model", @"Device model");
        self.device_d = [DeviceModel platform];
        if (self.device_d == nil) {
            self.device_d = UnKnown_G;
        }
        
        self.hostName = NSLocalizedString(@"Device Name", @"Device Name");
        self.hostName_d = [SystemSharedServices deviceName];
        if (self.hostName_d == nil) {
            self.hostName_d = UnKnown_G;
        }
        
        self.systemName = NSLocalizedString(@"System Name", @"System Name");
        self.systemName_d = [SystemSharedServices systemName];
        if (self.systemName_d == nil) {
            self.systemName_d = UnKnown_G;
        }
        
        self.sysVersion = NSLocalizedString(@"System Version", @"System Version");
        self.sysVersion_d = [SystemSharedServices systemsVersion];
        if (self.sysVersion_d == nil) {
            self.sysVersion_d = UnKnown_G;
        }
        
        CGFloat scale = [UIScreen mainScreen].scale;
        long withpix = (long)([SystemSharedServices screenWidth] * scale);
        long heightpix = (long)([SystemSharedServices screenHeight] * scale);
        self.ScreenResolution = NSLocalizedString(@"Screen Resolution", @"Screen Resolution");
        self.ScreenResolution_d = [NSString stringWithFormat:@"%ldx%ld",heightpix,withpix];
        if (self.ScreenResolution_d == nil) {
            self.ScreenResolution_d = UnKnown_G;
        }
        
        self.screenBrightnees = NSLocalizedString(@"Screen Brightness", @"Screen Brightness");
        self.screenBrightnees_d = [NSString stringWithFormat:@"%.0f%%", [SystemSharedServices screenBrightness]];
        if (self.screenBrightnees_d == nil) {
            self.screenBrightnees_d = UnKnown_G;
        }
        
        self.multiTasking = NSLocalizedString(@"Multitasking Enabled", @"Multitasking Enabled");
        self.multiTasking_d = ([SystemSharedServices multitaskingEnabled]) ? @"Yes" : @"No";
        if (self.multiTasking_d == nil) {
            self.multiTasking_d = UnKnown_G;
        }
        
        self.ProximitySensor =  NSLocalizedString(@"Proximity Sensor", @"Proximity Sensor");
        self.ProximitySensor_d = ([SystemSharedServices proximitySensorEnabled]) ? @"Yes" : @"No";
        if (self.ProximitySensor_d  == nil) {
            self.ProximitySensor_d  = UnKnown_G;
        }
        
        //details
        
        
    }
    return self;
}

-(NSArray *)systemInfoTitle{
    if (!_systemInfoTitle) {
        _systemInfoTitle = @[
                            self.device,
                            self.hostName,
                            self.systemName,
                            self.sysVersion,
                            self.ScreenResolution,
                            self.screenBrightnees,
                            self.multiTasking,
                            self.ProximitySensor,
                            ];
    }
    return _systemInfoTitle;
}

-(NSArray *)systemInfoDetails{
    if (!_systemInfoDetails) {
        _systemInfoDetails = @[
                             self.device_d,
                             self.hostName_d,
                             self.systemName_d,
                             self.sysVersion_d,
                             self.ScreenResolution_d,
                             self.screenBrightnees_d,
                             self.multiTasking_d,
                             self.ProximitySensor_d,
                             ];
    }
    return _systemInfoDetails;
}

@end
