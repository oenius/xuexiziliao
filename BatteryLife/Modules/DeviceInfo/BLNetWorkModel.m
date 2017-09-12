//
//  BLNetWorkModel.m
//  BatteryLife
//
//  Created by vae on 16/11/18.
//  Copyright © 2016年 vae. All rights reserved.
//

#import "BLNetWorkModel.h"
#import "SystemServices.h"

#define SystemSharedServices [SystemServices sharedServices]



@implementation BLNetWorkModel

-(instancetype)init{

    if (self = [super init]) {
        NSString * UnKnown_N = NSLocalizedString(@"Unknown state", @"Unknown state");
        
        NSString *CarrierName = NSLocalizedString(@"Carrier Name", @"Carrier Name");
        NSString *CarrierName_d = [SystemSharedServices carrierName];
        if (CarrierName_d == nil) {
            CarrierName_d = UnKnown_N;
        }
        
        NSString *CarrierCountry = NSLocalizedString(@"Carrier Country", @"Carrier Country");
        NSString *CarrierCountry_d = [SystemSharedServices carrierCountry];
        if (CarrierCountry_d == nil) {
            CarrierCountry_d = UnKnown_N;
        }
        
//        NSString *CarrierAllowsVOIP = @"Carrier Allows VOIP:";
//        NSString *CarrierAllowsVOIP_d = ([SystemSharedServices carrierAllowsVOIP]) ? @"Yes" : @"No";
//        if (CarrierAllowsVOIP_d == nil) {
//            CarrierAllowsVOIP_d = UnKnown_N;
//        }
        
        NSString *CurrentIPAddress = NSLocalizedString(@"Current IP Address", @"Current IP Address");
        NSString *CurrentIPAddress_d = [SystemSharedServices currentIPAddress];
        if (CurrentIPAddress_d == nil) {
            CurrentIPAddress_d = UnKnown_N;
        }
        
        NSString *CurrentMACAddress = NSLocalizedString(@"Current MAC Address", @"Current MAC Address");
        NSString *CurrentMACAddress_d = [SystemSharedServices currentMACAddress];
        if (CurrentMACAddress_d == nil) {
            CurrentMACAddress_d = UnKnown_N;
        }
        
        NSString *ExternalIPAddress = NSLocalizedString(@"External IP Address", @"External IP Address");
        NSString *ExternalIPAddress_d = [SystemSharedServices externalIPAddress];
        if (ExternalIPAddress_d == nil) {
            ExternalIPAddress_d = UnKnown_N;
        }
        
        NSString *WiFiIPAddress = NSLocalizedString(@"WiFi IP Address", @"WiFi IP Address");
        NSString *WiFiIPAddress_d = [SystemSharedServices wiFiIPAddress];
        if (WiFiIPAddress_d == nil) {
            WiFiIPAddress_d = UnKnown_N;
        }
        
        NSString *WiFiMACAddress = NSLocalizedString(@"WiFi MAC Address", @"WiFi MAC Address");
        NSString *WiFiMACAddress_d = [SystemSharedServices wiFiMACAddress];
        if (WiFiMACAddress_d == nil) {
            WiFiMACAddress_d = UnKnown_N;
        }
        
        NSString *WiFiNetmaskAddress = NSLocalizedString(@"WiFi Netmask Address", @"WiFi Netmask Address");
        NSString *WiFiNetmaskAddress_d = [SystemSharedServices wiFiNetmaskAddress];
        if (WiFiNetmaskAddress_d == nil) {
            WiFiNetmaskAddress_d = UnKnown_N;
        }
        
        NSString *WiFiBroadcastAddress = NSLocalizedString(@"WiFi Broadcast Address", @"WiFi Broadcast Address");
        NSString *WiFiBroadcastAddress_d = [SystemSharedServices wiFiBroadcastAddress];
        if (WiFiBroadcastAddress_d == nil) {
            WiFiBroadcastAddress_d = UnKnown_N;
        }
        
        NSString *WiFiRouterAddress = NSLocalizedString(@"WiFi Router Address", @"WiFi Router Address");
        NSString *WiFiRouterAddress_d = [SystemSharedServices wiFiRouterAddress];
        if (WiFiRouterAddress_d == nil) {
            WiFiRouterAddress_d = UnKnown_N;
        }
        
        NSString *ConnectedToWiFi = NSLocalizedString(@"Connected to WiFi", @"Connected to WiFi");
        NSString *ConnectedToWiFi_d = ([SystemSharedServices connectedToWiFi]) ? @"Yes" : @"No";
        if (ConnectedToWiFi_d == nil) {
            ConnectedToWiFi_d = UnKnown_N;
        }
        
        NSString *ConnectedToCellNetwork = NSLocalizedString(@"Connected to Cell Network", @"Connected to Cell Network");
        NSString *ConnectedToCellNetwork_d = ([SystemSharedServices connectedToCellNetwork]) ? @"Yes" : @"No";
        if (ConnectedToCellNetwork_d == nil) {
            ConnectedToCellNetwork_d = UnKnown_N;
        }
        
        NSArray *array = [[NSArray alloc] initWithObjects:CarrierName, CarrierCountry, CurrentIPAddress, CurrentMACAddress, ExternalIPAddress, WiFiIPAddress, WiFiMACAddress, WiFiNetmaskAddress, WiFiBroadcastAddress, WiFiRouterAddress, ConnectedToWiFi, ConnectedToCellNetwork, nil];
        
         NSArray *array_d = [[NSArray alloc] initWithObjects:CarrierName_d, CarrierCountry_d, CurrentIPAddress_d, CurrentMACAddress_d, ExternalIPAddress_d, WiFiIPAddress_d, WiFiMACAddress_d, WiFiNetmaskAddress_d, WiFiBroadcastAddress_d, WiFiRouterAddress_d, ConnectedToWiFi_d, ConnectedToCellNetwork_d, nil];
        
        _netWorkTitleArray = array;
        _netWorkDetailsArray = array_d;
        
    }
    return self;
}

@end
