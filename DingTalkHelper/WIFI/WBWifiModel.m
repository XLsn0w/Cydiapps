//
//  WBWifiModel.m
//  DingTalkAssistant
//
//  Created by buginux on 2017/7/29.
//  Copyright © 2017年 buginux. All rights reserved.
//

#import "WBWifiModel.h"

@interface WBWifiModel () <NSCoding>

@end

@implementation WBWifiModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.interfaceName forKey:@"ifnam"];
    [aCoder encodeInt32:self.flags forKey:@"flags"];
    [aCoder encodeObject:self.SSID forKey:@"SSID"];
    [aCoder encodeObject:self.BSSID forKey:@"BSSID"];
    [aCoder encodeObject:self.SSIDData forKey:@"SSIDDATA"];
    [aCoder encodeBool:self.selected forKey:@"selected"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _interfaceName = [[aDecoder decodeObjectForKey:@"ifnam"] copy];
        _flags = [aDecoder decodeInt32ForKey:@"flags"];
        _SSID = [[aDecoder decodeObjectForKey:@"SSID"] copy];
        _BSSID = [[aDecoder decodeObjectForKey:@"BSSID"] copy];
        _SSIDData = [[aDecoder decodeObjectForKey:@"SSIDDATA"] copy];
        _selected = [aDecoder decodeBoolForKey:@"selected"];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _SSID = [[dictionary valueForKey:@"SSID"] copy];
        _BSSID = [[dictionary valueForKey:@"BSSID"] copy];
        _SSIDData = [[dictionary valueForKey:@"SSIDDATA"] copy];
    }
    return self;
}

- (instancetype)initWithInterfaceName:(NSString *)ifname dictionary:(NSDictionary *)dictionary {
    if (self = [self initWithDictionary:dictionary]) {
        _interfaceName = ifname;
    }
    return self;
}

- (NSString *)wifiName {
    if ([self.SSID length] > 0) {
        return self.SSID;
    }
    
    if ([self.BSSID length] > 0) {
        return self.BSSID;
    }
    
    return @"未知 WIFI";
}

- (BOOL)isEqualToWifi:(WBWifiModel *)wifi {
    if (!wifi) {
        return NO;
    }
    
    BOOL haveEqualSSID = (!self.SSID && !wifi.SSID) || [self.SSID isEqualToString:wifi.SSID];
    BOOL haveEqualBSSID = (!self.BSSID && !wifi.BSSID) || [self.BSSID isEqualToString:wifi.BSSID];
    
    return haveEqualSSID && haveEqualBSSID;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[WBWifiModel class]]) {
        return NO;
    }
    
    return [self isEqualToWifi:object];
}

- (NSUInteger)hash {
    return [self.SSID hash] ^ [self.BSSID hash];
}

@end
